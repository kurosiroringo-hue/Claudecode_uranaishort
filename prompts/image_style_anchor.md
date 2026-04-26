# 画像生成 共通スタイル Anchor

> **使い方**: すべての画像生成プロンプト (タロット/星座/フック/CTA) の **末尾** に必ずこのブロックを追加。
> さらに OpenAI GPT Image 1 の image-edit エンドポイントに `assets/overlays/style_ref.png` を reference として渡す (M2以降)。
> 手動運用 (M1) では ChatGPT に reference 画像を毎回添付する。

---

## Style Anchor (英語: 画像生成モデルへの最終指示)

```
STYLE: dark navy and gold mystical aesthetic, art nouveau ornamental frame, soft volumetric god rays, subtle starfield background, gentle bokeh, painterly digital illustration, cinematic depth of field, no harsh lines, no glitch effects.

COLOR PALETTE: deep navy #0B1740, royal purple #2A1858, antique gold #C8A24A, soft moonlight #E9E4D0. Avoid neon, avoid pure black, avoid pure white as primary background.

COMPOSITION: vertical portrait 1024x1536 (9:16 ratio). Subject centered or slightly upper third. Leave 15% safe area at top and bottom for subtitle / UI overlays. No text inside the image unless explicitly requested.

LIGHTING: warm gold rim light, cool navy fill, soft moonlight from above. Avoid harsh contrast.

CONSISTENCY: match the reference image style (provided as image input). Maintain the same ornamental frame, color palette, and lighting across all cuts of the same video.

NEGATIVE: do not use neon colors, do not use modern photorealistic celebrity faces, do not include real brand logos, do not include weapons or violent imagery, do not include text overlays unless asked.
```

---

## 使い分け

### A. 文字を画像内に入れたいとき

GPT Image 1 は日本語テキストレンダリングが強い。明示的に書く:

```
Include the Japanese text "太陽" in elegant gold serif typography, centered at the top of the card frame, large and clearly readable.
```

ただし、**字幕として ffmpeg で後乗せする内容** は画像に入れない (ダブり防止)。
画像に入れるのはタロット名・星座名・「今日の運勢」のような **タイトル要素のみ**。

### B. 文字なし純背景カット

文字レンダリングが不要なカット (例: 「reveal」演出の手元、空) は Gemini 2.5 Flash Image にスイッチしてコスト削減 ($0.039/枚 vs $0.07/枚)。
Gemini に渡すときも上記 Style Anchor を英語のまま貼って一貫性確保。

---

## reference 画像 (`assets/overlays/style_ref.png`) の作り方

初回1度だけ、以下のプロンプトで GPT Image 1 (high quality) で生成し保存:

```
A vertical 1024x1536 reference plate showcasing the project's mystic aesthetic: a single ornate art nouveau gold frame on dark navy background, with soft volumetric light rays from upper left, faint starfield, antique gold filigree details. No subject inside the frame, just the frame on background. Painterly digital illustration. No text.
```

このファイルを以後すべての画像生成で reference として渡し、ジャンル (タロット/星座/フック/CTA) によらずスタイルを揃える。

---

## チェック (画像をディレクトリに保存する前)

- [ ] 解像度 1024×1536 (= 9:16) になっている
- [ ] 上15%・下15%が overlap 想定で空いている (字幕/CTAテロップ用)
- [ ] 期待していない文字 (英字ロゴ、ランダム文字) が映り込んでいない
- [ ] 配色がパレット (ネイビー/パープル/ゴールド/ムーンライト) に収まっている
- [ ] 同一動画内の他カットと色温度・明度が大きく乖離していない
