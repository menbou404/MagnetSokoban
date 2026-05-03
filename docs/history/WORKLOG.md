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
