# milestones/README.md

## 目的

フェーズごとの詳細文書を一覧できる入口である。
`docs/PHASES.md` は全体の概要、このディレクトリ配下の `PHASE_*.md` は各フェーズの詳細仕様、対象、確認項目、完了条件を扱う。

## 運用ルール

- フェーズごとの詳細は `PHASE_XX_NAME.md` に 1 ファイルでまとめる
- 進行中の詳細は `active/` に置く
- 次フェーズ候補や未着手の詳細案は `planned/` に置く
- 完了済みの詳細は `completed/` に移す
- ルート直下に `docs/PHASE_XX.md` を増やさない
- 新しいフェーズを追加したら `docs/PHASES.md` に概要を追記する
- 状態が変わったら対象の `PHASE_*.md`、`docs/PROJECT_STATUS.md`、`docs/HISTORY.md` を更新する
- 仕様変更を伴う場合は `docs/SPEC.md` または関連文書を先に更新する

## ディレクトリ

| ディレクトリ | 役割 |
| --- | --- |
| `active/` | いま実装または確認しているフェーズ |
| `planned/` | 次フェーズ候補、未着手の詳細案 |
| `completed/` | 完了済みフェーズの詳細履歴 |

## 一覧

| フェーズ | 状態 | 詳細 |
| --- | --- | --- |
| PHASE_12_CONTINUOUS_MAGNET_FIELD | 最小実装完了 / 実プレイ確認待ち | `active/PHASE_12_CONTINUOUS_MAGNET_FIELD.md` |
| PHASE_09_BASICPUSH | 最小実装完了 | `completed/PHASE_09_BASICPUSH.md` |
| PHASE_10_ROTATION_GIMMICK | 最小実装完了 | `completed/PHASE_10_ROTATION_GIMMICK.md` |
| PHASE_11_FIXED_MAGNETS | 最小実装完了 | `completed/PHASE_11_FIXED_MAGNETS.md` |

## 次フェーズ

PHASE_12_CONTINUOUS_MAGNET_FIELD は最小実装完了。
実プレイ確認後、次の正式フェーズを決める。
