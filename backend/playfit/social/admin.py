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
    Post,
    Like,
    Comment,
    Follow,
)

class ContinentAdmin(admin.ModelAdmin):
    list_display = ['name']

class CountryAdmin(admin.ModelAdmin):
    list_display = ['name', 'continent']

class CityAdmin(admin.ModelAdmin):
    list_display = ['name', 'country', 'order']


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
