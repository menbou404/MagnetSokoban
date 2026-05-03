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
