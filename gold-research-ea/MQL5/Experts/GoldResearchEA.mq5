//+------------------------------------------------------------------+
//|                                              GoldResearchEA.mq5 |
//|                       Research/educational template — XAUUSD.    |
//|                                                                  |
//|  IMPORTANT: NO PROFIT GUARANTEE. Past backtest performance does  |
//|  not guarantee future results. FX/CFD trading can result in      |
//|  losses exceeding deposited capital. Use at your own risk.       |
//|  See docs/risk_disclaimer.md before any live use.                |
//+------------------------------------------------------------------+
#property copyright   "Gold Research EA (MIT)"
#property version     "0.3"
#property description "XAUUSD research EA — EMA/SMA pullback + Donchian baseline"
#property strict

#include <Trade/Trade.mqh>
#include "../Include/RiskManager.mqh"
#include "../Include/ATRStops.mqh"
#include "../Include/SessionFilter.mqh"
#include "../Include/SignalEMA13Pullback.mqh"
#include "../Include/SignalEMA20Pullback.mqh"
#include "../Include/SignalDonchian.mqh"
#include "../Include/SignalSMACross.mqh"
#include "../Include/SignalEMA20Cross8Bar.mqh"

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY
{
   EMA13_PULLBACK   = 0,
   EMA20_M10        = 1,
   DONCHIAN_BREAK   = 2,
   SMA_CROSS_M15    = 3,
   EMA20_M15_8BAR   = 4
};

enum ENUM_STOP_MODE
{
   STOP_ATR   = 0,   // ATR(N) x InpATR_SL_Mult, TP = SL x InpRR
   STOP_PIPS  = 1,   // Fixed pips (InpSL_Pips / InpTP_Pips)
   STOP_SWING = 2    // Recent swing high/low (InpSwingLookback bars)
};

input group "=== Strategy ==="
input ENUM_STRATEGY   InpStrategy        = EMA13_PULLBACK;
input ENUM_TIMEFRAMES InpTimeframe       = PERIOD_CURRENT;   // PERIOD_CURRENT = use chart TF

input group "=== EMA13 pullback ==="
input int    InpEMA13_Fast       = 13;
input int    InpEMA13_Slow       = 100;
input int    InpEMA13_SlopeBars  = 10;

input group "=== EMA20 pullback (M10) ==="
input int    InpEMA20_Period     = 20;
input int    InpEMA20_SlopeBars  = 5;
input bool   InpEMA20_UseHTF     = false;
input ENUM_TIMEFRAMES InpEMA20_HTF        = PERIOD_H1;
input int    InpEMA20_HTF_Period = 50;

input group "=== Donchian baseline ==="
input int    InpDonchianPeriod   = 20;

input group "=== SMA cross (M15) ==="
input int    InpSMA_Fast         = 5;
input int    InpSMA_Slow         = 20;

input group "=== EMA20 cross + 8-bar (M15) ==="
input int    InpEMA20Cross_Period       = 20;
input int    InpEMA20Cross_Lookback     = 8;
input double InpEMA20Cross_StrongClose  = 0.7;   // close in top X of bar range
input double InpEMA20Cross_PinWickRatio = 2.0;   // pin-bar wick/body ratio

input group "=== Risk management ==="
input double InpRiskPercent      = 0.5;    // % of balance per trade
input ENUM_STOP_MODE InpStopMode = STOP_ATR;
input int    InpATR_Period       = 14;
input double InpATR_SL_Mult      = 1.5;
input double InpRR               = 1.5;    // TP = SL * RR (ATR & PIPS & SWING modes)
input double InpPipSize          = 0.1;    // XAUUSD: 1 pip = 0.1 (10 points @ digits=2)
input double InpSL_Pips          = 25.0;   // STOP_PIPS mode
input double InpTP_Pips          = 35.0;   // STOP_PIPS mode (ignored if InpRR>0)
input bool   InpPips_UseRR       = false;  // STOP_PIPS: derive TP from SL_Pips * RR
input int    InpSwingLookback    = 20;     // STOP_SWING: bars to scan for swing H/L
input double InpMaxDailyLossPct  = 3.0;    // daily DD circuit breaker
input double InpMaxSpreadPips    = 5.0;    // skip entry if current spread > this (XAUUSD pips)
input int    InpStopLevelPadPts  = 5;      // extra points beyond broker stop level

input group "=== Session ==="
input bool   InpSessionFilter    = true;
input int    InpSessionStartUTC  = 8;      // 08:00 UTC inclusive
input int    InpSessionEndUTC    = 21;     // 21:00 UTC exclusive
input bool   InpFridayClose      = true;
input int    InpFridayCloseHourUTC = 20;

input group "=== Misc ==="
input int    InpCooldownBars     = 3;
input long   InpMagicNumber      = 20260510;
input string InpComment          = "GoldResearchEA";

//+------------------------------------------------------------------+
//| Globals                                                           |
//+------------------------------------------------------------------+
CTrade                  trade;
CRiskManager            risk;
CATRStops               atrStops;
CSessionFilter          session;
CSignalEMA13Pullback    sigEMA13;
CSignalEMA20Pullback    sigEMA20;
CSignalDonchian         sigDonchian;
CSignalSMACross         sigSMA;
CSignalEMA20Cross8Bar   sigEMA20Cross;

ENUM_TIMEFRAMES g_tf;
datetime        g_lastBarTime  = 0;
datetime        g_lastEntryBar = 0;
int             g_lastEntryDir = 0;

//+------------------------------------------------------------------+
//| Helpers                                                           |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES ResolveTF()
{
   if(InpTimeframe == PERIOD_CURRENT) return (ENUM_TIMEFRAMES)Period();
   return InpTimeframe;
}

bool HasOpenPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
         PositionGetString(POSITION_SYMBOL) == _Symbol)
         return true;
   }
   return false;
}

int OpenPositionSide()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber &&
         PositionGetString(POSITION_SYMBOL) == _Symbol)
      {
         long type = PositionGetInteger(POSITION_TYPE);
         if(type == POSITION_TYPE_BUY)  return  1;
         if(type == POSITION_TYPE_SELL) return -1;
      }
   }
   return 0;
}

void CloseAllOurPositions(const string reason)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(!trade.PositionClose(ticket))
         PrintFormat("[Close] %s failed ticket=%I64u err=%d", reason, ticket, GetLastError());
   }
}

ENUM_SIGNAL_DIR DispatchSignal()
{
   switch(InpStrategy)
   {
      case EMA13_PULLBACK:  return sigEMA13.CheckSignal();
      case EMA20_M10:       return sigEMA20.CheckSignal();
      case DONCHIAN_BREAK:  return sigDonchian.CheckSignal();
      case SMA_CROSS_M15:   return sigSMA.CheckSignal();
      case EMA20_M15_8BAR:  return sigEMA20Cross.CheckSignal();
   }
   return SIG_NONE;
}

//--- Current spread in pips (using configured InpPipSize).
double CurrentSpreadPips()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0 || bid <= 0 || InpPipSize <= 0) return 1e9;
   return (ask - bid) / InpPipSize;
}

//--- Enforce broker minimum stop distance (SYMBOL_TRADE_STOPS_LEVEL) on SL/TP.
//    Returns false if entry-side distance can't reach the broker requirement
//    even after adjustment (the constraint conflicts with the trade direction).
bool EnforceStopLevel(ENUM_SIGNAL_DIR dir, double entry, double &sl, double &tp)
{
   long stops_level_pts = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0) return false;
   double min_dist = (stops_level_pts + InpStopLevelPadPts) * point;

   if(dir == SIG_LONG)
   {
      if(entry - sl < min_dist) sl = entry - min_dist;
      if(tp - entry < min_dist) tp = entry + min_dist;
      return (sl < entry) && (tp > entry);
   }
   if(dir == SIG_SHORT)
   {
      if(sl - entry < min_dist) sl = entry + min_dist;
      if(entry - tp < min_dist) tp = entry - min_dist;
      return (sl > entry) && (tp < entry);
   }
   return false;
}

//--- Compute SL/TP using the selected stop mode. Returns false on failure.
bool ComputeStops(ENUM_SIGNAL_DIR dir, double entry, double &sl, double &tp)
{
   if(InpStopMode == STOP_ATR)
   {
      return (dir == SIG_LONG)
                ? atrStops.LongStops(entry, InpATR_SL_Mult, InpRR, sl, tp)
                : atrStops.ShortStops(entry, InpATR_SL_Mult, InpRR, sl, tp);
   }
   if(InpStopMode == STOP_PIPS)
   {
      double sl_dist = InpSL_Pips * InpPipSize;
      double tp_dist = InpPips_UseRR ? sl_dist * InpRR : InpTP_Pips * InpPipSize;
      if(sl_dist <= 0 || tp_dist <= 0) return false;
      sl = (dir == SIG_LONG) ? (entry - sl_dist) : (entry + sl_dist);
      tp = (dir == SIG_LONG) ? (entry + tp_dist) : (entry - tp_dist);
      return true;
   }
   if(InpStopMode == STOP_SWING)
   {
      int idx_high = iHighest(_Symbol, g_tf, MODE_HIGH, InpSwingLookback, 1);
      int idx_low  = iLowest (_Symbol, g_tf, MODE_LOW,  InpSwingLookback, 1);
      if(idx_high < 0 || idx_low < 0) return false;
      double swing_high = iHigh(_Symbol, g_tf, idx_high);
      double swing_low  = iLow (_Symbol, g_tf, idx_low);
      if(swing_high <= 0 || swing_low <= 0) return false;

      if(dir == SIG_LONG)
      {
         sl = swing_low;
         tp = swing_high;
         if(sl >= entry || tp <= entry) return false;
      }
      else
      {
         sl = swing_high;
         tp = swing_low;
         if(sl <= entry || tp >= entry) return false;
      }
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| OnInit                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   g_tf = ResolveTF();

   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);

   risk.Init(_Symbol, InpRiskPercent, InpMaxDailyLossPct);
   if(!atrStops.Init(_Symbol, g_tf, InpATR_Period)) return INIT_FAILED;
   session.Init(InpSessionFilter, InpSessionStartUTC, InpSessionEndUTC,
                InpFridayCloseHourUTC, InpFridayClose);

   bool ok = true;
   switch(InpStrategy)
   {
      case EMA13_PULLBACK:
         ok = sigEMA13.Init(_Symbol, g_tf,
                            InpEMA13_Fast, InpEMA13_Slow, InpEMA13_SlopeBars);
         break;
      case EMA20_M10:
         ok = sigEMA20.Init(_Symbol, g_tf,
                            InpEMA20_Period, InpEMA20_SlopeBars,
                            InpEMA20_UseHTF, InpEMA20_HTF, InpEMA20_HTF_Period);
         break;
      case DONCHIAN_BREAK:
         sigDonchian.Init(_Symbol, g_tf, InpDonchianPeriod);
         break;
      case SMA_CROSS_M15:
         ok = sigSMA.Init(_Symbol, g_tf, InpSMA_Fast, InpSMA_Slow);
         break;
      case EMA20_M15_8BAR:
         ok = sigEMA20Cross.Init(_Symbol, g_tf,
                                 InpEMA20Cross_Period, InpEMA20Cross_Lookback,
                                 InpEMA20Cross_StrongClose, InpEMA20Cross_PinWickRatio);
         break;
   }
   if(!ok) return INIT_FAILED;

   PrintFormat("[Init] strategy=%d tf=%d magic=%I64d risk=%.2f%% maxDD=%.2f%%",
               (int)InpStrategy, (int)g_tf, InpMagicNumber,
               InpRiskPercent, InpMaxDailyLossPct);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| OnDeinit                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   atrStops.Deinit();
   sigEMA13.Deinit();
   sigEMA20.Deinit();
   sigSMA.Deinit();
   sigEMA20Cross.Deinit();
}

//+------------------------------------------------------------------+
//| OnTick                                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // Friday wind-down: close everything regardless of bar state.
   if(session.ShouldForceClose() && HasOpenPosition())
      CloseAllOurPositions("FridayClose");

   // Process once per bar close.
   datetime curBar = (datetime)iTime(_Symbol, g_tf, 0);
   if(curBar == g_lastBarTime) return;
   g_lastBarTime = curBar;

   risk.OnTickUpdate();

   // Early exit (EMA13 strategy only): close if EMA13 is breached against position.
   if(InpStrategy == EMA13_PULLBACK)
   {
      int side = OpenPositionSide();
      if(side != 0 && sigEMA13.ShouldEarlyExit(side))
      {
         CloseAllOurPositions("EMA13_EarlyExit");
         return;
      }
   }

   // Don't open new positions if we already have one.
   if(HasOpenPosition()) return;

   if(!risk.CanTradeToday())   return;
   if(!session.IsTradingHour()) return;

   ENUM_SIGNAL_DIR dir = DispatchSignal();
   if(dir == SIG_NONE) return;

   // Cooldown: same-direction entry within InpCooldownBars is suppressed.
   if(InpCooldownBars > 0 && g_lastEntryBar > 0 && g_lastEntryDir == (int)dir)
   {
      int bars_since = iBarShift(_Symbol, g_tf, g_lastEntryBar, true);
      if(bars_since >= 0 && bars_since < InpCooldownBars) return;
   }

   // Spread filter: skip entry during widened-spread events (news, illiquid hours).
   double spread_pips = CurrentSpreadPips();
   if(spread_pips > InpMaxSpreadPips)
   {
      PrintFormat("[Skip] spread=%.2fpips > max=%.2f", spread_pips, InpMaxSpreadPips);
      return;
   }

   // Compute stops + lot.
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl, tp;
   double entry = (dir == SIG_LONG) ? ask : bid;

   if(!ComputeStops(dir, entry, sl, tp)) return;
   if(!EnforceStopLevel(dir, entry, sl, tp))
   {
      PrintFormat("[Skip] stop level constraint not satisfiable");
      return;
   }

   double sl_dist = MathAbs(entry - sl);
   double lot = risk.LotForRisk(sl_dist);
   if(lot <= 0)
   {
      PrintFormat("[Skip] lot=0 (sl_dist=%.5f)", sl_dist);
      return;
   }

   bool placed = false;
   if(dir == SIG_LONG)
      placed = trade.Buy(lot, _Symbol, ask, sl, tp, InpComment);
   else
      placed = trade.Sell(lot, _Symbol, bid, sl, tp, InpComment);

   if(placed)
   {
      g_lastEntryBar = curBar;
      g_lastEntryDir = (int)dir;
      PrintFormat("[Entry] dir=%d lot=%.2f entry=%.2f sl=%.2f tp=%.2f spread=%.2fpips",
                  (int)dir, lot, entry, sl, tp, spread_pips);
   }
   else
   {
      PrintFormat("[Entry] failed retcode=%d desc=%s",
                  trade.ResultRetcode(), trade.ResultRetcodeDescription());
   }
}
