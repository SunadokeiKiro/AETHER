import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ストップウォッチの状態
class StopwatchState {
  final Duration elapsed;
  final bool isRunning;
  final List<Duration> laps;

  const StopwatchState({
    this.elapsed = Duration.zero,
    this.isRunning = false,
    this.laps = const [],
  });

  StopwatchState copyWith({
    Duration? elapsed,
    bool? isRunning,
    List<Duration>? laps,
  }) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      laps: laps ?? this.laps,
    );
  }
}

/// ストップウォッチを管理するProvider
final stopwatchProvider = StateNotifierProvider<StopwatchNotifier, StopwatchState>(
  (ref) => StopwatchNotifier(),
);

class StopwatchNotifier extends StateNotifier<StopwatchState> {
  StopwatchNotifier() : super(const StopwatchState());
  Timer? _timer;

  void start() {
    if (state.isRunning) return;
    
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      state = state.copyWith(
        elapsed: Duration(milliseconds: state.elapsed.inMilliseconds + 10),
      );
    });
  }

  void stop() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void lap() {
    if (!state.isRunning) return;
    state = state.copyWith(
      laps: [...state.laps, state.elapsed],
    );
  }

  void reset() {
    _timer?.cancel();
    state = const StopwatchState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// ストップウォッチ画面
class StopwatchScreen extends ConsumerWidget {
  const StopwatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stopwatchProvider);
    final notifier = ref.read(stopwatchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('ストップウォッチ'),
      ),
      body: Column(
        children: [
          // ディスプレイ
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                _formatDuration(state.elapsed),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          
          // コントロールボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // リセット / ラップボタン
                SizedBox(
                  width: 90,
                  height: 90,
                  child: ElevatedButton(
                    onPressed: state.isRunning
                        ? () => notifier.lap()
                        : state.elapsed > Duration.zero
                            ? () => notifier.reset()
                            : null,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      padding: const EdgeInsets.all(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        state.isRunning ? 'ラップ' : 'リセット',
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                
                // スタート / ストップボタン
                SizedBox(
                  width: 100,
                  height: 100,
                  child: ElevatedButton(
                    onPressed: state.isRunning
                        ? () => notifier.stop()
                        : () => notifier.start(),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: state.isRunning
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                    child: Icon(
                      state.isRunning ? Icons.stop : Icons.play_arrow,
                      size: 40,
                    ),
                  ),
                ),
                
                // 空のプレースホルダー
                const SizedBox(width: 80, height: 80),
              ],
            ),
          ),
          
          // ラップリスト
          Expanded(
            flex: 2,
            child: state.laps.isEmpty
                ? Center(
                    child: Text(
                      'ラップタイムがありません',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: state.laps.length,
                    itemBuilder: (context, index) {
                      final lapNumber = state.laps.length - index;
                      final lap = state.laps[state.laps.length - 1 - index];
                      final prevLap = index < state.laps.length - 1
                          ? state.laps[state.laps.length - 2 - index]
                          : Duration.zero;
                      final diff = lap - prevLap;
                      
                      return ListTile(
                        leading: Text(
                          'ラップ $lapNumber',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        title: Text(
                          _formatDuration(lap),
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        trailing: Text(
                          '+${_formatDuration(diff)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centiseconds = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }
}
