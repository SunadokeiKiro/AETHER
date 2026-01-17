import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage_service.dart';
import '../models/memo_model.dart';
import '../models/folder_model.dart';

/// メモとフォルダのRepository
class MemoRepository {
  Box<MemoModel> get _memosBox => StorageService.memosBox;
  Box<FolderModel> get _foldersBox => StorageService.foldersBox;

  // ============ メモ操作 ============

  /// 全メモを取得
  List<MemoModel> getAllMemos() {
    return _memosBox.values.toList();
  }

  /// IDでメモを取得
  MemoModel? getMemoById(String id) {
    return _memosBox.get(id);
  }

  /// メモを保存（新規作成または更新）
  Future<void> saveMemo(MemoModel memo) async {
    await _memosBox.put(memo.id, memo);
  }

  /// メモを削除
  Future<void> deleteMemo(String id) async {
    await _memosBox.delete(id);
  }

  /// 全メモを削除
  Future<void> deleteAllMemos() async {
    await _memosBox.clear();
  }

  /// メモの変更を監視
  ValueListenable<Box<MemoModel>> watchMemos() {
    return _memosBox.listenable();
  }

  // ============ フォルダ操作 ============

  /// 全フォルダを取得
  List<FolderModel> getAllFolders() {
    return _foldersBox.values.toList();
  }

  /// IDでフォルダを取得
  FolderModel? getFolderById(String id) {
    return _foldersBox.get(id);
  }

  /// フォルダを保存（新規作成または更新）
  Future<void> saveFolder(FolderModel folder) async {
    await _foldersBox.put(folder.id, folder);
  }

  /// フォルダを削除
  Future<void> deleteFolder(String id) async {
    await _foldersBox.delete(id);
  }

  /// 階層内のメモをルートに移動してフォルダを削除
  Future<void> deleteFolderAndMoveMemosToRoot(String folderId) async {
    // 対象フォルダ内のメモをルートに移動
    final memos = getAllMemos().where((m) => m.folderId == folderId);
    for (final memo in memos) {
      await saveMemo(memo.copyWith(folderId: null, clearFolder: true));
    }
    await deleteFolder(folderId);
  }

  /// フォルダの変更を監視
  ValueListenable<Box<FolderModel>> watchFolders() {
    return _foldersBox.listenable();
  }
}
