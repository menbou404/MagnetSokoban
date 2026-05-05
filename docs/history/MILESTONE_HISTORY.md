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

PHASE_05_GAMEPLAY_CONTENT として、最小プレイセットを整備した。
`BoardView` に箱の向き、N/S 面、強さドットの表示を追加し、`LevelLoader` に上下左右向きと強さ違いの箱記号を追加した。
`Main.gd` は 5 つの確認面を持つようにし、N / B キーで面を切り替えられるようにした。

#### 理由

PHASE_02 から PHASE_04 までで整備したデータ構造、磁力連鎖、競合解決を、実際に確認しながら遊べる最小状態にするため。

#### 次

Godot エディタ上で実プレイ確認を行い、必要なら本番用レベルデータ形式や次の追加ギミック候補を決める。

### 2026-05-03

#### 内容

PHASE_04_CONFLICT_RESOLUTION として、磁力作用の競合解決を `MagnetResolver` に実装した。
`MagneticInteractionCandidate` 相当の Dictionary と `PlannedMove` 相当の Dictionary を導入し、強さが異なる場合は `strength` の強い側の作用を逐次適用し、同強度の場合は両者の次の 1 マス移動候補を一括適用する。

#### 理由

複数の磁力作用が同時に成立する局面で、強い磁力優先と同強度時の同時処理を決定的なマス単位処理として扱うため。

#### 次

PHASE_05_GAMEPLAY_CONTENT で、磁力到達距離、引力、反発、連鎖、競合解決を確認できる最小面を追加する。
「強い磁力」の厳密な比較式と複数組の同時処理の解決順は未確定のまま残す。

### 2026-05-03

#### 内容

PHASE_03_MAGNET_CORE として、押された箱を最初の起点にする磁力連鎖の最小版を実装した。
`MagnetResolver` は直線上の最初の対象だけを探索し、`source.strength + target.strength >= distance` の距離判定、向かい合う面の極による引力 / 反発、1 マス単位の対象移動、`processed_sources` / `pending_sources` による連鎖管理を行う。

#### 理由

磁力を常時発生させず、箱を押した直後にだけ決定的なマス単位処理として連鎖させる PHASE_03 の要件を満たすため。

#### 次

PHASE_04_CONFLICT_RESOLUTION で、強い磁力優先と同強度時の同時処理を正式に実装する。
連鎖時の起点ごとの処理方向は未確定のため、現時点では押した方向を引き継ぐ暫定扱いとする。

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
