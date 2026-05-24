# PHASE_12_CONTINUOUS_MAGNET_FIELD.md

## 状態

最小実装完了。Godot エディタ上での実プレイ確認待ち。

## フェーズ名

常時磁場方式への移行。

## 目的

磁力ギミックを「箱を押した直後にだけ発動する連鎖処理」から、「プレイヤーが 1 手動いた後、盤面全体が安定するまで磁力に従う処理」へ変更する。

このフェーズで目指す挙動は、プレイヤーが直接押した箱だけでなく、盤面上のすべての磁力物体が毎手ごとに磁力ルールへ従うことである。

ここでの「常時」は、描画フレームごとに動き続けるリアルタイム処理ではない。倉庫番としての読みやすさを保つため、**プレイヤーの有効な 1 手の後に、盤面全体を磁場で安定させる**という意味で扱う。

## 背景

PHASE_11 までで、以下が成立している。

- 箱は `MagneticBodyState` として扱われる
- 箱は位置、向き、強さ、可動性を持つ
- 固定磁石も `MagneticBodyState` として扱われる
- 固定磁石は `kind = fixed_magnet`、`movable = false` である
- 磁力判定では、直線探索、距離判定、面の極による引力 / 反発を使っている
- 複数箱押し、回転床、固定磁石、Undo、アニメーションイベント列が存在する

現在の磁力処理は、`MoveResolver.gd` から以下のように呼ばれている。

```gdscript
if not primary_source_ids.is_empty():
	_magnet_resolver.apply_after_push_sources(state, primary_source_ids, dir, result)
```

この構造では、磁力は「箱を押した場合」かつ「押された箱を起点」かつ「押した方向」だけに発動する。

PHASE_12 では、この前提をやめる。

## このフェーズでの正式仕様

### 1. 磁力は有効な 1 手の後に毎回解決する

プレイヤーの移動が成立したら、箱を押したかどうかに関係なく、磁場処理を実行する。

つまり、以下のどちらでも磁場処理が走る。

```text
プレイヤーが空きマスへ歩いた
プレイヤーが箱を押した
```

ただし、壁にぶつかった、押しが成立しなかったなど、プレイヤーの 1 手が無効だった場合は、磁場処理を実行しない。

### 2. 磁場処理は盤面全体を見る

これまでのように「押された箱だけ」を起点にしない。

盤面上のすべての磁力物体を起点候補にする。

対象は以下を含む。

- 可動箱
- 固定磁石

固定磁石は動かないが、磁場の発生源にはなる。

### 3. 探索方向は上下左右すべて

各起点候補について、上下左右の 4 方向を調べる。

```text
      ↑
      |
← source →
      |
      ↓
```

ただし、棒磁石の軸と関係ない面には極がない。したがって、上下左右を調べても、最終的には既存の `get_pole_on_face()` によって無効になる方向がある。

例として、右向きの箱は左面と右面だけに極を持つ。上面と下面には極を持たない。

### 4. 対象探索ルールは既存仕様を維持する

対象探索は、既存の `find_first_target_in_line()` の考え方を維持する。

- 起点の隣マスから見る
- 指定方向に直線探索する
- 壁に当たったら探索終了
- 盤面外に出たら探索終了
- 最初に見つかった磁力物体だけを対象候補にする
- ゴールと回転床は探索を止めない
- プレイヤーは探索を止めない

つまり、奥に複数の磁力物体があっても、作用候補になるのは一番手前の 1 体だけである。

### 5. 距離判定と極判定は既存仕様を維持する

距離判定は既存通りでよい。

```text
source.strength + target.strength >= distance
```

極判定も既存通りでよい。

```text
同じ極なら反発
違う極なら引力
どちらかの面に極がなければ無効
```

### 6. 固定磁石も起点になる

PHASE_11 では、固定磁石は磁力判定の対象にはなるが、押し後連鎖の起点にはならない設計だった。

PHASE_12 では、固定磁石も起点として扱う。

```text
固定磁石 → 箱
```

この作用は成立してよい。

ただし、固定磁石自身は動かない。

### 7. 動ける物体だけが動く

相互作用する 2 物体の可動性に応じて、移動対象を決める。

```text
箱 と 箱            → 既存の強さ比較 / 同強度同時移動を使う
箱 と 固定磁石      → 箱だけが動く
固定磁石 と 箱      → 箱だけが動く
固定磁石 と 固定磁石 → どちらも動かない
```

既存の `resolve_interaction_candidate()`、`_resolve_single_movable_interaction()` はこの考え方に近い。PHASE_12 では、それを盤面全体の候補解決から使えるようにする。

### 8. 競合解決は既存の強さ優先を維持する

複数の磁力候補が同時に成立した場合、既存の `priority_score` の考え方を維持する。

- `priority_score = max(source.strength, target.strength)` を使う
- 最も強い候補を優先する
- 同じ強さの候補が複数ある場合は、同時に成立できるものだけ動かす
- 移動先衝突、入れ替わり衝突、プレイヤー位置への移動がある場合は、その同時移動は無効にする

最も強い候補が詰まって動けない場合、同じ磁場ステップ内で弱い候補を代わりに動かさない。これは「強い作用が盤面を支配しているが、障害物で動けない」と読むためである。

### 9. 盤面が安定するまで繰り返す

磁力で箱が動いたら、盤面全体を再評価する。

処理は次の形にする。

```text
盤面全体から磁力候補を集める
成立候補を強さ優先で解決する
箱が動いたら、回転床を適用する
盤面全体を再評価する
動くものがなくなったら終了する
```

「磁力で動いた箱だけを次の起点にする」という既存の連鎖方式は使わない。毎回、盤面全体を見直す。

### 10. 無限ループ対策を必ず入れる

常時磁場方式では、盤面が安定しない可能性がある。

このフェーズでは、以下の 2 つを必ず入れる。

```text
最大磁場解決ステップ数
同一盤面状態の再登場検知
```

推奨値は以下とする。

```gdscript
const MAX_FIELD_SETTLE_STEPS := 128
```

同一盤面状態を検出した場合は、その場で磁場解決を止める。クラッシュさせない。必要であれば `push_warning()` で警告してよい。

このフェーズでは、ループ検出をゲームギミック化しない。

## 処理順

有効な 1 手の処理順は次の通りにする。

```text
1. 入力方向を受け取る
2. プレイヤー移動または通常押しを解決する
3. 通常押しで動いた箱に回転床を適用する
4. プレイヤー位置と move_count を更新する
5. TurnResult にプレイヤー移動と通常押しのイベントを積む
6. 盤面全体の磁場を安定するまで解決する
7. クリア判定を行う
8. turn_end イベントを積む
```

重要点は、箱を押さずに歩いただけでも 6 の磁場解決へ進むことである。

## 回転床との関係

磁力で動いた箱が回転床へ入った場合も、回転床を適用する。

理由は、箱がどの原因で動いたかに関係なく、箱が回転床へ入ったなら向きが変わる方がルールとして自然だからである。

したがって、磁場解決中は次の順にする。

```text
磁力で 1 回分の移動を適用する
移動した箱が回転床に乗っていれば向きを変える
次の磁場再評価へ進む
```

固定磁石は動かないため、回転床では回転しない。

## 実装方針

### 1. `MoveResolver.gd`

現在の `apply_after_push_sources()` 呼び出しを、常時磁場用の呼び出しに置き換える。

変更前の考え方。

```gdscript
if not primary_source_ids.is_empty():
	_magnet_resolver.apply_after_push_sources(state, primary_source_ids, dir, result)
```

変更後の考え方。

```gdscript
_magnet_resolver.settle_magnetic_field(state, result)
```

この呼び出しは、プレイヤーの移動が成立した後なら、押しの有無に関係なく必ず行う。

`primary_source_ids` は不要になる。既存の `apply_after_push_sources()` をすぐ削除する必要はないが、`MoveResolver.gd` からは呼ばない。

### 2. `MagnetResolver.gd`

新しい入口を追加する。

```gdscript
func settle_magnetic_field(
	state: GameState,
	turn_result: TurnResultScript
) -> void:
```

この関数は、盤面全体の磁力候補を集め、盤面が安定するまで繰り返す。

推奨する疑似コードは以下。

```gdscript
const FIELD_DIRECTIONS := [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

const MAX_FIELD_SETTLE_STEPS := 128

func settle_magnetic_field(
	state: GameState,
	turn_result: TurnResultScript
) -> void:
	var seen_state_keys := {}

	for step in range(MAX_FIELD_SETTLE_STEPS):
		var state_key := _make_field_state_key(state)
		if seen_state_keys.has(state_key):
			push_warning("Magnetic field settle loop detected: %s" % state_key)
			break

		seen_state_keys[state_key] = true

		var candidates := build_field_interaction_candidates(state)
		if candidates.is_empty():
			break

		var selected_candidates := _get_strongest_candidates(candidates)
		if selected_candidates.is_empty():
			break

		_add_magnet_trigger_events(turn_result, selected_candidates)

		var moved_body_ids := resolve_interaction_candidates(
			state,
			selected_candidates,
			turn_result
		)

		if moved_body_ids.is_empty():
			break
```

`resolve_interaction_candidates()` は既存の候補解決を使ってよい。ただし、磁場方式では候補収集が盤面全体になる。

### 3. 全候補収集関数を追加する

`MagnetResolver.gd` に、全磁力物体と全方向から候補を作る関数を追加する。

```gdscript
func build_field_interaction_candidates(state: GameState) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var seen_pairs := {}

	for source_body in state.bodies:
		var source := source_body as MagneticBodyStateScript
		if source == null:
			continue

		for direction in FIELD_DIRECTIONS:
			var candidate := build_interaction_candidate(state, source, direction)
			if candidate.is_empty():
				continue

			var source_id := candidate["source_id"] as int
			var target_id := candidate["target_id"] as int
			var pair_key := _make_pair_key(source_id, target_id)
			if seen_pairs.has(pair_key):
				continue

			seen_pairs[pair_key] = true
			candidates.append(candidate)

	return candidates
```

ここでは、`source.movable` による除外をしてはいけない。固定磁石も起点になるためである。

### 4. 同じ 2 物体の二重候補を防ぐ

常時磁場では、同じ 2 物体を両方向から発見することがある。

例。

```text
A . . B
```

A から右を見ると B が見つかる。B から左を見ると A が見つかる。これは同じ相互作用である。

そのため、候補収集時に、物体 ID の組で重複排除する。

```gdscript
func _make_pair_key(a: int, b: int) -> String:
	var low := mini(a, b)
	var high := maxi(a, b)
	return "%d:%d" % [low, high]
```

### 5. 強い候補の選別を関数化する

磁場候補をすべて表示・解決すると、弱い候補まで発火表示されて見づらくなる。

そのため、解決前に最強候補だけを選ぶ関数を用意する。

```gdscript
func _get_strongest_candidates(candidates: Array[Dictionary]) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	if candidates.is_empty():
		return selected

	var strongest_priority := -1
	for candidate in candidates:
		strongest_priority = maxi(strongest_priority, candidate["priority_score"] as int)

	for candidate in candidates:
		if (candidate["priority_score"] as int) == strongest_priority:
			selected.append(candidate)

	return selected
```

`resolve_interaction_candidates()` 側にも強さ選別があるが、磁場方式では、イベント表示と実解決を揃えるため、呼び出し前に選別しておく。

### 6. 磁力発火イベントを関数化する

既存の `_process_source_batch()` には `magnet_trigger` イベントを積む処理がある。これを常時磁場でも使えるように関数化する。

```gdscript
func _add_magnet_trigger_events(
	turn_result: TurnResultScript,
	candidates: Array[Dictionary]
) -> void:
	if turn_result == null or candidates.is_empty():
		return

	var trigger_phase := turn_result.allocate_phase()
	for candidate in candidates:
		turn_result.add_event(ActionEventScript.magnet_trigger(
			trigger_phase,
			candidate["source_id"] as int,
			candidate["direction"] as Vector2i,
			candidate["target_id"] as int,
			candidate["interaction_type"] as String
		))
```

この関数を既存の `_process_source_batch()` からも使ってよい。

### 7. 盤面状態キーを追加する

ループ検出用に、磁力物体の状態を文字列化する。

```gdscript
func _make_field_state_key(state: GameState) -> String:
	var parts: Array[String] = []

	for body in state.bodies:
		parts.append("%d:%s:%d,%d:%d,%d:%d" % [
			body.id,
			body.kind,
			body.pos.x,
			body.pos.y,
			body.facing.x,
			body.facing.y,
			body.strength,
		])

	parts.sort()
	return "|".join(parts)
```

`movable` も含めたい場合は含めてよい。少なくとも `id`、`kind`、`pos`、`facing`、`strength` は含める。

### 8. 回転床処理を再利用可能にする

現在、回転床処理は `MoveResolver.gd` の private 関数に閉じている。

```gdscript
func _apply_rotation_tiles(state: GameState, moved_bodies: Array) -> void:
```

PHASE_12 では、磁力移動後にも同じ処理が必要になる。

推奨方針は、`scripts/systems/RotationResolver.gd` を追加し、通常押しと磁力移動の両方から使うことである。

最低限必要な責務は以下。

```gdscript
class_name RotationResolver
extends RefCounted

func apply_rotation_tiles(state: GameState, moved_bodies: Array) -> void:
	# moved_bodies に含まれる可動箱が回転床に乗っていたら facing を更新する
```

`MoveResolver.gd` は通常押しで動いた箱に対して `RotationResolver.apply_rotation_tiles()` を呼ぶ。

`MagnetResolver.gd` は `apply_planned_moves()` の中で、実際に動いた箱に対して `RotationResolver.apply_rotation_tiles()` を呼ぶ。

これにより、同強度の磁力で複数ステップ動く場合も、各ステップの移動直後に回転床が適用される。

### 9. `apply_planned_moves()` の注意点

`MagnetResolver.gd` の `apply_planned_moves()` は、磁力による移動の共通地点である。

PHASE_12 では、この関数で移動後の回転床処理も行う。

考え方は以下。

```gdscript
func apply_planned_moves(state: GameState, planned_moves: Array[Dictionary]) -> void:
	var moved_bodies: Array = []

	for planned_move in planned_moves:
		var body := state.get_body_by_id(planned_move["body_id"] as int)
		if body == null:
			continue

		body.pos = planned_move["to"] as Vector2i
		moved_bodies.append(body)

	_rotation_resolver.apply_rotation_tiles(state, moved_bodies)
```

`_rotation_resolver` を導入する場合、`MagnetResolver` の `_init()` で受け取れるようにする。

既存コードとの互換性を保つため、引数がない場合は内部で `RotationResolver.new()` してよい。

### 10. `Main.gd` の依存生成

`RotationResolver` を追加する場合、`Main.gd` で 1 つ生成し、`MoveResolver` と `MagnetResolver` へ渡す。

考え方は以下。

```gdscript
var rotation_resolver := RotationResolver.new()
var magnet_resolver := MagnetResolver.new(rotation_resolver)

func _ready() -> void:
	move_resolver = MoveResolver.new(
		magnet_resolver,
		win_checker,
		undo_history,
		rotation_resolver
	)
```

既存の `MoveResolver._init()` は引数追加が必要になる。

## 既存関数の扱い

### `apply_after_push()`

削除してもよいが、すぐ削除しなくてもよい。

ただし、PHASE_12 完了時点で、通常のゲーム進行からは呼ばれないこと。

### `apply_after_push_sources()`

同上。

過去の確認用コードとして残す場合は、コメントで「旧方式」と分かるようにする。

### `_process_source_batch()`

旧方式で使う関数として残してもよい。

ただし、常時磁場の本線では、`build_field_interaction_candidates()` と `resolve_interaction_candidates()` を使う。

## レベルと回帰確認

PHASE_12 は既存仕様を大きく変える。既存の `levels/test/` のうち、「押し後だけ磁力が発動する」ことを前提にした確認面は、期待挙動が変わる可能性がある。

そのため、既存レベルを壊れていないものとして無条件に扱わないこと。必要に応じて、説明文と確認目的を更新する。

### 追加する確認面

以下の確認面を `levels/test/` に追加する。

#### `field_walk_triggers_attract_01`

目的。

プレイヤーが箱を押さずに歩いただけで、盤面上の箱が磁力に従って動くことを確認する。

確認内容。

```text
有効な歩き移動
↓
磁場解決
↓
プレイヤーが触れていない箱が移動する
```

#### `field_fixed_source_attract_01`

目的。

固定磁石が起点になり、可動箱を引き寄せることを確認する。

確認内容。

```text
固定磁石 → 箱
```

固定磁石自身は動かず、箱だけが動くこと。

#### `field_fixed_source_repel_01`

目的。

固定磁石が起点になり、可動箱を反発させることを確認する。

確認内容。

```text
固定磁石 → 箱
```

反発方向へ箱だけが動くこと。

#### `field_all_directions_01`

目的。

押した方向に限定されず、上下左右の磁場候補が評価されることを確認する。

確認内容。

プレイヤー入力方向と異なる向きの磁力作用が発動すること。

#### `field_rotation_after_magnet_move_01`

目的。

磁力で動いた箱が回転床へ入ったとき、向きが変わり、その向きで次の磁場評価が行われることを確認する。

確認内容。

```text
磁力移動
↓
回転床で facing 更新
↓
更新後の facing で次の磁場判定
```

#### `field_loop_guard_01`

目的。

安定しない配置でもゲームが固まらないことを確認する。

確認内容。

最大ステップ数、または同一盤面状態の検出によって磁場処理が停止すること。

この確認面では、完全なパズル成立よりも、フリーズしないことを優先する。

### カタログ更新

新規確認面を追加したら、`levels/level_catalog.json` に登録する。

既存の番号順に合わせ、PHASE_12 の確認面は PHASE_11 の後ろ、または磁力系確認面のまとまりに追加する。

## 文書更新

このフェーズは正式仕様を変えるため、実装と同時に文書を更新する。

最低限、以下を更新する。

### `docs/SPEC.md`

以下の趣旨へ変更する。

変更前。

```text
磁力は箱を押した直後にのみ発動する
```

変更後。

```text
磁力は、有効な 1 手の後に盤面全体で解決される
箱を押したかどうかに関係なく、盤面が安定するまで磁場処理を行う
```

### `docs/CORE_DESIGN.md`

磁力処理の設計を、押し後起点方式から常時磁場方式へ更新する。

### `docs/PROJECT_STATUS.md`

PHASE_12 の実装状態と、現在の正式ルールを反映する。

### `docs/PHASES.md`

PHASE_12 を次フェーズまたは完了済みに追加する。

### `docs/milestones/README.md`

PHASE_12 の詳細文書を一覧に追加する。

### `docs/HISTORY.md`

作業履歴として、常時磁場方式への移行、主な実装変更、確認面追加を記録する。

### `AGENTS.md`

現在の `AGENTS.md` には、正式方針として「磁力は箱を押した直後にのみ発動する」と書かれている。

PHASE_12 完了時点では、この記述を常時磁場方式へ更新する。

## 今回まだやらないこと

以下は PHASE_12 では扱わない。

- リアルタイムで毎フレーム動く磁力
- 磁力の合力計算
- 斜め方向への移動
- 1 手の中でプレイヤーを磁力で動かす処理
- 磁力遮断壁
- 極性反転ギミック
- 固定磁石の回転
- 固定磁石の強さ変更
- ループ検出をゲーム内ギミックとして表示する演出
- レベルごとの `magnet_mode` 切り替え

PHASE_12 では、ゲーム全体の正式磁力ルールを常時磁場方式へ移行する。旧方式との併存は原則として行わない。

## 完了条件

以下を満たしたら、このフェーズは完了とする。

1. プレイヤーが空きマスへ歩いた後にも磁場処理が走る
2. プレイヤーが箱を押した後にも磁場処理が走る
3. 押された箱以外の磁力物体も磁場処理に参加する
4. 固定磁石も起点として磁場処理に参加する
5. 固定磁石自身は移動しない
6. 上下左右の候補探索が行われる
7. 同じ 2 物体の相互作用が二重処理されない
8. 距離判定、極判定、引力 / 反発は既存仕様を維持している
9. 複数候補の競合では、既存の強さ優先が維持されている
10. 磁力で動いた箱が回転床へ入った場合、向きが更新される
11. 盤面が安定するまで磁場処理が繰り返される
12. 無限ループ対策により、安定しない配置でもゲームが固まらない
13. Undo で、磁場解決前の 1 手開始前状態へ戻る
14. Reset で初期状態へ戻る
15. `TurnResult` / `ActionEvent` / `AnimationDirector` のイベント再生が破綻しない
16. 新規確認面が `levels/test/` に追加され、`level_catalog.json` に登録されている
17. `docs/` と `AGENTS.md` の仕様記述が常時磁場方式へ更新されている

## Codex 作業時の注意

実装前に必ず以下を読む。

```text
AGENTS.md
docs/README.md
docs/PROJECT_STATUS.md
docs/SPEC.md
docs/CORE_DESIGN.md
docs/LEVELS_AND_REGRESSION.md
docs/PHASES.md
docs/HISTORY.md
docs/milestones/README.md
```

この文書を `docs/milestones/active/PHASE_12_CONTINUOUS_MAGNET_FIELD.md` に置いて作業する。

作業後は、実装内容、変更理由、確認したレベル、残った未確定事項を報告する。
