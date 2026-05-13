# FXGT (XAUUSD / 10万円) セットアップ手順

このドキュメントは「FXGT で 10万円規模で本EAを検証する」想定の手順書。
**必ずデモ口座から始めること**。リアル投入前にデモで最低1〜2週間稼働させる。

## ステップ 0 — 事前理解 (必読)

- FXGT は **日本金融庁未登録の海外業者**。投資者保護基金の対象外
- 入出金・口座凍結トラブル事例あり (大半は規約違反だが、自己責任)
- ボーナス制度が複雑。**EA稼働口座はボーナス無し** にすること
- 10万円は「EAが動くか・勝てる可能性が見えるか」の **検証費用** と割り切る金額

## ステップ 1 — 口座開設

1. FXGT 公式サイトで口座登録
2. **口座種別**: **ECN口座** を選択 (スプレッドが約半分。10万円規模ではコスト差が致命的に効く)
   - ECN は別途コミッション ($6/lot 往復程度) かかるがトータルで安い
3. **口座通貨**: **USD** (JPY口座は内部換算で実効スプレッドが増える)
4. **レバレッジ**: 100倍〜500倍程度を選択。EAは実効レバレッジを自動制御するので最大値は重要ではない
5. **ボーナス**: **受け取らない** (ボーナス込みで証拠金が膨張するとEAが想定外のロットを出すため)

## ステップ 2 — シンボル仕様の確認

MT5にログインしたら **必ず確認**:

1. 気配値表示 (Market Watch) で `XAUUSD` を右クリック → 仕様 (Specification)
2. 以下をメモ:
   - **Digits** (通常 2 → `InpPipSize=0.1`、稀に 3 → `InpPipSize=0.01`)
   - **Contract size** (通常 100 oz)
   - **Lot step / Min volume** (通常 0.01)
   - **Stops level** (多くは 0、稀に 30〜50points)
   - **Spread** (時間帯で大きく変動するので何度か確認)
3. シンボル名が `XAUUSD` ではなく `XAUUSDz` `XAUUSD.r` など別名の場合あり → EA を起動するチャートのシンボルがそれと一致していること

## ステップ 3 — EA インストール

1. MT5 で **File > Open Data Folder**
2. 開いたフォルダの:
   - `MQL5/Experts/` ← `GoldResearchEA.mq5` をコピー
   - `MQL5/Include/` ← `.mqh` 7ファイル全部コピー
   - `MQL5/Profiles/Tester/` または `MQL5/Files/` ← `GoldResearchEA_FXGT_100k.set` をコピー
3. MetaEditor を開いて `GoldResearchEA.mq5` を **コンパイル (F7)**
4. エラー 0 を確認。警告は無視可
5. MT5 を再起動

## ステップ 4 — デモ口座でフォワード稼働

1. MT5 で FXGT デモ口座にログイン
2. デモ初期残高を **$650 (= 10万円相当)** に設定
3. `XAUUSD` の **M5 チャート** を開く
4. Navigator > Expert Advisors > `GoldResearchEA` をチャートにドラッグ
5. 設定ダイアログで **Load** ボタン → `GoldResearchEA_FXGT_100k.set` を読み込み
6. **AutoTrading** ボタンが緑になっているか確認
7. **「Allow algorithmic trading」** にチェック入っているか確認

### 期待する初日の挙動

- Experts タブに `[Init] strategy=0 tf=5 magic=...` が出る
- 取引時間 (UTC 08:00-21:00 = 日本時間 17:00-翌06:00) に入ると条件待ち
- シグナル成立で `[Entry] dir=...` ログが出る
- シグナル成立しても以下のいずれかで弾かれることあり (正常):
  - `[Skip] spread=...` ← 指標時のスプレッド拡大
  - `[Skip] lot=0` ← SL距離が大きすぎて 0.01 ロットでも規定リスクオーバー
  - `[Skip] stop level constraint not satisfiable` ← ブローカー最小SL距離問題

### 観察すべき指標 (最初の1週間)

- **平均スプレッド** (Experts ログから `spread=Xpips` を集計)
- **エントリ頻度** (1日 0-3トレード想定)
- **スキップ理由の分布** (lot=0 ばかりならリスク%を上げる検討)
- **ストップ抵触率** (SL/TPどちらに当たるか)

## ステップ 5 — 戦略切り替え (任意)

最初は `InpStrategy=0` (EMA13_PULLBACK) 推奨。1週間後に他戦略も試したい場合:

| 切替先 | 変更すべき入力 |
|--------|--------------|
| `EMA20_M10` (M10) | `InpStrategy=1`, `InpTimeframe=10` |
| `SMA_CROSS_M15` (M15) | `InpStrategy=3`, `InpTimeframe=15`, `InpStopMode=1` (PIPS) |
| `EMA20_M15_8BAR` (M15) | `InpStrategy=4`, `InpTimeframe=15`, `InpStopMode=2` (SWING) |

**同時に複数戦略を動かさないこと**。マジックナンバーが同一だとポジション管理が衝突する。複数試したい場合は別チャートで `InpMagicNumber` を変えること。

## ステップ 6 — リアル投入判断基準

デモで最低 **30トレード以上 / 4週間以上** 経過したあと:

| 指標 | 基準 |
|------|------|
| 取引数 | ≥ 30 |
| Profit Factor | ≥ 1.3 |
| 最大ドローダウン | ≤ 15% (10万円なら -$100 / -1.5万円以内) |
| 連敗 | ≤ 6 |
| 月次収益 (期待値) | > スプレッド+コミッション コスト |

**1つでも基準を下回ったらリアル投入しない**。戦略再選定 or パラメータ再調整。

## トラブルシューティング

| 症状 | 原因/対処 |
|------|----------|
| EA がエントリしない | AutoTrading が ON か / Allow algorithmic trading が ON か / 取引時間か (UTC 08-21) / シンボル名一致しているか |
| `[Skip] lot=0` が頻発 | 残高小 or SL大。`InpRiskPercent` を 1.0 → 1.5 に上げるか、`InpATR_SL_Mult` を 1.2 → 1.0 に下げる |
| `[Skip] spread` が頻発 | `InpMaxSpreadPips` を 5.0 → 8.0 に緩和 (ただしコスト増) / ECN口座に切替検討 |
| `[Skip] stop level constraint` | ブローカーのStops level が大きい。`InpStopLevelPadPts` を 5 → 0 にして再試 / SL を広げる |
| ロット計算がおかしい | シンボル仕様の Contract size と tick value を再確認 |

## 参考: FXGTとEA運用の相性で気をつけるべき点

- **ストップ狩り疑惑**: 海外業者は時折「指値直前で逆方向に瞬間的に動く」報告がある。EAのSLは余裕を持って設定 (`InpStopLevelPadPts` 加算)
- **約定スリッページ**: ECN口座でも指標時は数十points滑る。ロット小なら無視可だが、`[Entry]` ログの `entry=` 価格と実約定価格をたまに照合すること
- **週末ギャップ**: 月曜オープン時に大きく窓を開けることがある。金曜強制決済 (`InpFridayClose=true`) を必ず有効に
