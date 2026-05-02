# 週次レビュー プロンプト (analyze-weekly.md)

毎週日曜夜に、過去7日間の投稿実績 CSV を Claude に投げて改善仮説を得るためのプロンプト。

---

## 1. 入力フォーマット

ユーザー (しほ) は Threads / LINE 公式 / ASP 管理画面から以下のデータを CSV で抽出して貼り付ける。

### CSV カラム定義

```csv
date,post_id,pillar,template_type,post_excerpt,impressions,likes,saves,comments,profile_clicks,line_signups_attributed,affiliate_clicks,affiliate_conversions,pr_flag,notes
2026-04-26,001,1,story-before-after,"入社2年目の貯金 8,372円...",4500,82,18,7,32,4,0,0,FALSE,
2026-04-26,002,2,list-5,"NISA を始める前に、絶対やる5選...",3200,55,42,3,18,2,0,0,FALSE,
...
```

| カラム | 説明 |
|---|---|
| `date` | 投稿日 (YYYY-MM-DD) |
| `post_id` | 投稿ID (`content/posts/` のファイル名と一致) |
| `pillar` | 1〜4 (柱) |
| `template_type` | テンプレ種別 |
| `post_excerpt` | 投稿の冒頭60文字 |
| `impressions` | インプレッション数 |
| `likes` | いいね数 |
| `saves` | 保存数 |
| `comments` | コメント数 |
| `profile_clicks` | プロフ遷移数 |
| `line_signups_attributed` | この投稿経由と推定される LINE 登録数 |
| `affiliate_clicks` | アフィリンククリック数 (LINE 内 → ASP) |
| `affiliate_conversions` | 当該投稿 / LINE 流入経由の CV |
| `pr_flag` | TRUE/FALSE (PR 投稿か) |
| `notes` | 任意メモ |

> LINE / ASP の attribution は完璧でなくて OK。**UTM + LINE タグ** で大まかに追跡 (`asp/tracking.md` 参照)。

---

## 2. システムプロンプト本文 (Claude に渡す)

> ⚠️ prompt caching 対象。

```text
あなたは「しほ／Mio」の Threads × アフィリエイト運用を分析するアナリストです。

# 役割

過去7日間の投稿実績 CSV を受け取り、以下4つの分析結果を JSON で返します:

1. 上位3投稿の共通点抽出
2. 下位3投稿の改善案
3. 翌週の優先テーマ3つ
4. LINE 登録 CVR 改善仮説

# 評価軸

## 上位 / 下位の判定基準

- **エンゲージメント率** = (likes + saves * 2 + comments * 3) / impressions
  - 保存・コメントは いいね より重い (Threads アルゴリズム加点)
- **プロフ遷移率** = profile_clicks / impressions
- **LINE 登録貢献率** = line_signups_attributed / profile_clicks

「上位3」「下位3」は エンゲージメント率 を主軸に判定し、
LINE 登録貢献率を加味する。

## 共通点抽出の観点

- 柱 (pillar) の偏り
- テンプレ種別 (template_type) の傾向
- 1行目フックのパターン
- 数字の使い方
- ペルソナ訴求 (持っているなら)
- 投稿時間帯 / 曜日 (date から推定)

## 改善案の観点

- フックの強度 (数字 / 具体性)
- 文字数 (短すぎ / 長すぎ)
- 緩衝句の有無
- ハッシュタグの妥当性

## LINE CVR 改善仮説の観点

- プロフ遷移は多いが LINE 登録少ない → プロフ・特典の見直し
- LINE 登録は多いが ASP CV 少ない → ステップ配信内容の見直し
- 解除率増加なら配信頻度・内容の見直し

# 出力 JSON フォーマット

tool_use: weekly_review_report で出力。

{
  "period": "2026-04-26 〜 2026-05-02",
  "summary": {
    "total_posts": 14,
    "total_impressions": 56000,
    "avg_engagement_rate": 2.3,
    "total_line_signups": 18,
    "total_affiliate_conversions": 2
  },
  "top_3_posts": [
    {
      "post_id": "...",
      "rank_reason": "...",
      "metrics": {...}
    },
    ...
  ],
  "common_traits_of_top": [
    "...",
    "..."
  ],
  "bottom_3_posts": [
    {
      "post_id": "...",
      "improvement": "..."
    },
    ...
  ],
  "next_week_themes": [
    {
      "theme": "...",
      "pillar": 2,
      "template_type": "list-5",
      "rationale": "..."
    },
    ...
  ],
  "line_cvr_hypothesis": [
    {
      "observation": "...",
      "hypothesis": "...",
      "test_to_run": "..."
    }
  ],
  "warnings": []
}

# 注意

- 数字に基づいた分析を最優先 (主観・印象論は避ける)
- データが不足してる場合は warnings に明記
- 改善案は「次の1週間で実行可能」な粒度
- コンプラ違反疑義 (PR 表記漏れ等) を見つけたら必ず warnings に
```

---

## 3. user prompt (毎週変動)

```text
過去7日間 (YYYY-MM-DD 〜 YYYY-MM-DD) の Threads 投稿実績です。
分析と改善仮説をお願いします。

(CSV 全文を貼り付け)

追加情報:
- 今週の特殊要因: (例: GW中で読者の購買行動変化、新ステップ配信投入、など)
- 直近の悩み: (例: プロフ遷移が伸び悩み、ASP CV が0件、など)
```

---

## 4. tool 定義

```json
{
  "name": "weekly_review_report",
  "description": "週次の Threads 投稿実績レビューと翌週の打ち手を返す",
  "input_schema": {
    "type": "object",
    "properties": {
      "period": {"type": "string"},
      "summary": {
        "type": "object",
        "properties": {
          "total_posts": {"type": "integer"},
          "total_impressions": {"type": "integer"},
          "avg_engagement_rate": {"type": "number"},
          "total_line_signups": {"type": "integer"},
          "total_affiliate_conversions": {"type": "integer"}
        }
      },
      "top_3_posts": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "post_id": {"type": "string"},
            "rank_reason": {"type": "string"},
            "metrics": {"type": "object"}
          }
        }
      },
      "common_traits_of_top": {
        "type": "array",
        "items": {"type": "string"}
      },
      "bottom_3_posts": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "post_id": {"type": "string"},
            "improvement": {"type": "string"}
          }
        }
      },
      "next_week_themes": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "theme": {"type": "string"},
            "pillar": {"type": "integer"},
            "template_type": {"type": "string"},
            "rationale": {"type": "string"}
          }
        }
      },
      "line_cvr_hypothesis": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "observation": {"type": "string"},
            "hypothesis": {"type": "string"},
            "test_to_run": {"type": "string"}
          }
        }
      },
      "warnings": {
        "type": "array",
        "items": {"type": "string"}
      }
    },
    "required": ["period", "summary", "top_3_posts", "common_traits_of_top", "bottom_3_posts", "next_week_themes", "line_cvr_hypothesis", "warnings"]
  }
}
```

---

## 5. 出力例

### 入力例 (CSV 一部)

```csv
date,post_id,pillar,template_type,post_excerpt,impressions,likes,saves,comments,profile_clicks,line_signups_attributed,affiliate_clicks,affiliate_conversions,pr_flag,notes
2026-04-26,001,1,story-before-after,"入社2年目の貯金 8,372円...",4500,82,18,7,32,4,0,0,FALSE,
2026-04-27,002,2,list-5,"NISA を始める前に、絶対やる5選...",3200,55,42,3,18,2,0,0,FALSE,
2026-04-28,003,3,hook-confession,"私が最初に開いた証券口座...",2800,38,12,2,42,5,8,1,TRUE,
2026-04-29,004,4,question,"節約のために最初にやめたこと、何ですか?",5200,120,5,28,15,1,0,0,FALSE,
2026-04-30,005,1,hook-self-roast,"宝くじが私の老後対策でした",1800,22,8,1,9,0,0,0,FALSE,
2026-05-01,006,2,case-study,"NISA 14ヶ月 入金42万→47万8千",3800,68,38,4,25,3,0,0,FALSE,
2026-05-02,007,3,hook-number,"#PR 私の証券口座1年運用結果...",2100,28,14,1,24,2,5,0,TRUE,
```

### 想定出力

```json
{
  "period": "2026-04-26 〜 2026-05-02",
  "summary": {
    "total_posts": 7,
    "total_impressions": 23400,
    "avg_engagement_rate": 2.8,
    "total_line_signups": 17,
    "total_affiliate_conversions": 1
  },
  "top_3_posts": [
    {
      "post_id": "004",
      "rank_reason": "コメント28件は突出。質問投稿型が会話を生み、アルゴリズム加点を得たと推定。",
      "metrics": {"engagement_rate": 4.5, "comments": 28}
    },
    {
      "post_id": "002",
      "rank_reason": "保存42件 (= シェア性最高)。リスト型は保存される傾向が確認できる。",
      "metrics": {"saves": 42, "engagement_rate": 4.7}
    },
    {
      "post_id": "006",
      "rank_reason": "保存38件 + 高プロフ遷移率(0.66%)。Case Study (数字公開) はLINE誘導と相性が良い。",
      "metrics": {"saves": 38, "profile_click_rate": 0.66}
    }
  ],
  "common_traits_of_top": [
    "数字 or 具体的な質問が1行目にある",
    "情報提供 (pillar 2) と関係構築 (pillar 4) の組み合わせが伸びている",
    "保存・コメントが多い投稿は LINE 登録に貢献度高"
  ],
  "bottom_3_posts": [
    {
      "post_id": "005",
      "improvement": "hook-self-roast 単独は伝わりにくい。冒頭に金額数字を追加し、「Before/After」型に書き換えるとよい。"
    },
    {
      "post_id": "007",
      "improvement": "PR投稿だがエンゲージメントは中位。フックを「数字断言」から「告白型」に変えてLINE誘導文を1行追加するとよい。"
    },
    {
      "post_id": "003",
      "improvement": "PR投稿としてはプロフ遷移率1.5%で OK だが、CV 1件にとどまる。ステップ配信の#5 案件提案を見直す余地。"
    }
  ],
  "next_week_themes": [
    {
      "theme": "「節約で最初にやめたサブスク」読者参加型",
      "pillar": 4,
      "template_type": "question",
      "rationale": "今週の最高エンゲージメントは質問型。同型を週2回に増やす検証。"
    },
    {
      "theme": "iDeCo の節税効果を数字で",
      "pillar": 2,
      "template_type": "list-5",
      "rationale": "保存型が伸びている。NISA に偏ってるので iDeCo を追加してテーマ広げる。"
    },
    {
      "theme": "クレカ自己アフィの体験談 + 案件紹介 (#PR)",
      "pillar": 3,
      "template_type": "case-study",
      "rationale": "Case Study 型のプロフ遷移率が高い。Phase 3 想定で収益化柱を1本投入。"
    }
  ],
  "line_cvr_hypothesis": [
    {
      "observation": "プロフ遷移合計165、LINE 登録17人 (CVR 10.3%)。標準値15%を下回る。",
      "hypothesis": "プロフ文の特典訴求が弱い、もしくは特典 PDF の魅力が読者と合っていない。",
      "test_to_run": "翌週前半: プロフ3行目を「特典名 + 数字」型に書き換え (例: 『NISA 1ヶ月目チェックリスト 配布中』)。後半に効果測定。"
    },
    {
      "observation": "アフィリンクCV 1件、クリック13件中 (CVR 7.7%)。",
      "hypothesis": "ステップ#5 の案件提案文が唐突 or 教育不足。",
      "test_to_run": "ステップ#3-4 の教育配信を厚くし、#5 案件提案を「失敗回避」軸に書き換え。"
    }
  ],
  "warnings": []
}
```

---

## 6. 運用フロー

### 毎週日曜夜

1. Threads / LINE / ASP からデータを CSV にエクスポート
2. このプロンプトに CSV を投げて分析実行
3. 出力 JSON を `ops/weekly-review/YYYY-MM-DD.md` に保存
4. `ops/kpi-dashboard.md` の今月数値を更新
5. `next_week_themes` を `content/calendar/` の翌週分に反映
6. `line_cvr_hypothesis.test_to_run` を翌週の検証アクションとしてメモ

### 月末

- 4週分のレビューを統合
- 月次 KPI レポートを `ops/kpi-dashboard.md` に追記
- `ops/playbook-30to100.md` の進捗を更新

---

## 7. 注意点

- 1週間のデータは少なすぎて統計的有意性は低い。3週間以上の累計で傾向を見るのが本筋
- 季節要因 (年末年始・GW等) はレビューでは過剰反応しない
- コンプラ違反疑義 (PR 漏れ等) は最優先で対応 (warnings に出たら他より先に処理)
