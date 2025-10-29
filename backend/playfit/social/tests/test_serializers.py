import tempfile
import shutil
from django.test import TestCase, override_settings, RequestFactory
from django.contrib.auth.hashers import make_password
from push_notifications.models import GCMDevice
from social.serializers import (
    CustomizationItemSerializer,
    CustomizationSerializer,
    UserSerializer,
    BaseCharacterSerializer,
    GCMDeviceSerializer,
    PostListSerializer,
    PostSerializer,
    LikeSerializer,
    CommentSerializer,
    NotificationSerializer,
    WorldPositionResponseSerializer,
    UserSearchSerializer,
)
from social.models import (
    CustomizationItem, 
    Customization, 
    BaseCharacter,
    Post, 
    Like, 
    Comment, 
    Notification, 
    WorldPosition,
    Continent,
    Country,
    City,
)
from authentification.models import CustomUser
from utilities.images import create_test_image

TEMP_MEDIA_ROOT = tempfile.mkdtemp()

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemSerializerTest(TestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_customization_item_serializer(self):
        item = CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        serializer = CustomizationItemSerializer(item)
        self.assertEqual(serializer.data["name"], "Test")
        self.assertEqual(serializer.data["category"], "hat")
        self.assertTrue(serializer.data["image"].endswith(".webp"))

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationSerializerTest(TestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_customization_serializer(self):
        user = CustomUser.objects.create(
            email="test@test.com",
            username="test",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash"
        )
        item = CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        customization = Customization.objects.create(
            user=user,
            hat=item,
        )
        serializer = CustomizationSerializer(customization)
        self.assertEqual(serializer.data["hat"]["name"], "Test")
        self.assertEqual(serializer.data["hat"]["category"], "hat")
        self.assertTrue(serializer.data["hat"]["image"].endswith(".webp"))


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class UserSerializerTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def test_user_serializer_with_base_character(self):
        user = CustomUser.objects.create(
            email="test@test.com",
            username="testuser",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash"
        )
        base_character = BaseCharacter.objects.create(
            name="Test Character",
            image=create_test_image()
        )
        customization = Customization.objects.create(  # noqa: F841
            user=user,
            base_character=base_character
        )
        
        serializer = UserSerializer(user)
        self.assertEqual(serializer.data["id"], user.id)
        self.assertEqual(serializer.data["username"], "testuser")
        self.assertIsNotNone(serializer.data["base_character"])
        self.assertTrue(serializer.data["base_character"].endswith(".webp"))
    
    def test_user_serializer_without_customization(self):
        user = CustomUser.objects.create(
            email="test2@test.com",
            username="testuser2",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash2"
        )
        
        serializer = UserSerializer(user)
        self.assertEqual(serializer.data["id"], user.id)
        self.assertEqual(serializer.data["username"], "testuser2")
        self.assertIsNone(serializer.data["base_character"])
    
    def test_user_serializer_without_base_character(self):
        user = CustomUser.objects.create(
            email="test3@test.com",
            username="testuser3",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash3"
        )
        
        serializer = UserSerializer(user)
        self.assertEqual(serializer.data["id"], user.id)
        self.assertEqual(serializer.data["username"], "testuser3")
        self.assertIsNone(serializer.data["base_character"])


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class BaseCharacterSerializerTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def test_base_character_serializer(self):
        character = BaseCharacter.objects.create(
            name="Test Character",
            image=create_test_image()
        )
        
        serializer = BaseCharacterSerializer(character)
        self.assertEqual(serializer.data["id"], character.id)
        self.assertEqual(serializer.data["name"], "Test Character")
        self.assertIsNotNone(serializer.data["image"])
        self.assertTrue(serializer.data["image"].endswith(".webp"))


class GCMDeviceSerializerTest(TestCase):
    def test_gcm_device_serializer(self):
        user = CustomUser.objects.create(
            email="test@test.com",
            username="testuser",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash"
        )
        device = GCMDevice.objects.create(
            user=user,
            registration_id="test_registration_id"
        )
        
        serializer = GCMDeviceSerializer(device)
        self.assertEqual(serializer.data["id"], device.id)
        self.assertEqual(serializer.data["registration_id"], "test_registration_id")
        self.assertEqual(serializer.data["user"]["id"], user.id)
        self.assertEqual(serializer.data["user"]["username"], "testuser")


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class PostSerializerTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def setUp(self):
        self.factory = RequestFactory()
        self.user1 = CustomUser.objects.create(
            email="user1@test.com",
            username="user1",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="hash1"
        )
        self.user2 = CustomUser.objects.create(
            email="user2@test.com",
            username="user2",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="hash2"
        )
        self.post = Post.objects.create(
            user=self.user1,
            content="Test post content"
        )
    
    def test_post_list_serializer_with_authenticated_user(self):
        # Create likes and comments
        Like.objects.create(user=self.user2, post=self.post)
        # Comments are created for the post to be liked and tested
        comment1 = Comment.objects.create(user=self.user2, post=self.post, content="Comment 1")  # noqa: F841
        comment2 = Comment.objects.create(user=self.user1, post=self.post, content="Comment 2")  # noqa: F841
        
        # Create request with authenticated user
        request = self.factory.get('/test/')
        request.user = self.user2
        
        serializer = PostListSerializer(self.post, context={'request': request})
        data = serializer.data
        
        self.assertEqual(data["id"], self.post.id)
        self.assertEqual(data["content"], "Test post content")
        self.assertEqual(data["user"]["id"], self.user1.id)
        self.assertEqual(data["nb_likes"], 1)
        self.assertEqual(data["nb_comments"], 2)
        self.assertTrue(data["is_liked"])  # user2 liked the post
        self.assertEqual(len(data["comments"]), 2)  # Limited to 3, we have 2
    
    def test_post_list_serializer_with_unauthenticated_user(self):
        Like.objects.create(user=self.user2, post=self.post)
        
        request = self.factory.get('/test/')
        from django.contrib.auth.models import AnonymousUser
        request.user = AnonymousUser()
        
        serializer = PostListSerializer(self.post, context={'request': request})
        data = serializer.data
        
        self.assertEqual(data["nb_likes"], 1)
        self.assertFalse(data["is_liked"])  # Unauthenticated user
    
    def test_post_list_serializer_without_request(self):
        serializer = PostListSerializer(self.post)
        data = serializer.data
        
        self.assertFalse(data["is_liked"])  # No request context
    
    def test_post_serializer_with_all_comments(self):
        # Create multiple comments
        for i in range(5):
            Comment.objects.create(user=self.user2, post=self.post, content=f"Comment {i}")
        
        serializer = PostSerializer(self.post)
        data = serializer.data
        
        self.assertEqual(data["nb_comments"], 5)
        self.assertEqual(len(data["comments"]), 5)  # All comments for PostSerializer
    
    def test_post_serializer_with_authenticated_user(self):
        Like.objects.create(user=self.user2, post=self.post)
        
        request = self.factory.get('/test/')
        request.user = self.user2
        
        serializer = PostSerializer(self.post, context={'request': request})
        data = serializer.data
        
        self.assertTrue(data["is_liked"])


class LikeSerializerTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create(
            email="test@test.com",
            username="testuser",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash"
        )
        self.post = Post.objects.create(
            user=self.user,
            content="Test post"
        )
        self.like = Like.objects.create(
            user=self.user,
            post=self.post
        )
    
    def test_like_serializer(self):
        serializer = LikeSerializer(self.like)
        data = serializer.data
        
        self.assertEqual(data["id"], self.like.id)
        self.assertEqual(data["user"]["id"], self.user.id)
        self.assertEqual(data["user"]["username"], "testuser")
        self.assertIsNotNone(data["created_at"])


class CommentSerializerTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create(
            email="test@test.com",
            username="testuser",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash"
        )
        self.post = Post.objects.create(
            user=self.user,
            content="Test post"
        )
        self.comment = Comment.objects.create(
            user=self.user,
            post=self.post,
            content="Test comment"
        )
    
    def test_comment_serializer(self):
        serializer = CommentSerializer(self.comment)
        data = serializer.data
        
        self.assertEqual(data["id"], self.comment.id)
        self.assertEqual(data["content"], "Test comment")
        self.assertEqual(data["user"]["id"], self.user.id)
        self.assertEqual(data["user"]["username"], "testuser")
        self.assertIsNotNone(data["created_at"])


class NotificationSerializerTest(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create(
            email="user1@test.com",
            username="user1",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="hash1"
        )
        self.user2 = CustomUser.objects.create(
            email="user2@test.com",
            username="user2",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="hash2"
        )
        self.post = Post.objects.create(
            user=self.user1,
            content="Test post"
        )
        self.notification = Notification.objects.create(
            user=self.user1,
            sender=self.user2,
            post=self.post,
            notification_type="like"
        )
    
    def test_notification_serializer(self):
        serializer = NotificationSerializer(self.notification)
        data = serializer.data
        
        self.assertEqual(data["id"], self.notification.id)
        self.assertEqual(data["notification_type"], "like")
        self.assertEqual(data["user"]["id"], self.user1.id)
        self.assertEqual(data["sender"]["id"], self.user2.id)
        self.assertEqual(data["post"]["id"], self.post.id)
        self.assertIsNotNone(data["created_at"])


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class WorldPositionResponseSerializerTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def setUp(self):
        self.user = CustomUser.objects.create(
            email="test@test.com",
            username="testuser",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash"
        )
        self.continent = Continent.objects.create(name="Test Continent")
        self.country = Country.objects.create(
            name="Test Country",
            continent=self.continent,
            color="#FF0000"
        )
        self.city1 = City.objects.create(
            name="Test City 1",
            country=self.country,
            order=1,
            max_level=6
        )
        self.city2 = City.objects.create(
            name="Test City 2",
            country=self.country,
            order=2,
            max_level=6
        )
        self.base_character = BaseCharacter.objects.create(
            name="Test Character",
            image=create_test_image()
        )
        self.customization = Customization.objects.create(
            user=self.user,
            base_character=self.base_character
        )
    
    def test_world_position_in_city(self):
        position = WorldPosition.objects.create(
            user=self.user,
            city=self.city1,
            city_level=3
        )
        
        instance_data = {
            'user': self.user,
            'customization': self.customization,
            'position': position
        }
        
        serializer = WorldPositionResponseSerializer()
        data = serializer.to_representation(instance_data)
        
        self.assertEqual(data["status"], "in_city")
        self.assertEqual(data["continent"], "Test Continent")
        self.assertEqual(data["country"], "Test Country")
        self.assertEqual(data["city"], 1)
        self.assertEqual(data["level"], 3)
        self.assertEqual(data["max_level"], 6)
        self.assertEqual(data["country_color"], "#FF0000")
        self.assertEqual(data["city_name"], "Test City 1")
        self.assertEqual(data["user"]["id"], self.user.id)
        self.assertIsNotNone(data["character"])
    
    def test_world_position_in_transition(self):
        position = WorldPosition.objects.create(
            user=self.user,
            transition_from=self.city1,
            transition_to=self.city2,
            transition_level=2
        )
        
        instance_data = {
            'user': self.user,
            'customization': self.customization,
            'position': position
        }
        
        serializer = WorldPositionResponseSerializer()
        data = serializer.to_representation(instance_data)
        
        self.assertEqual(data["status"], "in_transition")
        self.assertEqual(data["continent"], "Test Continent")
        self.assertEqual(data["country"], "Test Country")
        self.assertEqual(data["city_from"], 1)
        self.assertEqual(data["city_to"], 2)
        self.assertEqual(data["level"], 2)
        self.assertEqual(data["max_level"], 4)
        self.assertEqual(data["country_color"], "#FF0000")
        self.assertEqual(data["user"]["id"], self.user.id)
        self.assertIsNotNone(data["character"])


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class UserSearchSerializerTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def test_user_search_serializer(self):
        user = CustomUser.objects.create(
            email="test@test.com",
            username="testuser",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash"
        )
        base_character = BaseCharacter.objects.create(
            name="Test Character",
            image=create_test_image()
        )
        customization = Customization.objects.create(  # noqa: F841
            user=user,
            base_character=base_character
        )
        
        serializer = UserSearchSerializer(user)
        data = serializer.data
        
        self.assertEqual(data["id"], user.id)
        self.assertEqual(data["username"], "testuser")
        self.assertIsNotNone(data["customizations"])
        self.assertEqual(data["customizations"]["base_character"]["name"], "Test Character")
