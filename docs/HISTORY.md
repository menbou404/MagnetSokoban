# HISTORY.md

## 目的

マイルストーン履歴と作業ログを 1 ファイルにまとめる。

新しい記録は上に追加する。

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
