# Generated by Django 5.1.6 on 2025-04-21 02:53

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('social', '0009_mountaindecorationimage'),
    ]

    operations = [
        migrations.CreateModel(
            name='DecorationImage',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image', models.ImageField(upload_to='decorations/')),
                ('label', models.CharField(blank=True, max_length=255)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),
    ]
