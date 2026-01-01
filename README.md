# MatchMon - Flutter版

「配合×マッチング」要素のUI/UXを検証するためのFlutterアプリケーションです。

## 概要

このアプリは、Next.jsで実装されたMatchMonプロジェクトをFlutterでリファクタリングしたものです。配合システムに「マッチングアプリ的な体験」を組み込んだときの、候補提示、スワイプ、マッチ成立、関係値（ボンド）強化、配合プランニング、配合結果提示までの一連のUI/UXを検証することを目的としています。

## 技術スタック

- **Flutter 3.x** - UIフレームワーク
- **Dart** - プログラミング言語
- **Riverpod** - 状態管理
- **go_router** - ルーティング
- **Material Design 3** - UIデザインシステム

## セットアップ

1. Flutter SDKをインストール（まだの場合）
   - https://flutter.dev/docs/get-started/install を参照

2. 依存関係のインストール:
```bash
flutter pub get
```

3. アプリの実行:
```bash
flutter run
```

## 主要機能

### 画面一覧

1. **ホーム（ダッシュボード）**
   - ユーザーの現在状態を表示
   - 目標ボード
   - 直近のマッチと配合結果

2. **探す（ディスカバー/スワイプ）**
   - 候補カードのスワイプ操作
   - いいね/スキップ/ブックマーク
   - 詳細モーダル
   - キーボード操作対応（PC）

3. **マッチ一覧**
   - 成立したペアの管理
   - ボンド値の表示と強化
   - 配合プランへの追加

4. **配合プランナー**
   - 親A・親Bの選択
   - 子の種族プレビュー（決定論的）
   - 継承プレビュー
   - 相性表示
   - 確認ダイアログ

5. **配合結果**
   - 新個体の表示
   - 結果の説明
   - 次のおすすめアクション

6. **所持一覧（コレクション）**
   - 検索・フィルタ機能
   - ロック機能
   - 配合への導線

7. **履歴**
   - 配合履歴の時系列表示
   - 詳細表示への導線

8. **設定**
   - 目標設定
   - 現在の状態表示

## 操作方法

### スマートフォン
- **左右スワイプ**: スキップ/いいね
- **タップ**: 詳細表示

### PC
- **ドラッグ**: カードを左右にドラッグ
- **←/Aキー**: スキップ
- **→/Dキー**: いいね
- **Enterキー**: 詳細表示

## データ設計

- データはメモリ内（Riverpod）で管理
- モックデータを使用（実際のバックエンドなし）
- 配合結果は決定論的（プレビューと結果が一致）

## プロジェクト構造

```
lib/
├── models/          # データモデル
│   ├── monster.dart
│   ├── match.dart
│   ├── breeding.dart
│   └── user_state.dart
├── providers/       # 状態管理（Riverpod）
│   └── app_state_provider.dart
├── screens/         # 画面
│   ├── home_screen.dart
│   ├── discover_screen.dart
│   ├── matches_screen.dart
│   ├── breeding_screen.dart
│   ├── breeding_result_screen.dart
│   ├── inventory_screen.dart
│   ├── history_screen.dart
│   └── settings_screen.dart
├── widgets/         # 共通ウィジェット
│   ├── monster_card.dart
│   ├── tag_widget.dart
│   ├── custom_button.dart
│   └── bottom_navigation.dart
├── services/        # ビジネスロジック
│   └── breeding_service.dart
├── data/            # モックデータ
│   └── mock_data.dart
└── router/          # ルーティング
    └── app_router.dart
```

## 検証項目

- 操作の直感性
- 情報提示の分かりやすさ
- 結果の予測可能性
- 反復行動のストレス
- 「一期一会っぽい演出」と「法則性のある結果」の両立感

## 注意事項

- このプロトタイプはUI/UX検証用です
- バックエンドやゲームバランスの実装は含まれません
- データはアプリを再起動するとリセットされます

## ライセンス

MIT
