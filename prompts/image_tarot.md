# タロット画像 生成プロンプト

> **使い方**: GPT Image 1 (`gpt-image-1`) に渡す本文。`{}` を実値に差し替えて使う。
> 末尾に必ず `prompts/image_style_anchor.md` の **Style Anchor ブロック全文** を追加。
> reference として `assets/overlays/style_ref.png` を image-edit に渡す。

---

## 0. Hook カット (image_role: "hook")

```
A captivating vertical illustration for a Japanese fortune-telling short video.
Theme: {theme_en}. (Examples for theme: "love and longing" / "career crossroads" / "financial flow" / "interpersonal harmony")

Composition: a young feminine fortune teller silhouette from behind, hands gently hovering over three face-down tarot cards on a dark velvet table. Soft golden candlelight. The three cards are visible but their faces are hidden, slightly tilted, ornate gold backs.

Mood: mysterious, warm, inviting. Slight smoke/incense haze.

Optional Japanese title in elegant gold serif at the top: "{theme_jp}" (only if specified, large and readable).

[Append Style Anchor here]
```

変数:
- `{theme_en}`: 英訳テーマ (例: "love and longing")
- `{theme_jp}`: 日本語テーマ (例: 「片思いの行方」)。タイトル表示が不要な場合は空欄

---

## 1. Card A / B / C (image_role: "card_a" / "card_b" / "card_c")

```
A single ornate vertical tarot card displayed prominently in the center of the frame, framed by an art nouveau gold border.

Card name: "{tarot_name_en}" ({tarot_name_jp})
Orientation: {upright_or_reversed}
Card illustration: {tarot_visual_description}

The Japanese name "{tarot_name_jp}" appears in elegant gold serif typography at the top of the card frame, large and clearly readable.
The English name "{tarot_name_en}" appears in smaller gold serif at the bottom of the card frame.

Background: deep navy starfield with subtle gold filigree corners. The card is the clear hero.

[Append Style Anchor here]
```

変数:
- `{tarot_name_en}`: 例: "The Sun" / "The Moon" / "The World"
- `{tarot_name_jp}`: 例: 「太陽」「月」「世界」
- `{upright_or_reversed}`: "upright" or "reversed"
- `{tarot_visual_description}`: カード絵柄の説明 (例: "a radiant sun with a smiling child on a white horse, sunflowers around")

### 主要22枚 (大アルカナ) のクイック参照

| 番号 | 英名 | 日本語名 | 主要キーワード |
|---|---|---|---|
| 0 | The Fool | 愚者 | 始まり、自由、無垢 |
| 1 | The Magician | 魔術師 | 創造、意志、可能性 |
| 2 | The High Priestess | 女教皇 | 直感、内省 |
| 3 | The Empress | 女帝 | 豊かさ、母性 |
| 4 | The Emperor | 皇帝 | 権威、安定 |
| 5 | The Hierophant | 教皇 | 伝統、助言 |
| 6 | The Lovers | 恋人 | 選択、愛、結びつき |
| 7 | The Chariot | 戦車 | 前進、勝利 |
| 8 | Strength | 力 | 内なる力、忍耐 |
| 9 | The Hermit | 隠者 | 内省、孤独 |
| 10 | Wheel of Fortune | 運命の輪 | 転機、巡り |
| 11 | Justice | 正義 | 公正、決断 |
| 12 | The Hanged Man | 吊るされた男 | 視点転換、忍耐 |
| 13 | Death | 死神 | 終わりと再生 |
| 14 | Temperance | 節制 | 調和、バランス |
| 15 | The Devil | 悪魔 | 執着、誘惑 |
| 16 | The Tower | 塔 | 衝撃、崩壊から再生 |
| 17 | The Star | 星 | 希望、導き |
| 18 | The Moon | 月 | 不安、直感 |
| 19 | The Sun | 太陽 | 成功、喜び |
| 20 | Judgement | 審判 | 復活、決断 |
| 21 | The World | 世界 | 完成、達成 |

詳細は `config/tarot_deck.yaml` 参照。

---

## 2. Reveal / 共通締め (image_role: "reveal")

```
A serene mystical scene representing revelation and inner guidance.
Composition: a glowing crescent moon and scattered constellations in the upper portion of the frame; below, a soft golden light orb rests in cupped hands of a feminine figure (only hands visible, palms up, jewelry minimal).
The hands are positioned at the lower-center, leaving the upper 60% open for the moon and stars.

No text in the image.

Mood: hopeful, gentle, magical realism.

[Append Style Anchor here]
```

---

## 3. CTA カット (image_role: "cta")

```
A clean composition optimized for end-of-video call-to-action overlay.
Composition: an ornate art nouveau gold frame in the upper-center with a glowing crescent moon inside; the lower 40% of the image is intentionally minimal (subtle starfield only) to leave room for subtitle text.
Soft golden light radiating outward from the moon.

No text in the image.

Mood: inviting, premium, trustworthy.

[Append Style Anchor here]
```

---

## チェックリスト (生成後)

- [ ] カード名の日本語が綺麗にレンダリングされている (誤字なし)
- [ ] 配色が他カットと調和 (色温度がブレていない)
- [ ] 文字が画面端に切れていない
- [ ] 字幕領域 (下15%) に重要な要素が被っていない
- [ ] 上1コマ目 (hook) はサムネ流用できる構図になっている
