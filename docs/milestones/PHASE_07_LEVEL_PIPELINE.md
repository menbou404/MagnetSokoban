# PHASE_07_LEVEL_PIPELINE.md

## フェーズ名
レベル運用基盤の整備

## 状態
最小実装完了。

既存確認面を `levels/test/` の `.lvl.json` へ外部化し、`levels/level_catalog.json` と `LevelLoader.gd` 経由で読み込む構造へ移行済み。
次は実プレイで外部化後の確認面を確認する。

## 目的
レベルを `Main.gd` から外部化し、`levels/` を正式なレベル管理場所として扱えるようにする。  
あわせて、確認用レベルとプレイ用レベルを分けやすい土台を作る。

## 背景
PHASE_06 までで、コアのルールと可読性改善は最小限成立している。  
次に新ギミックを追加する前に、レベル追加と確認を安全に回せる構造へ移る必要がある。

現状の課題:
- `Main.gd` に確認面が直書きされている
- レベルの追加や並べ替えで Main を編集する必要がある
- テスト用面とプレイ用面を分けにくい
- Codex がレベル追加だけを安全に実行しにくい

## 関連文書
- `docs/レベル運用方針.md`
- `docs/レベルデータ形式.md`
- `docs/データ構造.md`
- `docs/README_IMPLEMENTATION_ORDER.md`

## 対象
- `Main.gd` から確認面の直書きを外す
- `levels/` からレベルを読み込めるようにする
- `LevelLoader.gd` を外部ファイル対応にする
- 必要なら level catalog を導入する
- リセットとレベル切替を新構造で維持する
- 確認用レベルを `levels/test/` へ移す
- 今後のプレイ用レベルを `levels/play/` へ置けるようにする

## 完了条件
1. `Main.gd` に面データ直書きが残っていない
2. `levels/` からレベルを読み込める
3. 確認用レベルを複数ファイルで管理できる
4. 次のレベル / 前のレベル / リセットが動く
5. 既存の確認面が外部化後も動作する
6. Main を触らずに新しい確認面を追加できる
7. 既存のプレイフローを壊していない

## 推奨ディレクトリ構成

```text
levels/
  test/
    basic_push_01.lvl.json
    basic_attract_01.lvl.json
    basic_repel_01.lvl.json
    chain_01.lvl.json
    conflict_priority_01.lvl.json
    conflict_simultaneous_01.lvl.json
  play/
    stage_001.lvl.json
  level_catalog.json
```

## 今回まだやらないこと
- 本番用の大規模レベル設計
- レベルエディタ
- 難易度カーブの正式設計
- オンライン共有
- 外部ツール連携
- 追加ギミックの導入

## 次フェーズ候補
- 追加ギミックの導入
- 本番レベル設計
- レベル選択 UI
- 本番用アート差し替え
