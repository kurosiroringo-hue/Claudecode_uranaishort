# 計測設計 (tracking.md)

UTM・短縮URL・LINE 計測タグの運用ルール。
**月収100万円ルートに必須**: 「どの投稿が」「どの LINE 配信が」「どの案件で」CV を生んだかを 80%以上の精度で追えるようにする。

---

## 1. 全体構造

```
[Threads 投稿] → [短縮URL (Bitly/Bit.ly)] → [Linktree] → [LINE 公式] → [ステップ配信内アフィリンク (UTM付)] → [ASP 案件 LP] → [CV]
```

各段階で識別子を付け、CV 時に逆引きできるようにする。

---

## 2. UTM パラメータ設計

ASP がアフィリンクに UTM を許可している場合 (大半は許可)、以下のパラメータを統一する。

```
?utm_source=threads
&utm_medium=line
&utm_campaign=fx_account_2026q2
&utm_content=line_step_5
&utm_term=post_2026-04-26-001
```

| パラメータ | 値の例 | 用途 |
|---|---|---|
| `utm_source` | threads / x / note / line | 流入元プラットフォーム |
| `utm_medium` | line / direct / linktree | 中間メディア |
| `utm_campaign` | fx_account_2026q2 / nisa_q2 | 案件カテゴリ + 期間 |
| `utm_content` | line_step_5 / linktree_top | 具体的な配信位置 |
| `utm_term` | post_2026-04-26-001 | 起点 Threads 投稿 ID |

### 命名規則

- `utm_source`: 全部小文字、英数字のみ
- `utm_campaign`: `[カテゴリ]_[期間]` 形式 (例: `fx_account_2026q2`)
- `utm_term`: `post_YYYY-MM-DD-NN` (Threads 投稿日 + 番号)
- `utm_content`: 配信タイミングを示す (`line_step_3`, `line_step_5`, `linktree_top` など)

---

## 3. 短縮URL運用 (Bitly / Bit.ly)

### 用途

- Threads プロフィールに置く Linktree URL を Bitly でラップ
- LINE 配信内のアフィリンクは UTM 付の長 URL のまま (LINE は短縮しても表示変わらず)

### 設置手順

1. Bitly アカウント作成 (無料プラン or Pro $8/月)
2. Linktree URL をカスタム短縮 (例: `bit.ly/shiho-link`)
3. Threads プロフィールに貼る
4. 月次で Bitly のクリック数を `ops/kpi-dashboard.md` に記録

### 注意

- 短縮URL は Threads 内では基本的にプロフィール内 (Linktree) のみ
- Threads キャプション内に直接短縮URL は推奨しない (シャドウバンリスク)

---

## 4. Linktree (or 独自リンクページ) 設計

### 推奨レイアウト (上から順)

```
[1] LINE公式 登録ボタン (最大文字数、最も目立つ)
    → 「NISA 1ヶ月目チェックリスト 配布中」など特典を明示

[2] note トップ (自社商品)

[3] X / Instagram など他チャネル

[4] アフィ直リンク (Phase 3 のみ、最下段に1つだけ)
    → 「楽天証券 開設はこちら #PR」など
```

### Linktree のクリック計測

- Linktree 標準の Analytics でボタンごとのクリック数を確認
- 月次で `ops/kpi-dashboard.md` に記録

---

## 5. LINE 公式 計測タグ

### 流入元の識別 (LINE Messaging API)

LINE 公式登録時、登録元 URL に固有のパラメータを持たせる:

```
https://lin.ee/XXXXXXX?ref=threads_2026q2
```

LINE 管理画面で `ref` パラメータごとの登録数を確認できる (Messaging API 利用時)。

### 簡易版 (Messaging API なしの場合)

特典 PDF を 3パターン作り、Linktree のボタンごとに別 URL を出す。
登録時の特典選択で擬似的に流入元を識別する:

- 特典A (NISA 初心者向け) → ペルソナ A
- 特典B (副業手順書) → ペルソナ B
- 特典C (老後資金診断) → ペルソナ C

### LINE 配信内クリック計測

- 配信内の URL は **UTM 付の生 URL** をそのまま貼る (LINE 側で短縮表示される)
- ASP 管理画面の `utm_content=line_step_X` でクリック数・CV 数を確認

---

## 6. ASP 別 計測対応状況

| ASP | UTM 対応 | サブID 機能 | 推奨計測法 |
|---|---|---|---|
| A8.net | ○ | ○ (a8sid) | サブID + UTM 併用 |
| もしも | ○ | ○ (a_id 等) | サブID 主軸 |
| afb | ○ | ○ | サブID 主軸 |
| アクセストレード | ○ | ○ | サブID 主軸 |
| Amazon アソシエイト | × | ○ (tag) | tag のみ |

### サブID の使い方 (A8 例)

A8 のリンク末尾に `&a8sid=th2026q2post001` を付けると、ASP 管理画面で集計可能。
UTM はリダイレクト後にも残るため、ASP 側 LP の Google Analytics でも追える (ASP が引き継ぐ場合)。

---

## 7. データ集計 (週次)

### 週次データ取得元

| 指標 | 取得元 |
|---|---|
| Threads インプレ・いいね・保存 | Threads Insights |
| プロフ遷移数 | Threads Insights |
| Linktree クリック | Linktree Analytics |
| LINE 登録数 | LINE 公式アカウント管理画面 |
| LINE 配信クリック | LINE 公式 配信レポート |
| アフィクリック・CV | 各 ASP 管理画面 |

### CSV 統合

毎週日曜夜に上記から手動で CSV を作成し、`automation/analyze-weekly.md` のプロンプトに投げる。
詳細スキーマは `analyze-weekly.md` 参照。

---

## 8. プライバシー・規約 注意

- UTM パラメータは個人特定情報を含めない (生年月日・氏名等NG)
- LINE 公式登録時の同意文に「広告配信のためのデータ取得」を明記
- 投稿に直接フォーム連携する場合は特商法・個人情報保護法の表記を要確認

---

## 9. ダッシュボード (推奨ツール)

簡易版:

- Google Sheets で月次集計シートを作成
- 列: 日付 / 投稿ID / インプレ / プロフ遷移 / LINE登録 / アフィクリック / CV
- 関数で CTR / CVR を自動計算

中級版:

- Looker Studio (旧 Google Data Studio) で可視化
- ASP 各社の API or CSV エクスポートを連携

ここまで作るのは月100万到達後で OK。

---

## 10. 計測の優先順位 (時間ない人向け)

「すべての計測を完璧に」は不要。優先順位:

1. **Threads → Linktree → LINE 登録の流入元識別** (Linktree Analytics で十分)
2. **LINE 配信 → アフィクリック** (UTM `utm_content` でステップ位置識別)
3. **アフィクリック → CV** (ASP 管理画面で十分)
4. (上級) Threads 投稿ID別の CV 寄与度 (`utm_term` で識別、サブID 必要)

最低 1〜3 が動いていれば、月30万円ルートは追える。
4 までやるのは月100万到達後で OK。

---

## 11. トラブルシューティング

### LINE 登録は増えてるが Linktree クリックが少ない
→ LINE登録の流入が Linktree 経由でない可能性 (Threads キャプション貼り直接 etc.)。
原因不明の登録が多いと改善仮説が立てづらいため、必ず Linktree 経由に統一する。

### ASP CV があるが UTM が消えてる
→ ASP 側 LP のリダイレクトで UTM が消える場合あり。
案件ごとに UTM 引き継ぎ可否を ASP に確認。
不可の場合はサブID 機能 (`a8sid` 等) を主軸に切替。

### Threads Insights が反映されない
→ プロフを「ビジネスアカウント」化していない場合あり。設定確認。
