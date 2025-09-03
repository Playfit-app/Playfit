import tempfile
import shutil
from django.test import TestCase, override_settings
from django.core.exceptions import ValidationError
from django.contrib.auth.hashers import make_password
from social.models import (
    Follow,
    Continent,
    Country,
    City,
    WorldPosition,
    CustomizationItem,
    Customization,
    Post,
    Like,
    Comment,
    Notification,
    BaseCharacter,
    IntroductionCharacter,
    DecorationImage,
    CityDecorationImage,
    MountainDecorationImage,
    customizations_image_path,
    city_decoration_image_path,
    mountain_decoration_image_path,
)
from authentification.models import CustomUser
from utilities.images import create_test_image

TEMP_MEDIA_ROOT = tempfile.mkdtemp()

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemTest(TestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_create_customization_item(self):
        image = create_test_image()
        item = CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=image,
        )
        self.assertEqual(item.name, "Test")
        self.assertEqual(item.category, "hat")
        self.assertTrue(item.image.name.endswith(".webp"))

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationTest(TestCase):
    def setUp(self):
        from django.contrib.auth.hashers import make_password
        self.user = CustomUser.objects.create(
            email="test@test.com",
            username="test",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash1"
        )
        self.item = CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        self.customization = Customization.objects.create(
            user=self.user,
            hat=self.item,
        )

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_create_customization(self):
        self.assertEqual(self.customization.user, self.user)
        self.assertEqual(self.customization.hat, self.item)
        self.assertEqual(self.customization.backpack, None)
        self.assertEqual(self.customization.shirt, None)
        self.assertEqual(self.customization.pants, None)
        self.assertEqual(self.customization.shoes, None)
        self.assertEqual(self.customization.gloves, None)

class FollowTest(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create(
            email="test@test.com",
            username="test",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash1"
        )
        self.user2 = CustomUser.objects.create(
            email="test2@test.com",
            username="test2",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash2"
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

class ContinentTest(TestCase):
    def setUp(self):
        self.continent = Continent.objects.create(
            name="Europe",
        )

    def test_continent_creation(self):
        self.assertEqual(self.continent.name, "Europe")

    def test_continent_str(self):
        self.assertEqual(str(self.continent), "Europe")

    def test_continent_unique(self):
        with self.assertRaises(Exception):
            Continent.objects.create(
                name="Europe",
            )

class CountryTest(TestCase):
    def setUp(self):
        self.continent = Continent.objects.create(
            name="Europe",
        )
        self.country = Country.objects.create(
            name="France",
            continent=self.continent,
        )

    def test_country_creation(self):
        self.assertEqual(self.country.name, "France")
        self.assertEqual(self.country.continent, self.continent)

    def test_country_str(self):
        self.assertEqual(str(self.country), "France")

    def test_country_unique(self):
        with self.assertRaises(Exception):
            Country.objects.create(
                name="France",
                continent=self.continent,
            )

class CityTest(TestCase):
    def setUp(self):
        self.continent = Continent.objects.create(
            name="Europe",
        )
        self.country = Country.objects.create(
            name="France",
            continent=self.continent,
        )
        self.city = City.objects.create(
            name="Paris",
            country=self.country,
            order=1,
        )

    def test_city_creation(self):
        self.assertEqual(self.city.name, "Paris")
        self.assertEqual(self.city.country, self.country)

    def test_city_str(self):
        self.assertEqual(str(self.city), "Paris")

    def test_city_unique(self):
        with self.assertRaises(Exception):
            City.objects.create(
                name="Paris",
                country=self.country,
            )

class WorldPositionTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create(
            email="test@test.com",
            username="test",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash1"
        )
        self.continent = Continent.objects.create(
            name="Europe",
        )
        self.country = Country.objects.create(
            name="France",
            continent=self.continent,
        )
        self.city = City.objects.create(
            name="Paris",
            country=self.country,
            order=1,
        )
        self.world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city,
            city_level=1,
        )

    def test_world_position_creation(self):
        self.assertEqual(self.world_position.city, self.city)
        self.assertEqual(self.world_position.city_level, 1)

    def test_world_position_str(self):
        self.assertEqual(str(self.world_position), "test is in Paris (Level 1)")

    def test_world_position_move_to_next_level(self):
        self.world_position.move_to_next_level()
        self.assertEqual(self.world_position.city_level, 2)

    def test_world_position_start_transition(self):
        next_city = City.objects.create(
            name="Marseille",
            country=self.country,
            order=2,
        )
        self.world_position.start_transition(next_city)
        self.assertEqual(self.world_position.transition_to, next_city)

    def test_world_position_is_in_city(self):
        self.assertTrue(self.world_position.is_in_city())

    def test_world_position_is_in_transition(self):
        self.assertFalse(self.world_position.is_in_transition())
        self.world_position.start_transition(self.city)
        self.assertTrue(self.world_position.is_in_transition())


class PostTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create(
            username="testuser",
            email="test@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="testhash"
        )
    
    def test_post_creation(self):
        post = Post.objects.create(
            user=self.user,
            content="Test post content"
        )
        self.assertEqual(post.user, self.user)
        self.assertEqual(post.content, "Test post content")
        self.assertIsNotNone(post.created_at)
    
    def test_post_str(self):
        post = Post.objects.create(
            user=self.user,
            content="Test content"
        )
        expected_str = f"{self.user} posted on {post.created_at}"
        self.assertEqual(str(post), expected_str)
    
    def test_post_without_content(self):
        post = Post.objects.create(user=self.user)
        self.assertIsNone(post.content)
        self.assertEqual(post.user, self.user)


class LikeTest(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create(
            username="user1",
            email="user1@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="hash1"
        )
        self.user2 = CustomUser.objects.create(
            username="user2",
            email="user2@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="hash2"
        )
        self.post = Post.objects.create(
            user=self.user1,
            content="Test post"
        )
    
    def test_like_creation(self):
        like = Like.objects.create(
            user=self.user2,
            post=self.post
        )
        self.assertEqual(like.user, self.user2)
        self.assertEqual(like.post, self.post)
        self.assertIsNotNone(like.created_at)
    
    def test_like_str(self):
        like = Like.objects.create(
            user=self.user2,
            post=self.post
        )
        expected_str = f"{self.user2} liked {self.post}"
        self.assertEqual(str(like), expected_str)
    
    def test_like_unique_constraint(self):
        Like.objects.create(user=self.user2, post=self.post)
        with self.assertRaises(Exception):
            Like.objects.create(user=self.user2, post=self.post)


class CommentTest(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create(
            username="user1",
            email="user1@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="hash1"
        )
        self.user2 = CustomUser.objects.create(
            username="user2",
            email="user2@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="hash2"
        )
        self.post = Post.objects.create(
            user=self.user1,
            content="Test post"
        )
    
    def test_comment_creation(self):
        comment = Comment.objects.create(
            user=self.user2,
            post=self.post,
            content="Test comment"
        )
        self.assertEqual(comment.user, self.user2)
        self.assertEqual(comment.post, self.post)
        self.assertEqual(comment.content, "Test comment")
        self.assertIsNotNone(comment.created_at)
    
    def test_comment_str(self):
        comment = Comment.objects.create(
            user=self.user2,
            post=self.post,
            content="Test comment"
        )
        expected_str = f"{self.user2} commented on {self.post}"
        self.assertEqual(str(comment), expected_str)


class NotificationTest(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create(
            username="user1",
            email="user1@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="hash1"
        )
        self.user2 = CustomUser.objects.create(
            username="user2",
            email="user2@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="hash2"
        )
        self.post = Post.objects.create(
            user=self.user1,
            content="Test post"
        )
    
    def test_notification_creation(self):
        notification = Notification.objects.create(
            user=self.user1,
            sender=self.user2,
            post=self.post,
            notification_type="like"
        )
        self.assertEqual(notification.user, self.user1)
        self.assertEqual(notification.sender, self.user2)
        self.assertEqual(notification.post, self.post)
        self.assertEqual(notification.notification_type, "like")
        self.assertFalse(notification.seen)
        self.assertIsNotNone(notification.created_at)
    
    def test_notification_str(self):
        notification = Notification.objects.create(
            user=self.user1,
            sender=self.user2,
            notification_type="follow"
        )
        expected_str = f"{self.user2} follow {self.user1}"
        self.assertEqual(str(notification), expected_str)
    
    def test_notification_without_post(self):
        notification = Notification.objects.create(
            user=self.user1,
            sender=self.user2,
            notification_type="follow"
        )
        self.assertIsNone(notification.post)
    
    def test_notification_types(self):
        notification_types = dict(Notification.NOTIFICATION_TYPES)
        expected_types = {
            'like': 'Like',
            'comment': 'Comment',
            'follow': 'Follow',
            'post': 'Post',
            'world_position': 'World Position'
        }
        self.assertEqual(notification_types, expected_types)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class BaseCharacterTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def test_base_character_creation(self):
        image = create_test_image()
        character = BaseCharacter.objects.create(
            name="Test Character",
            image=image
        )
        self.assertEqual(character.name, "Test Character")
        self.assertIsNotNone(character.image)
    
    def test_base_character_str(self):
        image = create_test_image()
        character = BaseCharacter.objects.create(
            name="Test Character",
            image=image
        )
        self.assertEqual(str(character), "Test Character")
    
    def test_base_character_unique_name(self):
        image1 = create_test_image()
        image2 = create_test_image()
        BaseCharacter.objects.create(name="Test Character", image=image1)
        with self.assertRaises(Exception):
            BaseCharacter.objects.create(name="Test Character", image=image2)
    
    def test_base_character_save_png_conversion(self):
        from django.core.files.uploadedfile import SimpleUploadedFile
        from PIL import Image
        import io
        
        # Create a PNG image
        img = Image.new('RGB', (100, 100), color='red')
        img_io = io.BytesIO()
        img.save(img_io, format='PNG')
        img_io.seek(0)
        
        png_file = SimpleUploadedFile("test.png", img_io.getvalue(), content_type="image/png")
        character = BaseCharacter.objects.create(
            name="PNG Character",
            image=png_file
        )
        # The save method should convert PNG to WebP
        self.assertTrue(character.image.name.endswith('.webp'))


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class IntroductionCharacterTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def setUp(self):
        image = create_test_image()
        self.base_character = BaseCharacter.objects.create(
            name="Base Character",
            image=image
        )
    
    def test_introduction_character_creation(self):
        image = create_test_image()
        intro_character = IntroductionCharacter.objects.create(
            base_character=self.base_character,
            name="Intro Character",
            image=image
        )
        self.assertEqual(intro_character.base_character, self.base_character)
        self.assertEqual(intro_character.name, "Intro Character")
        self.assertIsNotNone(intro_character.image)


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class DecorationImageTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def test_decoration_image_creation(self):
        image = create_test_image()
        decoration = DecorationImage.objects.create(
            image=image,
            label="Test Decoration"
        )
        self.assertEqual(decoration.label, "Test Decoration")
        self.assertIsNotNone(decoration.image)
        self.assertIsNotNone(decoration.created_at)
    
    def test_decoration_image_str(self):
        image = create_test_image()
        decoration = DecorationImage.objects.create(
            image=image,
            label="Test Decoration"
        )
        expected_str = f"Test Decoration decoration ({decoration.created_at})"
        self.assertEqual(str(decoration), expected_str)
    
    def test_decoration_image_save_png_conversion(self):
        from django.core.files.uploadedfile import SimpleUploadedFile
        from PIL import Image
        import io
        
        # Create a PNG image
        img = Image.new('RGB', (100, 100), color='red')
        img_io = io.BytesIO()
        img.save(img_io, format='PNG')
        img_io.seek(0)
        
        png_file = SimpleUploadedFile("test.png", img_io.getvalue(), content_type="image/png")
        decoration = DecorationImage.objects.create(
            image=png_file,
            label="PNG Decoration"
        )
        self.assertTrue(decoration.image.name.endswith('.webp'))


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CityDecorationImageTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def setUp(self):
        self.continent = Continent.objects.create(name="Test Continent")
        self.country = Country.objects.create(
            name="Test Country",
            continent=self.continent
        )
        self.city = City.objects.create(
            name="Test City",
            country=self.country,
            order=1
        )
    
    def test_city_decoration_image_creation(self):
        image = create_test_image()
        decoration = CityDecorationImage.objects.create(
            city=self.city,
            image=image,
            label="City Decoration"
        )
        self.assertEqual(decoration.city, self.city)
        self.assertEqual(decoration.label, "City Decoration")
        self.assertIsNotNone(decoration.image)
        self.assertIsNotNone(decoration.created_at)
    
    def test_city_decoration_image_str(self):
        image = create_test_image()
        decoration = CityDecorationImage.objects.create(
            city=self.city,
            image=image,
            label="City Decoration"
        )
        expected_str = f"City Decoration decoration for {self.city} ({decoration.created_at})"
        self.assertEqual(str(decoration), expected_str)
    
    def test_city_decoration_image_save_png_conversion(self):
        from django.core.files.uploadedfile import SimpleUploadedFile
        from PIL import Image
        import io
        
        # Create a PNG image
        img = Image.new('RGB', (100, 100), color='red')
        img_io = io.BytesIO()
        img.save(img_io, format='PNG')
        img_io.seek(0)
        
        png_file = SimpleUploadedFile("test.png", img_io.getvalue(), content_type="image/png")
        decoration = CityDecorationImage.objects.create(
            city=self.city,
            image=png_file,
            label="PNG City Decoration"
        )
        self.assertTrue(decoration.image.name.endswith('.webp'))


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class MountainDecorationImageTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def test_mountain_decoration_image_creation(self):
        image = create_test_image()
        decoration = MountainDecorationImage.objects.create(
            image=image,
            label="Mountain Decoration"
        )
        self.assertEqual(decoration.label, "Mountain Decoration")
        self.assertIsNotNone(decoration.image)
        self.assertIsNotNone(decoration.created_at)
    
    def test_mountain_decoration_image_str(self):
        image = create_test_image()
        decoration = MountainDecorationImage.objects.create(
            image=image,
            label="Mountain Decoration"
        )
        expected_str = f"Mountain Decoration decoration ({decoration.created_at})"
        self.assertEqual(str(decoration), expected_str)
    
    def test_mountain_decoration_image_save_png_conversion(self):
        from django.core.files.uploadedfile import SimpleUploadedFile
        from PIL import Image
        import io
        
        # Create a PNG image
        img = Image.new('RGB', (100, 100), color='red')
        img_io = io.BytesIO()
        img.save(img_io, format='PNG')
        img_io.seek(0)
        
        png_file = SimpleUploadedFile("test.png", img_io.getvalue(), content_type="image/png")
        decoration = MountainDecorationImage.objects.create(
            image=png_file,
            label="PNG Mountain Decoration"
        )
        self.assertTrue(decoration.image.name.endswith('.webp'))


# Test for image path functions
class ImagePathFunctionTest(TestCase):
    def test_customizations_image_path(self):
        from unittest.mock import Mock
        instance = Mock()
        instance.category = "hat"
        filename = "test_image.png"
        
        path = customizations_image_path(instance, filename)
        expected_path = "customizations/hat/test_image.webp"
        self.assertEqual(path, expected_path)
    
    def test_city_decoration_image_path(self):
        from unittest.mock import Mock
        instance = Mock()
        instance.city.country.name = "Test Country"
        instance.city.name = "Test City"
        filename = "decoration.png"
        
        path = city_decoration_image_path(instance, filename)
        expected_path = "decorations/countries/test-country/test-city/decoration.webp"
        self.assertEqual(path, expected_path)
    
    def test_mountain_decoration_image_path(self):
        from unittest.mock import Mock
        instance = Mock()
        filename = "mountain.png"
        
        path = mountain_decoration_image_path(instance, filename)
        expected_path = "decorations/mountains/mountain.webp"
        self.assertEqual(path, expected_path)


# Test additional methods and edge cases for existing models
@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemSaveTest(TestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.addClassCleanup(shutil.rmtree, TEMP_MEDIA_ROOT, ignore_errors=True)
    
    def test_customization_item_save_png_conversion(self):
        from django.core.files.uploadedfile import SimpleUploadedFile
        from PIL import Image
        import io
        
        # Create a PNG image
        img = Image.new('RGB', (100, 100), color='red')
        img_io = io.BytesIO()
        img.save(img_io, format='PNG')
        img_io.seek(0)
        
        png_file = SimpleUploadedFile("test.png", img_io.getvalue(), content_type="image/png")
        item = CustomizationItem.objects.create(
            name="PNG Item",
            category="hat",
            image=png_file
        )
        self.assertTrue(item.image.name.endswith('.webp'))
    
    def test_customization_item_save_invalid_format(self):
        from django.core.files.uploadedfile import SimpleUploadedFile
        from django.core.exceptions import ValidationError
        
        # Create a JPEG file (invalid format)
        jpeg_file = SimpleUploadedFile("test.jpg", b"fake jpeg content", content_type="image/jpeg")
        
        with self.assertRaises(ValidationError):
            CustomizationItem.objects.create(
                name="JPEG Item",
                category="hat",
                image=jpeg_file
            )


class FollowValidationTest(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create(
            username="user1",
            email="user1@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="hash1"
        )
        self.user2 = CustomUser.objects.create(
            username="user2",
            email="user2@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="hash2"
        )
    
    def test_follow_clean_method(self):
        follow = Follow(follower=self.user1, following=self.user1)
        with self.assertRaises(ValidationError):
            follow.clean()
    
    def test_follow_save_calls_clean(self):
        follow = Follow(follower=self.user1, following=self.user1)
        with self.assertRaises(ValidationError):
            follow.save()


class WorldPositionPropertiesTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create(
            username="testuser",
            email="test@example.com",
            password=make_password("testpass123"),
            date_of_birth="2000-01-01",
            height=180,
            weight=70,
            email_hash="testhash"
        )
        self.continent = Continent.objects.create(name="Test Continent")
        self.country = Country.objects.create(
            name="Test Country",
            continent=self.continent
        )
        self.city1 = City.objects.create(
            name="Test City 1",
            country=self.country,
            order=1
        )
        self.city2 = City.objects.create(
            name="Test City 2",
            country=self.country,
            order=2
        )
    
    def test_country_property_with_city(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city1,
            city_level=1
        )
        self.assertEqual(world_position.country, self.country)
    
    def test_country_property_with_transition_to(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            transition_from=self.city1,
            transition_to=self.city2,
            transition_level=1
        )
        self.assertEqual(world_position.country, self.country)
    
    def test_country_property_without_city_or_transition(self):
        world_position = WorldPosition.objects.create(user=self.user)
        self.assertIsNone(world_position.country)
    
    def test_continent_property_with_country(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city1,
            city_level=1
        )
        self.assertEqual(world_position.continent, self.continent)
    
    def test_continent_property_without_country(self):
        world_position = WorldPosition.objects.create(user=self.user)
        self.assertIsNone(world_position.continent)
    
    def test_is_in_city_true(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city1,
            city_level=1
        )
        self.assertTrue(world_position.is_in_city())
    
    def test_is_in_city_false(self):
        world_position = WorldPosition.objects.create(user=self.user)
        self.assertFalse(world_position.is_in_city())
    
    def test_is_in_transition_true(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            transition_from=self.city1,
            transition_to=self.city2,
            transition_level=1
        )
        self.assertTrue(world_position.is_in_transition())
    
    def test_is_in_transition_false(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city1,
            city_level=1
        )
        self.assertFalse(world_position.is_in_transition())
    
    def test_move_to_next_level_in_city_not_max(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city1,
            city_level=1
        )
        world_position.move_to_next_level()
        world_position.refresh_from_db()
        self.assertEqual(world_position.city_level, 2)
    
    def test_move_to_next_level_in_city_max_level_no_next_city(self):
        # Create a city with max level and no next city
        city_max = City.objects.create(
            name="Max City",
            country=self.country,
            order=99,  # High order so no next city exists
            max_level=6
        )
        world_position = WorldPosition.objects.create(
            user=self.user,
            city=city_max,
            city_level=6  # Max level
        )
        world_position.move_to_next_level()
        world_position.refresh_from_db()
        # Should stay at same level since no next city
        self.assertEqual(world_position.city_level, 6)
        self.assertEqual(world_position.city, city_max)
    
    def test_move_to_next_level_in_transition_not_max(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            transition_from=self.city1,
            transition_to=self.city2,
            transition_level=1
        )
        world_position.move_to_next_level()
        world_position.refresh_from_db()
        self.assertEqual(world_position.transition_level, 2)
    
    def test_start_transition(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city1,
            city_level=6
        )
        world_position.start_transition(self.city2)
        world_position.refresh_from_db()
        self.assertEqual(world_position.transition_from, self.city1)
        self.assertEqual(world_position.transition_to, self.city2)
        self.assertEqual(world_position.transition_level, 1)
        self.assertIsNone(world_position.city)
        self.assertIsNone(world_position.city_level)
    
    def test_world_position_str_in_city(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city1,
            city_level=1
        )
        expected_str = f"{self.user} is in {self.city1} (Level 1)"
        self.assertEqual(str(world_position), expected_str)
    
    def test_world_position_str_in_transition(self):
        world_position = WorldPosition.objects.create(
            user=self.user,
            transition_from=self.city1,
            transition_to=self.city2,
            transition_level=1
        )
        expected_str = f"{self.user} is transitioning from {self.city1} to {self.city2} (Level 1)"
        self.assertEqual(str(world_position), expected_str)
    
    def test_world_position_str_in_void(self):
        world_position = WorldPosition.objects.create(user=self.user)
        expected_str = f"{self.user} is in the void"
        self.assertEqual(str(world_position), expected_str)
