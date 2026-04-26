# タロットカード素材 (assets/tarot_deck/)

「占い動物園・主は猫族の家」のオリジナルタロットデック (大アルカナ22枚) の保管場所。
このカードは動画素材としてだけでなく、**将来的なグッズ展開** (デジタル壁紙・LINEスタンプ・物販タロットデック等) の核となる長期資産。

## ディレクトリ構造

```
assets/tarot_deck/
├── README.md              ← このファイル
├── major/                 ← 動画用 (中解像度・JPEG/PNG・約1MB以下)
│   ├── 00_fool.png
│   ├── 01_magician.png
│   ├── 02_high_priestess.png
│   ├── 03_empress.png
│   ├── 04_emperor.png
│   ├── 05_hierophant.png
│   ├── 06_lovers.png
│   ├── 07_chariot.png
│   ├── 08_strength.png
│   ├── 09_hermit.png
│   ├── 10_wheel_of_fortune.png
│   ├── 11_justice.png
│   ├── 12_hanged_man.png
│   ├── 13_death.png
│   ├── 14_temperance.png
│   ├── 15_devil.png
│   ├── 16_tower.png
│   ├── 17_star.png
│   ├── 18_moon.png
│   ├── 19_sun.png
│   ├── 20_judgement.png
│   └── 21_world.png
└── major_hires/           ← グッズ用 (高解像度・PNG・印刷300dpi対応)
    ├── 00_fool@4x.png
    └── ...
```

## ファイル命名規則 (厳守)

形式: `{ID}_{英名_スネークケース}.{拡張子}`

- ID は2桁ゼロ埋め (00〜21)
- 英名は半角小文字、スペースは `_` で区切り
- 拡張子は基本 `.png` (透過なしならJPEGも可)

`config/tarot_deck.yaml` の各カードの `id` と `en` フィールドが命名に対応する。

## カード仕様 (動画用 `major/`)

| 項目 | 推奨値 |
|---|---|
| 解像度 | **1024×1536** (9:16縦)、または1500×2250 (3:2 タロット標準比) |
| 形式 | PNG (透過不要なら JPEG quality 90+ も可) |
| ファイルサイズ | 1MB以下を推奨 (動画パイプラインの読み込み速度) |
| アスペクト比 | 縦長。動画表示時は中央配置で上下に余白 (背景は黒猫の世界観カット等で埋める) |

## カード仕様 (グッズ用 `major_hires/`)

| 項目 | 推奨値 |
|---|---|
| 解像度 | **2480×3508 (300dpi A4相当)** または それ以上 |
| 形式 | PNG (アルファ含む元データ)、TIFF も可 |
| カラースペース | sRGB (印刷用は CMYK変換版を別途準備) |
| 命名 | `{ID}_{英名}@4x.png` のように `@4x` を末尾に |

## 各カードに登場する猫 (cat_featured)

`config/tarot_deck.yaml` の `cat_featured` フィールドにメモ。動画台本 (script.json) で「黒猫が黒猫の月カードを引く」などの自然なペアリングを実現するため。

| ID | カード | 登場する猫 (確定) | メモ |
|---|---|---|---|
| 0 | The Fool | 茶トラ | 旅立ちの愚者 |
| 6 | The Lovers | 黒猫+白猫 | 二人で寄り添う構図 |
| 17 | The Star | 白猫 | 星を見上げる |
| 18 | The Moon | 黒猫 | 三日月の下に座る |

残り18枚は判明し次第 `tarot_deck.yaml` の `cat_featured` を埋める。

## カード名表記の方針

カード下部の **空白カートゥーシュ** にどう表記するかは未確定:

- (1) **日本語のみ**「月」「恋人」「星」「愚者」 — 視認性◎、TikTok日本語ユーザー向け
- (2) **英日両方**「The Moon / 月」 — 海外展開時にそのまま使える
- (3) **空白のまま、動画内で字幕表記** — 美術品としての完成度◎、複数言語版を作りやすい

現状は **(3) のまま運用** (動画字幕で都度表記)。グッズ化フェーズで決定。

## 動画パイプラインでの参照

各カードの絵柄が必要な動画 (カード・オブ・ザ・デイ、3択リビール等) では、`config/tarot_deck.yaml` の各カードエントリの `image_file` フィールドからパスを引いてくる。

```yaml
# config/tarot_deck.yaml の例
- id: 18
  en: The Moon
  jp: 月
  image_file: assets/tarot_deck/major/18_moon.png
  cat_featured: black_cat
  ...
```

## グッズ展開時の準備

詳細は `docs/goods_roadmap.md` (今後作成予定)。

- Phase 1 (デジタル販売): `major_hires/` のZIP配布、Booth/Gumroad/Note有料記事
- Phase 2 (受注生産): SUZURI / pixivFACTORY に `major_hires/` の各画像をアップロード
- Phase 3 (物理デック印刷): クラウドファンディング前提、印刷会社 (萬印堂・大村印刷等) と相談

## ライセンス

このタロットカード絵は本プロジェクトのオリジナル創作物。商用利用権はあなた (作成者) に帰属。
公開時は **無断転載・AI再学習・二次配布を禁止** する旨を物販ページ等に明記。
