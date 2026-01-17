import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/data/data.dart';

// ============================================================================
// DOMAIN MODELS (UI層用)
// ============================================================================

/// フォルダモデル（UI層用）
class MemoFolder {
  final String id;
  final String name;
  final String? parentId;
  final Color color;
  final DateTime createdAt;
  final int sortOrder;

  MemoFolder({
    String? id,
    required this.name,
    this.parentId,
    this.color = Colors.blue,
    DateTime? createdAt,
    this.sortOrder = 0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  MemoFolder copyWith({String? name, String? parentId, Color? color, int? sortOrder}) {
    return MemoFolder(
      id: id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Hiveモデルから変換
  factory MemoFolder.fromModel(FolderModel model) {
    return MemoFolder(
      id: model.id,
      name: model.name,
      parentId: model.parentId,
      color: Color(model.colorValue),
      createdAt: model.createdAt,
      sortOrder: model.sortOrder,
    );
  }

  /// Hiveモデルへ変換
  FolderModel toModel() {
    return FolderModel(
      id: id,
      name: name,
      parentId: parentId,
      colorValue: color.value,
      createdAt: createdAt,
      sortOrder: sortOrder,
    );
  }
}

/// メモデータモデル（UI層用）
class Memo {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final List<String> tags;
  final int sortOrder;
  final String? folderId;

  Memo({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
    this.tags = const [],
    this.sortOrder = 0,
    this.folderId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Memo copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    bool? isPinned,
    List<String>? tags,
    int? sortOrder,
    String? folderId,
    bool clearFolder = false,
  }) {
    return Memo(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
    );
  }

  /// Hiveモデルから変換
  factory Memo.fromModel(MemoModel model) {
    return Memo(
      id: model.id,
      title: model.title,
      content: model.content,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isPinned: model.isPinned,
      tags: model.tags,
      sortOrder: model.sortOrder,
      folderId: model.folderId,
    );
  }

  /// Hiveモデルへ変換
  MemoModel toModel() {
    return MemoModel(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPinned: isPinned,
      tags: tags,
      sortOrder: sortOrder,
      folderId: folderId,
    );
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// MemoRepositoryのProvider
final memoRepositoryProvider = Provider<MemoRepository>((ref) => MemoRepository());

/// フォルダリストProvider（永続化対応）
final folderListProvider = StateNotifierProvider<FolderListNotifier, List<MemoFolder>>(
  (ref) => FolderListNotifier(ref.watch(memoRepositoryProvider)),
);

class FolderListNotifier extends StateNotifier<List<MemoFolder>> {
  final MemoRepository _repository;

  FolderListNotifier(this._repository) : super([]) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final models = _repository.getAllFolders();
    final folders = models.map((m) => MemoFolder.fromModel(m)).toList();
    folders.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = folders;
  }

  Future<void> add(MemoFolder folder) async {
    final maxOrder = state.isEmpty ? 0 : state.map((f) => f.sortOrder).reduce((a, b) => a > b ? a : b);
    final newFolder = folder.copyWith(sortOrder: maxOrder + 1);
    await _repository.saveFolder(newFolder.toModel());
    state = [...state, newFolder];
  }

  Future<void> update(MemoFolder folder) async {
    await _repository.saveFolder(folder.toModel());
    state = state.map((f) => f.id == folder.id ? folder : f).toList();
  }

  Future<void> delete(String id) async {
    await _repository.deleteFolder(id);
    state = state.where((f) => f.id != id).toList();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final folders = List<MemoFolder>.from(state);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = folders.removeAt(oldIndex);
    folders.insert(newIndex, item);
    for (var i = 0; i < folders.length; i++) {
      folders[i] = folders[i].copyWith(sortOrder: i);
      await _repository.saveFolder(folders[i].toModel());
    }
    state = folders;
  }
}

/// メモリストProvider（永続化対応）
final memoListProvider = StateNotifierProvider<MemoListNotifier, List<Memo>>(
  (ref) => MemoListNotifier(ref.watch(memoRepositoryProvider)),
);

class MemoListNotifier extends StateNotifier<List<Memo>> {
  final MemoRepository _repository;

  MemoListNotifier(this._repository) : super([]) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final models = _repository.getAllMemos();
    state = models.map((m) => Memo.fromModel(m)).toList();
  }

  Future<void> add(Memo memo) async {
    final maxOrder = state.isEmpty ? 0 : state.map((m) => m.sortOrder).reduce((a, b) => a > b ? a : b);
    final newMemo = memo.copyWith(sortOrder: maxOrder + 1);
    await _repository.saveMemo(newMemo.toModel());
    state = [...state, newMemo];
  }

  Future<void> update(Memo memo) async {
    await _repository.saveMemo(memo.toModel());
    state = state.map((m) => m.id == memo.id ? memo : m).toList();
  }

  Future<void> delete(String id) async {
    await _repository.deleteMemo(id);
    state = state.where((m) => m.id != id).toList();
  }

  Future<void> togglePin(String id) async {
    final memo = state.firstWhere((m) => m.id == id);
    final updated = memo.copyWith(isPinned: !memo.isPinned);
    await _repository.saveMemo(updated.toModel());
    state = state.map((m) => m.id == id ? updated : m).toList();
  }

  Future<void> moveToFolder(String memoId, String? folderId) async {
    final memo = state.firstWhere((m) => m.id == memoId);
    final updated = memo.copyWith(folderId: folderId, clearFolder: folderId == null);
    await _repository.saveMemo(updated.toModel());
    state = state.map((m) => m.id == memoId ? updated : m).toList();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final memos = List<Memo>.from(state);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = memos.removeAt(oldIndex);
    memos.insert(newIndex, item);
    for (var i = 0; i < memos.length; i++) {
      memos[i] = memos[i].copyWith(sortOrder: i);
      await _repository.saveMemo(memos[i].toModel());
    }
    state = memos;
  }
}

/// 現在のフォルダID
final currentFolderProvider = StateProvider<String?>((ref) => null);

/// 検索クエリ
final memoSearchQueryProvider = StateProvider<String>((ref) => '');

/// フィルタリング・ソートされたメモリスト
final filteredMemosProvider = Provider<List<Memo>>((ref) {
  final memos = ref.watch(memoListProvider);
  final query = ref.watch(memoSearchQueryProvider);
  final currentFolder = ref.watch(currentFolderProvider);

  var filtered = memos.where((m) => m.folderId == currentFolder).toList();

  if (query.isNotEmpty) {
    filtered = filtered.where((m) {
      return m.title.toLowerCase().contains(query.toLowerCase()) ||
          m.content.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  filtered.sort((a, b) {
    if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
    return a.sortOrder.compareTo(b.sortOrder);
  });

  return filtered;
});

/// 現在のフォルダ内のサブフォルダ
final subFoldersProvider = Provider<List<MemoFolder>>((ref) {
  final folders = ref.watch(folderListProvider);
  final currentFolder = ref.watch(currentFolderProvider);
  return folders.where((f) => f.parentId == currentFolder).toList();
});
