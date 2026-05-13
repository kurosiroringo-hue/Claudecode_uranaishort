# Gold Research EA (XAUUSD)

> **重要な免責事項**: このソフトウェアは **教育・研究目的のテンプレート** です。
> 利益を **一切保証しません**。FX/CFD は元本を超える損失が生じる可能性があります。
> 過去のバックテスト結果は将来の収益を約束しません。実弾運用は完全に自己責任で行ってください。
> 詳細は [`docs/risk_disclaimer.md`](docs/risk_disclaimer.md) を必読のこと。

## 概要

XAUUSD (ゴールド) を対象とした研究用 MetaTrader 5 EA。
**SNS で流布する「勝率○%」「○分で○万円」系の手法を、自分のバックテスト環境で再現・検証する** ことを目的とする。

## 実装シグナル (検証候補)

EA は 1 つのシグナルを `InpStrategy` パラメータで切り替えて実行する。同時に複数を動かすことはしない (検証性のため)。

| ID | 名称 | 出典 | デフォルト時間足 |
|----|------|------|----------------|
| `EMA13_PULLBACK` | EMA13 パターン手法 | X 投稿 (@Kirto_JPY) | M5 |
| `EMA20_M10` | 10分足 × 20EMA 手法 | X 投稿 (@Kirto_JPY) | M10 |
| `SMA_CROSS_M15` | SMA5/SMA20 ゴールデン/デッドクロス | X 投稿 (@mzgaangy) | M15 |
| `EMA20_M15_8BAR` | EMA20クロス + 確認足 (ピンバー/強い終値) | X 投稿 (@Cora641899...) | M15 |
| `DONCHIAN_BREAK` | Donchian ブレイクアウト (比較ベースライン) | 古典トレンドフォロー | H1 |

**いずれもエッジを保証しない。** SNSで主張されている「勝率78.4%」「5分で12万円」「月800万」「月600万」などは、サンプル数や検証手順が開示されていないか統計的有意性を主張できない。さらに `SMA_CROSS_M15` と `EMA20_M15_8BAR` の出典投稿は末尾でLINE登録を促す情報商材アフィリエイト導線 (`lin.ee/...`) を含んでおり、投稿者の動機は読者の利益とは限らない。実装目的は「自分で検証すること」であり、「主張を信じること」ではない。

## SL/TP モード (`InpStopMode`)

| モード | 仕様 |
|--------|------|
| `STOP_ATR` (デフォルト) | ATR(14) × Mult を SL、RR倍を TP |
| `STOP_PIPS` | 固定 pips SL/TP (例: SL=25pips, TP=35pips) |
| `STOP_SWING` | 直近 N バーの安値/高値を SL/TP に使用 |

## 共通リスク管理 (全シグナル共通)

- **ポジションサイズ**: 口座残高の `InpRiskPercent`% (デフォルト 0.5%) ÷ SL 距離で決定
- **SL**: ATR(14) × `InpATR_SL_Mult` (デフォルト 1.5)
- **TP**: SL 距離 × `InpRR` (デフォルト 1.5R)
- **同時保有ポジション数**: 1
- **日次損失制限**: 残高の `InpMaxDailyLossPct`% (デフォルト 3%) で当日新規停止
- **週末強制決済**: 金曜 NY クローズ前に全決済 (`InpFridayCloseHourUTC`)
- **取引時間帯**: London-NY (UTC 08:00-21:00、`InpSessionFilter` で無効化可能)

## ディレクトリ構成

```
gold-research-ea/
├── README.md                    # 本ファイル
├── LICENSE                      # MIT
├── .gitignore
├── docs/
│   ├── strategy.md              # 各シグナルの詳細仕様と意図
│   ├── risk_disclaimer.md       # リスク開示
│   └── backtest_protocol.md     # ウォークフォワード検証手順
├── MQL5/
│   ├── Experts/
│   │   └── GoldResearchEA.mq5   # メイン EA
│   ├── Include/
│   │   ├── RiskManager.mqh      # ポジションサイジング・日次DD回路ブレーカー
│   │   ├── ATRStops.mqh         # ATR ベース SL/TP 計算
│   │   ├── SessionFilter.mqh    # 時間帯・週末決済
│   │   ├── SignalEMA13Pullback.mqh
│   │   ├── SignalEMA20Pullback.mqh
│   │   └── SignalDonchian.mqh
│   └── Files/
│       └── GoldResearchEA.set   # デフォルトパラメータセット
└── tests/
    └── walk_forward_2022_2024.md
```

## インストール

1. MetaTrader 5 を開き、`File > Open Data Folder`
2. `MQL5/Experts/` 配下に `GoldResearchEA.mq5` を、`MQL5/Include/` 配下に `*.mqh` 群をコピー
3. MetaEditor でコンパイル (F7)。エラー 0 を確認
4. MT5 を再起動、`Navigator > Expert Advisors > GoldResearchEA` をチャートにドロップ

### FXGT + 10万円で始める場合

専用プリセット `MQL5/Files/GoldResearchEA_FXGT_100k.set` を用意。
セットアップ手順は [`docs/fxgt_setup.md`](docs/fxgt_setup.md) を参照。

## スプレッド/ストップレベル対策 (v0.3〜)

- `InpMaxSpreadPips` (デフォルト 5.0 pips): 現在スプレッドがこれを超えるとエントリ抑制。指標発表時の異常スプレッドで掴まされるのを防ぐ
- `InpStopLevelPadPts` (デフォルト 5 points): ブローカーの `SYMBOL_TRADE_STOPS_LEVEL` に追加マージンを乗せて発注。ストップ狩り耐性も若干向上

## 使い方 (バックテスト)

1. `View > Strategy Tester` (Ctrl+R)
2. Expert: `GoldResearchEA`、Symbol: `XAUUSD` (ブローカーによっては `GOLD` `XAUUSD.r` 等)
3. Period: `M5` (`InpStrategy=EMA13_PULLBACK` の場合)
4. Date range: 2022-01-01 ~ 2024-12-31 (アウトオブサンプル推奨)
5. Modeling: `Every tick based on real ticks`
6. Initial deposit: 10,000 USD、Leverage: 1:100
7. `Start` で実行、終了後にレポートを `tests/results/` に保存

詳細手順は [`docs/backtest_protocol.md`](docs/backtest_protocol.md) を参照。

## 出典・参考

- EMA13/EMA20 系の入退場ロジックは X (旧Twitter) ユーザー @Kirto_JPY の投稿 (2026年初頭) から着想を得て独自に機械化したもの。投稿者の主張する成績は **独立検証していない**
- Donchian チャネルブレイクアウトは Richard Donchian / Turtle Traders 由来の古典手法
