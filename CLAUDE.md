# CLAUDE.md

このリポジトリで作業する Claude Code 向けプロジェクト指示。

## プロジェクト概要

AI占いショート動画 × アフィリエイト自動化。
**アカウントテーマ: 「占い動物園」 — 様々な動物が日替わりで占い、最後に鳴いて締める。**

- 1アカウントで複数の動物キャラ (黒猫・白うさぎ・狐…) が登場
- 全動画 **15秒・4カット・コメント誘導型** で統一 (= `prompts/script_user_3choice_short.md`)
- 動物の鳴き声 (にゃおー・きゅう・コーン…) がアカウントのブランドサウンド
- 結果はピン留めコメントで開示 → コメント率と再視聴率を最大化

詳細は `README.md` `docs/strategy.md` `config/cast.yaml` 参照。

## 厳守事項

### コンプライアンス (絶対)

すべての台本・キャプション・概要欄テキストは、生成時と検査時の **二層** でチェックする。
詳細ルールは `docs/compliance.md` を必ず読むこと。

要点:

- **ステマ規制 (2023.10〜)**: 動画キャプション/概要欄に必ず `#PR` または「広告」を含める
- **景表法**: 「絶対」「100%」「必ず当たる」「儲かる」などの断定表現は禁止
- **薬機法**: 健康・治療・効能を匂わせる表現は禁止 (例:「不眠が治る」「痩せる」)
- **未成年訴求NG**: 18歳未満を主たる対象とした金銭的サービス誘導は禁止
- **娯楽目的の前置き**: 占い結果には「※エンタメ・娯楽目的です」を自然に組み込む

これらの違反は `compliance_check.py` (M2以降) で正規表現により自動検査され、引っかかった場合パイプラインを停止させる。

### スコープ規律

- 1動画あたりの工程は `データフロー` (script.json → images → voice → subtitles → master.mp4 + pinned_comment.txt) を逸脱しない
- 既存のプロンプトテンプレを **継承して差分追加** すること。新しいスタイルガイドを増やさない
- **デフォルト尺は15秒** (コメント誘導型)。45〜60秒の長尺フォーマットは特別な深掘り回のみ
- 9:16 / 1080×1920 / 30fps を逸脱しない
- 出力フォルダ命名は `output/YYYY-MM-DD/{cast_id}_{NNN}/` (例: `cat_001/` `rabbit_002/`)。`cast_id` は `config/cast.yaml` の active キーと一致させる

### Claude API 利用方針

- モデルは `claude-sonnet-4-6` 固定 (台本品質と速度のバランス)
- system prompt (`prompts/script_system.md`) は **prompt caching 対象**。最後のブロックに `cache_control: {"type": "ephemeral"}` を付ける
- user prompt は最小化 (日付 + 星座/タロットseed のみ) して キャッシュヒット率を上げる
- 出力は **tool_use による JSON 強制** で受ける (テキストパース禁止)

### 画像生成方針

- メイン: OpenAI GPT Image 1 (`gpt-image-1`)
  - 日本語テキスト (タロット名・星座名) を画像に直接入れたいカットに使う
  - reference image (`assets/overlays/style_ref.png`) を image-edit で渡しスタイル統一
  - 解像度 1024×1536 縦、quality `medium`
- サブ: Gemini 2.5 Flash Image (Nano Banana)
  - 文字なし純背景カット (例: 神秘的な空、星空) でコスト圧縮したい時のみ

### TTS 方針

- VOICEVOX ローカル (port 50021) を使用
- 占い向け推奨スピーカー: 九州そら (cool) / 玄野武宏 / 雀松朱司
- `accent_phrases` から `mora.vowel_length` `consonant_length` を集計し正確な発話秒数を計算
- 字幕タイミングは Whisper を介さず VOICEVOX の出力から直接生成

### Git 運用

- 開発ブランチ: `claude/ai-affiliate-fortune-videos-0BsMq`
- このブランチ以外への push は禁止 (明示的な指示があった場合のみ)
- コミットは小さく、`docs:` `prompts:` `config:` `feat:` `fix:` のプレフィックスを使う
- API キーは絶対にコミットしない (`.env` は `.gitignore` 必須)

## 触ってはいけないもの

- `output/` 配下の生成済みファイル (再生成可能だが履歴として残す)
- `assets/bgm/LICENSE.md` (素材出典記録)

## よく使うコマンド (M2以降)

```bash
# 台本生成
python src/generate_script.py --genre tarot --seed 2026-04-26

# 画像生成
python src/generate_images.py --script output/2026-04-26/tarot_001/script.json

# 音声合成
python src/synthesize_voice.py --script output/2026-04-26/tarot_001/script.json

# パイプライン一発実行
python src/pipeline.py --genre tarot --date today
```
