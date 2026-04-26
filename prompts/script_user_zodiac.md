# 12星座今日の運勢 User Prompt テンプレ

> **使い方**: `{}` の変数を実値に置き換えて Claude API の `user` メッセージに渡す。
> system は `prompts/script_system.md` 全文 (キャッシュ対象)。

---

## A. 全12星座 通し版 (45〜55秒)

```
date: {date}
genre: zodiac
seed: {seed}

このパラメータで、{date} の12星座運勢ショート動画 (45〜55秒) の台本を生成してください。

構成:
- hook (3秒): 「今日の運勢チェック、〇〇座の人は要注意」など、最下位 or 最上位の星座を匂わせて引く
- body は12星座を運勢順に **下位→上位の逆順** で発表 (12位から1位)。各星座2〜3秒、合計30〜40秒。
  - 下位 4星座 (12〜9位): image_role "zodiac_bottom"
  - 中位 4星座 (8〜5位): image_role "zodiac_mid"
  - 上位 4星座 (4〜1位): image_role "zodiac_top"
  - 各セグメント `text` は「◯◯座、△△に注意。だけど□□で挽回できそう」のように二文構成
- 中盤4位発表前に小さなタメ「ここからは特に運勢が良い4星座…」(image_role: "transition")
- cta (5秒): プロフィール固定リンクへ、#PR と緩衝句

出力は record_script tool で。
```

---

## B. 上位3 + 下位3 ダイジェスト版 (30〜35秒)

```
date: {date}
genre: zodiac
seed: {seed}
mode: digest

このパラメータで、{date} の12星座運勢ダイジェスト (30〜35秒) を生成してください。

構成:
- hook (3秒): 「今日のラッキー3星座、ワースト3星座、サクッと発表」
- body:
  - ワースト3 (3位 → 2位 → 1位の順) 各3秒 (image_role: "zodiac_bottom")
  - 軽い切替フレーズ「逆に今日エネルギーが満ちてるのは…」(image_role: "transition")
  - ラッキー3 (3位 → 2位 → 1位の順) 各3秒 (image_role: "zodiac_top")
- cta (5秒)

出力は record_script tool で。
```

---

## 変数

| 変数 | 例 | 備考 |
|---|---|---|
| `{date}` | 2026-04-26 | YYYY-MM-DD |
| `{seed}` | 426 | 同じ日付なら同じseedにすると再現可能 |

## 運勢生成のガイドライン

- 12星座すべてを毎日「最高」にしない (信頼性が下がる)。下位星座にも必ず存在させる
- 「最下位だから不幸」と書かない。「注意点はあるが工夫で挽回できる」トーンで
- 各星座の話題は **恋愛・仕事・対人・金銭・健康** から1つランダムに割り当て (健康は薬機NGに留意)
- 同じ日に複数本作る場合 (朝/昼/夜) は seed を変え、テーマの偏りも変える

## 12星座の英名・色 (画像生成用、`config/zodiac.yaml` と一致)

牡羊座 Aries / 牡牛座 Taurus / 双子座 Gemini / 蟹座 Cancer / 獅子座 Leo / 乙女座 Virgo /
天秤座 Libra / 蠍座 Scorpio / 射手座 Sagittarius / 山羊座 Capricorn / 水瓶座 Aquarius / 魚座 Pisces

詳細メタは `config/zodiac.yaml` を参照。
