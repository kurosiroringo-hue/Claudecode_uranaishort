# Claudecode_uranaishort

AI画像生成 × ショート動画 × アフィリエイト の自動化プロジェクト。
第一弾は **占い動画 (タロット3択 / 12星座・今日の運勢)** を、TikTok / Instagram Reels / YouTube Shorts に毎日量産し、A8.net 電話占い系案件で収益化する。

## 構成

| 工程 | ツール |
|---|---|
| 台本生成 | Claude `claude-sonnet-4-6` (prompt caching) |
| 画像生成 | OpenAI GPT Image 1 (`gpt-image-1`) |
| 音声合成 | VOICEVOX (ローカル) |
| 字幕生成 | VOICEVOX timings → ASS |
| 動画合成 | ffmpeg (`zoompan` + `xfade` + `amix`) |
| BGM | DOVA-SYNDROME / 甘茶の音楽工房 (商用OK) |

## ディレクトリ

```
docs/        戦略・コンプライアンス・運用ドキュメント
prompts/     台本/画像/CTAのプロンプトテンプレート (M1の心臓部)
config/      星座・タロット・パイプライン設定
src/         M2以降で実装する自動化スクリプト (現状空)
assets/      BGM・フォント・オーバーレイ
output/      YYYY-MM-DD/{genre}_{NNN}/ 配下に成果物
```

## マイルストーン

- **M1 (現在)**: ドキュメント+プロンプト集のみ。手動運用 (Claude Web/ChatGPT/VOICEVOX/ffmpeg) で1日3本作れる
- **M2**: 台本/画像/音声生成スクリプトを個別CLI化
- **M3**: `python src/pipeline.py --genre tarot --date today` で master.mp4 まで自動
- **M4** (任意): 投稿スケジューラ + A8成果計測

## 始める前に必ず読むもの

1. `docs/strategy.md` — ジャンル戦略とKPI
2. `docs/compliance.md` — **ステマ規制 / 景表法 / 各プラットフォーム規約**
3. `docs/operations.md` — 1日3本ワークフロー手順書

## 1動画あたりコスト

約 **¥66/本** (Claude台本 ¥2 + GPT Image 1 ×6枚 ¥63 + VOICEVOX 0円)。
A8電話占い 1件成約 (3,000〜8,000円) で 45本以上の制作費を回収できる。

詳細は `docs/cost.md` 参照。
