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
- 旧個別設計 docs の作成と、docs 圧縮として `CORE_DESIGN.md`、`LEVELS_AND_REGRESSION.md`、`PHASES.md`、`HISTORY.md` へ統合
- `AGENTS.md` の整備
- フェーズ別マイルストーン運用の導入
- `docs` 配下への文書集約設計
- PHASE_06_ANIMATION_READABILITY のマイルストーン作成
- PHASE_07_LEVEL_PIPELINE のマイルストーン作成
- PHASE_08_RULE_REGRESSION_TESTS のマイルストーン作成
- PHASE_09_BASICPUSH のマイルストーン作成
- PHASE_10_ROTATION_GIMMICK のマイルストーン作成
- PHASE_11_FIXED_MAGNETS のマイルストーン作成
- フェーズ詳細文書を `docs/milestones/` に集約し、`active/`、`planned/`、`completed/` に状態別整理
- PHASE_12_CONTINUOUS_MAGNET_FIELD の実装指示文書作成
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
- PHASE_07_LEVEL_PIPELINE の最小実装
- 既存確認面 5 つの `levels/test/` 外部化
- `levels/level_catalog.json` による確認用レベル順序管理
- `LevelLoader.gd` の外部 JSON / catalog 読込対応
- PHASE_08_RULE_REGRESSION_TESTS の最小実装
- `levels/test/` の回帰確認用 11 面セット整備
- 各確認面の `id`、`name`、`description`、`tags` 整備
- 回帰確認向け `levels/level_catalog.json` の順序整理
- PHASE_09_BASICPUSH の最小実装
- 隙間なく連続する複数可動箱の通常押し列処理
- 押しで同時に動いた箱すべてを一次起点候補にする磁力処理接続
- 複数箱押し確認用レベルの追加
- PHASE_10_ROTATION_GIMMICK の最小実装
- 右回転床 / 左回転床のレベル読込、論理回転、表示対応
- 回転後の向きで磁力判定を行う確認面の追加
- PHASE_11_FIXED_MAGNETS の最小実装
- 固定磁石のレベル読込、非可動磁力物体としての保持、表示対応
- 固定磁石に対する引力 / 反発、押し停止、回転床連携の確認面追加
- PHASE_12_CONTINUOUS_MAGNET_FIELD の最小実装
- 有効な 1 手後に盤面全体を安定するまで解決する常時磁場処理
- 固定磁石を含む全磁力物体の上下左右候補収集、重複ペア除外、強さ優先、ループガード
- 磁力移動後の回転床適用を共通化する `RotationResolver.gd` の追加
- 常時磁場方式の確認面 6 面追加

### 現在地

仕様整理フェーズ、PHASE_02_DATA_MODEL、PHASE_03_MAGNET_CORE、PHASE_04_CONFLICT_RESOLUTION、PHASE_05_GAMEPLAY_CONTENT、PHASE_06_ANIMATION_READABILITY、PHASE_07_LEVEL_PIPELINE、PHASE_08_RULE_REGRESSION_TESTS、PHASE_09_BASICPUSH、PHASE_10_ROTATION_GIMMICK、PHASE_11_FIXED_MAGNETS、PHASE_12_CONTINUOUS_MAGNET_FIELD の最小実装は完了。
箱は `MagneticBodyState` により、位置・向き・強さ・可動性を持つ磁力物体として保持されている。  
有効な 1 手の後に盤面全体の磁力物体を起点候補として、上下左右の磁場候補を評価し、盤面が安定するまで磁場処理を行う。
競合解決では、強さが異なる場合に強い側を優先し、同強度の場合は両者を 1 マスずつ同時に動かす。
常時磁場方式では、最大磁場解決ステップ数と同一盤面状態検知で安定しない配置を停止する。
固定磁石も磁場の起点になり、固定磁石自身は移動しない。
磁力で動いた箱が回転床へ入った場合も向きが更新される。
1 手の結果は `TurnResult` / `ActionEvent` のイベント列として生成され、`AnimationDirector` が `BoardView` の表示専用状態を使って phase 順に再生する。
再生中は新しい入力を受け付けない。
確認用レベルは `levels/test/` の `.lvl.json` として 35 面に整理され、`levels/level_catalog.json` の順序で N / B キー切り替えができる。
`Main.gd` はレベル本文を持たず、現在のレベルインデックスとカタログ entry だけを扱う。
PHASE_12 用スモーク確認と Godot headless 起動確認は実施済み。
文書は圧縮済みで、基本の読む対象は `README.md`、`PROJECT_STATUS.md`、`SPEC.md`、`CORE_DESIGN.md`、`LEVELS_AND_REGRESSION.md`、`PHASES.md`、`HISTORY.md` に整理されている。
フェーズ詳細はルート直下の `PHASE_XX.md` ではなく、`docs/milestones/README.md` から `active/`、`planned/`、`completed/` 配下の対象ファイルを読む。

## いま進める対象

### 直近の最優先

1. Godot エディタ上で PHASE_12 確認面と既存回帰確認面を実プレイ確認する
2. 常時磁場方式で挙動が変わる既存確認面の説明を必要に応じてさらに整理する
3. 次フェーズ候補を正式化する場合は、先に `docs/` と `docs/milestones/` を更新する

### 直近で触らないもの

- 無限ループ検知の正式実装
- 極性反転
- 磁力遮断壁
- 豪華なパーティクル演出
- 音
- カメラ演出
- 本番用 UI
- 速度変更やスキップ機能の完成版

## 現在の暫定ルール

- 強い磁力の厳密な比較式は未確定
- 同強度時は両側を同時に同距離動かす
- 常時磁場方式では最大ステップ数と同一盤面状態検知で無限ループを止める
- ループ検出のゲーム内ギミック化は将来予定だが現時点では行わない
- アニメーションは確定済みの論理結果をイベント列として再生する
- 再生中は新しい入力を受け付けない
- レベル内容は `Main.gd` に直書きせず、`levels/` 配下へ移す
- レベルファイルの解釈は `LevelLoader.gd` に集約する
- 1 確認面 1 主目的を基本とする
- 確認用レベルは新ギミック追加前後の回帰確認に使う

## 次に完了させるべき状態

PHASE_12_CONTINUOUS_MAGNET_FIELD のコード上の完了条件は満たした。
次に完了させるべき状態は以下。

1. Godot エディタ上で `field_*` 確認面を実プレイ確認する
2. 既存の通常押し、磁力、競合、回転床、固定磁石、アニメーション、レベル運用の回帰確認を行う
3. 次フェーズの仕様を正式化する場合は、文書を先に更新する
