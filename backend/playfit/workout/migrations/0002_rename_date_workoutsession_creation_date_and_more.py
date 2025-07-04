# Generated by Django 5.1.6 on 2025-04-10 07:49

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('social', '0006_basecharacter_customization_base_character'),
        ('workout', '0001_initial'),
    ]

    operations = [
        migrations.RenameField(
            model_name='workoutsession',
            old_name='date',
            new_name='creation_date',
        ),
        migrations.AddField(
            model_name='workoutsession',
            name='city',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='social.city'),
        ),
        migrations.AddField(
            model_name='workoutsession',
            name='city_level',
            field=models.PositiveIntegerField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='workoutsession',
            name='completed_date',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='workoutsession',
            name='transition_from',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='+', to='social.city'),
        ),
        migrations.AddField(
            model_name='workoutsession',
            name='transition_to',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='+', to='social.city'),
        ),
        migrations.AlterField(
            model_name='workoutsession',
            name='duration',
            field=models.DurationField(default=0),
        ),
    ]
