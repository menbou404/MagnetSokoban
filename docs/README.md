# docs/README.md

## 目的

このディレクトリは、本プロジェクトの仕様、用語、内部設計、実装順、進捗、履歴をまとめて管理する場所である。

## 読む順番

1. `PROJECT_STATUS.md`
2. `spec.md`
3. `用語集.md`
4. `データ構造.md`
5. `磁力解決アルゴリズム.md`
6. `README_IMPLEMENTATION_ORDER.md`

必要に応じて読むもの:

- `milestones/PHASE_*.md`
- `history/MILESTONE_HISTORY.md`
- `history/WORKLOG.md`

## 文書の役割

### `PROJECT_STATUS.md`

現在の到達点と、直近で進める対象をまとめる。

### `spec.md`

ゲーム全体の仕様をまとめる。  
最も広い範囲の正本。

### `用語集.md`

プロジェクト内で使う言葉の定義を固定する。

### `データ構造.md`

内部表現と主要クラスの役割を整理する。

### `磁力解決アルゴリズム.md`

磁力処理の流れと優先順位を定義する。

### `README_IMPLEMENTATION_ORDER.md`

実装順を固定するための手順書。

### `milestones/`

フェーズごとの目的、対象、完了条件を管理する。

### `history/`

作業履歴と日次ログを管理する。

## 運用ルール

- 仕様変更時は、先に `spec.md` か関連文書を更新する
- 大きな変更後は `history/MILESTONE_HISTORY.md` を更新する
- 細かな作業ごとは `history/WORKLOG.md` に追記する
- 現在地は常に `PROJECT_STATUS.md` を正とする
