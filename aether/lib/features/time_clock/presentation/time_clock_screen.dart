import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../providers/time_clock_providers.dart';

// TimerPreset, TimerState, StopwatchStateはtime_clock_providers.dartからエクスポートされる

// ============================================================================
// TIME CLOCK SCREEN (UNIFIED)
// ============================================================================

class TimeClockScreen extends ConsumerStatefulWidget {
  const TimeClockScreen({super.key});

  @override
  ConsumerState<TimeClockScreen> createState() => _TimeClockScreenState();
}

class _TimeClockScreenState extends ConsumerState<TimeClockScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('タイムクロック'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AETHER AI',
            onPressed: () => showAetherTrigger(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timer), text: 'タイマー'),
            Tab(icon: Icon(Icons.timer_outlined), text: 'ストップウォッチ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_TimerTab(), _StopwatchTab()],
      ),
    );
  }
}

// ============================================================================
// TIMER TAB
// ============================================================================

class _TimerTab extends ConsumerWidget {
  const _TimerTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final presets = ref.watch(timerPresetsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // プログレスリング
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: state.progress,
                  strokeWidth: 10,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                ),
                Center(
                  child: Text(_formatTimer(state.remaining), style: Theme.of(context).textTheme.displayMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // プリセット / カスタム（タイマーが停止中かつ未設定時のみ表示）
          if (!state.isRunning && state.remaining == state.duration) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ...presets.map((p) => FilledButton.tonal(onPressed: () => notifier.setDuration(p.duration), child: Text(p.label))),
                OutlinedButton(onPressed: () => _showTimePicker(context, notifier), child: const Text('カスタム')),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // コントロール
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.isRunning)
                ElevatedButton.icon(onPressed: notifier.pause, icon: const Icon(Icons.pause), label: const Text('一時停止'))
              else
                ElevatedButton.icon(
                  onPressed: state.remaining.inSeconds > 0 ? notifier.start : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('開始'),
                ),
              const SizedBox(width: 16),
              OutlinedButton.icon(onPressed: notifier.reset, icon: const Icon(Icons.refresh), label: const Text('リセット')),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimePicker(BuildContext context, TimerNotifier notifier) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 5),
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!);
      },
    );
    if (time != null) {
      notifier.setDuration(Duration(hours: time.hour, minutes: time.minute));
    }
  }

  String _formatTimer(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

// ============================================================================
// STOPWATCH TAB
// ============================================================================

class _StopwatchTab extends ConsumerWidget {
  const _StopwatchTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stopwatchProvider);
    final notifier = ref.read(stopwatchProvider.notifier);

    return Column(
      children: [
        // ディスプレイ
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              _formatStopwatch(state.elapsed),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),

        // コントロール
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ラップ/リセット
              SizedBox(
                width: 90,
                height: 90,
                child: ElevatedButton(
                  onPressed: state.isRunning ? notifier.lap : (state.elapsed > Duration.zero ? notifier.reset : null),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: FittedBox(child: Text(state.isRunning ? 'ラップ' : 'リセット', style: const TextStyle(fontSize: 13))),
                ),
              ),
              // スタート/ストップ
              SizedBox(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  onPressed: state.isRunning ? notifier.stop : notifier.start,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: state.isRunning ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                  ),
                  child: Icon(state.isRunning ? Icons.stop : Icons.play_arrow, size: 40),
                ),
              ),
              const SizedBox(width: 90, height: 90),
            ],
          ),
        ),

        // ラップリスト
        Expanded(
          flex: 2,
          child: state.laps.isEmpty
              ? Center(
                  child: Text('ラップタイムがありません', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: state.laps.length,
                  itemBuilder: (context, index) {
                    final lapNum = state.laps.length - index;
                    final lap = state.laps[state.laps.length - 1 - index];
                    final prev = index < state.laps.length - 1 ? state.laps[state.laps.length - 2 - index] : Duration.zero;
                    final diff = lap - prev;
                    return ListTile(
                      leading: Text('ラップ $lapNum', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                      title: Text(_formatStopwatch(lap), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                      trailing: Text('+${_formatStopwatch(diff)}', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _formatStopwatch(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final cs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$cs';
  }
}
