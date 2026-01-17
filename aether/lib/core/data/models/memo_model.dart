import 'package:hive/hive.dart';

part 'memo_model.g.dart';

/// メモのHiveモデル
@HiveType(typeId: 0)
class MemoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  bool isPinned;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  int sortOrder;

  @HiveField(8)
  String? folderId;

  MemoModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.tags = const [],
    this.sortOrder = 0,
    this.folderId,
  });

  /// コピーを作成
  MemoModel copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    bool? isPinned,
    List<String>? tags,
    int? sortOrder,
    String? folderId,
    bool clearFolder = false,
  }) {
    return MemoModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? List.from(this.tags),
      sortOrder: sortOrder ?? this.sortOrder,
      folderId: clearFolder ? null : (folderId ?? this.folderId),
    );
  }
}
