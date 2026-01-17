import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../providers/alarm_providers.dart';

// Alarmはalarm_providers.dartからエクスポートされる

/// アラーム画面
class AlarmScreen extends ConsumerWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('アラーム'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AETHER AI',
            onPressed: () => showAetherTrigger(context),
          ),
        ],
      ),
      body: alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'アラームがありません',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return _AlarmCard(
                  alarm: alarm,
                  onEdit: () => _showAlarmEditor(context, ref, alarm),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAlarmEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAlarmEditor(BuildContext context, WidgetRef ref, [Alarm? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AlarmEditorSheet(existingAlarm: existing),
    );
  }
}

/// アラーム編集シート
class _AlarmEditorSheet extends ConsumerStatefulWidget {
  final Alarm? existingAlarm;

  const _AlarmEditorSheet({this.existingAlarm});

  @override
  ConsumerState<_AlarmEditorSheet> createState() => _AlarmEditorSheetState();
}

class _AlarmEditorSheetState extends ConsumerState<_AlarmEditorSheet> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late List<int> _selectedDays;

  static const _dayLabels = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.existingAlarm?.time ?? TimeOfDay.now();
    _labelController = TextEditingController(text: widget.existingAlarm?.label ?? '');
    _selectedDays = List<int>.from(widget.existingAlarm?.repeatDays ?? []);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAlarm != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ヘッダー
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  Text(
                    isEditing ? 'アラームを編集' : '新規アラーム',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: _save,
                    child: Text(isEditing ? '保存' : '追加'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // 時間表示/選択
              GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // ラベル入力
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'ラベル',
                  hintText: 'アラームの名前（任意）',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 24),
              
              // 繰り返し設定
              Text(
                '繰り返し',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              // 曜日選択
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final isSelected = _selectedDays.contains(index);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(index);
                        } else {
                          _selectedDays.add(index);
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: Text(
                          _dayLabels[index],
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              // プリセットボタン
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetButton(
                    label: '1回のみ',
                    isSelected: _selectedDays.isEmpty,
                    onTap: () => setState(() => _selectedDays.clear()),
                  ),
                  _PresetButton(
                    label: '毎日',
                    isSelected: _selectedDays.length == 7,
                    onTap: () => setState(() => _selectedDays = [0, 1, 2, 3, 4, 5, 6]),
                  ),
                  _PresetButton(
                    label: '平日',
                    isSelected: _selectedDays.length == 5 &&
                        !_selectedDays.contains(0) &&
                        !_selectedDays.contains(6),
                    onTap: () => setState(() => _selectedDays = [1, 2, 3, 4, 5]),
                  ),
                  _PresetButton(
                    label: '週末',
                    isSelected: _selectedDays.length == 2 &&
                        _selectedDays.contains(0) &&
                        _selectedDays.contains(6),
                    onTap: () => setState(() => _selectedDays = [0, 6]),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _save() {
    final alarm = Alarm(
      id: widget.existingAlarm?.id,
      time: _selectedTime,
      label: _labelController.text,
      repeatDays: List<int>.from(_selectedDays),
      isEnabled: widget.existingAlarm?.isEnabled ?? true,
    );

    if (widget.existingAlarm != null) {
      ref.read(alarmListProvider.notifier).update(alarm);
    } else {
      ref.read(alarmListProvider.notifier).add(alarm);
    }
    Navigator.pop(context);
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
      child: Text(label),
    );
  }
}

class _AlarmCard extends ConsumerWidget {
  final Alarm alarm;
  final VoidCallback onEdit;

  const _AlarmCard({
    required this.alarm,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // 時刻と情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.formattedTime,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: alarm.isEnabled 
                            ? Theme.of(context).colorScheme.onSurface 
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.label.isEmpty ? alarm.repeatText : '${alarm.label} • ${alarm.repeatText}',
                      style: TextStyle(
                        color: alarm.isEnabled 
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              // コントロール
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: alarm.isEnabled,
                    onChanged: (_) {
                      ref.read(alarmListProvider.notifier).toggle(alarm.id);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('アラームを削除'),
                          content: const Text('このアラームを削除してもよろしいですか？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                              ),
                              child: const Text('削除'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(alarmListProvider.notifier).delete(alarm.id);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
