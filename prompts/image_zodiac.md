# 星座画像 生成プロンプト

> **使い方**: GPT Image 1 (`gpt-image-1`) に渡す本文。`{}` を実値に差し替え。
> 末尾に必ず `prompts/image_style_anchor.md` の Style Anchor ブロック全文を追加。
> reference として `assets/overlays/style_ref.png` を image-edit に渡す。

---

## 0. Hook カット (image_role: "hook") — 12星座一覧

```
A captivating vertical composition of all 12 zodiac constellations arranged in a circular wheel.
Each zodiac symbol is rendered as glowing gold linework on deep navy starfield. The symbols are connected by faint gold lines forming a celestial wheel.

In the center of the wheel, a small glowing orb of golden light, suggesting cosmic energy.

At the top of the frame, an elegant Japanese serif title: "{title_jp}" (e.g., "{date} 今日の運勢", or "今日のラッキー3星座" — only if specified).

Mood: cosmic, premium, slightly cinematic.

[Append Style Anchor here]
```

変数:
- `{title_jp}`: 「2026年4月26日 今日の運勢」「ラッキー3星座&ワースト3星座」など。タイトル不要なら空欄
- `{date}`: 日付を題に入れたい場合

---

## 1. Top / Mid / Bottom 単体星座カット (image_role: "zodiac_top" / "zodiac_mid" / "zodiac_bottom")

```
A single zodiac sign featured prominently in the center of a vertical art nouveau gold frame.

Zodiac: {zodiac_en} ({zodiac_jp})
Symbol: {zodiac_symbol_description}
Constellation: faint gold dots and lines representing the actual {zodiac_en} constellation in the background

Header text in elegant gold serif at the top: "{zodiac_jp}" (large, readable Japanese)
Optional rank badge in upper-right corner: "{rank}位" in gold (e.g., "1位", "12位")

{accent_color_instruction}

Mood: {mood_modifier}

[Append Style Anchor here]
```

変数:
- `{zodiac_en}`: Aries / Taurus / ... / Pisces
- `{zodiac_jp}`: 牡羊座 / 牡牛座 / ... / 魚座
- `{zodiac_symbol_description}`: 星座のシンボル絵 (`config/zodiac.yaml` 参照)
- `{rank}`: 1〜12 (運勢順位)。順位表示が不要なら空欄
- `{accent_color_instruction}`: 各星座の守護色を補助光に使う指示。例: "Add a subtle rose accent light from upper-left, matching the zodiac's traditional color." (config/zodiac.yaml の color)
- `{mood_modifier}`:
  - top (上位): "uplifting, radiant, hopeful"
  - mid (中位): "balanced, calm, steady"
  - bottom (下位): "introspective, gentle, grounded — never ominous or threatening"
  - 注意: 下位でも **不安や恐怖を煽る絵にしない** (景表法/プラットフォーム規約)

---

## 12星座シンボル簡易リファレンス

| 星座 | 英名 | シンボル絵柄 | 守護色 |
|---|---|---|---|
| 牡羊座 | Aries | 雄羊の角を様式化したカーブ模様、勇ましい | rose red |
| 牡牛座 | Taurus | 牛の角と顔のミニマル線画、地の安定感 | emerald green |
| 双子座 | Gemini | 二人の人影が並ぶシルエット、ミラー対称 | sunny yellow |
| 蟹座 | Cancer | 蟹のシルエットと月のクレッセント | pearl silver |
| 獅子座 | Leo | 堂々たる獅子の顔と太陽のたてがみ | royal gold |
| 乙女座 | Virgo | 麦の穂を持つ女性のシルエット | soft green |
| 天秤座 | Libra | 天秤と balanced scales | sky blue |
| 蠍座 | Scorpio | 蠍の尻尾とS字曲線 | deep crimson |
| 射手座 | Sagittarius | 弓を引くケンタウロスのシルエット | violet |
| 山羊座 | Capricorn | 山羊の頭と海羊の尾 | charcoal black |
| 水瓶座 | Aquarius | 水瓶から流れる水の波紋 | electric blue |
| 魚座 | Pisces | 二匹の魚が円を描く | sea green |

詳細メタは `config/zodiac.yaml` 参照。

---

## 2. Transition カット (image_role: "transition")

```
A short transitional vertical scene used between zodiac segments.
Composition: a sweep of golden cosmic dust traveling diagonally across a dark navy starfield, suggesting a transition from one set of zodiacs to another.
No subject, no text. Pure abstract motion-implied imagery (although it's a still).

[Append Style Anchor here]
```

---

## 3. CTA カット (image_role: "cta")

タロットと共通のため `prompts/image_tarot.md` の CTA セクションを使用。

---

## チェックリスト

- [ ] 星座名の日本語が綺麗にレンダリングされている
- [ ] 順位バッジを入れた場合、数字が読める
- [ ] 下位星座でも恐怖・不安を煽る絵柄になっていない
- [ ] 配色が Style Anchor のパレットに収まっている
- [ ] 字幕領域 (下15%) に重要な要素が被っていない
