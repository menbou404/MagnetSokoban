# HISTORY.md

## 目的

マイルストーン履歴と作業ログを 1 ファイルにまとめる。

新しい記録は上に追加する。

## 2026-05-24

### PHASE_12_CONTINUOUS_MAGNET_FIELD 実装

磁力処理を押し後起点方式から、有効な 1 手の後に盤面全体を安定するまで評価する常時磁場方式へ移行した。
`MoveResolver.gd` は押しの有無に関係なく、有効手の後に `MagnetResolver.settle_magnetic_field()` を呼ぶようにした。
`MagnetResolver.gd` に全磁力物体・上下左右の候補収集、同一 2 物体ペアの重複排除、最強候補選別、最大 128 ステップと同一盤面状態検知によるループガードを追加した。
固定磁石も磁場の起点に含め、固定磁石自身は移動しない既存可動性ルールを維持した。
`RotationResolver.gd` を追加し、通常押しと磁力移動の両方で、箱が回転床へ入った直後に向きを更新できるようにした。
`levels/test/` に `field_*` 6 面を追加し、`levels/level_catalog.json` に登録した。
Godot headless 起動、PHASE_12 用スモーク確認、JSON 読み込み確認を行った。

### PHASE_12_CONTINUOUS_MAGNET_FIELD 文書反映

`docs/milestones/active/PHASE_12_CONTINUOUS_MAGNET_FIELD.md` を現在の着手対象として扱うため、`docs/PHASES.md`、`docs/milestones/README.md`、`docs/milestones/active/README.md` を更新した。
常時磁場方式への移行に合わせ、`docs/SPEC.md` と `docs/CORE_DESIGN.md` の磁力処理記述を、押し後起点方式から有効な 1 手後の盤面全体安定化方式へ更新した。
`docs/PROJECT_STATUS.md`、`docs/LEVELS_AND_REGRESSION.md`、`AGENTS.md` に、PHASE_12 の現在地、確認面方針、正式方針の変更を反映した。
この時点ではコード実装とレベル追加は未着手であり、次に `MoveResolver.gd` と `MagnetResolver.gd` へ常時磁場処理を実装する。

## 2026-05-23

### milestones 内整理

`docs/milestones/` を `active/`、`planned/`、`completed/` に分け、完了済みの `PHASE_09_BASICPUSH.md`、`PHASE_10_ROTATION_GIMMICK.md`、`PHASE_11_FIXED_MAGNETS.md` を `completed/` へ移動した。
各状態ディレクトリに README を追加し、`docs/milestones/README.md`、`docs/README.md`、`docs/PHASES.md`、`docs/PROJECT_STATUS.md`、`AGENTS.md` の参照を新構成に更新した。

### フェーズ文書整理

`docs/PHASE_09.md`、`docs/PHASE_10.md`、`docs/PHASE_11.md` の内容は各 `docs/milestones/PHASE_*.md` と重複していたため削除し、フェーズ詳細の置き場を `docs/milestones/` に統一した。
`docs/milestones/README.md` を追加し、フェーズ詳細文書の一覧、状態、運用ルールをまとめた。
`docs/README.md`、`docs/PHASES.md`、`docs/PROJECT_STATUS.md`、`AGENTS.md` を更新し、今後はルート直下に `PHASE_XX.md` を増やさない方針を明記した。

## 2026-05-18

### PHASE_11_FIXED_MAGNETS

固定磁石を `MagneticBodyState` の `kind = fixed_magnet`、`movable = false` として追加した。
`LevelLoader.gd` で `.lvl.json` の `fixed_magnets` 配列を読み込み、`MagnetResolver.gd` で固定磁石を磁力対象に含めつつ可動側だけを移動させるようにした。
`BoardView.gd` に固定磁石の表示を追加し、引力、反発、押し停止、連鎖候補再評価、回転床連携、Undo の確認面を追加した。
Godot headless 起動と PHASE_11 用スモーク確認を行った。

### PHASE_11_FIXED_MAGNETS マイルストーン追加

`docs/milestones/PHASE_11_FIXED_MAGNETS.md` を追加した。
`PHASES.md` と `PROJECT_STATUS.md` を更新し、次フェーズを PHASE_11_FIXED_MAGNETS として整理した。
`docs/PHASE_11.md` を追加し、固定磁石の予定仕様、処理順、責務を要約した。

## 2026-05-12

### PHASE_10_ROTATION_GIMMICK

箱が入ると向きを 90 度変える右回転床 / 左回転床を追加した。
`GameState.gd` に回転床位置を保持し、`LevelLoader.gd` で `]` / `[` を読み込み、`MoveResolver.gd` で箱移動確定後かつ磁力処理前に facing を更新するようにした。
`BoardView.gd` に回転床の簡易表示を追加し、回転、回転後の引力 / 反発、Undo を確認する 5 面を `levels/test/` と catalog に追加した。
Godot headless 起動と PHASE_10 用スモーク確認を行った。

### PHASE_09_BASICPUSH

`MoveResolver.gd` の通常押しを押し列処理へ拡張し、隙間なく連続する複数の可動箱をまとめて 1 マス押せるようにした。
押しで同時に動いた箱の id 一覧を `MagnetResolver.gd` へ渡し、一次起点候補を同じ段階で評価できるようにした。
PHASE_09 用に複数箱押し、3 個押し、壁ブロック、隙間、複数一次起点、押し後磁力、Undo の確認面を追加し、`levels/level_catalog.json` へ登録した。
Godot headless 起動と PHASE_09 用スモーク確認を行った。

### PHASE_09 / PHASE_10 マイルストーン追加

`docs/milestones/PHASE_09_BASICPUSH.md` と `docs/milestones/PHASE_10_ROTATION_GIMMICK.md` を追加した。
`PHASES.md` と `PROJECT_STATUS.md` を更新し、次フェーズを PHASE_09_BASICPUSH、その次を PHASE_10_ROTATION_GIMMICK として整理した。
`README.md` と `AGENTS.md` に、着手対象の `docs/milestones/PHASE_*.md` を読む運用を追記した。

## 2026-05-11

### docs 圧縮

設計系、レベル / 回帰系、フェーズ、履歴を統合文書へ整理した。

### PHASE_08_RULE_REGRESSION_TESTS

`levels/test/` を回帰確認向けの 11 面セットへ整理した。
`rule_*`、`system_*`、`view_*` の確認面を追加し、`description` と `tags` を付与した。
`levels/level_catalog.json` を回帰確認順に更新した。

### PHASE_07_LEVEL_PIPELINE

既存確認面を `Main.gd` から `levels/test/` の `.lvl.json` へ外部化した。
`levels/level_catalog.json` を追加し、`LevelLoader.gd` を外部 JSON / catalog 読込へ対応した。

### PHASE_07 設計文書整備

レベル外部化、LevelLoader 集約、catalog、確認用 / プレイ用レベル分離の方針を整理した。

## 2026-05-10

### PHASE_06_ANIMATION_READABILITY

`TurnResult`、`ActionEvent`、`AnimationDirector` を導入した。
resolver がイベント列を生成し、`BoardView` が表示専用状態で補間と磁力面ハイライトを行うようにした。
再生中入力停止を実装した。

### PHASE_06 設計文書整備

イベントモデルとアニメーション方針を文書化した。

## 2026-05-03

### PHASE_05_GAMEPLAY_CONTENT

箱の向き、N/S 面、強さドットの表示を追加した。
確認用レベルを整備した。

### PHASE_04_CONFLICT_RESOLUTION

強さ優先と同強度時の同時処理を `MagnetResolver` に実装した。

### PHASE_03_MAGNET_CORE

押された箱を起点にした磁力連鎖、距離判定、引力 / 反発を実装した。

### PHASE_02_DATA_MODEL

`MagneticBodyState` を導入し、旧 `boxes + box_poles` 方式から移行した。

## YYYY-MM-DD

docs 構成を導入し、仕様、現在地、実装順、履歴を分離した。
