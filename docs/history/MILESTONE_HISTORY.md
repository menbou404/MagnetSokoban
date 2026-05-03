# MILESTONE_HISTORY.md

## 目的

大きな変更の履歴を時系列で残す。

## 記録ルール

- 新しい記録を上に追加する
- 日付を書く
- 何を変えたか、なぜ変えたか、次に何をするかを書く
- 仕様に影響する変更は必ず残す

## 履歴

### 2026-05-03

#### 内容

PHASE_02_DATA_MODEL として、箱の内部表現を `MagneticBodyState` 中心に再設計した。  
`GameState` は旧 `boxes + box_poles` ではなく `bodies` を保持し、ロード、移動、Undo、クリア判定、描画の主経路を新構造へ接続した。

#### 理由

箱を 1 マスの棒磁石として扱い、位置・向き・強さ・可動性を持つ磁力物体へ移行するため。

#### 次

PHASE_03 以降で、`MagnetResolver` を新構造前提に再設計し、距離判定、面の極による引力 / 反発、連鎖処理を実装する。

### YYYY-MM-DD

#### 内容

文書構成を `docs/` 配下に集約した。  
`PROJECT_STATUS.md`、`README_IMPLEMENTATION_ORDER.md`、`milestones/`、`history/` を整理し、Codex が読みやすい動線に再構成した。

#### 理由

仕様、現在地、実装順、履歴を分離し、エージェントと人の双方が迷わず作業できるようにするため。

#### 次

`PHASE_02_DATA_MODEL` に従い、`MagneticBodyState` 相当の導入と `GameState` 再設計に進む。
