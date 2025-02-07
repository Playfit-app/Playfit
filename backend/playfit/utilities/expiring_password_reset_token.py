import time
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.core.signing import TimestampSigner, BadSignature, SignatureExpired
from .encrypted_fields import get_fernet, hash

class ExpiringPasswordResetTokenGenerator(PasswordResetTokenGenerator):
    def _make_hash_value(self, user, timestamp):
        return f"{user.pk}{timestamp}{user.is_active}"

    def make_signed_token(self, user):
        signer = TimestampSigner()
        token = self.make_token(user)
        return signer.sign(f"{token}:{int(time.time())}")

    def make_email_signed_token(self, user, email):
        signer = TimestampSigner()
        token = self.make_token(user)
        return signer.sign(f"{token}:{get_fernet().encrypt(email.encode()).decode()}:{int(time.time())}")

    def check_signed_token(self, user, token):
        signer = TimestampSigner()
        try:
            token, timestamp = signer.unsign(token).split(":")
        except (BadSignature, SignatureExpired):
            return False

        if self.is_token_expired(int(timestamp)):
            return False

        return self.check_token(user, token)

    def check_email_signed_token(self, user, email_hash, token):
        signer = TimestampSigner()
        try:
            token, encrypted_email, timestamp = signer.unsign(token).split(":")
        except (BadSignature, SignatureExpired, ValueError):
            return False

        if self.is_token_expired(int(timestamp)):
            return False

        email = get_fernet().decrypt(encrypted_email.encode()).decode()
        if hash(email) != email_hash:
            return False

        return self.check_token(user, token)

    def is_token_expired(self, timestamp):
        return time.time() - timestamp > 900 # 15 minutes

def get_email_from_signed_token(token):
    signer = TimestampSigner()
    try:
        token, email, timestamp = signer.unsign(token).split(":")
    except (BadSignature, SignatureExpired):
        return None

    if ExpiringPasswordResetTokenGenerator().is_token_expired(int(timestamp)):
        return None

    return get_fernet().decrypt(email).decode()
