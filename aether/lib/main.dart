import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'core/data/storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive初期化
  await Hive.initFlutter();
  
  // Firebase初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ストレージサービス初期化（アダプター登録 + ボックスオープン）
  await StorageService.initialize();
  
  runApp(
    const ProviderScope(
      child: AetherApp(),
    ),
  );
}
