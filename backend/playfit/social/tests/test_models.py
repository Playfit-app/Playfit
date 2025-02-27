from django.test import TestCase
from social.models import Follow
from authentification.models import CustomUser

class FollowTest(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.user2 = CustomUser.objects.create_user(
            email="test2@test.com",
            username="test2",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.follow = Follow.objects.create(
            follower=self.user1,
            following=self.user2,
        )

    def test_follow_creation(self):
        self.assertEqual(self.follow.follower, self.user1)
        self.assertEqual(self.follow.following, self.user2)

    def test_follow_str(self):
        self.assertEqual(str(self.follow), "test follows test2")

    def test_follow_unique(self):
        with self.assertRaises(Exception):
            Follow.objects.create(
                follower=self.user1,
                following=self.user2,
            )

    def test_follow_self(self):
        with self.assertRaises(Exception):
            Follow.objects.create(
                follower=self.user1,
                following=self.user1,
            )

    def test_follow_delete(self):
        self.follow.delete()
        self.assertEqual(Follow.objects.count(), 0)
