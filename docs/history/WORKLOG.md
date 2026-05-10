# WORKLOG.md

## 目的

このファイルは、細かな作業ログを残すための台帳である。  
大きな節目は `MILESTONE_HISTORY.md` に記録し、日々の作業や小さな判断はこのファイルに残す。

## 記録ルール

- 新しい記録を上に追加する
- 日付を書く
- 何をしたかを短く書く
- 迷った点や次に触る点があれば残す
- 大きな仕様変更は `MILESTONE_HISTORY.md` にも残す

## ログ

### 2026-05-11

- PHASE_08_RULE_REGRESSION_TESTS の最小実装を実施
- `levels/test/` を推奨確認面 11 面へ整理
- `basic_*` 系の既存確認面を `rule_*` / `system_*` / `view_*` の回帰確認向け命名へ置き換え
- 各 `.lvl.json` に `description` と `tags` を追加し、確認目的を明確化
- `levels/level_catalog.json` を回帰確認順へ更新
- `LevelLoader.gd` が `description` / `tags` を catalog entry と level file から保持できるようにした
- `Main.gd` のレベル表示に description を追加
- `docs/回路確認方針.md` を指定名に合わせて `docs/回帰確認方針.md` へ改名し、参照を更新
- Godot 4.6.2 のヘッドレス起動確認、全 catalog entry 読込、次 / 前 / リセット、主要ルールイベントのスモーク確認を実施

### 2026-05-11

- PHASE_08_RULE_REGRESSION_TESTS の追加に合わせて文書構成を更新
- `AGENTS.md` と `docs/README.md` の読む順に `テストレベル設計.md` と `回帰確認方針.md` を追加
- `PROJECT_STATUS.md` を PHASE_08 の着手前状態へ更新
- `README_IMPLEMENTATION_ORDER.md` に PHASE_08 用の実装順を追加
- `SPEC.md` に回帰確認方針を追記
- `レベルデータ形式.md` に `description` と `tags` の扱いを追記
- `データ構造.md` と `用語集.md` に回帰確認用の項目と用語を追記
- `PHASE_08_RULE_REGRESSION_TESTS.md`、`テストレベル設計.md`、`回帰確認方針.md` に関連文書を追記

### 2026-05-11

- PHASE_07_LEVEL_PIPELINE の最小実装を実施
- `docs/レベルデータ形式.md` を追加し、`.lvl.json` と `level_catalog.json` の最小形式を文書化
- 既存確認面 5 つを `levels/test/` の `.lvl.json` へ外部化
- `levels/level_catalog.json` を追加し、確認用レベルの順序とメタ情報を管理するようにした
- `levels/play/.gitkeep` を追加し、今後のプレイ用レベル配置場所を用意
- `LevelLoader.gd` にレベルファイル、カタログ、カタログ entry からの読込経路を追加
- `Main.gd` から面データ直書きを撤去し、現在インデックスと catalog entry だけでレベル切替 / リセットするようにした
- Godot 4.6.2 のヘッドレス起動確認と、全 catalog entry 読込、次 / 前 / リセットのスモーク確認を実施

### 2026-05-11

- PHASE_07_LEVEL_PIPELINE の追加に合わせて文書構成を更新
- `AGENTS.md` と `docs/README.md` の読む順に `レベル運用方針.md` を追加
- `PROJECT_STATUS.md` を PHASE_07 の着手前状態へ更新
- `README_IMPLEMENTATION_ORDER.md` に PHASE_07 用の実装順を追加
- `SPEC.md` にレベル外部化と `LevelLoader` 集約の方針を追記
- `データ構造.md` に `LevelCatalog` 相当の考え方を追記
- `用語集.md` に確認用レベル、プレイ用レベル、レベルカタログを追記
- `レベル運用方針.md` と `PHASE_07_LEVEL_PIPELINE.md` のコードブロックを整え、状態と関連文書を追記

### 2026-05-10

- PHASE_06_ANIMATION_READABILITY の最小実装を実施
- `ActionEvent.gd` と `TurnResult.gd` を追加し、1 手のイベント列、phase、クリア状態、手数を保持できるようにした
- `AnimationDirector.gd` を追加し、`TurnResult.events` を phase 単位で再生するようにした
- `MoveResolver.gd` が `bool` ではなく `TurnResult` を返し、プレイヤー移動と箱押しをイベント化するようにした
- `MagnetResolver.gd` が `magnet_trigger`、`body_move`、`simultaneous_move` を記録するようにした
- `BoardView` に表示専用の補間位置と磁力面ハイライトを追加した
- `Main.gd` は `AnimationDirector` 経由で再生し、再生中は入力を受け付けないようにした
- Godot 4.6.2 のヘッドレス起動確認、1 手の `TurnResult` 生成スモーク確認、scene 経由のアニメーション再生スモーク確認を実施

### 2026-05-10

- PHASE_06_ANIMATION_READABILITY の追加に合わせて文書構成を更新
- `AGENTS.md` と `docs/README.md` の読む順に `イベントモデル.md` と `アニメーション方針.md` を追加
- `PROJECT_STATUS.md` を PHASE_06 の着手前状態へ更新
- `README_IMPLEMENTATION_ORDER.md` に PHASE_06 用の実装順を追加
- `SPEC.md` にイベント列ベースのアニメーション方針を追記
- `PHASE_06_ANIMATION_READABILITY.md` に状態と関連文書を追記

### 2026-05-03

- PHASE_05_GAMEPLAY_CONTENT の最小実装を実施
- `BoardView` に N/S 面マーカー、向き矢印、強さドットを追加
- `LevelLoader` に `>` / `<` / `^` / `v` と `1` から `5` の強さ付き右向き箱を追加
- `Main.gd` に 5 つの確認面を追加し、N / B キーで次 / 前の面へ切り替えられるようにした
- 確認面は、基本移動と箱押し、引力、反発、連鎖、強さ差優先、同強度同時処理、向き表示を確認する構成にした
- `godot` / `godot4` コマンドが見つからないため、実起動確認は未実施

### 2026-05-03

- PHASE_04_CONFLICT_RESOLUTION の最小実装を実施
- `MagnetResolver` に `MagneticInteractionCandidate` 相当の候補生成を追加
- `PlannedMove` 相当の移動計画と `apply_planned_moves()` による一括適用を追加
- 強さが異なる場合は、`strength` が強い側の作用を優先して 1 マス逐次適用するようにした
- 同強度の場合は、source / target の次の 1 マス候補を毎回作り、両方有効な場合だけ同時適用するようにした
- 同時処理中の同一マス到達、位置交換、壁、盤面外、他物体占有、プレイヤー位置への移動を無効化した
- 強い磁力の厳密な比較式と複数組の同時処理順は TODO として残した

### 2026-05-03

- PHASE_03_MAGNET_CORE の最小実装を実施
- `MagnetResolver` を固定レンジの単発処理から、押された箱を起点にしたキュー型連鎖処理へ更新
- 直線上の最初の対象だけを探索し、壁または盤面外で探索を停止するようにした
- `source.strength + target.strength >= distance` による発動判定を追加
- 向かい合う面の極から引力 / 反発を判定し、対象を 1 マス単位で移動するようにした
- `processed_sources` により、同じ起点を 1 手で 1 回だけ処理する暫定ルールを実装
- 連鎖時の処理方向は未確定のため、PHASE_03 では押した方向を引き継ぐ TODO として残した

### 2026-05-03

- PHASE_02_DATA_MODEL を実装
- `MagneticBodyState.gd` を追加し、`id`、`kind`、`pos`、`facing`、`strength`、`movable` を保持する構造にした
- `GameState` の主データを `bodies` に置き換え、スナップショットも新構造に対応
- `LevelLoader`、`MoveResolver`、`MagnetResolver`、`WinChecker`、`BoardView` を旧 `boxes + box_poles` 非依存に更新
- `N/S/n/s` のレベル記号から向き付き箱へ変換する暫定対応を入れた
- PHASE_03 以降で、棒磁石の軸と直交する面の扱い、強さ比較、連鎖処理を詰める

### YYYY-MM-DD

- 文書構成の再整理を実施
- `AGENTS.md` から `docs/` を読む流れを固定
- 進捗台帳を現在地とフェーズに分離
- 次は `PHASE_02_DATA_MODEL` の実装準備を行う
