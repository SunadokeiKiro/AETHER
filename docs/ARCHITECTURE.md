# AETHER システムアーキテクチャ

## 概要

本ドキュメントはAETHERのフロントエンド・バックエンド構成と、ローカル・ファースト設計思想を定義します。

---

## アーキテクチャ概観

```mermaid
graph TB
    subgraph "Frontend (Android App)"
        UI[UIエンジン<br/>Generative UI]
        NAV[グローバル・ナビゲーション<br/>AETHER Trigger]
        LOCAL[ローカル・ビジネスロジック<br/>電卓・タイマー等]
        SDK[Google AI SDK]
        DB[(ローカルDB<br/>Room/Realm)]
    end
    
    subgraph "Backend (Cloud)"
        AUTH[認証・認可<br/>Firebase Auth]
        BILLING[決済管理<br/>Play Billing検証]
        GATEWAY[API Gateway<br/>& プロキシ]
        SYNC[データ同期<br/>Cloud Sync]
        ORCH[AIオーケストレーション]
    end
    
    subgraph "External APIs"
        GEMINI[Google Gemini API]
        GCAL[Google Calendar API]
        WEATHER[Weather API]
    end
    
    UI --> LOCAL
    UI --> SDK
    NAV --> UI
    LOCAL --> DB
    SDK --> GATEWAY
    GATEWAY --> GEMINI
    GATEWAY --> ORCH
    AUTH --> BILLING
    DB --> SYNC
    UI --> GCAL
    UI --> WEATHER
    
    style UI fill:#6366f1,stroke:#4338ca,color:#fff
    style GATEWAY fill:#f59e0b,stroke:#d97706,color:#fff
    style GEMINI fill:#22c55e,stroke:#16a34a,color:#fff
```

---

## 1. フロントエンド（Client-side / Android App）

フロントエンドの主責務は**「ユーザー体験の提示」と「ローカルでの機能実行」、そして「AI指示の可視化」**です。

### 構成要素

| コンポーネント | 責務 |
|---------------|------|
| **UI/UX エンジン (Generative UI)** | Geminiから受け取ったDesign Tokens（JSON）を解析し、アプリ全体のテーマをリアルタイムに書き換え |
| **ローカル・ビジネスロジック** | 電卓の計算処理、タイマーのカウントダウン、ボイスレコーダーの制御。Android OS標準機能連携 |
| **グローバル・ナビゲーション** | AETHER Trigger（常駐UI）の描画と、画面間のシームレスな遷移管理 |
| **AI SDK 連携** | Google AI SDK for Android を介した Gemini との通信 |
| **ローカル・パーシスタンス** | ユーザーのメモデータ、設定、カスタムテーマのキャッシュ保存（Room / Realm） |

---

## 2. バックエンド（Server-side / Cloud）

バックエンドの主責務は**「ビジネスロジックの秘匿」、「セキュリティ」、および「データの永続化と同期」**です。

### 構成要素

| コンポーネント | 責務 |
|---------------|------|
| **認証・認可 (Auth)** | ユーザーアカウントの管理（Firebase Auth等） |
| **決済・サブスクリプション管理** | Google Play Billing からの領収書検証、ユーザーの課金ステータス（Free/Premium）判定と機能解放 |
| **API Gateway & プロキシ** | APIキー漏洩防止のため、Geminiへのリクエストをバックエンド経由に。ユーザーごとのトークン使用量カウントとクォータ管理 |
| **データ同期 (Cloud Sync)** | 複数デバイス間でのメモデータやカスタムテーマの同期 |
| **AI オーケストレーション** | 複雑なプロンプト管理（システムプロンプト更新）、Gemini Pro / Flash の動的ルーティング |

---

## 3. フロント・バックのデータフロー

```mermaid
sequenceDiagram
    participant User as ユーザー (Frontend)
    participant UI as UIエンジン (Frontend)
    participant BE as バックエンド (Cloud)
    participant Gemini as Google Gemini API

    User->>UI: 「目に優しいデザインにして」
    UI->>BE: 指示送信 (課金ステータス確認含む)
    BE->>BE: トークン使用量チェック
    BE->>Gemini: UI生成用プロンプト送信
    Gemini-->>BE: Design Tokens (JSON)
    BE-->>UI: トークン配信 + 使用量記録
    UI->>UI: アプリ全体のデザインを再描画
    UI-->>User: 新しいUIを表示
```

---

## 4. ローカル・ファースト設計

ビジネス上の機密性（メモ内容の保護）とレスポンス速度を両立するため、**「ローカル・ファースト（Local-first）」**の設計を採用します。

### 設計原則

| 原則 | 説明 |
|------|------|
| **処理の優先順位** | 基本的な機能（計算やタイマー）は全てフロントエンドで完結させ、ネットワークがオフラインでも動作可能に |
| **プライバシー保護** | ユーザーのメモや音声データは原則ローカルに保存、明示的な同意なしにクラウドへ送信しない |
| **レスポンス速度** | 頻繁に使う機能はネットワーク遅延の影響を受けないローカル処理を優先 |

### AI処理の役割分担

| 処理場所 | 担当する処理 |
|----------|-------------|
| **フロントエンド** | UIの即時反映、シンプルな指示の解釈、オフライン時の基本機能 |
| **バックエンド** | 複雑なデータ解析（AIディレクター）、セキュアな決済処理、大規模なデータバックアップ |

---

## 5. セキュリティ設計

### APIキー保護

```mermaid
sequenceDiagram
    participant App as Android App
    participant BE as バックエンド
    participant Gemini as Gemini API

    Note over App: APIキーを持たない
    App->>BE: ユーザートークン + リクエスト
    BE->>BE: 認証検証
    BE->>BE: クォータ確認
    BE->>Gemini: APIキー付きリクエスト
    Gemini-->>BE: レスポンス
    BE-->>App: 処理結果
```

### セキュリティ対策一覧

| 対策 | 実装 |
|------|------|
| **APIキー秘匿** | フロントエンドにAPIキーを埋め込まない。バックエンド経由でのみAPI呼び出し |
| **トークン認証** | Firebase Auth トークンによるリクエスト認証 |
| **領収書検証** | Google Play RTDN によるサーバーサイドでの購入検証 |
| **データ暗号化** | ローカルDBの暗号化、通信のTLS必須化 |
| **クォータ管理** | ユーザーごとのAPI使用量制限で不正利用防止 |

---

## 6. 技術スタック詳細

| カテゴリ | 技術 | 備考 |
|----------|------|------|
| **モバイルフレームワーク** | Flutter | クロスプラットフォーム対応 |
| **ローカルDB** | Room / Realm | 高速なローカルデータ永続化 |
| **認証** | Firebase Auth | Google/メール認証 |
| **バックエンド** | Firebase Functions | サーバーレスアーキテクチャ |
| **AI API** | Google Gemini 1.5 | Pro/Flashの使い分け |
| **決済** | Google Play Billing v6.0+ | サブスクリプション管理 |
| **分析** | Firebase Analytics | ユーザー行動分析 |

---

## 関連ドキュメント

| ドキュメント | 説明 |
|--------------|------|
| [MONETIZATION.md](./MONETIZATION.md) | マネタイズ戦略 |
| [AETHER_SPECIFICATION.md](./AETHER_SPECIFICATION.md) | プロダクト仕様書 |
| [GEMINI_FUNCTION_CALLING.md](./GEMINI_FUNCTION_CALLING.md) | AI連携仕様 |
| [DATA_MODEL.md](./DATA_MODEL.md) | データベース設計 |
