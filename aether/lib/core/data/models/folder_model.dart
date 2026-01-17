import 'package:hive/hive.dart';

part 'folder_model.g.dart';

/// フォルダのHiveモデル
@HiveType(typeId: 1)
class FolderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? parentId;

  @HiveField(3)
  int colorValue; // Color.valueで保存

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  int sortOrder;

  FolderModel({
    required this.id,
    required this.name,
    this.parentId,
    required this.colorValue,
    required this.createdAt,
    this.sortOrder = 0,
  });

  /// コピーを作成
  FolderModel copyWith({
    String? name,
    String? parentId,
    int? colorValue,
    int? sortOrder,
  }) {
    return FolderModel(
      id: id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
