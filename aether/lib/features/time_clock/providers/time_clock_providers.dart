import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/data.dart';

// ============================================================================
// DOMAIN MODEL (UI層用)
// ============================================================================

/// タイマープリセットモデル（UI層用）
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

  /// Hiveモデルから変換
  factory TimerPreset.fromModel(TimerPresetModel model) {
    return TimerPreset(
      id: model.id,
      label: model.label,
      duration: Duration(seconds: model.durationSeconds),
      isBuiltIn: model.isBuiltIn,
    );
  }

  /// Hiveモデルへ変換
  TimerPresetModel toModel() {
    return TimerPresetModel(
      id: id,
      label: label,
      durationSeconds: duration.inSeconds,
      isBuiltIn: isBuiltIn,
    );
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// タイムクロック画面のタブインデックス（0=タイマー, 1=ストップウォッチ）
final timeClockTabProvider = StateProvider<int>((ref) => 0);

/// TimerPresetRepositoryのProvider
final timerPresetRepositoryProvider = Provider<TimerPresetRepository>((ref) => TimerPresetRepository());

/// タイマープリセットProvider（永続化対応）
final timerPresetsProvider = StateNotifierProvider<TimerPresetsNotifier, List<TimerPreset>>(
  (ref) => TimerPresetsNotifier(ref.watch(timerPresetRepositoryProvider)),
);

class TimerPresetsNotifier extends StateNotifier<List<TimerPreset>> {
  final TimerPresetRepository _repository;

  TimerPresetsNotifier(this._repository) : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _repository.initializeDefaults();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final models = _repository.getAll();
    final presets = models.map((m) => TimerPreset.fromModel(m)).toList();
    // 時間順（短い順）にソート
    presets.sort((a, b) => a.duration.compareTo(b.duration));
    state = presets;
  }

  Future<void> add(TimerPreset preset) async {
    await _repository.save(preset.toModel());
    state = [...state, preset];
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    state = state.where((p) => p.id != id).toList();
  }
}

// ============================================================================
// TIMER STATE & NOTIFIER
// ============================================================================

class TimerState {
  final Duration duration;
  final Duration remaining;
  final bool isRunning;

  const TimerState({
    this.duration = Duration.zero,
    this.remaining = Duration.zero,
    this.isRunning = false,
  });

  TimerState copyWith({
    Duration? duration,
    Duration? remaining,
    bool? isRunning,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  /// タイマー進捗率を返す（0.0～1.0）
  double get progress => duration.inSeconds > 0 ? remaining.inSeconds / duration.inSeconds : 0;
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) => TimerNotifier());

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;

  TimerNotifier() : super(const TimerState());

  void setDuration(Duration duration) {
    _timer?.cancel();
    state = TimerState(duration: duration, remaining: duration);
  }

  void start() {
    if (state.remaining <= Duration.zero) return;
    _timer?.cancel();
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remaining <= const Duration(seconds: 1)) {
        _timer?.cancel();
        state = state.copyWith(remaining: Duration.zero, isRunning: false);
      } else {
        state = state.copyWith(remaining: state.remaining - const Duration(seconds: 1));
      }
    });
  }



  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void stop() {
    _timer?.cancel();
    state = const TimerState();
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(remaining: state.duration, isRunning: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ============================================================================
// STOPWATCH STATE & NOTIFIER
// ============================================================================

class StopwatchState {
  final Duration elapsed;
  final bool isRunning;
  final List<Duration> laps;

  const StopwatchState({
    this.elapsed = Duration.zero,
    this.isRunning = false,
    this.laps = const [],
  });

  StopwatchState copyWith({Duration? elapsed, bool? isRunning, List<Duration>? laps}) {
    return StopwatchState(
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
      laps: laps ?? this.laps,
    );
  }
}

final stopwatchProvider = StateNotifierProvider<StopwatchNotifier, StopwatchState>((ref) => StopwatchNotifier());

class StopwatchNotifier extends StateNotifier<StopwatchState> {
  Timer? _timer;

  StopwatchNotifier() : super(const StopwatchState());

  void start() {
    _timer?.cancel();
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      state = state.copyWith(elapsed: state.elapsed + const Duration(milliseconds: 10));
    });
  }

  void stop() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void lap() {
    state = state.copyWith(laps: [...state.laps, state.elapsed]);
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
