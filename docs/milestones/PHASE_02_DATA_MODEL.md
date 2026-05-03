# PHASE_02_DATA_MODEL.md

## フェーズ名

データ構造再設計

## 目的

箱を「位置・向き・強さ」を持つ磁力物体として扱えるように、内部状態構造を作り直す。

## 対象

- `MagneticBodyState` 相当の導入
- `GameState` の再設計
- `LevelLoader` の再設計
- Undo 用スナップショットの更新

## 完了条件

- 箱を `pos + facing + strength + movable` で管理している
- 旧 `boxes + box_poles` 方式が撤去または非依存になっている
- ロードと巻き戻しが新構造で動作する

## 未解決論点

- `id` を `int` にするか `String` にするか
- `kind` を早期に入れるか最小構成に絞るか

## 次のフェーズへの引き渡し条件

磁力判定が新構造の箱を参照できること
