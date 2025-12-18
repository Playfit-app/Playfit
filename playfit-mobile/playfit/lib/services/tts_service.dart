import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Configures the Text-to-Speech (TTS) settings.
/// This method sets the language, pitch, and speech rate for the TTS engine.
///
/// It reads the selected locale from secure storage and applies it.
/// If no locale is found, it defaults to English (en-US).
///
/// Returns a [Future] that completes when the configuration is done.
Future<void> configureTtsLanguage(FlutterTts flutterTts) async {
  const storage = FlutterSecureStorage();
  String? locale = await storage.read(key: 'selected_locale');

  // FlutterTts expects a full language tag (e.g. en-US, fr-FR).
  // Map short or underscored codes that we persist to a supported tag.
  String normalizedLocale;
  if (locale != null) {
    final cleaned = locale.replaceAll('_', '-').toLowerCase();
    if (cleaned.startsWith('fr')) {
      normalizedLocale = 'fr-FR';
    } else if (cleaned.startsWith('en')) {
      normalizedLocale = 'en-US';
    } else {
      normalizedLocale = cleaned;
    }
  } else {
    normalizedLocale = 'en-US'; // Default to English if no locale is set
  }

  await flutterTts.setLanguage(normalizedLocale);

  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(0.5);
}
