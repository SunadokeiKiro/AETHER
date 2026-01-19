import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_service.g.dart';

@Riverpod(keepAlive: true)
GeminiService geminiService(GeminiServiceRef ref) {
  return GeminiService();
}

class GeminiService {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<GeminiResponse> sendMessage({
    required String message,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final callable = _functions.httpsCallable('chat');
      final response = await callable.call({
        'message': message,
        'conversationHistory': history,
      });

      final data = response.data as Map<String, dynamic>;
      
      final actionsList = (data['actions'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      
      return GeminiResponse(
        type: data['type'] as String,
        actions: actionsList,
        text: data['text'] as String?,
        fullText: data['fullText'] as String?,
      );
    } catch (e) {
      // エラーハンドリングは呼び出し元で行う、またはカスタム例外を投げる
      rethrow;
    }
  }
}

class GeminiResponse {
  final String type; // 'text' or 'action'
  final List<Map<String, dynamic>> actions;
  final String? text;
  final String? fullText;

  GeminiResponse({
    required this.type,
    this.actions = const [],
    this.text,
    this.fullText,
  });


  
  @override
  String toString() {
    return 'GeminiResponse(type: $type, actions: $actions, text: $text, fullText: $fullText)';
  }
}
