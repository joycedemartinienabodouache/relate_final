import 'package:translator/translator.dart';

class TranslationApi{

  static Future<String> translate (
      String message, String fromLanguageCode, String toLanguageCode
      ) async {

    final translation = await GoogleTranslator().translate(
      message,
      from: fromLanguageCode,
      to: toLanguageCode,
    );
    return translation.text;
  }

}