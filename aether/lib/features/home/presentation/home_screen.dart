import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../app.dart';

/// ホーム画面 - アダプティブ・ゲートウェイ
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = ref.watch(designTokensProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AETHER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.density.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Text(
                'クイックアクション',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: tokens.density.spacingMd),
              
              // QuickActionGrid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: tokens.density.spacingMd,
                  crossAxisSpacing: tokens.density.spacingMd,
                  children: [
                    _QuickActionTile(
                      icon: Icons.calculate,
                      label: '電卓',
                      color: tokens.palette.primary,
                      onTap: () => context.push('/calculator'),
                    ),
                    _QuickActionTile(
                      icon: Icons.note_alt,
                      label: 'メモ',
                      color: tokens.palette.secondary,
                      onTap: () => context.push('/memo'),
                    ),
                    _QuickActionTile(
                      icon: Icons.timer,
                      label: 'タイムクロック',
                      color: const Color(0xFF22C55E),
                      onTap: () => context.push('/timeclock'),
                    ),
                    _QuickActionTile(
                      icon: Icons.alarm,
                      label: 'アラーム',
                      color: const Color(0xFFEF4444),
                      onTap: () => context.push('/alarm'),
                    ),
                    _QuickActionTile(
                      icon: Icons.swap_horiz,
                      label: '単位換算',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => context.push('/converter'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // AETHER Trigger FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAetherTrigger(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AETHER'),
      ),
    );
  }
}

/// クイックアクションタイル
class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// AETHER Trigger ボトムシート
class _AetherTriggerSheet extends StatefulWidget {
  const _AetherTriggerSheet();

  @override
  State<_AetherTriggerSheet> createState() => _AetherTriggerSheetState();
}

class _AetherTriggerSheetState extends State<_AetherTriggerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // タイトル
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'AETHER AI',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 入力フィールド
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: '何かお手伝いしましょうか？',
              prefixIcon: Icon(Icons.chat_bubble_outline),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 16),
          
          // 送信ボタン
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: AI処理を実装
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
