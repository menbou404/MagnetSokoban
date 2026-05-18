# LEVELS_AND_REGRESSION.md

## 目的

レベル運用、レベルデータ形式、回帰確認方針、確認用レベル設計を 1 ファイルにまとめる。

## レベル運用

レベルデータは `Main.gd` に直書きしない。
`levels/` 配下で管理し、読み込みは `LevelLoader.gd` に集約する。

基本配置:

```text
levels/
  test/
  play/
  level_catalog.json
```

- `levels/test/`: 仕様確認と回帰確認用
- `levels/play/`: 将来のプレイ用
- `levels/level_catalog.json`: 読み込み順、分類、表示名、path を管理

`Main.gd` は現在インデックスと catalog entry だけを扱う。
`BoardView.gd` と resolver はレベルファイル形式を知らない。

## レベルファイル形式

1 レベル 1 ファイル。
拡張子は `.lvl.json`。

最小項目:

- `id`
- `name`
- `purpose`
- `description`
- `tags`
- `rows`

## rows の文字

- `#`: 壁
- `.`: 床
- `G`: ゴール
- `P`: プレイヤー
- `+`: ゴール上のプレイヤー
- `>` / `R`: 右向き箱
- `<` / `L`: 左向き箱
- `^` / `U`: 上向き箱
- `v` / `V` / `D`: 下向き箱
- `1` から `5`: 強さ付き右向き箱
- `n`: ゴール上の右向き箱
- `s`: ゴール上の左向き箱
- `]`: 右回転床
- `[`: 左回転床

## catalog 形式

`levels/level_catalog.json` は内容ではなく、順番と分類を管理する。

主な項目:

- `default_group`
- `levels`

`levels` の各要素:

- `id`
- `name`
- `group`
- `path`
- `purpose`
- `description`
- `tags`

## 回帰確認方針

新ギミック追加前後に、既存ルールが壊れていないことを `levels/test/` で確認する。

基本ルール:

- 1 レベル 1 主目的を基本にする
- 短く、意図が明確な面にする
- `id`、`name`、`description`、`tags` で目的を明示する
- プレイ用レベルと確認用レベルを分ける
- 自動テスト導入はまだ行わない

確認対象:

- 基本押し
- 複数箱の通常押し
- 回転床
- 引力
- 反発
- 連鎖
- 強さ優先
- 同強度同時処理
- Undo
- Reset
- レベル再読込
- アニメーション中入力停止
- 連鎖順の可視性

## 現在の確認面

- `rule_push_01`: 基本移動、箱押し、壁、ゴール
- `rule_multi_push_01`: 2 個連続の箱をまとめて押す
- `rule_multi_push_three_01`: 3 個以上の箱を同じ押し列処理で押す
- `rule_multi_push_blocked_01`: 押し列の先頭が壁で止まる
- `rule_multi_push_gap_01`: 空きマスで押し列が切れる
- `rule_multi_push_dual_sources_01`: 押しで同時に動いた箱が一次起点候補になる
- `rule_multi_push_then_magnet_01`: 押し列成立後に磁力処理へ進む
- `system_multi_push_undo_01`: 複数箱押し後の Undo
- `rotation_right_01`: 右回転床で箱が 90 度右回転する
- `rotation_left_01`: 左回転床で箱が 90 度左回転する
- `rotation_then_attract_01`: 回転後の向きで引力判定が行われる
- `rotation_then_repel_01`: 回転後の向きで反発判定が行われる
- `rotation_undo_01`: 回転後の Undo で向きが戻る
- `rule_attract_01`: 引力
- `rule_repel_01`: 反発
- `rule_chain_01`: 連鎖
- `rule_priority_01`: 強さ優先
- `rule_simultaneous_01`: 同強度同時処理
- `system_undo_01`: Undo
- `system_reset_01`: Reset
- `system_reload_01`: レベル切替 / 再読込
- `view_animation_lock_01`: アニメーション中入力停止
- `view_chain_readability_01`: 連鎖順と磁力発動面の可読性

## まだやらないこと

- 本格的な自動テスト
- CI
- レベルエディタ
- ステージ選択 UI
- 本番用大規模レベルセット
- 新ギミック追加
