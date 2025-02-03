from datetime import timedelta
from django.core.management.base import BaseCommand
from django.core.mail import send_mail
from django.utils.timezone import now
from authentification.models import CustomUser

class Command(BaseCommand):
    def handle(self, *args, **kwargs):
        try:
            one_year_ago = now()
            users_to_email = CustomUser.objects.filter(last_login__lt=one_year_ago - timedelta(days=30), is_active=False)

            for user in users_to_email:
                send_mail(
                    subject="Votre compte Playfit va être supprimé",
                    message="Bonjour, votre compte Playfit va être supprimé dans 30 jours. Si vous souhaitez le conserver, veuillez faire une demande de réactivation.",
                    from_email="no-reply@playfit.com",
                    recipient_list=[user.email],
                )
                self.stdout.write(f"Email sent to {user.email}")

            users_to_delete = CustomUser.objects.filter(last_login__lt=one_year_ago, is_active=False).delete()
            self.stdout.write(f"{users_to_delete} users deleted")
        except Exception as e:
            self.stderr.write(f"An error occurred: {e}")
            self.stdout.write(f"An error occurred: {e}")
