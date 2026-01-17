import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/calculator/presentation/calculator_screen.dart';
import '../../features/memo/presentation/memo_list_screen.dart';
import '../../features/time_clock/presentation/time_clock_screen.dart';
import '../../features/alarm/presentation/alarm_screen.dart';
import '../../features/converter/presentation/converter_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

/// アプリルーターを提供するProvider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // ホーム画面
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      // 電卓
      GoRoute(
        path: '/calculator',
        name: 'calculator',
        builder: (context, state) => const CalculatorScreen(),
      ),
      // メモ
      GoRoute(
        path: '/memo',
        name: 'memo',
        builder: (context, state) => const MemoListScreen(),
      ),
      // タイムクロック（タイマー + ストップウォッチ）
      GoRoute(
        path: '/timeclock',
        name: 'timeclock',
        builder: (context, state) => const TimeClockScreen(),
      ),
      // アラーム
      GoRoute(
        path: '/alarm',
        name: 'alarm',
        builder: (context, state) => const AlarmScreen(),
      ),
      // 単位/通貨換算
      GoRoute(
        path: '/converter',
        name: 'converter',
        builder: (context, state) => const ConverterScreen(),
      ),
      // 設定
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});

