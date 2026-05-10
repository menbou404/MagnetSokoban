# README_IMPLEMENTATION_ORDER.md

## 目的

この文書は、実装順を固定するための作業順序表である。  
Codex がどのファイルから触るべきかを迷わないようにする。

## 実装原則

1. 仕様変更がある場合は、先に `docs/` を更新する
2. 進捗確認は `PROJECT_STATUS.md` を正とする
3. 大きな作業の前後で `history/MILESTONE_HISTORY.md` を更新する
4. `Main.gd` は最後に接続調整だけ行う
5. View より先に State と Resolver を固める
6. アニメーションは確定済みの論理結果をイベント列として再生する
7. resolver に Tween や待ち時間を入れない
8. レベル内容は `Main.gd` に直書きせず、`levels/` 配下で管理する
9. レベルファイルの解釈は `LevelLoader.gd` に集約する

## 固定の実装順

### Step 0

文書確認

読む順番:

1. `AGENTS.md`
2. `docs/README.md`
3. `docs/PROJECT_STATUS.md`
4. `docs/SPEC.md`
5. `docs/用語集.md`
6. `docs/データ構造.md`
7. `docs/磁力解決アルゴリズム.md`
8. `docs/イベントモデル.md`
9. `docs/アニメーション方針.md`
10. `docs/レベル運用方針.md`
11. `docs/レベルデータ形式.md`
12. 対象フェーズ文書

### Step 1

状態構造を作る

対象:

- `MagneticBodyState.gd` を新規作成
- `GameState.gd` を更新
- `UndoHistory.gd` の保存対象を更新

目的:

- 箱を `pos + facing + strength + movable` で持てるようにする

完了条件:

- 旧 `boxes + box_poles` 方式に依存しない

### Step 2

ロード処理を合わせる

対象:

- `LevelLoader.gd`

目的:

- 新しい箱構造で面データを読み込めるようにする

完了条件:

- 初期配置が新構造で再現できる

### Step 3

表示を合わせる

対象:

- `BoardView.gd`

目的:

- 向き付きの棒磁石箱を描画できるようにする

完了条件:

- 箱の向きが見分けられる
- 強さ表示の土台を入れられる

### Step 4

通常移動を接続する

対象:

- `MoveResolver.gd`

目的:

- 新しい箱構造でも押し処理が壊れないようにする

完了条件:

- プレイヤー移動
- 箱押し
- 壁判定
- 巻き戻し
  が新構造で動く

### Step 5

磁力の最小版を実装する

対象:

- `MagnetResolver.gd`

目的:

- 押した直後の起点処理
- 距離判定
- 引力 / 反発
- 連鎖
  を実装する

完了条件:

- `source.strength + target.strength >= distance` が動く
- 同じ起点は 1 手で 1 回だけ処理される
- 連鎖が停止する

### Step 6

競合解決を入れる

対象:

- `MagnetResolver.gd`
- 必要なら `PlannedMove` 相当の補助構造

目的:

- 強い磁力優先
- 同強度時の同時処理
  を実装する

完了条件:

- 強さ差ありのケースで優先が正しい
- 同強度ケースで同時移動が正しい

### Step 7

Main を最終接続する

対象:

- `Main.gd`

目的:

- 新しい State / Resolver / View を接続する

完了条件:

- 1 手が最後まで流れる
- クリア判定まで通る

### Step 8

テスト面を追加する

対象:

- レベルデータ
- 必要なら `LevelLoader.gd`

目的:

- 磁力の到達距離
- 反発
- 引力
- 連鎖
- 強さ優先
- 同時処理
  を個別に確認する

完了条件:

- 少なくとも 5 ケースの確認面がある

## PHASE_06 の実装順

PHASE_06_ANIMATION_READABILITY では、既存のゲームルールを壊さず、アニメーション再生用のイベント列を追加する。

### Step 9

イベント構造を作る

対象:

- `TurnResult` 相当
- `ActionEvent` 相当

目的:

- 1 手の論理結果をイベント列として保持する
- `did_change_state`、`did_clear`、`move_count_after` を 1 つの結果にまとめる

完了条件:

- 1 手の結果が `TurnResult` 相当で返せる
- イベントが `type`、`phase`、対象、移動元、移動先を持てる

### Step 10

resolver からイベントを返す

対象:

- `MoveResolver.gd`
- `MagnetResolver.gd`

目的:

- プレイヤー移動、箱押し、磁力発動、磁力移動、同時移動、ターン終了を `ActionEvent` として列挙する

完了条件:

- `player_move`
- `body_move`
- `magnet_trigger`
- `simultaneous_move`
- `turn_end`
  の最小イベントが生成できる
- resolver に Tween や待ち時間が入っていない

### Step 11

アニメーション再生役を作る

対象:

- `AnimationDirector.gd` 相当

目的:

- `TurnResult.events` を phase 単位で順番に再生する
- 同じ phase のイベントを同時再生候補として扱う

完了条件:

- 逐次イベントが順番に再生される
- 同時処理イベントが同時に再生される
- 再生完了を `Main.gd` へ通知できる

### Step 12

表示状態を BoardView に寄せる

対象:

- `BoardView.gd`

目的:

- 論理状態とは別に、補間中の描画位置や面の強調表示を扱う

完了条件:

- プレイヤー移動と箱移動が視認できる
- 磁力発動面を短く強調できる
- BoardView がゲームルール判定を持たない

### Step 13

Main を接続する

対象:

- `Main.gd`

目的:

- 入力から `TurnResult` を受け取り、`AnimationDirector` の再生を開始する
- 再生中は入力を止め、再生完了後に次の入力を受け付ける

完了条件:

- 1 手の因果関係が追える
- 再生中に次の入力が入らない
- クリア、巻き戻し、リセットの基本動線を壊さない

## PHASE_07 の実装順

PHASE_07_LEVEL_PIPELINE では、確認用レベルを `Main.gd` から外部化し、`levels/` を正式なレベル管理場所にする。

### Step 14

レベル形式を固定する

対象:

- `docs/レベル運用方針.md`
- `docs/レベルデータ形式.md`
- `levels/` 配下のファイル形式

目的:

- 既存の確認面を外部ファイルとして表現できる最小形式を決める
- レベル内容とレベル選択情報を分ける

完了条件:

- 1 レベル 1 ファイルの形式が決まっている
- 必要なら `levels/level_catalog.json` の役割が決まっている

### Step 15

確認用レベルを外部化する

対象:

- `levels/test/`
- 既存の確認面

目的:

- PHASE_05 で追加した確認面を `Main.gd` から `levels/test/` へ移す

完了条件:

- 既存の確認面が複数ファイルとして管理されている
- 確認用レベルとプレイ用レベルを分けられる

### Step 16

LevelLoader を外部ファイル対応にする

対象:

- `LevelLoader.gd`

目的:

- `levels/` 配下のレベルファイルを読み込んで `GameState` を作る
- `Main.gd` や `BoardView.gd` がファイル形式を直接解釈しないようにする

完了条件:

- レベル ID またはファイルパスから `GameState` を生成できる
- 既存の文字列行ベースの読み込み経路と矛盾しない

### Step 17

Main をレベル管理へ接続する

対象:

- `Main.gd`

目的:

- レベル内容の直書きを撤去する
- レベル一覧、現在レベル、次 / 前 / リセットを外部レベル構造へ接続する

完了条件:

- `Main.gd` に面データ直書きが残っていない
- 次のレベル / 前のレベル / リセットが新構造で動く
- 新しい確認面を追加するときに `Main.gd` を編集しなくてよい

### Step 18

動作確認と履歴更新

対象:

- `PROJECT_STATUS.md`
- `history/MILESTONE_HISTORY.md`
- `history/WORKLOG.md`
- `milestones/PHASE_07_LEVEL_PIPELINE.md`

目的:

- 既存の確認面が外部化後も動作することを記録する

完了条件:

- 既存のプレイフローを壊していない
- PHASE_07 の完了状態が文書に反映されている

## 実装時の更新ルール

各 Step が終わったら次を更新する。

- `PROJECT_STATUS.md`
- `history/MILESTONE_HISTORY.md`

フェーズ完了条件を満たしたら、対応する `milestones/PHASE_*.md` の状態も更新する。
