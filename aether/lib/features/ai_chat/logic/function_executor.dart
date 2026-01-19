import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aether/core/theme/theme_provider.dart';
import 'package:aether/features/alarm/providers/alarm_providers.dart';
import 'package:aether/features/memo/providers/memo_providers.dart';
import 'package:aether/features/time_clock/providers/time_clock_providers.dart';

final functionExecutorProvider = Provider<FunctionExecutor>((ref) {
  return FunctionExecutor(ref);
});

class FunctionExecutor {
  final Ref _ref;

  FunctionExecutor(this._ref);


  /// アクション実行のタイムアウト時間
  static const Duration _actionTimeout = Duration(seconds: 10);

  /// アクションを実行し、完了を待つ（タイムアウト付き）
  Future<void> execute(BuildContext context, String action, Map<String, dynamic> params) async {
    debugPrint('FunctionExecutor: executing $action with $params');
    
    try {
      await Future.any([
        _executeAction(context, action, params),
        Future.delayed(_actionTimeout).then((_) {
          throw TimeoutException('Action timed out: $action');
        }),
      ]);
    } on TimeoutException catch (e) {
      debugPrint('FunctionExecutor: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('操作がタイムアウトしました')),
        );
      }
    } catch (e) {
      debugPrint('FunctionExecutor error: $e');
      rethrow;
    }
  }

  Future<void> _executeAction(BuildContext context, String action, Map<String, dynamic> params) async {
    switch (action) {
      case 'theme_change':
        await _handleThemeChange(context, params);
        break;
      case 'navigate':
        await _handleNavigate(context, params);
        break;
      case 'timer_control':
        await _handleTimerControl(context, params);
        break;
      case 'alarm_control':
        await _handleAlarmControl(context, params);
        break;
      case 'memo_control':
        await _handleMemoControl(context, params);
        break;
      default:
        debugPrint('Unknown action: $action');
    }
  }

  Future<void> _handleTimerControl(BuildContext context, Map<String, dynamic> params) async {
    final actionType = params['action_type'] as String?; // start, pause, etc.
    final durationSeconds = params['duration_seconds'] as int?;
    final timerType = params['timer_type'] as String?; // countdown, stopwatch, pomodoro

    if (actionType == null) return;

    // timer_typeに応じてタブを切り替え
    if (timerType == 'stopwatch') {
      _ref.read(timeClockTabProvider.notifier).state = 1; // ストップウォッチタブ
    } else {
      _ref.read(timeClockTabProvider.notifier).state = 0; // タイマータブ
    }

    final notifier = _ref.read(timerProvider.notifier);

    // 先にタイマーを設定・開始
    switch (actionType) {
      case 'start':
        if (durationSeconds != null && durationSeconds > 0) {
          notifier.setDuration(Duration(seconds: durationSeconds));
        }
        notifier.start();
        break;
      case 'pause':
        notifier.pause();
        break;
      case 'resume':
        notifier.start();
        break;
      case 'stop':
        notifier.stop();
        break;
      case 'reset':
        notifier.reset();
        break;
    }

    // タイマー操作後に画面遷移（ユーザーが確認できるようにする）
    // pushはawaitしない（画面がポップされるまで待たない）
    if (context.mounted) {
      context.push('/timeclock');
    }
  }

  Future<void> _handleAlarmControl(BuildContext context, Map<String, dynamic> params) async {
    final subAction = params['sub_action'] as String?;
    final alarmNotifier = _ref.read(alarmListProvider.notifier);
    final alarms = _ref.read(alarmListProvider);

    switch (subAction) {
      case 'create':
        final timeStr = params['time'] as String?; // "HH:MM"
        final label = params['label'] as String? ?? 'AI設定アラーム';
        
        if (timeStr != null) {
          final parts = timeStr.split(':');
          if (parts.length == 2) {
            final hour = int.tryParse(parts[0]);
            final minute = int.tryParse(parts[1]);
            if (hour != null && minute != null) {
              final time = TimeOfDay(hour: hour, minute: minute);
              await alarmNotifier.add(
                Alarm(time: time, label: label, isEnabled: true)
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('アラームを設定しました: $timeStr')),
                );
              }
            }
          }
        }
        break;

      case 'toggle':
        final timeStr = params['time'] as String?;
        if (timeStr != null) {
          final targetAlarm = _findAlarmByTime(alarms, timeStr);
          if (targetAlarm != null) {
            await alarmNotifier.toggle(targetAlarm.id);
            if (context.mounted) {
              final status = !targetAlarm.isEnabled ? 'オン' : 'オフ';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('アラームを$statusにしました: $timeStr')),
              );
            }
          }
        }
        break;

      case 'delete':
        final timeStr = params['time'] as String?;
        final label = params['label'] as String?;
        Alarm? targetAlarm;
        
        if (timeStr != null) {
          targetAlarm = _findAlarmByTime(alarms, timeStr);
        } else if (label != null) {
          targetAlarm = alarms.cast<Alarm?>().firstWhere(
            (a) => a?.label.toLowerCase().contains(label.toLowerCase()) ?? false,
            orElse: () => null,
          );
        }
        
        if (targetAlarm != null) {
          await alarmNotifier.delete(targetAlarm.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('アラームを削除しました: ${targetAlarm.formattedTime}')),
            );
          }
        }
        break;
    }
  }

  /// 時刻文字列からアラームを検索
  Alarm? _findAlarmByTime(List<Alarm> alarms, String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    
    return alarms.cast<Alarm?>().firstWhere(
      (a) => a?.time.hour == hour && a?.time.minute == minute,
      orElse: () => null,
    );
  }

  Future<void> _handleMemoControl(BuildContext context, Map<String, dynamic> params) async {
    final subAction = params['sub_action'] as String?;

    switch (subAction) {
      case 'create':
        final title = params['title'] as String? ?? '無題';
        final content = params['content'] as String? ?? '';
        await _ref.read(memoListProvider.notifier).add(
          Memo(title: title, content: content)
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('メモを作成しました')),
          );
        }
        break;

      case 'search':
        final query = params['search_query'] as String?;
        if (query != null) {
          _ref.read(memoSearchQueryProvider.notifier).state = query;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('「$query」を検索しました')),
            );
          }
        }
        break;

      case 'delete':
        final title = params['title'] as String?;
        if (title != null) {
          final memos = _ref.read(memoListProvider);
          final targetMemo = memos.cast<Memo?>().firstWhere(
            (m) => m?.title.toLowerCase().contains(title.toLowerCase()) ?? false,
            orElse: () => null,
          );
          if (targetMemo != null) {
            await _ref.read(memoListProvider.notifier).delete(targetMemo.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('メモを削除しました: ${targetMemo.title}')),
              );
            }
          }
        }
        break;
    }
  }

  Future<void> _handleThemeChange(BuildContext context, Map<String, dynamic> params) async {
    final preset = params['preset'] as String?;
    if (preset != null) {
      final notifier = _ref.read(designTokensProvider.notifier);
      await notifier.setPreset(preset);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('テーマを「$preset」に変更しました')),
        );
      }
    }
  }

  Future<void> _handleNavigate(BuildContext context, Map<String, dynamic> params) async {
    final destination = params['destination'] as String?;
    if (destination == null) return;

    // 画面遷移ロジック（正確なルートパスにマッピング）
    final path = switch (destination) {
      'home' => '/',
      'settings' => '/settings',
      'timer' => '/timeclock',
      'timeclock' => '/timeclock',
      'stopwatch' => '/timeclock',
      'alarm' => '/alarm',
      'memo' => '/memo',
      'calculator' => '/calculator',
      'converter' => '/converter',
      'calendar' => '/timeclock', // カレンダーは未実装のためタイムクロックへ
      _ => '/',
    };

    if (context.mounted) {
      await context.push(path);
    }
  }
}
