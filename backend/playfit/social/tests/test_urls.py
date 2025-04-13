from django.test import SimpleTestCase
from django.urls import resolve, reverse
from social.views import (
    CustomizationItemListView,
    CustomizationItemByCategoryListView,
    CustomizationUpdateView,
    CustomizationView,
)

class TestUrls(SimpleTestCase):
    def test_customization_items_url_resolves(self):
        url = reverse('customization_items')
        self.assertEqual(resolve(url).func.view_class, CustomizationItemListView)

    def test_customization_items_by_category_url_resolves(self):
        url = reverse('customization_items_by_category', args=['some-category'])
        self.assertEqual(resolve(url).func.view_class, CustomizationItemByCategoryListView)

    def test_customization_update_url_resolves(self):
        url = reverse('update_customization')
        self.assertEqual(resolve(url).func.view_class, CustomizationUpdateView)

    def test_customization_url_resolves(self):
        url = reverse('customization')
        self.assertEqual(resolve(url).func.view_class, CustomizationView)
