import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:playfit/i18n/strings.g.dart';

class LanguageService {
  static const _key = 'selected_locale';
  static final _storage = FlutterSecureStorage();

  /// Saves the selected locale to secure storage.
  /// This method stores the language tag of the provided [AppLocale].
  ///
  /// `locale` is the [AppLocale] to be saved.
  ///
  /// Returns a [Future] that completes when the locale is saved.
  static Future<void> saveLocale(AppLocale locale) async {
    await _storage.write(key: _key, value: locale.languageTag);
  }

  /// Loads the saved locale from secure storage.
  ///
  /// This method retrieves the language tag from storage and parses it into an [AppLocale].
  ///
  /// Returns a [Future] that completes with the [AppLocale] if found, or null if not.
  static Future<AppLocale?> loadLocale() async {
    final tag = await _storage.read(key: _key);
    if (tag != null) {
      return AppLocaleUtils.parse(tag);
    }
    return null;
  }

  static Future<void> clearLocale() async {
    await _storage.delete(key: _key);
  }

  static String getLocaleName(AppLocale locale) {
    return t.settings.languages[locale.languageCode] ?? locale.languageCode;
  }
}
