# AETHER ナビゲーションマップ

## 概要

本ドキュメントはAETHERアプリの画面構成と遷移フローを定義します。

---

## 画面階層図

```mermaid
graph TB
    subgraph "AETHER Global Layer"
        GT[AETHER Trigger<br/>常駐フローティングボタン]
        AI[AI Chat Overlay]
    end
    
    subgraph "Adaptive Gateway"
        HOME[ホーム画面]
    end
    
    subgraph "Modular Tools"
        CALC[電卓]
        MEMO[メモ]
        TIMER[タイマー]
        CAL[カレンダー]
        ALARM[アラーム]
        SW[ストップウォッチ]
        CONV[単位/通貨換算]
        VR[ボイスレコーダー]
        FM[ファイルマネージャー]
        SCAN[スキャナー]
        WEATHER[天気/環境]
        NOTIF[通知]
        MEDIA[メディア]
        LAUNCH[アプリランチャー]
    end
    
    subgraph "Settings"
        SET[設定]
        THEME[テーマ設定]
        PREF[環境設定]
        PRIVACY[プライバシー]
    end
    
    GT -.-> AI
    HOME --> CALC & MEMO & TIMER & CAL
    HOME --> ALARM & SW & CONV & VR
    HOME --> FM & SCAN & WEATHER & NOTIF
    HOME --> MEDIA & LAUNCH
    HOME --> SET
    SET --> THEME & PREF & PRIVACY
    
    style GT fill:#f59e0b,stroke:#d97706,color:#fff
    style AI fill:#f59e0b,stroke:#d97706,color:#fff
    style HOME fill:#6366f1,stroke:#4338ca,color:#fff
```

---

## 画面一覧

| ID | 画面名 | 説明 | ルート |
|----|--------|------|--------|
| `home` | ホーム | アダプティブ・ゲートウェイ | `/` |
| `calculator` | 電卓 | 基本・関数計算 | `/calculator` |
| `memo` | メモ | メモ一覧・フォルダ管理・編集 | `/memo` |
| `memo_detail` | メモ詳細 | 単一メモ編集 | `/memo/:id` |
| `time_clock` | タイムクロック | タイマー・ストップウォッチ（タブ切替） | `/time-clock` |
| `calendar` | カレンダー | 月間・週間・日間表示 | `/calendar` |
| `calendar_event` | イベント詳細 | 予定の作成・編集 | `/calendar/event/:id` |
| `alarm` | アラーム | アラーム一覧・設定 | `/alarm` |
| `converter` | 換算 | 単位・通貨変換 | `/converter` |
| `voice_recorder` | ボイスレコーダー | 録音・再生 | `/voice` |
| `file_manager` | ファイル | ファイル管理 | `/files` |
| `scanner` | スキャナー | ドキュメントスキャン | `/scanner` |
| `weather` | 天気 | 天気・環境情報 | `/weather` |
| `notifications` | 通知 | 通知アグリゲーター | `/notifications` |
| `media_controller` | メディア | 再生コントロール | `/media` |
| `app_launcher` | ランチャー | 外部アプリ起動 | `/launcher` |
| `settings` | 設定 | アプリ設定・言語・テーマ | `/settings` |
| `theme_settings` | テーマ設定 | デザイン変更 | `/settings/theme` |
| `preferences` | 環境設定 | 動作設定 | `/settings/preferences` |
| `privacy` | プライバシー | データ・権限管理 | `/settings/privacy` |

---

## 遷移パターン

### 1. 標準遷移

```mermaid
sequenceDiagram
    participant H as ホーム
    participant M as モジュール
    participant D as 詳細画面
    
    H->>M: タップで遷移
    Note over M: スライドアップ
    M->>D: 項目タップ
    Note over D: スライドイン
    D-->>M: 戻るボタン
    M-->>H: 戻るボタン / ホームアクション
```

### 2. AIトリガー遷移

```mermaid
sequenceDiagram
    participant Any as 任意の画面
    participant AI as AIオーバーレイ
    participant Target as 遷移先
    
    Any->>AI: トリガータップ
    Note over AI: ボトムシート表示
    AI->>AI: ユーザー入力
    AI->>Target: AI指示による遷移
    Note over Target: フェード遷移
```

### 3. ディープリンク

```mermaid
sequenceDiagram
    participant Ext as 外部（通知等）
    participant App as AETHER
    participant Target as 対象画面
    
    Ext->>App: aether://timer?action=start&duration=180
    App->>Target: 直接遷移
    Note over Target: パラメータ適用
```

---

## ディープリンク設計

### URLスキーム

`aether://[screen]/[action]?[params]`

### 対応リンク一覧

| リンク | 動作 |
|--------|------|
| `aether://home` | ホームを開く |
| `aether://timer?action=start&duration=180` | 3分タイマー開始 |
| `aether://memo?action=create` | 新規メモ作成 |
| `aether://memo/abc123` | 特定メモを開く |
| `aether://alarm?action=create&time=07:00` | 7時アラーム作成 |
| `aether://calendar?date=2026-01-15` | 特定日を表示 |
| `aether://converter?from=USD&to=JPY&value=100` | 換算実行 |

---

## 状態管理

### グローバル状態

| 状態名 | 型 | 説明 |
|--------|-----|------|
| `currentUser` | User | ログインユーザー情報 |
| `themeConfig` | ThemeConfig | 適用中のテーマ |
| `geminiContext` | Map | AIに渡すコンテキスト |
| `activeTimers` | List | 実行中タイマー |
| `pendingTasks` | int | 未完了タスク数 |

### 画面ローカル状態

各画面は独自の状態を持ち、画面スタックから削除されると破棄される。

---

## ナビゲーションルール

| ルール | 説明 |
|--------|------|
| **一撃帰還** | どの深さからでもワンアクションでホームへ戻れる |
| **状態保持** | バックスタックにある画面の状態は保持される |
| **コンテキスト継承** | 遷移元画面のコンテキストをAIに渡せる |
| **アニメーション統一** | Design Tokensのtransitions設定に従う |

---

## アクセシビリティ対応

- フォーカス順序は論理的な読み順に従う
- 全てのインタラクティブ要素にセマンティックラベルを付与
- スクリーンリーダー使用時はモーダル遷移を明示的にアナウンス
