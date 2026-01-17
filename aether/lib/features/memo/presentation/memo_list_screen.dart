import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../providers/memo_providers.dart';

// MemoとMemoFolderはmemo_providers.dartからエクスポートされる

// ============================================================================
// MEMO LIST SCREEN
// ============================================================================

class MemoListScreen extends ConsumerWidget {
  const MemoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(filteredMemosProvider);
    final folders = ref.watch(subFoldersProvider);
    final currentFolderId = ref.watch(currentFolderProvider);
    final allFolders = ref.watch(folderListProvider);
    final isSearching = ref.watch(memoSearchQueryProvider).isNotEmpty;

    // 現在のフォルダ名を取得
    String? currentFolderName;
    if (currentFolderId != null) {
      final folder = allFolders.where((f) => f.id == currentFolderId).firstOrNull;
      currentFolderName = folder?.name;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (currentFolderId != null) {
              // 親フォルダに戻る
              final currentFolder = allFolders.where((f) => f.id == currentFolderId).firstOrNull;
              ref.read(currentFolderProvider.notifier).state = currentFolder?.parentId;
            } else {
              context.pop();
            }
          },
        ),
        title: Text(currentFolderName ?? 'メモ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AETHER AI',
            onPressed: () => _showAetherAI(context),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            onPressed: () => _showFolderDialog(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'メモを検索',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(memoSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          
          // フォルダ一覧（ドラッグ並び替え対応）
          if (folders.isNotEmpty && !isSearching)
            SizedBox(
              height: 80,
              child: ReorderableListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: folders.length,
                onReorder: (oldIndex, newIndex) => ref.read(folderListProvider.notifier).reorder(oldIndex, newIndex),
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 4,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return ReorderableDragStartListener(
                    key: ValueKey(folder.id),
                    index: index,
                    child: _FolderChip(
                      folder: folder,
                      onTap: () {
                        ref.read(currentFolderProvider.notifier).state = folder.id;
                      },
                      onLongPress: () => _showFolderDialog(context, ref, folder),
                    ),
                  );
                },
              ),
            ),
          
          // メモリスト
          Expanded(
            child: (memos.isEmpty && folders.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('メモがありません', style: TextStyle(color: Theme.of(context).colorScheme.outline)),
                      ],
                    ),
                  )
                : isSearching
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: memos.length,
                        itemBuilder: (context, index) => _MemoCard(memo: memos[index], onTap: () => _showMemoDetail(context, ref, memos[index])),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: memos.length,
                        onReorder: (oldIndex, newIndex) => ref.read(memoListProvider.notifier).reorder(oldIndex, newIndex),
                        itemBuilder: (context, index) {
                          final memo = memos[index];
                          return _MemoCard(key: ValueKey(memo.id), memo: memo, onTap: () => _showMemoDetail(context, ref, memo));
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMemoEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showMemoDetail(BuildContext context, WidgetRef ref, Memo memo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _MemoDetailSheet(memo: memo),
    );
  }

  void _showMemoEditor(BuildContext context, WidgetRef ref, [Memo? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _MemoEditorSheet(existingMemo: existing),
    );
  }

  void _showAetherAI(BuildContext context) {
    showAetherTrigger(context);
  }

  void _showFolderDialog(BuildContext context, WidgetRef ref, [MemoFolder? existing]) {
    final controller = TextEditingController(text: existing?.name ?? '');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                existing != null ? 'フォルダを編集' : '新しいフォルダ',
                style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface),
              ),
            ),
            if (existing != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Theme.of(dialogContext).colorScheme.error),
                tooltip: 'フォルダを削除',
                onPressed: () => _showDeleteFolderOptions(dialogContext, ref, existing),
              ),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'フォルダ名',
            labelStyle: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurfaceVariant),
          ),
          style: TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('キャンセル')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final currentFolderId = ref.read(currentFolderProvider);
                if (existing != null) {
                  ref.read(folderListProvider.notifier).update(existing.copyWith(name: controller.text));
                } else {
                  ref.read(folderListProvider.notifier).add(MemoFolder(name: controller.text, parentId: currentFolderId));
                }
                Navigator.pop(dialogContext);
              }
            },
            child: Text(existing != null ? '保存' : '作成'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFolderOptions(BuildContext context, WidgetRef ref, MemoFolder folder) {
    final allFolders = ref.read(folderListProvider);
    final allMemos = ref.read(memoListProvider);
    
    // 下層フォルダのIDを再帰的に取得
    Set<String> getDescendantFolderIds(String folderId) {
      final ids = <String>{folderId};
      for (final f in allFolders.where((f) => f.parentId == folderId)) {
        ids.addAll(getDescendantFolderIds(f.id));
      }
      return ids;
    }
    
    final folderIds = getDescendantFolderIds(folder.id);
    final affectedMemos = allMemos.where((m) => folderIds.contains(m.folderId)).toList();
    final memoCount = affectedMemos.length;
    final subFolderCount = folderIds.length - 1; // 自身を除く
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('「${folder.name}」を削除', style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (memoCount > 0 || subFolderCount > 0) ...[
              Text(
                memoCount > 0 && subFolderCount > 0
                    ? 'このフォルダには $subFolderCount 個のサブフォルダと $memoCount 件のメモがあります。'
                    : memoCount > 0
                        ? 'このフォルダには $memoCount 件のメモがあります。'
                        : 'このフォルダには $subFolderCount 個のサブフォルダがあります。',
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text(
                'どのように処理しますか？',
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
              ),
            ] else
              Text(
                'このフォルダを削除してもよろしいですか？',
                style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          if (memoCount > 0)
            TextButton(
              onPressed: () {
                // メモを「メモ一覧」に移動してフォルダを削除
                for (final memo in affectedMemos) {
                  ref.read(memoListProvider.notifier).moveToFolder(memo.id, null);
                }
                // 下層フォルダも削除
                for (final id in folderIds) {
                  ref.read(folderListProvider.notifier).delete(id);
                }
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$memoCount 件のメモを「メモ一覧」に移動しました')),
                );
              },
              child: const Text('メモを「メモ一覧」に移動'),
            ),
          TextButton(
            onPressed: () {
              // メモも一緒に削除
              for (final memo in affectedMemos) {
                ref.read(memoListProvider.notifier).delete(memo.id);
              }
              // 下層フォルダも削除
              for (final id in folderIds) {
                ref.read(folderListProvider.notifier).delete(id);
              }
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(memoCount > 0 ? 'すべて削除' : '削除'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FOLDER CHIP
// ============================================================================

class _FolderChip extends StatelessWidget {
  final MemoFolder folder;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FolderChip({required this.folder, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder, color: folder.color, size: 28),
              const SizedBox(height: 4),
              Text(
                folder.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MEMO DETAIL SHEET
// ============================================================================

class _MemoDetailSheet extends ConsumerWidget {
  final Memo memo;
  const _MemoDetailSheet({required this.memo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memos = ref.watch(memoListProvider);
    final currentMemo = memos.firstWhere((m) => m.id == memo.id, orElse: () => memo);
    final folders = ref.watch(folderListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  Row(
                    children: [
                      // フォルダ移動
                      IconButton(
                        icon: const Icon(Icons.folder_open),
                        onPressed: () => _showMoveToFolderDialog(context, ref, currentMemo, folders),
                      ),
                      IconButton(
                        icon: Icon(currentMemo.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            color: currentMemo.isPinned ? Theme.of(context).colorScheme.primary : null),
                        onPressed: () => ref.read(memoListProvider.notifier).togglePin(currentMemo.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pop(context);
                          showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
                              builder: (ctx) => _MemoEditorSheet(existingMemo: currentMemo));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('メモを削除'),
                              content: const Text('このメモを削除してもよろしいですか？'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                  child: const Text('削除'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            ref.read(memoListProvider.notifier).delete(currentMemo.id);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(currentMemo.title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '作成: ${_formatDate(currentMemo.createdAt)}  更新: ${_formatDate(currentMemo.updatedAt)}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(currentMemo.content.isEmpty ? '（内容なし）' : currentMemo.content, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoveToFolderDialog(BuildContext context, WidgetRef ref, Memo memo, List<MemoFolder> folders) {
    // フォルダのパスを構築するヘルパー関数
    String getFolderPath(MemoFolder folder) {
      final parts = <String>[folder.name];
      String? parentId = folder.parentId;
      while (parentId != null) {
        final parent = folders.where((f) => f.id == parentId).firstOrNull;
        if (parent != null) {
          parts.insert(0, parent.name);
          parentId = parent.parentId;
        } else {
          break;
        }
      }
      return parts.join(' / ');
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '移動先を選択',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(
                  'メモ一覧',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                ),
                subtitle: Text(
                  'フォルダに入れない',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
                ),
                selected: memo.folderId == null,
                onTap: () {
                  ref.read(memoListProvider.notifier).moveToFolder(memo.id, null);
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              ...folders.map((f) => ListTile(
                leading: Icon(Icons.folder, color: f.color),
                title: Text(
                  f.name,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                ),
                subtitle: f.parentId != null
                    ? Text(
                        getFolderPath(f),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(ctx).colorScheme.outline,
                        ),
                      )
                    : null,
                selected: memo.folderId == f.id,
                onTap: () {
                  ref.read(memoListProvider.notifier).moveToFolder(memo.id, f.id);
                  Navigator.pop(ctx);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// MEMO EDITOR SHEET
// ============================================================================

class _MemoEditorSheet extends ConsumerStatefulWidget {
  final Memo? existingMemo;
  const _MemoEditorSheet({this.existingMemo});

  @override
  ConsumerState<_MemoEditorSheet> createState() => _MemoEditorSheetState();
}

class _MemoEditorSheetState extends ConsumerState<_MemoEditorSheet> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingMemo?.title ?? '');
    _contentController = TextEditingController(text: widget.existingMemo?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingMemo != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
                  Text(
                    isEditing ? 'メモを編集' : '新規メモ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  TextButton(onPressed: _save, child: Text(isEditing ? '保存' : '作成')),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'タイトル',
                  hintStyle: TextStyle(color: theme.colorScheme.outline),
                  border: InputBorder.none,
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: '内容を入力...',
                    hintStyle: TextStyle(color: theme.colorScheme.outline),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    final title = _titleController.text.isEmpty ? '無題' : _titleController.text;
    final content = _contentController.text;
    final currentFolderId = ref.read(currentFolderProvider);

    if (widget.existingMemo != null) {
      ref.read(memoListProvider.notifier).update(widget.existingMemo!.copyWith(title: title, content: content));
    } else {
      ref.read(memoListProvider.notifier).add(Memo(title: title, content: content, folderId: currentFolderId));
    }
    Navigator.pop(context);
  }
}

// ============================================================================
// MEMO CARD
// ============================================================================

class _MemoCard extends ConsumerWidget {
  final Memo memo;
  final VoidCallback onTap;

  const _MemoCard({super.key, required this.memo, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineCount = '\n'.allMatches(memo.content).length + 1;
    final hasMoreContent = lineCount > 2 || memo.content.length > 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: memo.isPinned 
          ? Icon(Icons.push_pin, color: Theme.of(context).colorScheme.primary) 
          : const Icon(Icons.note_outlined),
        title: Text(memo.title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: memo.isPinned ? FontWeight.w600 : FontWeight.normal, color: Theme.of(context).colorScheme.onSurface)),
        subtitle: memo.content.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memo.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                if (hasMoreContent) Text('…もっと見る', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
              ],
            )
          : null,
        trailing: const Icon(Icons.drag_handle),
        onTap: onTap,
      ),
    );
  }
}
