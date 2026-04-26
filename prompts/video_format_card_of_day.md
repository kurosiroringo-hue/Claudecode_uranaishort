# 動画フォーマット: カード・オブ・ザ・デイ (15秒・1枚特化型)

> 「今日のあなたへ、1枚」 — 22枚のオリジナルタロットカード (`assets/tarot_deck/major/`) を1枚ずつ深く見せる動画フォーマット。
> 3択フォーマットと並走することで、22本のシリーズ確定枠が生まれる。

## このフォーマットの強み

- **22本の連載が確定**: 月数・タロット番号と紐づけて週2〜3本の安定供給
- **カード絵そのものを5秒以上アップで見せる** = ブランド資産 (オリジナル22枚) のショーケース
- **グッズ展開の布石**: 視聴者に「このカード絵欲しい」を醸成
- **制作工数最小**: 既存の占い師カット (黒猫/三毛/シャム) + カード画像 だけで完結。AI動画生成不要

## 構成 (15秒)

| 秒 | 内容 | 素材 |
|---|---|---|
| 0-2 | 占い師の猫が登場「今日のあなたへ、1枚🔮」 | 占い師の hook カット (黒猫 or 該当の猫) |
| 2-3 | カード裏面が中央に出てくる (フェードイン) | 共通カード裏画像 |
| 3-5 | カードがめくれる演出 (回転 or フェード切替) | カード裏 → 表 |
| 5-12 | カード表面アップ + 字幕「{jp名} / {一行メッセージ}」(ゆっくりズームイン) | `tarot_deck/major/{NN_name}.png` |
| 12-14 | 占い師の猫が鳴く 「にゃおー🐈」 (カードは隅に小さく残す) | 占い師の meow カット |
| 14-15 | テロップ「詳しい意味はピン留めコメント👇」 | 静止 + 字幕 |

合計4ビート。AI動画生成は不要、すべて静止画+ffmpegで完結。

## 占い師キャストとカードの組み合わせ

`config/tarot_deck.yaml` の `cat_featured` フィールドを参照し、**カードに登場する猫種** と **占い師の猫種** を一致させる:

| カード | 占い師 | テーマ |
|---|---|---|
| 月 (黒猫) | 🖤 黒猫 | 直感・違和感・恋愛 |
| 恋人 (黒+白猫) | 🖤 黒猫 (恋愛主担当) | 愛・選択 |
| 星 (白猫) | 🖤 黒猫 (主役で固定) | 希望・癒し |
| 愚者 (茶トラ) | 🖤 黒猫 | 始まり・自由 |
| 太陽 | 🧡 三毛猫 | 成功・喜び |
| 運命の輪 | 💜 シャム猫 | 転機 |
| ... | ... | ... |

> 占い師キャラ ≠ カード上の猫 = OK。**「黒猫占い師が、白猫が描かれた星のカードを引く」** という構図はむしろ自然。占い師は語り部、カードは絵物語。

## script.json テンプレ

```json
{
  "meta": {
    "genre": "card_of_day",
    "format": "single_card_short",
    "card_id": 18,
    "card_jp": "月",
    "card_en": "The Moon",
    "card_image": "assets/tarot_deck/major/18_moon.png",
    "fortuneteller": "black_cat",
    "target_duration_sec": 15
  },
  "hook": {
    "text": "今日のあなたへ、1枚🔮",
    "image_role": "fortuneteller_hook",
    "duration_sec": 2
  },
  "body": [
    {
      "segment_id": 1,
      "subtitle_only": "...",
      "image_role": "card_back_to_front_transition",
      "duration_sec": 3,
      "panel_note": "カード裏が中央に現れ、フェード/回転で表面に切り替わる"
    },
    {
      "segment_id": 2,
      "subtitle_only": "月\nThe Moon",
      "image_role": "card_face_zoom",
      "duration_sec": 4,
      "panel_note": "カード表面がアップ、ゆっくりズームイン。下部に大きく日本語名"
    },
    {
      "segment_id": 3,
      "subtitle_only": "今の違和感こそが\n大切なヒントになりそう",
      "image_role": "card_face_held",
      "duration_sec": 3,
      "panel_note": "カード表面のまま、メッセージのみ字幕で提示"
    },
    {
      "segment_id": 4,
      "sound_effect": "cat_meow_black.wav",
      "subtitle_only": "にゃおー🐈",
      "image_role": "fortuneteller_meow",
      "duration_sec": 2,
      "panel_note": "黒猫が鳴く。カードは右下に小さく残す or 完全切替"
    }
  ],
  "cta": {
    "subtitle_only": "詳しい意味はピン留めコメント👇",
    "image_role": "card_face_freeze",
    "duration_sec": 1
  },
  "caption": {
    "text_short": "今日のあなたへ届いたカードは『月』🌙\n詳しい意味はピン留めコメントに👇\n\n#タロット #黒猫タロット #今日のメッセージ\n\n※エンタメ・娯楽目的のコンテンツです\n※18歳以上推奨"
  },
  "pinned_comment": {
    "text": "🌙月のカード🌙\n\n今のあなたに必要なのは、違和感を無視しないこと。\n誰かの言葉、出来事、なんとなくの引っかかり…\nそれは潜在意識からの大切なメッセージかも。\n\n見ないふりをせず、心の声に耳を傾けてみて。\n\n選んだあなたへ💌 共感したらコメントで教えてね\n※エンタメ目的"
  }
}
```

## ffmpeg 合成コマンド (テンプレ)

```bash
# 引数: CARD_FILE (例: assets/tarot_deck/major/18_moon.png)
#       FORTUNE_HOOK (例: output/.../images/00_hook.png)
#       FORTUNE_MEOW (例: output/.../images/03_meow.png)
#       CARD_BACK    (例: assets/overlays/card_back.png)
#       SE_FILE      (例: assets/se/cat_meow_black.wav)
#       BGM          (例: assets/bgm/mystic_dark.mp3)
#       OUTPUT       (例: master.mp4)

ffmpeg \
  -loop 1 -t 2.2 -i "$FORTUNE_HOOK" \
  -loop 1 -t 1.5 -i "$CARD_BACK" \
  -loop 1 -t 8.5 -i "$CARD_FILE" \
  -loop 1 -t 2.2 -i "$FORTUNE_MEOW" \
  -i "$BGM" \
  -itsoffset 12 -i "$SE_FILE" \
  -filter_complex "
    [0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,zoompan=z='min(zoom+0.0008,1.05)':d=66:s=1080x1920[v0];
    [1:v]scale=720:1080:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=#0B1740,setsar=1[v1];
    [2:v]scale=900:1350:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=#0B1740,setsar=1,zoompan=z='min(zoom+0.0006,1.08)':d=255:s=1080x1920[v2];
    [3:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1,zoompan=z='min(zoom+0.001,1.05)':d=66:s=1080x1920[v3];
    [v0][v1]xfade=transition=fade:duration=0.4:offset=1.8[x01];
    [x01][v2]xfade=transition=fadeblack:duration=0.5:offset=3.0[x012];
    [x012][v3]xfade=transition=fade:duration=0.4:offset=11.5[vall];
    [vall]ass=subtitles.ass[vsub];
    [4:a]volume=0.18,aloop=loop=-1:size=2e9[a_bgm];
    [5:a]volume=1.4[a_se];
    [a_bgm][a_se]amix=inputs=2:duration=first:dropout_transition=2[aout]
  " \
  -map "[vsub]" -map "[aout]" \
  -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -r 30 \
  -c:a aac -b:a 192k \
  -t 15 \
  "$OUTPUT"
```

ポイント:
- カードは `pad` で 1080×1920 キャンバスに中央配置 (背景 navy `#0B1740`)、上下に余白を作る
- `zoompan` で ゆっくりズームイン (8.5秒で 1.0→1.08倍)
- カード裏→表のトランジションは `xfade=fadeblack` で「めくれた」感を出す
- BGM は全体ループ、SE は12秒地点 (にゃおーカット開始) に被せる

## 字幕 (subtitles.ass) 例

```
[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:00.00,0:00:02.00,Default,,0,0,0,,今日のあなたへ、1枚🔮
Dialogue: 0,0:00:02.00,0:00:05.00,Default,,0,0,0,,
Dialogue: 0,0:00:05.00,0:00:09.00,Big,,0,0,0,,月\nThe Moon
Dialogue: 0,0:00:09.00,0:00:12.00,Default,,0,0,0,,今の違和感こそが\n大切なヒントに
Dialogue: 0,0:00:12.00,0:00:14.00,Big,,0,0,0,,にゃおー🐈
Dialogue: 0,0:00:14.00,0:00:15.00,Default,,0,0,0,,結果はピン留めコメント👇
```

`Big` スタイルはカード名強調用 (140pt金色)、`Default` は本文 (90pt白)。

## 投稿戦略

### シリーズ展開

22枚を **タロット番号順** に投稿していくと「The Fool 0番から始めて世界 21番で完結」の連載感が出る。
3択動画と並走するため、週2本このフォーマット = **11週で22枚完結**。

または **テーマ順**:
- 恋愛系を黒猫担当でまとめて投稿 (恋人・月・太陽・星)
- 仕事系を三毛猫担当でまとめて (戦車・力・運命の輪・正義)
- 決断系をシャム猫担当で (節制・吊るされた男・審判・世界)

### ピン留めコメントの差別化

3択動画は「3つの結果」を並べる必要があるが、このフォーマットは **1枚のカードを深掘り** できる。
正位置の意味 + 逆位置の意味 + 著者からの一言 を ピン留めコメントに。

```
🌙月のカード🌙

【正位置】今の違和感こそ大切なヒントに
心の声、夢、潜在意識からのメッセージに耳を傾けて。

【逆位置】霧が晴れて真実が見える時
モヤモヤしていた状況に光が差すかも。

選んだあなたへ💌 ぜひコメントで感想を
※エンタメ目的
```

## グッズ展開との連動

各動画の概要欄や Phase 3 のCTAで:
- 「カード壁紙はBoothで配布中」
- 「物理タロットデックの予約はこちら」

など、22本のシリーズ配信中にグッズの導線を仕込める。Stage 3移行時に最強の販促コンテンツになる。

## 量産メモ

1動画あたりの作業:
1. `tarot_deck.yaml` から該当カードのデータをコピー → `script.json` に貼る (3分)
2. ピン留めコメントを30秒で書く (3分)
3. ffmpeg一発合成 (1分)
4. 字幕ASS差し替え (2分)

= **1本10分以内**。22本を集中制作すれば1日で全話入稿可能。
