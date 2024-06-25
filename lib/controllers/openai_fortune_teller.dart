import 'package:dart_openai/dart_openai.dart';
import 'package:fortuntella/controllers/fortune_teller.dart';
import 'package:fortuntella/services/openai_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIFortuneTeller implements FortuneTeller {
  final OpenAIService _openAIService;
  late Stream completionStream;

  OpenAIFortuneTeller()
      : _openAIService = OpenAIService(dotenv.env['OPENAI_API_KEY']!);

  @override
  Stream<String> getFortune(String question) {
    Stream<OpenAIStreamChatCompletionModel> completionStream =
        _openAIService.getFortune(question);
    return completionStream.map((event) {
      return event.choices.first.delta.content
              ?.map((contentItem) => contentItem?.text ?? '')
              .join() ??
          '';
    });
  }

  @override
  void onFortuneReceived(Function(String) callback, Function(String) onError) {
    completionStream.listen(
      (fortunePart) {
        callback(fortunePart);
      },
      onDone: () {
        callback('🔮');
      },
      onError: (error) {
        onError('Unexpected error occurred. Error: $error');
      },
    );
  }
}
