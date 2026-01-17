import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';

/// AETHERアプリのルートウィジェット
class AetherApp extends ConsumerWidget {
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeData = ref.watch(themeDataProvider);

    return MaterialApp.router(
      title: 'AETHER',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      routerConfig: router,
    );
  }
}

/// AETHER AIを開くためのグローバル関数
void showAetherTrigger(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const AetherTriggerSheet(),
  );
}

/// AETHER Trigger ボトムシート（他の画面からも使える）
class AetherTriggerSheet extends StatefulWidget {
  const AetherTriggerSheet({super.key});

  @override
  State<AetherTriggerSheet> createState() => _AetherTriggerSheetState();
}

class _AetherTriggerSheetState extends State<AetherTriggerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドル
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // タイトル
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'AETHER AI',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 入力フィールド
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: '何かお手伝いしましょうか？',
              hintStyle: TextStyle(color: theme.colorScheme.outline),
              prefixIcon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.outline),
            ),
            style: TextStyle(color: theme.colorScheme.onSurface),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 16),
          
          // 送信ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI機能は Phase 3 で実装予定です')),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('送信'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
