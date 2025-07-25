# Generated by Django 5.1.6 on 2025-04-09 06:19

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('social', '0005_merge_20250409_0618'),
    ]

    operations = [
        migrations.CreateModel(
            name='BaseCharacter',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50, unique=True)),
                ('image', models.ImageField(upload_to='base_characters/')),
            ],
        ),
        migrations.AddField(
            model_name='customization',
            name='base_character',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='character', to='social.basecharacter'),
        ),
    ]
