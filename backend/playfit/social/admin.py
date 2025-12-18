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
admin.site.register(IntroductionCharacter, IntroductionCharacterAdmin)
admin.site.register(ShopItem)
admin.site.register(ShopPurchase)
