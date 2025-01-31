import time
from django.contrib.auth.tokens import PasswordResetTokenGenerator
from django.core.signing import TimestampSigner, BadSignature, SignatureExpired

class ExpiringPasswordResetTokenGenerator(PasswordResetTokenGenerator):
    def _make_hash_value(self, user, timestamp):
        return f"{user.pk}{timestamp}{user.is_active}"

    def make_signed_token(self, user):
        signer = TimestampSigner()
        token = self.make_token(user)
        return signer.sign(f"{token}:{int(time.time())}")

    def check_signed_token(self, user, token):
        signer = TimestampSigner()
        try:
            token, timestamp = signer.unsign(token).split(":")
        except (BadSignature, SignatureExpired):
            return False

        if self.is_token_expired(int(timestamp)):
            return False

        return self.check_token(user, token)

    def is_token_expired(self, timestamp):
        return time.time() - timestamp > 900 # 15 minutes
