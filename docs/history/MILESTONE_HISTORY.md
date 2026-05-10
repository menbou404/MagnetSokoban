# MILESTONE_HISTORY.md

## 目的

大きな変更の履歴を時系列で残す。

## 記録ルール

- 新しい記録を上に追加する
- 日付を書く
- 何を変えたか、なぜ変えたか、次に何をするかを書く
- 仕様に影響する変更は必ず残す

## 履歴

### 2026-05-11

#### 内容

PHASE_07_LEVEL_PIPELINE の最小実装として、既存確認面 5 つを `Main.gd` から `levels/test/` の `.lvl.json` へ外部化した。

`levels/level_catalog.json` を追加し、確認用レベルの順序、分類、表示名、ファイルパスを管理するようにした。
`LevelLoader.gd` はレベルファイル、カタログ、カタログ entry からの `GameState` 生成に対応し、`Main.gd` は現在のレベルインデックスと catalog entry だけを扱うようにした。

#### 理由

レベル追加や並べ替えのために `Main.gd` を編集する状態を解消し、確認用レベルとプレイ用レベルを `levels/` 配下で管理できるようにするため。

#### 次

Godot エディタ上で外部化後の確認面を実プレイ確認する。
新しい確認面を追加する場合は、`levels/test/` に `.lvl.json` を追加し、`levels/level_catalog.json` に entry を追加する。

### 2026-05-11

#### 内容

PHASE_07_LEVEL_PIPELINE の設計文書を正式な文書構成に組み込んだ。

`レベル運用方針.md` と `PHASE_07_LEVEL_PIPELINE.md` を読む順と実装順に追加し、`PROJECT_STATUS.md` を PHASE_07 開始前の現在地へ更新した。

#### 理由

確認用レベルを `Main.gd` から外部化し、`levels/` 配下で安全に追加・分類・確認できる運用へ移るため。

#### 次

レベルファイル形式を固定し、既存の確認面を `levels/test/` へ移したうえで、`LevelLoader.gd` と `Main.gd` を外部レベル構造へ接続する。

### 2026-05-10

#### 内容

PHASE_06_ANIMATION_READABILITY の最小実装として、1 手の結果を `TurnResult` / `ActionEvent` のイベント列にまとめ、`AnimationDirector` で再生する流れを導入した。

`MoveResolver` はプレイヤー移動と箱押しをイベント化し、`MagnetResolver` は磁力発動、磁力移動、同強度時の同時移動をイベントとして記録するようにした。
`BoardView` は論理状態とは別の表示専用位置と磁力面ハイライトを持ち、`Main.gd` は再生中の入力停止と再生開始 / 完了処理だけを担当する。

#### 理由

プレイヤーが、プレイヤー移動、箱押し、磁力発動、連鎖、同時処理の因果関係を 1 手の中で追えるようにするため。

#### 次

Godot エディタ上で実プレイ確認を行い、PHASE_06 の範囲内で duration やハイライトの見やすさを必要に応じて調整する。

### 2026-05-10

#### 内容

PHASE_06_ANIMATION_READABILITY の設計文書を正式な文書構成に組み込んだ。

`イベントモデル.md`、`アニメーション方針.md`、`PHASE_06_ANIMATION_READABILITY.md` を読む順と実装順に追加し、`PROJECT_STATUS.md` を PHASE_06 開始前の現在地へ更新した。

#### 理由

磁力、連鎖、競合、同時処理の因果関係をプレイヤーが追えるように、次の作業対象をイベント列ベースのアニメーション再生へ切り替えるため。

#### 次

`TurnResult` / `ActionEvent` 相当の最小構造を導入し、`MoveResolver` / `MagnetResolver` から 1 手のイベント列を返せるようにする。

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
