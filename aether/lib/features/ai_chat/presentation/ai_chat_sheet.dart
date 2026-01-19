import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aether/core/theme/theme_provider.dart';
import 'package:aether/core/services/gemini_service.dart';
import 'package:aether/features/ai_chat/logic/function_executor.dart';
import 'package:aether/features/ai_chat/providers/chat_history_provider.dart';

class AIChatSheet extends ConsumerStatefulWidget {
  const AIChatSheet({super.key});

  @override
  ConsumerState<AIChatSheet> createState() => _AIChatSheetState();
}

class _AIChatSheetState extends ConsumerState<AIChatSheet> {

  final TextEditingController _controller = TextEditingController();
  // removed local _history
  bool _isLoading = false;
  String? _lastResponse;

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _lastResponse = null;
    });

    try {
      // 単発リクエストのため履歴は毎回空で送信
      final response = await ref.read(geminiServiceProvider).sendMessage(
        message: message,
        history: [], // 履歴は残さない
      );

      setState(() {
        // アクションがある場合は、テキストを表示しない（もしくは、アクションの説明文として表示する）
        // JSONと混ざったテキストが表示されるのを防ぐため、アクション優先
        if (response.type == 'action' && response.actions.isNotEmpty) {
           _lastResponse = "アクションを実行中..."; 
        } else {
           _lastResponse = response.text;
        }
        _controller.clear();
      });

      // アクションの実行ロジック
      if (response.type == 'action' && response.actions.isNotEmpty) {
        await _handleActions(response.actions);
        // アクション実行後はボトムシートを閉じる
        if (mounted) {
          Navigator.of(context).pop();
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getUserFriendlyError(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleActions(List<Map<String, dynamic>> actions) async {
    if (!mounted) return;

    final executor = ref.read(functionExecutorProvider);
    
    // アクションを優先度順にソート
    // 1: theme_change, 2: その他機能, 3: navigate
    final sortedActions = List<Map<String, dynamic>>.from(actions);
    sortedActions.sort((a, b) {
      final priorityA = _getActionPriority(a['action'] as String?);
      final priorityB = _getActionPriority(b['action'] as String?);
      return priorityA.compareTo(priorityB);
    });
    
    for (final actionData in sortedActions) {
      final actionName = actionData['action'] as String?;
      
      // paramsがなければフラット構造とみなして抽出
      Map<String, dynamic> params = actionData['params'] as Map<String, dynamic>? ?? {};
      if (params.isEmpty) {
        params = Map<String, dynamic>.from(actionData)..remove('action');
      }

      if (actionName != null) {
        try {
          // 各アクションの完了を待つ（executor内でタイムアウト管理）
          await executor.execute(context, actionName, params);
        } catch (e) {
          debugPrint('Action execution error: $e');
        }
      }
    }
  }

  /// アクションの実行優先度を返す（数値が小さいほど優先）
  int _getActionPriority(String? action) {
    switch (action) {
      case 'theme_change':
        return 1; // 最優先: テーマ設定
      case 'navigate':
        return 3; // 最後: 画面遷移
      default:
        return 2; // 中間: その他機能（memo_control, alarm_control, timer_control等）
    }
  }

  /// エラーをユーザーフレンドリーなメッセージに変換
  String _getUserFriendlyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('network') || errorStr.contains('socket')) {
      return 'ネットワーク接続を確認してください';
    }
    if (errorStr.contains('timeout')) {
      return '応答がタイムアウトしました。もう一度お試しください';
    }
    if (errorStr.contains('permission') || errorStr.contains('unauthorized')) {
      return '権限がありません';
    }
    return 'AIとの通信に失敗しました。しばらく待ってお試しください';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = ref.watch(designTokensProvider).palette;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'AETHER AI',
            style: theme.textTheme.titleLarge?.copyWith(
              color: palette.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (_lastResponse != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  palette.surfaceVariant.withOpacity(0.5),
                  palette.surface,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _lastResponse!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'AIに指示を送る...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: palette.background,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16), // キーボード分の余白（必要に応じて調整）
        ],
      ),
    );
  }
}
