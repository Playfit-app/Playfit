import shutil
import tempfile
import io
from PIL import Image
from django.test import override_settings


class TempMediaMixin:
    """Redirect MEDIA_ROOT to a temporary directory during tests."""
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls._temp_media = tempfile.mkdtemp(prefix="test_media_")
        cls._override = override_settings(
            MEDIA_ROOT=cls._temp_media,
            DEFAULT_FILE_STORAGE="django.core.files.storage.FileSystemStorage",
        )
        cls._override.enable()

    @classmethod
    def tearDownClass(cls):
        cls._override.disable()
        shutil.rmtree(cls._temp_media, ignore_errors=True)
        super().tearDownClass()


def make_image_file(fmt="PNG", size=(10, 10), color=(255, 0, 0), name="test"):
    """Return a Django-friendly in-memory uploaded file of the given format."""
    buf = io.BytesIO()
    Image.new("RGB", size, color).save(buf, format=fmt)
    buf.seek(0)
    # Give it an appropriate extension so your model logic sees the right suffix
    ext = fmt.lower()
    if ext == "jpeg":  # Pillow uses "JPEG" but you probably want ".jpg"
        ext = "jpg"
    from django.core.files.uploadedfile import SimpleUploadedFile
    return SimpleUploadedFile(f"{name}.{ext}", buf.read(), content_type=f"image/{ext}")
