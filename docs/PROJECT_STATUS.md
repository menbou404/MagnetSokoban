# PROJECT_STATUS.md

## 目的

このファイルは「現在の到達点」と「直近で進める対象」を表す。  
フェーズ文書とは別に、常に最新の現在地だけを簡潔に記録する。

## 現在の到達点

### 完了済み

- Godot 4 + VS Code + Git の開発環境構築
- `Main.gd` の肥大化を避けるためのファイル分割
- `Main.tscn` の最小構成作成
- `BoardView` への描画分離
- Kenney 素材の仮導入
- `SPEC.md` の作成
- `用語集.md` の作成
- `データ構造.md` の作成
- `磁力解決アルゴリズム.md` の作成
- `イベントモデル.md` の作成
- `アニメーション方針.md` の作成
- `レベル運用方針.md` の作成
- `AGENTS.md` の整備
- フェーズ別マイルストーン運用の導入
- `docs` 配下への文書集約設計
- PHASE_06_ANIMATION_READABILITY のマイルストーン作成
- PHASE_07_LEVEL_PIPELINE のマイルストーン作成
- PHASE_02_DATA_MODEL の実装
- `MagneticBodyState` の導入
- `GameState` / `LevelLoader` / Undo スナップショットの新データ構造対応
- PHASE_03_MAGNET_CORE の最小実装
- 押された箱を起点にした磁力連鎖処理
- 距離条件と面の極による引力 / 反発判定
- PHASE_04_CONFLICT_RESOLUTION の最小実装
- `strength` による強い側優先処理
- 同強度時の `PlannedMove` 相当による同時処理
- PHASE_05_GAMEPLAY_CONTENT の最小実装
- 箱の向きと強さの視覚表示
- 基本移動、箱押し、引力、反発、連鎖、競合解決を確認する 5 つのテスト面
- PHASE_06_ANIMATION_READABILITY の最小実装
- `TurnResult` / `ActionEvent` / `AnimationDirector` の導入
- プレイヤー移動、箱移動、磁力発動面、連鎖、同時処理のイベント列ベース再生
- アニメーション再生中の入力停止

### 現在地

仕様整理フェーズ、PHASE_02_DATA_MODEL、PHASE_03_MAGNET_CORE、PHASE_04_CONFLICT_RESOLUTION、PHASE_05_GAMEPLAY_CONTENT、PHASE_06_ANIMATION_READABILITY の最小実装は完了。
箱は `MagneticBodyState` により、位置・向き・強さ・可動性を持つ磁力物体として保持されている。  
箱を押した直後にだけ、押された箱を起点として直線探索、距離判定、引力 / 反発、連鎖処理を行う。
競合解決では、強さが異なる場合に強い側を優先し、同強度の場合は両者を 1 マスずつ同時に動かす。
現在は、5 つの確認面を `Main.gd` 内のレベル配列として持ち、N / B キーで切り替えられる。
1 手の結果は `TurnResult` / `ActionEvent` のイベント列として生成され、`AnimationDirector` が `BoardView` の表示専用状態を使って phase 順に再生する。
再生中は新しい入力を受け付けない。
次は PHASE_07_LEVEL_PIPELINE として、確認用レベルを `Main.gd` から外部化し、`levels/` を正式なレベル管理場所として扱う段階である。

## いま進める対象

### 直近の最優先

1. `Main.gd` から確認面の直書きを外す
2. `levels/test/` から確認用レベルを読み込めるようにする
3. `LevelLoader.gd` を外部ファイル対応にする
4. 必要なら `levels/level_catalog.json` を導入する
5. 次のレベル / 前のレベル / リセットを新構造で維持する

### 直近で触らないもの

- 無限ループ検知の正式実装
- 固定磁石
- 回転床
- 極性反転
- 磁力遮断壁
- 豪華なパーティクル演出
- 音
- カメラ演出
- 本番用 UI
- 速度変更やスキップ機能の完成版

## 現在の暫定ルール

- 同じ起点は 1 手で 1 回しか磁力判定しない
- 強い磁力の厳密な比較式は未確定
- 同強度時は両側を同時に同距離動かす
- 無限ループは将来ギミック化予定だが現時点では未実装
- アニメーションは確定済みの論理結果をイベント列として再生する
- 再生中は新しい入力を受け付けない
- レベル内容は `Main.gd` に直書きせず、`levels/` 配下へ移す
- レベルファイルの解釈は `LevelLoader.gd` に集約する

## 次に完了させるべき状態

PHASE_07 の最小実装では以下を満たす。

1. `Main.gd` に面データ直書きが残っていない
2. `levels/` からレベルを読み込める
3. 確認用レベルを複数ファイルで管理できる
4. 次のレベル / 前のレベル / リセットが動く
5. 既存の確認面が外部化後も動作する
6. Main を触らずに新しい確認面を追加できる
7. 既存のプレイフローを壊していない
