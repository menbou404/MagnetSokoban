# docs/README.md

## 目的

このディレクトリは、本プロジェクトの仕様、用語、内部設計、実装順、進捗、履歴をまとめて管理する場所である。

## 読む順番

1. `PROJECT_STATUS.md`
2. `SPEC.md`
3. `CORE_DESIGN.md`
4. `LEVELS_AND_REGRESSION.md`
5. `PHASES.md`
6. `HISTORY.md`

着手対象が決まっている場合は、対応する `milestones/PHASE_*.md` も読む。

## 文書の役割

### `PROJECT_STATUS.md`

現在の到達点と、直近で進める対象をまとめる。

### `SPEC.md`

ゲーム全体の仕様をまとめる。  
最も広い範囲の正本。

### `CORE_DESIGN.md`

用語、データ構造、磁力解決、イベントモデル、アニメーション方針をまとめる。

### `LEVELS_AND_REGRESSION.md`

レベル運用、レベルデータ形式、確認面、回帰確認方針をまとめる。

### `PHASES.md`

フェーズ別マイルストーンの概要をまとめる。

### `milestones/PHASE_*.md`

これから着手するフェーズの詳細な目的、対象、完了条件をまとめる。

### `HISTORY.md`

マイルストーン履歴と作業ログをまとめる。

## 運用ルール

- 仕様変更時は、先に `SPEC.md` か関連文書を更新する
- 大きな変更後は `HISTORY.md` を更新する
- 細かな作業ごとは `HISTORY.md` に追記する
- 現在地は常に `PROJECT_STATUS.md` を正とする
