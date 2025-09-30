import 'package:flutter/material.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/services/language_service.dart';

class LanguageProvider extends ChangeNotifier {
  AppLocale _currentLocale = AppLocale.en;
  
  AppLocale get currentLocale => _currentLocale;
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  /// Loads the saved language from storage and updates the locale
  Future<void> _loadSavedLanguage() async {
    final savedLocale = await LanguageService.loadLocale();
    if (savedLocale != null) {
      _currentLocale = savedLocale;
      await LocaleSettings.setLocale(_currentLocale);
      notifyListeners();
    } else {
      // Use device locale if no saved locale
      final deviceLocale = await LocaleSettings.useDeviceLocale();
      _currentLocale = deviceLocale;
      await LanguageService.saveLocale(_currentLocale);
      notifyListeners();
    }
  }
  
  /// Changes the app language and saves it to storage
  /// This triggers a complete rebuild of the app
  Future<void> changeLanguage(AppLocale newLocale) async {
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      
      // Save to storage and update locale settings
      await LanguageService.saveLocale(newLocale);
      await LocaleSettings.setLocale(newLocale);
      
      // Notify all listeners to rebuild
      notifyListeners();
    }
  }
  
  /// Gets the display name for a locale
  String getLanguageName(AppLocale locale) {
    return LanguageService.getLocaleName(locale);
  }
}