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

  if (locale != null) {
    await flutterTts.setLanguage(locale);
  } else {
    await flutterTts.setLanguage('en-US'); // Default to English if no locale is set
  }

  await flutterTts.setPitch(1.0);
  await flutterTts.setSpeechRate(0.5);
}
