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
#property version     "0.1"
#property description "XAUUSD research EA — EMA13/EMA20 pullback + Donchian baseline"
#property strict

#include <Trade/Trade.mqh>
#include "../Include/RiskManager.mqh"
#include "../Include/ATRStops.mqh"
#include "../Include/SessionFilter.mqh"
#include "../Include/SignalEMA13Pullback.mqh"
#include "../Include/SignalEMA20Pullback.mqh"
#include "../Include/SignalDonchian.mqh"

//+------------------------------------------------------------------+
//| Inputs                                                            |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY
{
   EMA13_PULLBACK = 0,
   EMA20_M10      = 1,
   DONCHIAN_BREAK = 2
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

input group "=== Risk management ==="
input double InpRiskPercent      = 0.5;    // % of balance per trade
input int    InpATR_Period       = 14;
input double InpATR_SL_Mult      = 1.5;
input double InpRR               = 1.5;    // TP = SL * RR
input double InpMaxDailyLossPct  = 3.0;    // daily DD circuit breaker

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
CTrade               trade;
CRiskManager         risk;
CATRStops            atrStops;
CSessionFilter       session;
CSignalEMA13Pullback sigEMA13;
CSignalEMA20Pullback sigEMA20;
CSignalDonchian      sigDonchian;

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
      case EMA13_PULLBACK: return sigEMA13.CheckSignal();
      case EMA20_M10:      return sigEMA20.CheckSignal();
      case DONCHIAN_BREAK: return sigDonchian.CheckSignal();
   }
   return SIG_NONE;
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

   // Compute stops + lot.
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl, tp;
   double entry = (dir == SIG_LONG) ? ask : bid;

   bool ok = (dir == SIG_LONG)
                ? atrStops.LongStops(entry, InpATR_SL_Mult, InpRR, sl, tp)
                : atrStops.ShortStops(entry, InpATR_SL_Mult, InpRR, sl, tp);
   if(!ok) return;

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
      PrintFormat("[Entry] dir=%d lot=%.2f entry=%.2f sl=%.2f tp=%.2f",
                  (int)dir, lot, entry, sl, tp);
   }
   else
   {
      PrintFormat("[Entry] failed retcode=%d desc=%s",
                  trade.ResultRetcode(), trade.ResultRetcodeDescription());
   }
}
