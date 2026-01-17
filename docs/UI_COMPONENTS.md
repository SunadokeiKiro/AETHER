# AETHER UIコンポーネントカタログ

## 概要

本ドキュメントはAETHERアプリで使用する共通UIコンポーネントを定義します。
全コンポーネントはDesign Tokensに従って動的にスタイリングされます。

---

## コンポーネント階層

```
Components/
├── Atoms/          # 最小単位
│   ├── Button
│   ├── Icon
│   ├── Text
│   └── Input
├── Molecules/      # Atomsの組み合わせ
│   ├── Card
│   ├── ListTile
│   ├── SearchBar
│   └── Chip
├── Organisms/      # 複雑なUI
│   ├── AppBar
│   ├── BottomSheet
│   ├── TimerDisplay
│   └── QuickActionGrid
└── Templates/      # ページレイアウト
    ├── StandardPage
    └── FullscreenPage
```

---

## Atoms（原子）

### 1. AetherButton

汎用ボタンコンポーネント。

```dart
AetherButton(
  label: "開始",
  variant: ButtonVariant.primary,  // primary, secondary, text, outlined
  size: ButtonSize.medium,         // small, medium, large
  icon: Icons.play_arrow,          // optional
  isLoading: false,
  onPressed: () {},
)
```

| プロパティ | 型 | 必須 | 説明 |
|------------|-----|------|------|
| `label` | String | ✓ | ボタンテキスト |
| `variant` | ButtonVariant | | スタイルバリアント |
| `size` | ButtonSize | | サイズ |
| `icon` | IconData | | 先頭アイコン |
| `isLoading` | bool | | ローディング状態 |
| `onPressed` | VoidCallback | ✓ | タップ時コールバック |

**バリアント一覧：**

| バリアント | 用途 |
|------------|------|
| `primary` | 主要アクション（塗りつぶし、プライマリ色） |
| `secondary` | 副次アクション（塗りつぶし、セカンダリ色） |
| `text` | テキストのみ（背景なし） |
| `outlined` | 枠線のみ（背景なし） |

---

### 2. AetherIcon

テーマ対応アイコン。

```dart
AetherIcon(
  icon: Icons.timer,
  size: IconSize.medium,
  color: null,  // null = on_surface color
)
```

---

### 3. AetherText

テーマ対応テキスト。

```dart
AetherText(
  "見出しテキスト",
  style: TextStyle.headline,  // display_large, headline, body, caption, code
  color: null,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

---

### 4. AetherInput

テキスト入力フィールド。

```dart
AetherInput(
  label: "メモタイトル",
  hint: "タイトルを入力",
  variant: InputVariant.outlined,  // outlined, filled, underlined
  prefixIcon: Icons.edit,
  suffixIcon: Icons.clear,
  errorText: null,
  onChanged: (value) {},
)
```

---

## Molecules（分子）

### 5. AetherCard

コンテンツカード。

```dart
AetherCard(
  child: Widget,
  variant: CardVariant.elevated,  // elevated, outlined, filled
  onTap: () {},
  padding: EdgeInsets.all(16),
)
```

---

### 6. AetherListTile

リストアイテム。

```dart
AetherListTile(
  leading: AetherIcon(Icons.alarm),
  title: "7:00 AM",
  subtitle: "毎日",
  trailing: Switch(value: true, onChanged: (_) {}),
  onTap: () {},
)
```

---

### 7. AetherSearchBar

検索バー。

```dart
AetherSearchBar(
  hint: "メモを検索",
  onSearch: (query) {},
  onClear: () {},
  showVoiceInput: true,
)
```

---

### 8. AetherChip

チップ/タグ。

```dart
AetherChip(
  label: "仕事",
  color: Colors.blue,
  isSelected: false,
  onTap: () {},
  onDelete: () {},  // null = 削除ボタンなし
)
```

---

## Organisms（有機体）

### 9. AetherAppBar

アプリバー。

```dart
AetherAppBar(
  title: "メモ",
  showBackButton: true,
  showHomeButton: true,
  actions: [
    IconButton(icon: Icons.search, onPressed: () {}),
  ],
)
```

---

### 10. AetherBottomSheet

ボトムシート（AI入力用）。

```dart
AetherBottomSheet(
  child: Widget,
  isDraggable: true,
  showHandle: true,
  initialHeight: 0.4,  // 画面の40%
  maxHeight: 0.9,
)
```

---

### 11. AetherTimerDisplay

タイマー表示専用。

```dart
AetherTimerDisplay(
  duration: Duration(minutes: 3, seconds: 45),
  status: TimerStatus.running,  // idle, running, paused, completed
  showProgress: true,
  onTap: () {},
)
```

**表示形式：**
- `mm:ss`（1時間未満）
- `hh:mm:ss`（1時間以上）
- プログレスリング（オプション）

---

### 12. QuickActionGrid

ホーム画面のワンタッチアクショングリッド。

```dart
QuickActionGrid(
  actions: List<QuickAction>,
  columns: 4,
  onActionTap: (action) {},
  onActionLongPress: (action) {},  // 編集モード
)
```

---

### 13. AetherTrigger

AI呼び出しフローティングボタン。

```dart
AetherTrigger(
  position: TriggerPosition.bottomRight,
  isExpanded: false,
  onTap: () {},
  onLongPress: () {},  // クイック入力
)
```

---

## Templates（テンプレート）

### 14. StandardPage

標準ページレイアウト。

```dart
StandardPage(
  appBar: AetherAppBar(...),
  body: Widget,
  floatingActionButton: Widget?,
  showAetherTrigger: true,
)
```

---

### 15. FullscreenPage

フルスクリーンレイアウト（タイマー画面など）。

```dart
FullscreenPage(
  body: Widget,
  showStatusBar: false,
  showAetherTrigger: true,
  backgroundColor: Colors.black,
)
```

---

## 状態表示ガイドライン

| 状態 | 視覚的表現 |
|------|------------|
| Default | 通常スタイル |
| Hover | 軽い背景色変化 |
| Pressed | スケールダウン + 色変化 |
| Disabled | 透明度50% + タップ無効 |
| Loading | スピナー表示 |
| Error | エラー色枠線 + エラーテキスト |
| Success | サクセス色 + チェックマーク |

---

## アクセシビリティ要件

| 要件 | 実装 |
|------|------|
| タップターゲット | 最小48x48dp |
| コントラスト比 | 4.5:1以上（WCAG AA） |
| フォーカス表示 | 枠線ハイライト |
| セマンティクス | Semanticsウィジェットでラベル付与 |
| スクリーンリーダー | 全コンポーネントに読み上げテキスト |
