# PHASES.md

## 目的

フェーズ別マイルストーンの概要を管理する。
詳細な作業指示が必要なフェーズは `milestones/active/`、`milestones/planned/`、`milestones/completed/` 配下の `PHASE_*.md` に分ける。
詳細文書の一覧と運用ルールは `milestones/README.md` を正とする。

## 完了済み

### PHASE_01_FOUNDATION

Godot 4 + VS Code + Git の開発環境、最小シーン、描画分離の土台を作成。

### PHASE_02_DATA_MODEL

箱を `MagneticBodyState` へ移行。
`GameState`、`LevelLoader`、Undo、描画、クリア判定を新データ構造へ対応。

### PHASE_03_MAGNET_CORE

押された箱を起点にする磁力連鎖の最小実装。
距離判定、面の極による引力 / 反発、1 手内の起点処理制限を導入。

### PHASE_04_CONFLICT_RESOLUTION

強さ差ありの優先処理と、同強度時の同時処理を実装。
強い磁力の厳密な比較式は未確定として残す。

### PHASE_05_GAMEPLAY_CONTENT

向き、N/S 面、強さの視覚表示を追加。
基本確認面を用意。

### PHASE_06_ANIMATION_READABILITY

`TurnResult`、`ActionEvent`、`AnimationDirector` を導入。
1 手の論理結果をイベント列として再生し、再生中入力停止を実装。

### PHASE_07_LEVEL_PIPELINE

レベルを `Main.gd` から外部化。
`levels/test/`、`levels/play/`、`levels/level_catalog.json`、外部 JSON 読込を整備。

### PHASE_08_RULE_REGRESSION_TESTS

`levels/test/` を 11 面の回帰確認セットへ整理。
各確認面に `description` と `tags` を付与し、新ギミック追加前後の確認資産にした。

### PHASE_09_BASICPUSH

詳細: `milestones/completed/PHASE_09_BASICPUSH.md`

通常押しギミックを拡張し、隙間なく連続する複数の可動箱を 1 つの押し列として 1 マス押せるようにする。
磁力ではなく `MoveResolver.gd` の通常移動ルールとして扱い、押しで同時に動いた箱をすべて一次起点候補として `MagnetResolver.gd` に渡す。

### PHASE_10_ROTATION_GIMMICK

詳細: `milestones/completed/PHASE_10_ROTATION_GIMMICK.md`

箱の向きを変える最初の正式ギミックとして、右回転床 / 左回転床を追加する。
箱が回転床へ入った直後に向きを更新し、その後の磁力判定へ反映する。

### PHASE_11_FIXED_MAGNETS

詳細: `milestones/completed/PHASE_11_FIXED_MAGNETS.md`

盤面上に移動しない磁力物体である固定磁石を追加する。
固定磁石は箱と同じく向きと強さを持つが、押しても磁力でも動かず、箱との相互作用では可動側だけを移動対象にする。

### PHASE_12_CONTINUOUS_MAGNET_FIELD

詳細: `milestones/active/PHASE_12_CONTINUOUS_MAGNET_FIELD.md`

磁力処理を、押された箱を起点にする押し後連鎖方式から、有効な 1 手の後に盤面全体を安定するまで解決する常時磁場方式へ移行する。
固定磁石も起点に含め、上下左右の磁場候補を評価し、最大ステップ数と同一盤面状態検知で安定しない配置を止める。

## 次フェーズ

未定。

## 次フェーズ以降の候補

- 磁力遮断
- 本番レベル設計
- レベル選択 UI

## 運用

新しいフェーズを始める前に、この文書へ概要を追記する。
詳細な作業範囲が必要な場合は `milestones/active/PHASE_*.md` または `milestones/planned/PHASE_*.md` を追加し、`milestones/README.md` の一覧も更新する。
ルート直下に `PHASE_XX.md` は増やさず、フェーズ詳細は `docs/milestones/` に集約する。
大きな作業履歴は `HISTORY.md` へ残す。
