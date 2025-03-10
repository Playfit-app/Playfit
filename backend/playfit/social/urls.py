from django.urls import path
from .views import (
    CustomizationItemListView,
    CustomizationItemByCategoryListView,
    CustomizationUpdateView,
    CustomizationView,
)

urlpatterns = [
    path("customization-items/", CustomizationItemListView.as_view(), name="customization_items"),
    path("customization-items/<str:category>/", CustomizationItemByCategoryListView.as_view(), name="customization_items_by_category"),
    path("update-customization/", CustomizationUpdateView.as_view(), name="update_customization"),
    path("customization/", CustomizationView.as_view(), name="customization"),
]
