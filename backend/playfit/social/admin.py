from django.contrib import admin
from .models import Continent, Country, City, WorldPosition

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
