import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.setLanguage("en-IN");
      await flutterTts.setPitch(0.8); // Lower pitch for divine tone
      await flutterTts.setSpeechRate(0.9);

      if (Platform.isIOS) {
        await flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          ],
        );
      }
    } catch (e) {
      debugPrint("TTS Initialization Error: $e");
    }
  }

  Future<void> speak(String text) async {
    try {
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint("TTS Error: $e");
    }
  }

  Future<void> stop() async {
    await flutterTts.stop();
  }
}
