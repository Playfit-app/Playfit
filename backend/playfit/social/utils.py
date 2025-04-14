from PIL import Image
from io import BytesIO
from django.core.files.base import ContentFile
from django.core.files.uploadedfile import SimpleUploadedFile

def convert_to_webp(image_field):
    """Convert an uploaded image to WebP format."""
    image_field.file.seek(0)
    image = Image.open(image_field)
    image = image.convert("RGBA")

    webp_io = BytesIO()
    image.save(webp_io, format="WEBP")

    filename_without_ext = image_field.name.split('.')[0]
    webp_file = ContentFile(webp_io.getvalue(), f"{filename_without_ext}.webp")
    return webp_file

def create_test_image():
    img = Image.new('RGB', (100, 100), color='red')
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    return SimpleUploadedFile("test_image.png", buffer.read(), content_type="image/png")

