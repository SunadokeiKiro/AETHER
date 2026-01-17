import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// タイマープリセット
class TimerPreset {
  final String id;
  final String label;
  final Duration duration;
  final bool isBuiltIn;

  const TimerPreset({
    required this.id,
    required this.label,
    required this.duration,
    this.isBuiltIn = false,
  });

  TimerPreset copyWith({String? label, Duration? duration}) {
    return TimerPreset(
      id: id,
      label: label ?? this.label,
      duration: duration ?? this.duration,
      isBuiltIn: isBuiltIn,
    );
  }
}

/// デフォルトプリセット
const _defaultPresets = [
  TimerPreset(id: 'p1m', label: '1分', duration: Duration(minutes: 1), isBuiltIn: true),
  TimerPreset(id: 'p3m', label: '3分', duration: Duration(minutes: 3), isBuiltIn: true),
  TimerPreset(id: 'p5m', label: '5分', duration: Duration(minutes: 5), isBuiltIn: true),
  TimerPreset(id: 'p10m', label: '10分', duration: Duration(minutes: 10), isBuiltIn: true),
  TimerPreset(id: 'p25m', label: '25分', duration: Duration(minutes: 25), isBuiltIn: true),
];

/// タイマープリセットを管理するProvider
final timerPresetsProvider = StateNotifierProvider<TimerPresetsNotifier, List<TimerPreset>>(
  (ref) => TimerPresetsNotifier(),
);

class TimerPresetsNotifier extends StateNotifier<List<TimerPreset>> {
  TimerPresetsNotifier() : super([..._defaultPresets]);

  void add(TimerPreset preset) {
    state = [...state, preset];
  }

  void update(TimerPreset preset) {
    state = state.map((p) => p.id == preset.id ? preset : p).toList();
  }

  void delete(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

/// タイマーの状態
class TimerState {
  final Duration duration;
  final Duration remaining;
  final bool isRunning;
  final bool isPomodoro;
  final bool isBreak;

  const TimerState({
    this.duration = const Duration(minutes: 25),
    this.remaining = const Duration(minutes: 25),
    this.isRunning = false,
    this.isPomodoro = false,
    this.isBreak = false,
  });

  TimerState copyWith({
    Duration? duration,
    Duration? remaining,
    bool? isRunning,
    bool? isPomodoro,
    bool? isBreak,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
      isPomodoro: isPomodoro ?? this.isPomodoro,
      isBreak: isBreak ?? this.isBreak,
    );
  }

  double get progress => duration.inSeconds > 0 
      ? remaining.inSeconds / duration.inSeconds 
      : 0;
}

/// タイマーを管理するProvider
final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>(
  (ref) => TimerNotifier(),
);

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(const TimerState());
  Timer? _timer;

  void setDuration(Duration duration) {
    _timer?.cancel();
    state = TimerState(duration: duration, remaining: duration);
  }

  void startPomodoro() {
    _timer?.cancel();
    state = const TimerState(
      duration: Duration(minutes: 25),
      remaining: Duration(minutes: 25),
      isPomodoro: true,
      isBreak: false,
    );
    start();
  }

  void start() {
    if (state.remaining.inSeconds <= 0) return;
    
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remaining.inSeconds > 0) {
        state = state.copyWith(
          remaining: Duration(seconds: state.remaining.inSeconds - 1),
        );
      } else {
        _timer?.cancel();
        state = state.copyWith(isRunning: false);
        
        // ポモドーロの場合は休憩に切り替え
        if (state.isPomodoro) {
          if (state.isBreak) {
            // 休憩終了、作業に戻る
            state = const TimerState(
              duration: Duration(minutes: 25),
              remaining: Duration(minutes: 25),
              isPomodoro: true,
              isBreak: false,
            );
          } else {
            // 作業終了、休憩開始
            state = const TimerState(
              duration: Duration(minutes: 5),
              remaining: Duration(minutes: 5),
              isPomodoro: true,
              isBreak: true,
            );
          }
        }
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = TimerState(duration: state.duration, remaining: state.duration);
  }

  void stop() {
    _timer?.cancel();
    state = const TimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// タイマー画面
class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final presets = ref.watch(timerPresetsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(state.isPomodoro 
          ? (state.isBreak ? 'ポモドーロ - 休憩' : 'ポモドーロ - 作業')
          : 'タイマー'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showPresetManager(context, ref),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // プログレスリング
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: state.progress,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        state.isBreak 
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatDuration(state.remaining),
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          if (state.isPomodoro)
                            Text(
                              state.isBreak ? '休憩中' : '集中中',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // プリセットボタン
              if (!state.isRunning && state.remaining == state.duration) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ...presets.map((preset) => _PresetButton(
                      label: preset.label,
                      onTap: () => notifier.setDuration(preset.duration),
                    )),
                    _PresetButton(
                      label: 'カスタム',
                      onTap: () => _showCustomTimePicker(context, notifier),
                      isOutlined: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => notifier.startPomodoro(),
                  icon: const Icon(Icons.timer),
                  label: const Text('ポモドーロ開始'),
                ),
                const SizedBox(height: 24),
              ],
              
              // コントロールボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isRunning) ...[
                    ElevatedButton.icon(
                      onPressed: () => notifier.pause(),
                      icon: const Icon(Icons.pause),
                      label: const Text('一時停止'),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: state.remaining.inSeconds > 0 ? () => notifier.start() : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('開始'),
                    ),
                  ],
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => notifier.reset(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('リセット'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomTimePicker(BuildContext context, TimerNotifier notifier) {
    int hours = 0;
    int minutes = 5;
    int seconds = 0;

    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'カスタム時間設定',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 時間
                  _TimePickerColumn(
                    label: '時間',
                    value: hours,
                    maxValue: 23,
                    onChanged: (v) => setState(() => hours = v),
                  ),
                  const Text(' : ', style: TextStyle(fontSize: 24)),
                  // 分
                  _TimePickerColumn(
                    label: '分',
                    value: minutes,
                    maxValue: 59,
                    onChanged: (v) => setState(() => minutes = v),
                  ),
                  const Text(' : ', style: TextStyle(fontSize: 24)),
                  // 秒
                  _TimePickerColumn(
                    label: '秒',
                    value: seconds,
                    maxValue: 59,
                    onChanged: (v) => setState(() => seconds = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final duration = Duration(
                      hours: hours,
                      minutes: minutes,
                      seconds: seconds,
                    );
                    if (duration.inSeconds > 0) {
                      notifier.setDuration(duration);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('設定'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPresetManager(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _PresetManagerSheet(),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _TimePickerColumn extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const _TimePickerColumn({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 40,
              child: Text(
                value.toString().padLeft(2, '0'),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: value < maxValue ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isOutlined;

  const _PresetButton({
    required this.label,
    required this.onTap,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(onPressed: onTap, child: Text(label));
    }
    return FilledButton.tonal(onPressed: onTap, child: Text(label));
  }
}

/// プリセット管理シート
class _PresetManagerSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(timerPresetsProvider);
    final notifier = ref.read(timerPresetsProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'タイマープリセット',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    return ListTile(
                      title: Text(preset.label),
                      subtitle: Text(_formatDuration(preset.duration)),
                      trailing: preset.isBuiltIn
                          ? null
                          : IconButton(
                              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                              onPressed: () => notifier.delete(preset.id),
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPreset(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('プリセットを追加'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddPreset(BuildContext context, WidgetRef ref) {
    final labelController = TextEditingController();
    int hours = 0;
    int minutes = 5;
    int seconds = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('プリセット追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'ラベル',
                  hintText: '例: 昼休み',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MiniTimePicker(
                    label: '時',
                    value: hours,
                    maxValue: 23,
                    onChanged: (v) => setState(() => hours = v),
                  ),
                  const Text(':'),
                  _MiniTimePicker(
                    label: '分',
                    value: minutes,
                    maxValue: 59,
                    onChanged: (v) => setState(() => minutes = v),
                  ),
                  const Text(':'),
                  _MiniTimePicker(
                    label: '秒',
                    value: seconds,
                    maxValue: 59,
                    onChanged: (v) => setState(() => seconds = v),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                final duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
                if (duration.inSeconds > 0 && labelController.text.isNotEmpty) {
                  ref.read(timerPresetsProvider.notifier).add(
                    TimerPreset(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      label: labelController.text,
                      duration: duration,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h時間${m}分${s}秒';
    } else if (m > 0) {
      return '$m分${s}秒';
    }
    return '$s秒';
  }
}

class _MiniTimePicker extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const _MiniTimePicker({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_drop_up),
          onPressed: value < maxValue ? () => onChanged(value + 1) : null,
          iconSize: 20,
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_drop_down),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          iconSize: 20,
        ),
      ],
    );
  }
}
