# Claudecode_uranaishort

AI画像生成 × ショート動画 × アフィリエイトの自動化プロジェクト。

## アカウントテーマ: 占い動物園 🐈🐇🦊🦉🐦🦔🐕

主役の **黒猫** を中心に、複数の動物キャラが日替わりで占いを行い、最後に鳴き声で締める。
鳴き声 (にゃおー・きゅう・コーン・ホー…) がアカウントのブランドサウンド。

- **動物 (キャスト)**: `config/cast.yaml`
- **占いツール (視覚系のみ)**: タロット / 星座 / パワーストーン / キャンドル / アンティーク鍵 / ルーン / 月相 / 古文書 / ハーブ / 花 / 木の実 / おみくじ → `config/tools.yaml`
- **動画フォーマット**: 15秒・4カット・コメント誘導型 (結果はピン留めコメントで開示)
- **収益化**: TikTok / Instagram Reels / YouTube Shorts 同時投稿 → プロフ固定リンクから A8.net 電話占い系案件へ

## 技術構成

| 工程 | ツール |
|---|---|
| 台本生成 | Claude `claude-sonnet-4-6` (prompt caching) |
| 画像生成 | OpenAI GPT Image 1 (`gpt-image-1`) |
| 音声合成 | VOICEVOX (ローカル) |
| 字幕生成 | VOICEVOX timings → ASS |
| 動画合成 | ffmpeg (`zoompan` + `xfade` + `amix`) |
| BGM / SE | DOVA-SYNDROME / 効果音ラボ (商用OK) |

## ディレクトリ

```
docs/        戦略・コンプライアンス・運用ドキュメント
prompts/     台本/画像/CTAのプロンプトテンプレート (M1の心臓部)
config/      cast / tools / 星座 / タロット / 全体設定
src/         M2以降で実装する自動化スクリプト (現状空)
assets/      BGM・SE (動物の鳴き声)・フォント・オーバーレイ
output/      YYYY-MM-DD/{cast_id}_{NNN}/ 配下に成果物 (例: cat_001/)
```

## マイルストーン

- **M1 (現在)**: ドキュメント+プロンプト集+設定のみ。手動運用 (Claude Web/ChatGPT/VOICEVOX/ffmpeg) で1日3本作れる
- **M2**: 台本/画像/音声生成スクリプトを個別CLI化
- **M3**: `python src/pipeline.py --cast cat --tool tarot --date today` で master.mp4 まで自動
- **M4** (任意): 投稿スケジューラ + A8成果計測

## 始める前に必ず読むもの

1. `docs/strategy.md` — アカウント戦略・コンテンツマトリクス・KPI
2. `docs/compliance.md` — **ステマ規制 / 景表法 / 各プラットフォーム規約**
3. `docs/operations.md` — 1日3本ワークフロー手順書

## 1動画あたりコスト

15秒・4カット構成で約 **¥45/本** (Claude台本 ¥2 + GPT Image 1 ×4枚 ¥42 + VOICEVOX 0円)。
A8電話占い 1件成約 (3,000〜8,000円) で 70本以上の制作費を回収。

詳細は `docs/cost.md` 参照。
