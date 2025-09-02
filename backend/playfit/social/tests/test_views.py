import tempfile
import shutil
from rest_framework import status
from rest_framework.test import APITestCase
from django.test import override_settings
from unittest.mock import patch
from social.models import (
    CustomizationItem, Customization, BaseCharacter, Follow, Post, Like, Comment, 
    Notification, WorldPosition, Country, City, DecorationImage, CityDecorationImage,
    IntroductionCharacter, Continent
)
from utilities.images import create_test_image
from authentification.models import CustomUser

TEMP_MEDIA_ROOT = tempfile.mkdtemp()

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemListViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_get_customization_items(self):
        CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.client.force_authenticate(user=user)
        response = self.client.get("/api/social/customization-items/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["name"], "Test")
        self.assertEqual(response.data[0]["category"], "hat")
        self.assertTrue(response.data[0]["image"].endswith(".webp"))

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemByCategoryListViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_get_customization_items_by_category(self):
        CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.client.force_authenticate(user=user)
        response = self.client.get("/api/social/customization-items/hat/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["name"], "Test")
        self.assertEqual(response.data[0]["category"], "hat")
        self.assertTrue(response.data[0]["image"].endswith(".webp"))

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationUpdateViewTests(APITestCase):
    def test_update_customization(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        base_character = BaseCharacter.objects.create(
            name="character_image",
            image=create_test_image(),
        )
        Customization.objects.create(
            user=user,
        )
        data = {
            'base_character': base_character.name,
        }
        self.client.force_authenticate(user=user)
        response = self.client.patch("/api/social/update-customization/", data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_get_customization(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        base_character = BaseCharacter.objects.create(
            name="character_image",
            image=create_test_image(),
        )
        Customization.objects.create(
            user=user,
            base_character=base_character,
        )
        self.client.force_authenticate(user=user)
        response = self.client.get("/api/social/customization/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class GCMDeviceCreateViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_create_gcm_device_success(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.client.force_authenticate(user=user)
        data = {"registration_id": "test_registration_id"}
        response = self.client.post("/api/social/store-device-token/", data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

    def test_create_gcm_device_invalid_data(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.client.force_authenticate(user=user)
        data = {}  # Invalid data
        response = self.client.post("/api/social/store-device-token/", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class FollowViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
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

    def test_followers_list_view(self):
        Follow.objects.create(follower=self.user2, following=self.user1)
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/followers/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_following_list_view(self):
        Follow.objects.create(follower=self.user1, following=self.user2)
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/following/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    @patch('social.utils.send_notification')
    def test_follow_create_self_follow(self, mock_send):
        self.client.force_authenticate(user=self.user1)
        data = {"id": self.user1.id}
        response = self.client.post("/api/social/follow/", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["detail"], "You cannot follow yourself")

    def test_follow_create_already_following(self):
        Follow.objects.create(follower=self.user1, following=self.user2)
        self.client.force_authenticate(user=self.user1)
        data = {"id": self.user2.id}
        response = self.client.post("/api/social/follow/", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["detail"], "You already follow this user")

    def test_follow_create_user_not_found(self):
        self.client.force_authenticate(user=self.user1)
        data = {"id": 99999}
        response = self.client.post("/api/social/follow/", data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_follow_delete_success(self):
        Follow.objects.create(follower=self.user1, following=self.user2)
        self.client.force_authenticate(user=self.user1)
        response = self.client.delete(f"/api/social/unfollow/{self.user2.id}/")
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_follow_delete_not_following(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.delete(f"/api/social/unfollow/{self.user2.id}/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class PostViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
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

    def test_post_create_invalid_data(self):
        self.client.force_authenticate(user=self.user1)
        data = {}  # Invalid data
        response = self.client.post("/api/social/posts/create/", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_post_detail_view(self):
        post = Post.objects.create(user=self.user1, content="Test content")
        self.client.force_authenticate(user=self.user1)
        response = self.client.get(f"/api/social/posts/{post.id}/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_post_detail_not_found(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/posts/99999/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_post_list_view(self):
        Follow.objects.create(follower=self.user1, following=self.user2)
        Post.objects.create(user=self.user2, content="Test content")
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/posts/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class LikeViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
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
        self.post = Post.objects.create(user=self.user1, content="Test content")

    @patch('social.utils.send_notification')
    def test_like_post_already_liked(self, mock_send):
        Like.objects.create(user=self.user2, post=self.post)
        self.client.force_authenticate(user=self.user2)
        data = {"post": self.post.id}
        response = self.client.post(f"/api/social/posts/{self.post.id}/like/", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["detail"], "You already liked this post")

    def test_like_post_not_found(self):
        self.client.force_authenticate(user=self.user2)
        data = {"post": 99999}
        response = self.client.post("/api/social/posts/99999/like/", data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_unlike_post_success(self):
        Like.objects.create(user=self.user2, post=self.post)
        self.client.force_authenticate(user=self.user2)
        response = self.client.delete(f"/api/social/posts/{self.post.id}/unlike/")
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_unlike_post_not_liked(self):
        self.client.force_authenticate(user=self.user2)
        response = self.client.delete(f"/api/social/posts/{self.post.id}/unlike/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CommentViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
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
        self.post = Post.objects.create(user=self.user1, content="Test content")

    @patch('social.utils.send_notification')
    def test_comment_create_invalid_data(self, mock_send):
        self.client.force_authenticate(user=self.user2)
        data = {"post": self.post.id}
        response = self.client.post(f"/api/social/posts/{self.post.id}/comment/", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_comment_create_post_not_found(self):
        self.client.force_authenticate(user=self.user2)
        data = {"post": 99999, "content": "Test comment"}
        response = self.client.post("/api/social/posts/99999/comment/", data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_comment_delete_success(self):
        comment = Comment.objects.create(user=self.user2, post=self.post, content="Test comment")  # noqa: F841
        self.client.force_authenticate(user=self.user2)
        response = self.client.delete(f"/api/social/comments/{self.post.id}/delete/")
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_comment_delete_not_found(self):
        self.client.force_authenticate(user=self.user2)
        response = self.client.delete(f"/api/social/comments/{self.post.id}/delete/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class NotificationViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )

    def test_notification_read_all(self):
        Notification.objects.create(
            user=self.user1, 
            sender=self.user1, 
            notification_type="follow"
        )
        self.client.force_authenticate(user=self.user1)
        response = self.client.patch("/api/social/notifications/read/all/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["detail"], "All notifications read")


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class WorldPositionViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
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
        
        # Create required objects
        self.continent = Continent.objects.create(name="TestContinent")
        self.country = Country.objects.create(name="TestCountry", continent=self.continent, color="#FF0000")
        self.city = City.objects.create(name="TestCity", country=self.country, order=1)
        
        self.base_character = BaseCharacter.objects.create(
            name="character_image",
            image=create_test_image(),
        )
        
        # Create customizations
        self.customization1 = Customization.objects.create(
            user=self.user1,
            base_character=self.base_character,
        )
        self.customization2 = Customization.objects.create(
            user=self.user2,
            base_character=self.base_character,
        )
        
        # Create world positions
        self.world_position1 = WorldPosition.objects.create(
            user=self.user1,
            city=self.city,
            city_level=1
        )
        self.world_position2 = WorldPosition.objects.create(
            user=self.user2,
            city=self.city,
            city_level=2
        )

    def test_world_positions_list_view(self):
        Follow.objects.create(follower=self.user1, following=self.user2)
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/get-world-positions/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_world_positions_list_view_missing_customization(self):
        self.customization1.delete()
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/get-world-positions/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_world_positions_list_view_missing_world_position(self):
        self.world_position1.delete()
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/get-world-positions/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationUpdateViewErrorTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        Customization.objects.create(user=self.user1)

    def test_update_customization_invalid_base_character(self):
        self.client.force_authenticate(user=self.user1)
        data = {"base_character": "nonexistent_character"}
        response = self.client.patch("/api/social/update-customization/", data)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(str(response.data["detail"]), "No BaseCharacter matches the given query.")

    def test_update_customization_invalid_data(self):
        self.client.force_authenticate(user=self.user1)
        data = {"invalid_field": "value"}
        response = self.client.patch("/api/social/update-customization/", data)
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["detail"], "Invalid data")


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class GetCharacterImagesViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        # Create base characters for registration
        self.base_char1 = BaseCharacter.objects.create(
            name="character1-white-outfit1",
            image=create_test_image(),
        )
        self.base_char2 = BaseCharacter.objects.create(
            name="character1-black-outfit1",
            image=create_test_image(),
        )
        
        # Create introduction characters
        self.intro_char1 = IntroductionCharacter.objects.create(
            name="intro1",
            base_character=self.base_char1,
            image=create_test_image(),
        )

    def test_get_registration_images(self):
        response = self.client.get("/api/social/get-character-images/?registration=true")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("character1", response.data)

    def test_get_customization_images_authenticated(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/get-character-images/?registration=false")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("character1", response.data)

    def test_get_customization_images_unauthenticated(self):
        response = self.client.get("/api/social/get-character-images/?registration=false")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data["detail"], "Authentication required for customization images")


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class GetDecorationImagesViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        self.continent = Continent.objects.create(name="TestContinent")
        self.country = Country.objects.create(name="TestCountry", continent=self.continent, color="#FF0000")
        self.city = City.objects.create(name="TestCity", country=self.country, order=1)
        
        # Create decoration images
        self.tree_image = DecorationImage.objects.create(
            label="tree_TestCountry",
            image=create_test_image(),
        )
        self.building_image = DecorationImage.objects.create(
            label="building_TestCountry",
            image=create_test_image(),
        )
        self.flag_image = DecorationImage.objects.create(
            label="flag",
            image=create_test_image(),
        )
        self.path_image = DecorationImage.objects.create(
            label="path_TestCountry",
            image=create_test_image(),
        )
        
        # Create city decoration images
        self.city_image = CityDecorationImage.objects.create(
            city=self.city,
            image=create_test_image(),
        )

    def test_get_decoration_images_success(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get(f"/api/social/get-decoration-images/{self.country.name}/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("tree", response.data)
        self.assertIn("building", response.data)
        self.assertIn("flag", response.data)
        self.assertIn("path", response.data)
        self.assertIn("country", response.data)

    def test_get_decoration_images_country_not_found(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/get-decoration-images/NonexistentCountry/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class UserSearchViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="searchuser1",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.user2 = CustomUser.objects.create_user(
            email="test2@test.com",
            username="searchuser2",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )

    def test_user_search_view(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/search-users/?search=searchuser")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data["results"]), 1)

    def test_user_search_pagination(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/search-users/?search=searchuser&page_size=1")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data["results"]), 1)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)  
class SimpleFollowViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
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

    def test_followers_list_view_empty(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/followers/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_following_list_view_empty(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/following/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_followers_list_view_with_followers(self):
        Follow.objects.create(follower=self.user2, following=self.user1)
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/followers/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_following_list_view_with_following(self):
        Follow.objects.create(follower=self.user1, following=self.user2)
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/following/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_follow_delete_success_without_notification(self):
        Follow.objects.create(follower=self.user1, following=self.user2)
        self.client.force_authenticate(user=self.user1)
        response = self.client.delete(f"/api/social/unfollow/{self.user2.id}/")
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_follow_delete_not_following(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.delete(f"/api/social/unfollow/{self.user2.id}/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class SimplePostViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test1@test.com",
            username="test1",
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

    def test_post_detail_view_simple(self):
        post = Post.objects.create(user=self.user1, content="Test content")
        self.client.force_authenticate(user=self.user1)
        response = self.client.get(f"/api/social/posts/{post.id}/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["content"], "Test content")

    def test_post_detail_not_found(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/posts/99999/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_post_list_view_empty(self):
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/posts/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_post_list_view_with_recent_posts(self):
        Follow.objects.create(follower=self.user1, following=self.user2)
        post = Post.objects.create(user=self.user2, content="Test content")  # noqa: F841
        self.client.force_authenticate(user=self.user1)
        response = self.client.get("/api/social/posts/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
