import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatHistoryProvider = StateNotifierProvider<ChatHistoryNotifier, List<Map<String, dynamic>>>((ref) {
  return ChatHistoryNotifier();
});

class ChatHistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ChatHistoryNotifier() : super([]);

  void addUserMessage(String message) {
    state = [...state, {'role': 'user', 'parts': [{'text': message}]}];
  }

  void addModelMessage(String message) {
    state = [...state, {'role': 'model', 'parts': [{'text': message}]}];
  }

  void clear() {
    state = [];
  }
}
