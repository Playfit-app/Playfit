import tempfile
import shutil
from django.test import TestCase, override_settings
from social.models import (
    Follow,
    Continent,
    Country,
    City,
    WorldPosition,
    CustomizationItem,
    Customization,
)
from authentification.models import CustomUser
from social.utils import create_test_image

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
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
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
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
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
