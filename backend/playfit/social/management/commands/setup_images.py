import os
import json
from django.core.management.base import BaseCommand
from django.core.files import File
from authentification.models import GameAchievement
from social.models import (
    Continent,
    Country,
    City,
    DecorationImage,
    CityDecorationImage,
    MountainDecorationImage,
    BaseCharacter,
    CustomizationItem,
)
from workout.models import Exercise

EXTENSIONS: tuple[str] = (".png", ".webp")

def is_valid_file(path: str) -> bool:
    """
    Checks if the given path is a valid file.
    """
    return os.path.exists(path) and os.path.isfile(path) and os.access(path, os.R_OK) and path.endswith(EXTENSIONS)

def is_valid_directory(path: str) -> bool:
    """
    Checks if the given path is a valid directory.
    """
    return os.path.exists(path) and os.path.isdir(path) and os.access(path, os.R_OK)

def get_label_from_path(path: str, extension = False, lower = True) -> str:
    """
    Extracts the label from the given path.
    The label is the last part of the path without the file extension.
    """
    filename = os.path.basename(path)
    label = filename if extension else os.path.splitext(filename)[0]
    if lower:
        label = label.lower()
    return label

def read_sort_order(path: str) -> list[str]:
    """
    Reads the sort order from a file.
    The file should contain one label per line.
    """
    if not os.path.exists(path):
        return []
    with open(path, "r") as file:
        lines = file.readlines()
    ordered_files: list[str] = [line.strip() for line in lines if line.strip()]

    base_path = os.path.dirname(path).split("/sort_order.txt")[0]
    for i in range(len(ordered_files)):
        if base_path not in ordered_files[i]:
            ordered_files[i] = os.path.join(base_path, ordered_files[i])

    return ordered_files


def get_sorted_files(path: str, sort_order: list[str] = []) -> list[str]:
    """
    Returns a sorted list of files in the given directory with the specified extensions.
    The sorting is done based on the labels extracted from the file names.
    """
    files = [
        os.path.join(path, f)
        for f in os.listdir(path)
        if is_valid_file(os.path.join(path, f))
    ]
    return sorted(files, key=lambda f: sort_order.index(f) if f in sort_order else float("inf"))

class Command(BaseCommand):
    help = "Set up initial images and data for the application"

    def add_arguments(self, parser):
        parser.add_argument(
            "--path",
            type=str,
            help="Path to the directory containing images",
            required=True,
        )

    def handle(self, *args, **kwargs):
        path = kwargs["path"]
        if not os.path.exists(path):
            self.stderr.write(self.style.ERROR(f"Path {path} does not exist."))
            return
        if not os.path.isdir(path):
            self.stderr.write(self.style.ERROR(f"Path {path} is not a directory."))
            return
        if not os.access(path, os.R_OK):
            self.stderr.write(self.style.ERROR(f"Path {path} is not readable."))
            return

        self.create_continents()
        self.create_countries()
        self.create_cities()
        self.stdout.write(self.style.NOTICE("Setting up images..."))
        self.create_base_characters(path)
        self.create_mountain_decorations(path)
        self.create_exercises(path)
        self.create_city_decorations(path)
        self.create_decorations(path)
        self.create_achievements(path)
        self.stdout.write(self.style.SUCCESS("All images and data set up successfully."))

    def create_continents(self) -> None:
        """
        Create continents in the database.
        """
        continents = [
            "Africa",
            "Antarctica",
            "Asia",
            "Europe",
            "North America",
            "Oceania",
            "South America",
        ]

        self.stdout.write(self.style.NOTICE("Creating continents..."))
        for continent_name in continents:
            continent_obj, created = Continent.objects.get_or_create(name=continent_name)
            if created:
                self.stdout.write(self.style.SUCCESS(f"Created continent: {continent_obj.name}"))
            else:
                self.stdout.write(self.style.WARNING(f"Continent already exists: {continent_obj.name}"))
        self.stdout.write(self.style.SUCCESS("All continents created."))

    def create_countries(self) -> None:
        """
        Create countries in the database.
        """
        countries = [
            ("France", "Europe"),
        ]

        self.stdout.write(self.style.NOTICE("Creating countries..."))
        for country_name, continent_name in countries:
            continent = Continent.objects.get(name=continent_name)
            country_obj, created = Country.objects.get_or_create(name=country_name, continent=continent)
            if created:
                self.stdout.write(self.style.SUCCESS(f"Created country: {country_obj.name}"))
            else:
                self.stdout.write(self.style.WARNING(f"Country already exists: {country_obj.name}"))
        self.stdout.write(self.style.SUCCESS("All countries created."))

    def create_cities(self) -> None:
        """
        Create cities in the database.
        """
        cities = [
            ("Paris", "France", 1),
            ("Lyon", "France", 2),
            ("Marseille", "France", 3),
        ]

        self.stdout.write(self.style.NOTICE("Creating cities..."))
        for city_name, country_name, order in cities:
            country = Country.objects.get(name=country_name)
            city_obj, created = City.objects.get_or_create(name=city_name, country=country, order=order)
            if created:
                self.stdout.write(self.style.SUCCESS(f"Created city: {city_obj.name}"))
            else:
                self.stdout.write(self.style.WARNING(f"City already exists: {city_obj.name}"))
        self.stdout.write(self.style.SUCCESS("All cities created."))

    def create_decorations(self, base_path: str) -> None:
        """
        Create decoration images in the database.
        """
        self.stdout.write(self.style.NOTICE("Creating decoration images..."))
        decorations_path = os.path.join(base_path, "decorations")

        if not is_valid_directory(decorations_path):
            self.stderr.write(self.style.ERROR(f"Decorations path {decorations_path} does not exist or is not a directory."))
            return

        for image_file in os.listdir(decorations_path):
            full_path = os.path.join(decorations_path, image_file)

            if is_valid_file(full_path):
                label = get_label_from_path(image_file)
                label_with_extension = get_label_from_path(image_file, extension=True)

                try:
                    decoration_image = DecorationImage.objects.get(label=label)
                    created = False
                except DecorationImage.DoesNotExist:
                    decoration_image = DecorationImage(label=label)
                    decoration_image.image.save(label_with_extension, File(open(full_path, "rb")))
                    decoration_image.save()
                    created = True

                if created:
                    self.stdout.write(self.style.SUCCESS(f"Created decoration image: {decoration_image.label}"))
                else:
                    self.stdout.write(self.style.WARNING(f"Decoration image already exists: {decoration_image.label}"))
        self.stdout.write(self.style.SUCCESS("All decoration images created."))

    def create_mountain_decorations(self, base_path: str) -> None:
        """
        Create mountain decoration images in the database.
        """
        self.stdout.write(self.style.NOTICE("Creating mountain decoration images..."))
        mountains_path = os.path.join(base_path, "decorations", "mountains")

        if not is_valid_directory(mountains_path):
            self.stderr.write(self.style.ERROR(f"Mountains path {mountains_path} does not exist or is not a directory."))
            return

        sort_order = read_sort_order(os.path.join(mountains_path, "sort_order.txt"))
        sorted_files = get_sorted_files(mountains_path, sort_order=sort_order)

        for image_path in sorted_files:
            label = get_label_from_path(image_path)
            label_with_extension = get_label_from_path(image_path, extension=True)

            try:
                mountain_decoration_image = MountainDecorationImage.objects.get(label=label)
                created = False
            except MountainDecorationImage.DoesNotExist:
                mountain_decoration_image = MountainDecorationImage(label=label)
                mountain_decoration_image.image.save(label_with_extension, File(open(image_path, "rb")))
                mountain_decoration_image.save()
                created = True

            if created:
                self.stdout.write(self.style.SUCCESS(f"Created decoration image: {mountain_decoration_image.label}"))
            else:
                self.stdout.write(self.style.WARNING(f"Decoration image already exists: {mountain_decoration_image.label}"))
        self.stdout.write(self.style.SUCCESS("All mountain decoration images created."))

    def create_base_characters(self, base_path: str) -> None:
        """
        Create base character images in the database.
        """
        self.stdout.write(self.style.NOTICE("Creating base character images..."))
        base_characters_path = os.path.join(base_path, "base_characters")

        if not is_valid_directory(base_characters_path):
            self.stderr.write(self.style.ERROR(f"Base characters path {base_characters_path} does not exist or is not a directory."))
            return

        sort_order = read_sort_order(os.path.join(base_characters_path, "sort_order.txt"))
        sorted_files = get_sorted_files(base_characters_path, sort_order=sort_order)

        for image_path in sorted_files:
            name = get_label_from_path(image_path)
            name_with_extension = get_label_from_path(image_path, extension=True)

            try:
                base_character_image = BaseCharacter.objects.get(name=name)
                created = False
            except BaseCharacter.DoesNotExist:
                base_character_image = BaseCharacter(name=name)
                print(f"Creating base character image: {name} at {image_path}")
                base_character_image.image.save(name_with_extension, File(open(image_path, "rb")))
                base_character_image.save()
                created = True

            if created:
                self.stdout.write(self.style.SUCCESS(f"Created base character image: {base_character_image.name}"))
            else:
                self.stdout.write(self.style.WARNING(f"Base character image already exists: {base_character_image.name}"))
        self.stdout.write(self.style.SUCCESS("All base character images created."))

    def create_exercises(self, base_path: str) -> None:
        """
        Create exercise images in the database.
        """
        self.stdout.write(self.style.NOTICE("Creating exercise images..."))
        exercises_path = os.path.join(base_path, "workout", "exercises")

        if not is_valid_directory(exercises_path):
            self.stderr.write(self.style.ERROR(f"Exercises path {exercises_path} does not exist or is not a directory."))
            return

        for image_file in os.listdir(exercises_path):
            full_path = os.path.join(exercises_path, image_file)
            name = get_label_from_path(image_file, lower=False)
            name_with_extension = get_label_from_path(image_file, extension=True, lower=False)

            if is_valid_file(full_path):
                try:
                    exercise_image = Exercise.objects.get(name=name)
                    created = False
                except Exercise.DoesNotExist:
                    exercise_image = Exercise(name=name)
                    exercise_image.image.save(name_with_extension, File(open(full_path, "rb")))
                    exercise_image.save()
                    created = True

                if created:
                    self.stdout.write(self.style.SUCCESS(f"Created exercise image: {exercise_image.name}"))
                else:
                    self.stdout.write(self.style.WARNING(f"Exercise image already exists: {exercise_image.name}"))
        self.stdout.write(self.style.SUCCESS("All exercise images created."))

    def create_city_decorations(self, base_path: str) -> None:
        """
        Create city decoration images in the database.
        """
        self.stdout.write(self.style.NOTICE("Creating city decoration images..."))
        decorations_path = os.path.join(base_path, "decorations", "countries")

        if not is_valid_directory(decorations_path):
            self.stderr.write(self.style.ERROR(f"City decorations path {decorations_path} does not exist or is not a directory."))
            return

        for country_name in os.listdir(decorations_path):
            country_path = os.path.join(decorations_path, country_name)
            if not is_valid_directory(country_path):
                continue

            for city_name in os.listdir(country_path):
                city_path = os.path.join(country_path, city_name)
                if not is_valid_directory(city_path):
                    continue

                sort_order = read_sort_order(os.path.join(city_path, "sort_order.txt"))
                sorted_files = get_sorted_files(city_path, sort_order=sort_order)

                try:
                    # lowercase the country and city names
                    country = Country.objects.get(name__iexact=country_name)
                    city = City.objects.get(name__iexact=city_name, country=country)
                except (Country.DoesNotExist, City.DoesNotExist):
                    self.stderr.write(self.style.ERROR(f"Country or city does not exist: {country_name}, {city_name}"))
                    continue

                for image_path in sorted_files:
                    label = get_label_from_path(image_path)
                    label_with_extension = get_label_from_path(image_path, extension=True)

                    try:
                        city_decoration_image = CityDecorationImage.objects.get(city=city, label=label)
                        created = False
                    except CityDecorationImage.DoesNotExist:
                        city_decoration_image = CityDecorationImage(city=city, label=label)
                        city_decoration_image.image.save(label, File(open(image_path, "rb")))
                        city_decoration_image.save()
                        created = True

                    if created:
                        self.stdout.write(self.style.SUCCESS(f"Created decoration image for {city.name}: {city_decoration_image.label}"))
                    else:
                        self.stdout.write(self.style.WARNING(f"Decoration image already exists for {city.name}: {city_decoration_image.label}"))

        self.stdout.write(self.style.SUCCESS("All city decoration images created."))

    def create_achievements(self, base_path: str) -> None:
        """
        Create achievements in the database.
        """
        self.stdout.write(self.style.NOTICE("Creating achievements..."))
        achievements_path = os.path.join(base_path, "achievements")

        if not is_valid_directory(achievements_path):
            self.stderr.write(self.style.ERROR(f"Achievements path {achievements_path} does not exist or is not a directory."))
            return

        config_path = os.path.join(achievements_path, "config.json")

        with open(config_path, "r") as file:
            achievements = json.load(file)
        for achievement in achievements:
            name = achievement["name"]
            description = achievement["description"]
            type = achievement["type"]
            target = achievement["target"]
            image_path = achievement["image"]
            xp_reward = achievement["xp_reward"]

            if not is_valid_file(os.path.join(achievements_path, image_path)):
                self.stderr.write(self.style.ERROR(f"Image path {image_path} does not exist or is not a file."))
                continue

            try:
                a = GameAchievement.objects.get(name=name)
                created = False
            except GameAchievement.DoesNotExist:
                a = GameAchievement(
                    name=name,
                    description=description,
                    type=type,
                    target=target,
                    xp_reward=xp_reward,
                )
                a.image.save(name, File(open(os.path.join(achievements_path, image_path), "rb")))
                a.save()
                created = True

            if created:
                self.stdout.write(self.style.SUCCESS(f"Created achievement: {a.name}"))
            else:
                self.stdout.write(self.style.WARNING(f"Achievement already exists: {a.name}"))
        self.stdout.write(self.style.SUCCESS("All achievements created."))
