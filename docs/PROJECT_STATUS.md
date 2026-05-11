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

### 現在地

仕様整理フェーズ、PHASE_02_DATA_MODEL、PHASE_03_MAGNET_CORE、PHASE_04_CONFLICT_RESOLUTION、PHASE_05_GAMEPLAY_CONTENT、PHASE_06_ANIMATION_READABILITY、PHASE_07_LEVEL_PIPELINE、PHASE_08_RULE_REGRESSION_TESTS の最小実装は完了。
箱は `MagneticBodyState` により、位置・向き・強さ・可動性を持つ磁力物体として保持されている。  
箱を押した直後にだけ、押された箱を起点として直線探索、距離判定、引力 / 反発、連鎖処理を行う。
競合解決では、強さが異なる場合に強い側を優先し、同強度の場合は両者を 1 マスずつ同時に動かす。
1 手の結果は `TurnResult` / `ActionEvent` のイベント列として生成され、`AnimationDirector` が `BoardView` の表示専用状態を使って phase 順に再生する。
再生中は新しい入力を受け付けない。
確認用レベルは `levels/test/` の `.lvl.json` として 11 面に整理され、`levels/level_catalog.json` の順序で N / B キー切り替えができる。
`Main.gd` はレベル本文を持たず、現在のレベルインデックスとカタログ entry だけを扱う。
次は Godot エディタ上で回帰確認面を実プレイ確認し、その後 PHASE_09_ROTATION_GIMMICK などの追加ギミックに進む段階である。
文書は圧縮済みで、読む対象は `README.md`、`PROJECT_STATUS.md`、`SPEC.md`、`CORE_DESIGN.md`、`LEVELS_AND_REGRESSION.md`、`PHASES.md`、`HISTORY.md` に整理されている。

## いま進める対象

### 直近の最優先

1. Godot エディタ上で 11 面の回帰確認セットを実プレイ確認する
2. 新ギミック追加前後に `levels/test/` の確認面を一通り確認する運用を定着させる
3. 次フェーズとして PHASE_09_ROTATION_GIMMICK または固定磁石 / 遮断系の優先順位を決める

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
- 1 確認面 1 主目的を基本とする
- 確認用レベルは新ギミック追加前後の回帰確認に使う

## 次に完了させるべき状態

PHASE_08 の最小実装はコード上では以下を満たす。

1. 主要仕様に対応する確認面がある
2. 各確認面の目的が明確である
3. 基本押し、引力、反発、連鎖、強さ優先、同強度同時処理を確認できる
4. Undo、Reset、レベル再読込を確認できる
5. アニメーション中入力停止と連鎖順の可視性を確認できる
6. 確認面が `levels/test/` で整理されている
7. 新ギミック追加前後の回帰確認に使える
8. 既存プレイフローを壊していない

残る確認は、Godot エディタ上で 11 面を実プレイして意図通り見えることを確認すること。
