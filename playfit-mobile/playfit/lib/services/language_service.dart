import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:playfit/i18n/strings.g.dart';

class LanguageService {
  static const _key = 'selected_locale';
  static final _storage = FlutterSecureStorage();

  static Future<void> saveLocale(AppLocale locale) async {
    await _storage.write(key: _key, value: locale.languageTag);
  }

  static Future<AppLocale?> loadLocale() async {
    final tag = await _storage.read(key: _key);
    if (tag != null) {
      return AppLocaleUtils.parse(tag);
    }
    return null;
  }
}
