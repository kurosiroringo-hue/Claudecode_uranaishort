# CLAUDE.md — Threads アフィリエイト収益化プロジェクト

このサブディレクトリで作業する Claude Code への指示書。

## プロジェクト概要

**目的**: Threads を主戦場とする高単価アフィリエイトの戦略・コンテンツ・自動化・KPI 管理を一元化する。

**運用者ペルソナ**: しほ／Mio (会社員、yuru-FIRE 志向、20代後半〜30代女性、簿記スキル、イラストが描ける、堅実)。
**既存資産**: X (週21投稿)、LINE 公式、note。本プロジェクトは「Xでは届かない層 × Meta系発見性」を取りに行く第2軸。

**収益目標**:

- 3ヶ月で月30万円 (高単価1案件特化、月10〜20件)
- 12ヶ月で月100万円 (単価分散 + LINE リスト3000人ベース、月50〜80件)

## ディレクトリ構造

```
threads-affiliate/
├── CLAUDE.md                    # 本ファイル
├── strategy/                    # 戦略ドキュメント
│   ├── revenue-model.md
│   ├── persona.md
│   ├── funnel-design.md
│   └── compliance-checklist.md
├── content/                     # コンテンツ設計と生成物
│   ├── pillars.md
│   ├── templates/               # 投稿テンプレ集
│   ├── calendar/                # 月次・週次カレンダー
│   └── posts/                   # 生成済み投稿 (YYYY-MM-DD-NN.md)
├── asp/                         # ASP案件管理
│   ├── product-list.md
│   ├── lp-snippets/             # LINE内ミニLP原稿
│   └── tracking.md
├── automation/                  # Claude プロンプト群
│   ├── generate-post.md
│   ├── repurpose.md
│   └── analyze-weekly.md
└── ops/                         # KPI・ロードマップ
    ├── kpi-dashboard.md
    └── playbook-30to100.md
```

## 厳守事項

### 1. 法令遵守 (絶対)

詳細は `strategy/compliance-checklist.md` を必ず読むこと。

- **ステマ規制 (景表法 2023.10〜)**: アフィリエイトを含む投稿には必ず冒頭に `#PR` または「広告」を明記
- **景表法 (優良誤認・有利誤認)**: 「絶対」「必ず」「100%」「業界No.1」など根拠のない断定/最上級表現は禁止
- **金商法**: 投資について「断定的判断の提供」(=「絶対儲かる」「必ず上がる」) は禁止 (38条)。「元本保証」も金融商品では NG
- **薬機法**: 健康・美容案件で効果効能の断定は禁止 (例:「○日で痩せる」「シミが消える」)
- **未成年訴求NG**: 18歳未満を主たる対象にした金融サービス誘導は禁止

### 2. Threads プラットフォーム仕様

- 1投稿 **500字以内** (半角換算1000字)。改行・空行で可読性を担保
- 外部リンクは **1本まで推奨** (アルゴリズム的にも、規約的にも)
- 画像最大10枚、動画最大5分
- ハッシュタグは投稿あたり **3〜5個** (Threadsはハッシュタグ依存度が低めの設計)

### 3. ASP 規約遵守

各案件ごとに規約を都度確認。本リポジトリで主に扱う ASP は:

- A8.net
- もしもアフィリエイト
- afb (アフィb)
- アクセストレード
- Amazon アソシエイト

違反フォーマット (例: 自己アフィ、リスティング広告、比較訴求NG案件での比較訴求) は出さないこと。

### 4. ペルソナ・トーン整合

しほさんの既存ブランド (yuru-FIRE、非攻撃的、誠実、簿記スキル、堅実) と一貫したメッセージング・ペルソナを維持する。X・LINE・note の既存発信と矛盾させない。

煽り・恐怖訴求・即金教祖型・「絶対稼げる」断定は **使用禁止**。

## スコープ規律

- 1投稿の生成は `automation/generate-post.md` のフォーマットを逸脱しない
- 既存テンプレ (`content/templates/`) を **継承して差分追加** する。新スタイルガイドを増やさない
- Threads 投稿の出力は `content/posts/YYYY-MM-DD-NN.md` 命名
- Threads 投稿の生成時は **必ず** `strategy/compliance-checklist.md` のチェックを通す

## Claude API 利用方針

- モデル: `claude-sonnet-4-6` 固定
- system prompt は `automation/generate-post.md` 内の指示部分を `cache_control: ephemeral` でキャッシュ
- user prompt は最小化 (柱・型・テーマ・案件IDのみ) してキャッシュヒット率を上げる
- 出力は **tool_use による JSON 強制** で受ける (テキストパース禁止)

## Git 運用

- 開発ブランチ: `claude/threads-affiliate-system-gaUco`
- コミットは小さく、`docs:` `prompts:` `config:` `feat:` `fix:` のプレフィックスを使う
- API キー・LINE トークン・ASP 管理画面の認証情報は **絶対にコミットしない** (`.env` 必須)

## 触ってはいけないもの

- `content/posts/` 配下の生成済み投稿 (再生成可能だが履歴として残す)
- `asp/product-list.md` の単価情報 (ASP管理画面で確認した数値はユーザーが手で更新する)

## よく使うフロー

1. **新規投稿生成**: `automation/generate-post.md` のプロンプトに柱・型・テーマを入力 → Claude が投稿本文を出力 → コンプラチェック → `content/posts/` に保存
2. **既存資産の転用**: `automation/repurpose.md` のルールで X / note / LINE 配信を Threads 用に変換
3. **週次レビュー**: `automation/analyze-weekly.md` に CSV を貼り付け → 改善仮説を得る → `ops/kpi-dashboard.md` 更新
4. **月次目標調整**: `ops/playbook-30to100.md` を参照しながら次月の打ち手を決定
