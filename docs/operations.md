# 運用手順 (operations.md) — M1 手動ワークフロー

M2以降のスクリプトが揃う前に、**手動で1日3本作る** ための手順書。
所要時間: 慣れれば1本15〜25分。

---

## 必要なもの

- Claude (Web版 or claude.ai/code) — 台本生成
- ChatGPT (GPT Image 1 アクセス可) — 画像生成。Plus以上推奨
- VOICEVOX (ローカルインストール) — 音声合成。https://voicevox.hiroshiba.jp/
- ffmpeg (CLI) — 動画合成
- フォント: NotoSansJP-Bold.otf (`assets/fonts/` に配置)
- BGM: DOVA-SYNDROME や 甘茶の音楽工房 から神秘系を3〜5曲ダウンロードして `assets/bgm/` に配置 (LICENSE.mdに出典記録)
- A8.net の電話占い案件リンク (Linktree経由推奨)

---

## 手順 (タロット3択 1本作成)

### Step 1: 出力ディレクトリ作成

```bash
DATE=$(date +%Y-%m-%d)
SLUG=tarot_$(date +%H%M)
mkdir -p output/$DATE/$SLUG/images
cd output/$DATE/$SLUG
```

### Step 2: 台本生成 (Claude Web)

1. `prompts/script_system.md` の内容を Claude のシステム指示にコピペ
2. `prompts/script_user_tarot3.md` のテンプレを user メッセージに貼り、変数を埋める
   - `{date}`: 今日の日付
   - `{theme}`: 「片思いの行方」「復縁の可能性」「金運の流れ」等から選択
3. Claude が JSON で台本を返すので `script.json` として保存

```bash
# Claude の出力を script.json に保存
```

### Step 3: コンプライアンス目視チェック

`docs/compliance.md` のチェックリスト全項目に目を通す。
特に **「絶対/必ず/100%/必ず当たる」が含まれていないか** を Ctrl+F で確認。

### Step 4: 画像生成 (ChatGPT GPT Image 1)

`script.json` の `body[].image_role` に応じて画像を生成。タロット3択の標準は6枚:

| 番号 | role | プロンプト |
|---|---|---|
| 00 | hook | `prompts/image_tarot.md` の hook テンプレ + テーマ |
| 01 | card_a | カードA (「太陽」など) を art nouveau 額装で描画 |
| 02 | card_b | カードB |
| 03 | card_c | カードC |
| 04 | reveal | 選んだあなたへ…の演出カット (神秘的な手元) |
| 05 | cta | 概要欄誘導用、シンプル背景 |

ChatGPT で画像を1枚ずつ生成し、`images/00_hook.png` 〜 `images/05_cta.png` として保存。
**reference image (`assets/overlays/style_ref.png`)** を毎回添付してスタイル統一。

### Step 5: 音声合成 (VOICEVOX)

1. VOICEVOX を起動 (デフォルトで http://localhost:50021)
2. スピーカー: 九州そら (cool) を選択
3. `script.json` の `hook` `body[].text` `cta` を順に貼って読み上げ
4. 各セグメントのwavを書き出し、ffmpegで連結

```bash
# 例: hook.wav body_01.wav body_02.wav ... cta.wav を連結
ffmpeg -i "concat:hook.wav|body_01.wav|body_02.wav|body_03.wav|body_04.wav|body_05.wav|cta.wav" \
  -acodec pcm_s16le voice.wav
```

または GUI から「全選択 → 音声書き出し」でまとめて voice.wav を作成。
セグメントごとの秒数を `timings.json` に手動で控えておく:

```json
[
  {"text": "最近◯◯について悩んでいる人へ", "start_ms": 0, "end_ms": 2800},
  {"text": "選んでください、A、B、C", "start_ms": 2800, "end_ms": 5400},
  ...
]
```

### Step 6: 字幕作成

VS Code or Aegisub で ASS ファイルを作成。`subtitles.ass` のテンプレ:

```
[Script Info]
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, OutlineColour, Outline, Shadow, Alignment
Style: Default,Noto Sans JP,90,&H00FFFFFF,&H00000000,8,2,2

[Events]
Format: Layer, Start, End, Style, Text
Dialogue: 0,0:00:00.00,0:00:02.80,Default,最近◯◯について悩んでいる人へ
Dialogue: 0,0:00:02.80,0:00:05.40,Default,選んでください、A、B、C
...
```

`timings.json` の値を `H:MM:SS.cc` 形式に変換して貼る。

### Step 7: 動画合成 (ffmpeg)

```bash
# Ken Burns + クロスフェード + BGMダッキング のコマンド例
ffmpeg \
  -loop 1 -t 3 -i images/00_hook.png \
  -loop 1 -t 8 -i images/01_card_a.png \
  -loop 1 -t 8 -i images/02_card_b.png \
  -loop 1 -t 8 -i images/03_card_c.png \
  -loop 1 -t 20 -i images/04_reveal.png \
  -loop 1 -t 5 -i images/05_cta.png \
  -i voice.wav \
  -i ../../../assets/bgm/mystic01.mp3 \
  -filter_complex "
    [0:v]scale=1080:1920,setsar=1[v0];
    [1:v]scale=1080:1920,setsar=1[v1];
    [2:v]scale=1080:1920,setsar=1[v2];
    [3:v]scale=1080:1920,setsar=1[v3];
    [4:v]scale=1080:1920,setsar=1[v4];
    [5:v]scale=1080:1920,setsar=1[v5];
    [v0][v1]xfade=transition=fade:duration=0.5:offset=2.5[v01];
    [v01][v2]xfade=transition=fade:duration=0.5:offset=10[v012];
    [v012][v3]xfade=transition=fade:duration=0.5:offset=17.5[v0123];
    [v0123][v4]xfade=transition=fade:duration=0.5:offset=25[v01234];
    [v01234][v5]xfade=transition=fade:duration=0.5:offset=44.5[vall];
    [vall]subtitles=subtitles.ass[vsub];
    [6:a]volume=1.0[a_voice];
    [7:a]volume=0.18[a_bgm];
    [a_bgm][a_voice]sidechaincompress=threshold=0.05:ratio=8:attack=20:release=400[a_bgm_ducked];
    [a_voice][a_bgm_ducked]amix=inputs=2:duration=first[aout]
  " \
  -map "[vsub]" -map "[aout]" \
  -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 192k \
  -shortest \
  master.mp4
```

時間設定 (`-t 3`, `-t 8` 等) と `xfade` の `offset` は `timings.json` に合わせて調整。

### Step 8: プラットフォーム別書き出し

M1段階では `master.mp4` をそのまま3プラットフォームにアップしてOK。
微調整は M3 で `export_platforms.py` 化する。

### Step 9: キャプション作成

`prompts/cta_templates.md` のテンプレから1つ選び、テーマ・案件名を埋めて `caption.txt` に保存。

```text
#PR

最近◯◯について悩んでる人、当たってない?
気になる人は、本格鑑定はプロフリンクから ✨
※エンタメ・娯楽目的のコンテンツです
※18歳以上推奨

#タロット #タロット3択 #占い #当たる占い #復縁 #恋愛運
```

### Step 10: 投稿

- TikTok: master.mp4 をアップ、キャプション貼り付け、ハッシュタグ確認
- Instagram Reels: 同上、投稿時間予約
- YouTube Shorts: タイトル60字以内 (キャプション冒頭1行を流用)、概要欄に full caption + Linktree URL

---

## 1日3本のスケジュール例 (慣れた人)

| 時刻 | 作業 |
|---|---|
| 朝7:00 | 12星座運勢動画を1本生成 (テンプレ強い→15分) |
| 朝7:30 | 投稿 (3プラットフォーム) |
| 夜20:00 | タロット3択A (恋愛系) を生成 (25分) |
| 夜21:30 | 投稿 |
| 夜22:00 | タロット3択B (仕事/金運) を生成 (25分) |
| 夜23:00 | 投稿 |

---

## トラブルシュート

| 症状 | 対処 |
|---|---|
| ChatGPTが画像内に文字を入れてくれない | プロンプトで `画像内に「太陽」と日本語で大きく描いてください` と明示 |
| VOICEVOXの読みが変 | アクセント編集タブで手動修正、または読みをひらがなで指示 |
| ffmpegの xfade で映像が真っ黒 | `offset` の合計が `-t` の累積を超えている可能性。各 `-t` を伸ばす |
| 字幕が縦長すぎる | フォントサイズを80に下げる、または1行最大文字数を10に絞り改行を追加 |
