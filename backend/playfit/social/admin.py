from django.contrib import admin
from .models import (
    Continent,
    Country,
    City,
    WorldPosition,
    BaseCharacter,
    CustomizationItem,
    Customization,
    DecorationImage,
    CityDecorationImage,
    MountainDecorationImage,
    IntroductionCharacter,
    Post,
    Like,
    Comment,
    Follow,
    ShopItem,
    ShopPurchase,
)

class ContinentAdmin(admin.ModelAdmin):
    list_display = ['name']

class CountryAdmin(admin.ModelAdmin):
    list_display = ['name', 'continent']

class CityAdmin(admin.ModelAdmin):
    list_display = ['name', 'country', 'order']

class IntroductionCharacterAdmin(admin.ModelAdmin):
    list_display = ['name', 'image']


admin.site.register(Continent, ContinentAdmin)
admin.site.register(Country, CountryAdmin)
admin.site.register(City, CityAdmin)
admin.site.register(WorldPosition)
admin.site.register(BaseCharacter)
admin.site.register(CustomizationItem)
admin.site.register(Customization)
admin.site.register(DecorationImage)
admin.site.register(CityDecorationImage)
admin.site.register(MountainDecorationImage)
admin.site.register(Post)
admin.site.register(Like)
admin.site.register(Comment)
admin.site.register(Follow)
class ShopItemAdmin(admin.ModelAdmin):
    list_display = ['base_character', 'price', 'is_active', 'created_at']
    list_filter = ['is_active', 'created_at']
    search_fields = ['base_character__name']
    readonly_fields = ['created_at']

class ShopPurchaseAdmin(admin.ModelAdmin):
    list_display = ['user', 'item', 'purchased_at']
    list_filter = ['purchased_at']
    search_fields = ['user__username', 'item__base_character__name']
    readonly_fields = ['purchased_at']

admin.site.register(IntroductionCharacter, IntroductionCharacterAdmin)
admin.site.register(ShopItem, ShopItemAdmin)
admin.site.register(ShopPurchase, ShopPurchaseAdmin)