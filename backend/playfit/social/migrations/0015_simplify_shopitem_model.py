# Generated manually to simplify ShopItem model

from django.db import migrations, models
import django.db.models.deletion


def remove_invalid_shop_items(apps, schema_editor):
    """Remove ShopItem records that don't have a base_character linked."""
    ShopItem = apps.get_model('social', 'ShopItem')
    # Delete any shop items without a base_character
    deleted_count = ShopItem.objects.filter(base_character__isnull=True).delete()[0]
    if deleted_count > 0:
        print(f"Deleted {deleted_count} ShopItem(s) without base_character")


class Migration(migrations.Migration):

    dependencies = [
        ('social', '0014_shopitem_shoppurchase'),
    ]

    operations = [
        # Step 1: Clean up any invalid data
        migrations.RunPython(remove_invalid_shop_items, migrations.RunPython.noop),

        # Step 2: Remove the old fields we no longer need
        migrations.RemoveField(
            model_name='shopitem',
            name='name',
        ),
        migrations.RemoveField(
            model_name='shopitem',
            name='image',
        ),

        # Step 3: Change base_character from ForeignKey to OneToOneField and make it required
        migrations.AlterField(
            model_name='shopitem',
            name='base_character',
            field=models.OneToOneField(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='shop_item',
                to='social.basecharacter'
            ),
        ),
    ]