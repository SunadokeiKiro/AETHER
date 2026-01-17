import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';

/// テーマプリセット
const themePresets = ['default', 'cyberpunk', 'minimal', 'nature', 'sunset'];

/// 言語設定
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption(this.code, this.name, this.nativeName);
}

const supportedLanguages = [
  LanguageOption('ja', 'Japanese', '日本語'),
  LanguageOption('en', 'English', 'English'),
  LanguageOption('ko', 'Korean', '한국어'),
  LanguageOption('zh', 'Chinese (Simplified)', '简体中文'),
  LanguageOption('zh_TW', 'Chinese (Traditional)', '繁體中文'),
  LanguageOption('es', 'Spanish', 'Español'),
  LanguageOption('pt', 'Portuguese', 'Português'),
  LanguageOption('fr', 'French', 'Français'),
  LanguageOption('de', 'German', 'Deutsch'),
  LanguageOption('it', 'Italian', 'Italiano'),
  LanguageOption('ru', 'Russian', 'Русский'),
  LanguageOption('ar', 'Arabic', 'العربية'),
  LanguageOption('hi', 'Hindi', 'हिन्दी'),
  LanguageOption('th', 'Thai', 'ไทย'),
  LanguageOption('vi', 'Vietnamese', 'Tiếng Việt'),
  LanguageOption('id', 'Indonesian', 'Bahasa Indonesia'),
];

/// 現在の言語設定Provider
final selectedLanguageProvider = StateProvider<String>((ref) => 'ja');

/// 設定画面
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPreset = ref.watch(themePresetProvider);
    final currentLanguage = ref.watch(selectedLanguageProvider);
    final currentLang = supportedLanguages.firstWhere((l) => l.code == currentLanguage, orElse: () => supportedLanguages[0]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 言語設定セクション
          Text(
            '言語',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text('アプリの言語'),
              subtitle: Text(currentLang.nativeName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageSelector(context, ref),
            ),
          ),
          const SizedBox(height: 24),

          // テーマ設定セクション
          Text(
            'テーマ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: themePresets.map((preset) {
                return RadioListTile<String>(
                  title: Text(_getPresetLabel(preset)),
                  subtitle: Text(_getPresetDescription(preset)),
                  value: preset,
                  groupValue: currentPreset,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themePresetProvider.notifier).state = value;
                      ref.read(designTokensProvider.notifier).setPreset(value);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          
          // 一般設定セクション
          Text(
            '一般',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('通知'),
                  subtitle: const Text('アラームとタイマーの通知'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: 通知設定を実装
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.vibration),
                  title: const Text('振動'),
                  subtitle: const Text('ボタン操作時の振動'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: 振動設定を実装
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('サウンド'),
                  subtitle: const Text('アラーム・タイマーのサウンド'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: サウンド設定画面
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // AI設定セクション
          Text(
            'AI設定',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.auto_awesome),
                  title: const Text('AETHER AI'),
                  subtitle: const Text('Phase 3で実装予定'),
                  trailing: Switch(
                    value: false,
                    onChanged: null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // アプリ情報
          Text(
            'アプリ情報',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('バージョン'),
                  trailing: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('ライセンス'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showLicensePage(context: context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.read(selectedLanguageProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('言語を選択', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: supportedLanguages.length,
                itemBuilder: (context, index) {
                  final lang = supportedLanguages[index];
                  final isSelected = lang.code == currentLanguage;
                  return ListTile(
                    leading: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : const SizedBox(width: 24),
                    title: Text(lang.nativeName),
                    subtitle: Text(lang.name),
                    selected: isSelected,
                    onTap: () {
                      ref.read(selectedLanguageProvider.notifier).state = lang.code;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('言語を ${lang.nativeName} に変更しました。アプリを再起動すると完全に反映されます。')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPresetLabel(String preset) {
    switch (preset) {
      case 'cyberpunk':
        return 'Cyberpunk';
      case 'minimal':
        return 'Minimal';
      case 'nature':
        return 'Nature';
      case 'sunset':
        return 'Sunset';
      default:
        return 'Default';
    }
  }

  String _getPresetDescription(String preset) {
    switch (preset) {
      case 'cyberpunk':
        return 'ネオンカラーとシャープなエッジ';
      case 'minimal':
        return 'ライトテーマ、シンプルな形状';
      case 'nature':
        return 'アースカラー、オーガニックな形状';
      case 'sunset':
        return '暖色系グラデーション';
      default:
        return 'モダンでクリーンなダークテーマ';
    }
  }
}
