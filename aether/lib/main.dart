import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/data/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive初期化
  await Hive.initFlutter();
  
  // ストレージサービス初期化（アダプター登録 + ボックスオープン）
  await StorageService.initialize();
  
  runApp(
    const ProviderScope(
      child: AetherApp(),
    ),
  );
}
