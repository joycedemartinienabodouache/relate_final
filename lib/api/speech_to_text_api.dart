

import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechApi{
  static final _speech = SpeechToText();

  static Future<bool> toggleRecording(
  {
    @required Function(String text) onResult,
    @required ValueChanged<bool> onListening,
  }
      ) async {

    final isAvailable = await _speech.initialize(
      onStatus: (status) async => onListening(_speech.isListening),
      onError: (err) => print('Error: $err'),
    );

    if(isAvailable){
      _speech.listen(
        onResult: (value) => onResult(value.recognizedWords),
      );
    }
    return isAvailable;

  }
}