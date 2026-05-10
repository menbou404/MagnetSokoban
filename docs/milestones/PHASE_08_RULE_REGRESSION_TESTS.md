# PHASE_08_RULE_REGRESSION_TESTS.md

## フェーズ名
ルール回帰確認基盤の整備

## 状態
未着手。

設計文書は配置済みで、次は確認用レベル群の整理と `level_catalog.json` の回帰確認向け調整に進む。

## 目的
既存ルールが壊れていないことを継続確認できるように、確認用レベル群と確認手順を整備する。

---

## 背景
PHASE_07 までで、ルール、アニメーション、レベル運用の最小土台が成立している。  
この状態で新ギミックを追加すると、既存ルールの破綻が見えにくくなる。

そのため、PHASE_08 では以下を整える。

- 既存ルールを目的別に確認できる短い面
- それらを運用するための整理
- 今後の回帰確認に使う固定セット

---

## 関連文書
- `docs/テストレベル設計.md`
- `docs/回路確認方針.md`
- `docs/レベルデータ形式.md`
- `docs/README_IMPLEMENTATION_ORDER.md`

---

## 対象
- 確認用レベル群の整理
- 各確認面の目的明文化
- levels/test/ の確認面構成見直し
- 必要なら level catalog の見直し
- 既存仕様の確認手順整理
- docs/PROJECT_STATUS.md の更新
- docs/history/MILESTONE_HISTORY.md の更新
- docs/history/WORKLOG.md の更新

---

## 完了条件
1. 主要仕様に対応する確認面がある
2. 各確認面の目的が明確である
3. 少なくとも以下を確認できる
   - 基本押し
   - 引力
   - 反発
   - 連鎖
   - 強さ優先
   - 同強度同時処理
   - Undo
   - Reset
   - レベル再読込
   - アニメーション中入力停止
4. 確認面が levels/test/ で整理されている
5. 新ギミック追加前後の回帰確認に使える
6. 既存プレイフローを壊していない

---

## 推奨確認面
- `rule_push_01`
- `rule_attract_01`
- `rule_repel_01`
- `rule_chain_01`
- `rule_priority_01`
- `rule_simultaneous_01`
- `system_undo_01`
- `system_reset_01`
- `system_reload_01`
- `view_animation_lock_01`
- `view_chain_readability_01`

---

## 実装方針

### レベル
- 1 面 1 主目的を基本とする
- 短く、意図が明確であることを優先する
- 名前と description で目的が分かるようにする

### docs
- 回帰確認の対象と優先順位を docs に明文化する
- 今後ギミック追加時の入口として使える状態にする

### Main / Loader
- 必要なら確認面の順番や読み込み導線を微調整してよい
- ただし PHASE_08 の主目的はルール確認であり、新機能追加ではない

---

## 今回まだやらないこと
- 本格的な自動テスト導入
- CI 連携
- ステージ選択 UI 完成
- 新ギミック追加
- 本番用大規模面の整備
- 演出強化

---

## 次フェーズ候補
- PHASE_09_ROTATION_GIMMICK
- PHASE_10_FIXED_MAGNETS_OR_BLOCKERS

PHASE_08 完了後は、最初の追加ギミックとして回転床を入れるのが推奨である。
