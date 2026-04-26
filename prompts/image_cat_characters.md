# 猫族キャラクター 画像生成プロンプト

> **使い方**: GPT Image 1 (`gpt-image-1`) に渡す。`prompts/image_style_anchor.md` の Style Anchor ブロックを末尾に必ず追加。reference 画像として既存の黒猫カットを渡すと「同じ世界観の別の猫」が出やすい。
> 各キャストにつき **4カット** (hook / setup / choose / meow) 必要。choose カットは猫が映らないので共通使い回し可能。

---

## 共通シーン要素 (3猫すべて同一)

世界観は黒猫と完全統一。以下が全カットに必ず映り込む:

- 紫のベルベットの占いテーブル (金の星座/コンパス模様)
- 背景の暗い書架 (古めの本)
- 水晶玉 (左奥)
- アンティーク真鍮のキャンドルスタンド + ロウソクの炎
- 暗いネイビー&ゴールドの色調
- 9:16 縦構図、1024×1536

3枚のタロットカード (裏面) は黒・金の星模様、シンプル、テキスト/シンボルなし。

---

## 1. 🖤 黒猫 (既存・参考)

既存の8カット素材があるので新規生成は不要。新カットを足したい場合の参考プロンプト:

```
A serene mystical scene featuring a single black cat fortune teller. Pure 
glossy black fur with bright yellow-green eyes. The cat wears a deep purple 
hooded cloak with subtle gold filigree, a pentacle pendant on chest. The 
cat sits behind a velvet table with three face-down tarot cards. Atmosphere 
is mysterious and warm. Candlelight from the right side, crystal ball on 
the left, dim bookshelf in background.
```

---

## 2. 🧡 三毛猫 (calico_cat) — 新規生成

招き猫の代表色 = 金運の象徴。黒猫より明るく賑やかな印象。

### 2-1. Hook カット (00_hook.png)

```
A dramatic close-up portrait of a calico cat (white, orange, and black 
patches) as a fortune teller. The cat looks directly at the camera with 
bright golden-amber eyes wide open, mouth slightly parted. White fur on 
chest and face, orange patches on head and ears, black patches on the 
back of head. Whiskers prominent.

The cat wears a warm orange-gold hooded cloak with subtle gold star 
embroidery. A small lucky bell pendant on chest.

Setting: same dim mystical fortune-telling room as the existing black 
cat character — purple velvet table edge visible, single warm candle 
flame on the right, crystal ball blurry on the left, dim bookshelf in 
background.

Lighting: warm golden candlelight from right, deep navy fill.

Tight close-up framing, vertical 1024x1536, head fills 70% of frame.
```

### 2-2. Setup カット (01_setup.png)

```
A medium shot of a calico cat fortune teller seated behind a purple 
velvet table with three face-down tarot cards arranged in front. The 
cat wears a warm orange-gold cloak. The cat looks gently at the viewer 
with paws resting near the cards. White, orange, and black patched fur 
clearly visible.

The three cards have plain dark backs with subtle gold star pattern, 
no text, no symbols. Background includes a crystal ball on left, 
candle on right, dim bookshelf.

Vertical 9:16, ornamental composition matching the existing black cat 
fortune teller scene exactly.
```

### 2-3. Meow カット (03_meow.png)

```
A dramatic close-up of a calico cat with mouth open in a short bright 
meow. White, orange, and black patched fur. The mouth is open in a 
clean energetic shape (not aggressive, joyful). Whiskers spread, ears 
slightly forward, eyes bright golden-amber narrowed slightly with the 
sound.

The cat wears the warm orange-gold cloak. A bell pendant catches a 
glint of light.

Background: same dim mystical fortune-telling room, candle flame 
flickering brighter on the right.

Vertical 1024x1536 close-up.
```

### 2-4. Choose カット (黒猫と共通使い回し可)

3枚のカードのみが映るカットなので、黒猫の `02_choose.png` をそのまま流用OK。新規生成不要。

---

## 3. 💜 シャム猫 (siamese) — 新規生成

知性派・神秘的・少しエキゾチック。深い青の瞳が特徴。

### 3-1. Hook カット (00_hook.png)

```
A dramatic close-up portrait of a Siamese cat as a fortune teller. 
Classic Siamese coloring: pale cream body fur with darker seal-brown 
points on face mask, ears, and visible paws. Striking deep blue 
almond-shaped eyes locked onto the camera. Sharp intelligent expression, 
mouth slightly parted.

The cat wears a deep blue-violet hooded cloak with silver star 
embroidery. A polished silver pendant with a small blue stone on chest.

Setting: same dim mystical fortune-telling room as the existing black 
cat character — purple velvet table edge visible, candle on right, 
crystal ball on left, dim bookshelf in background.

Lighting: cool blue moonlight tone mixed with warm candlelight, more 
dramatic chiaroscuro than the calico.

Tight close-up framing, vertical 1024x1536, head fills 70% of frame.
```

### 3-2. Setup カット (01_setup.png)

```
A medium shot of a Siamese cat fortune teller seated behind a purple 
velvet table with three face-down tarot cards arranged in front. Cream 
body with seal-brown points clearly visible. The cat wears a deep 
blue-violet cloak with silver embroidery. The cat watches the viewer 
with its piercing blue eyes, paws resting calmly near the cards.

The three cards have plain dark backs with subtle gold star pattern, 
no text, no symbols. Background includes a crystal ball on left, 
candle on right, dim bookshelf.

Vertical 9:16, ornamental composition matching the existing black cat 
scene exactly.
```

### 3-3. Meow カット (03_meow.png)

```
A dramatic close-up of a Siamese cat with mouth open in a sharp short 
meow. Cream body, dark seal-brown mask and ears. The mouth is open in 
a precise vocal shape, narrower than a casual meow — focused and 
intentional. Deep blue eyes narrowed and intense. Whiskers held forward.

The cat wears the deep blue-violet cloak with silver star embroidery. 
The silver pendant catches a sharp glint.

Background: same dim mystical fortune-telling room, candle flame 
slightly stronger.

Vertical 1024x1536 close-up.
```

### 3-4. Choose カット (黒猫と共通使い回し可)

同上、黒猫の `02_choose.png` をそのまま使用。

---

## 生成ワークフロー (各猫種につき)

1. ChatGPT (or OpenAI API) で GPT Image 1 (medium quality, 1024×1536) を選択
2. 既存の `assets/overlays/style_ref.png` を reference として添付
3. 上記 Hook → Setup → Meow の順で3枚生成
4. Choose カットは黒猫の既存ファイルから流用 (再生成不要)
5. 4枚揃ったら `output/2026-04-26/{calico|siamese}_001/images/` に配置:
   - `00_hook.png`
   - `01_setup.png`
   - `02_choose.png` (黒猫から複製)
   - `03_meow.png`

合計新規生成 = **6枚** (三毛3 + シャム3)。
コスト = $0.07 × 6 = **$0.42 ≒ ¥63**。1度の投資で各猫30本以上の動画素材になる。

---

## チェックリスト (生成後)

- [ ] 解像度 1024×1536 (= 9:16)
- [ ] 背景の世界観 (紫テーブル/書架/水晶玉/キャンドル) が黒猫カットと一致している
- [ ] 三毛猫: 白・橙・黒のパッチが明確、招き猫らしさあり
- [ ] シャム猫: クリーム体色 + ダークポイント、青い瞳が印象的
- [ ] マントの色が各キャストの accent_color (cast.yaml) と整合
- [ ] 上15%・下15%が overlap 想定で空いている
- [ ] 期待していない文字 (英字ロゴ、ランダム文字) が映り込んでいない

---

## 拡張時の注意

将来 白猫・茶トラ・ロシアンブルーを追加するときも、本ファイルに同じ構造で追記する:
- 共通シーン要素はすべて引き継ぐ
- 各猫種の **マント色 + ペンダント素材 + 鳴き声口の形** で個性を出す
- 背景・テーブル・カードは常に同一
