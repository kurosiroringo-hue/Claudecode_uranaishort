//+------------------------------------------------------------------+
//|                                          SignalEMA20Pullback.mqh |
//|  20 EMA pullback on M10 (or any chosen timeframe).               |
//|  Optional higher-timeframe (H1, EMA50) trend confirmation.       |
//|  Performance claims circulated on social media are not           |
//|  independently verified — use only as a research candidate.      |
//+------------------------------------------------------------------+
#ifndef GRE_SIGNAL_EMA20_MQH
#define GRE_SIGNAL_EMA20_MQH

#property strict

#include "SignalEMA13Pullback.mqh"   // ENUM_SIGNAL_DIR

class CSignalEMA20Pullback
{
private:
   string m_symbol;
   ENUM_TIMEFRAMES m_tf;
   int    m_period;             // 20
   int    m_slope_lookback;
   bool   m_use_htf;
   ENUM_TIMEFRAMES m_htf;       // PERIOD_H1
   int    m_htf_period;         // 50
   int    m_h_main;
   int    m_h_htf;

public:
   bool Init(const string symbol, ENUM_TIMEFRAMES tf, int period,
             int slope_lookback, bool use_htf,
             ENUM_TIMEFRAMES htf_tf, int htf_period)
   {
      m_symbol         = symbol;
      m_tf             = tf;
      m_period         = period;
      m_slope_lookback = slope_lookback;
      m_use_htf        = use_htf;
      m_htf            = htf_tf;
      m_htf_period     = htf_period;
      m_h_main = iMA(symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE);
      m_h_htf  = use_htf ? iMA(symbol, htf_tf, htf_period, 0, MODE_EMA, PRICE_CLOSE)
                         : INVALID_HANDLE;
      if(m_h_main == INVALID_HANDLE) return false;
      if(use_htf && m_h_htf == INVALID_HANDLE) return false;
      return true;
   }

   void Deinit()
   {
      if(m_h_main != INVALID_HANDLE) IndicatorRelease(m_h_main);
      if(m_h_htf  != INVALID_HANDLE) IndicatorRelease(m_h_htf);
      m_h_main = INVALID_HANDLE;
      m_h_htf  = INVALID_HANDLE;
   }

   ENUM_SIGNAL_DIR CheckSignal()
   {
      double main_now[1], main_old[1];
      if(CopyBuffer(m_h_main, 0, 1, 1, main_now) != 1) return SIG_NONE;
      if(CopyBuffer(m_h_main, 0, 1 + m_slope_lookback, 1, main_old) != 1) return SIG_NONE;

      double high_1  = iHigh(m_symbol, m_tf, 1);
      double low_1   = iLow(m_symbol, m_tf, 1);
      double close_1 = iClose(m_symbol, m_tf, 1);
      if(high_1 <= 0 || low_1 <= 0 || close_1 <= 0) return SIG_NONE;

      double ema_1 = main_now[0];
      double slope = main_now[0] - main_old[0];

      bool htf_up = true, htf_dn = true;
      if(m_use_htf)
      {
         double htf_now[1], htf_old[1];
         if(CopyBuffer(m_h_htf, 0, 1, 1, htf_now) != 1) return SIG_NONE;
         if(CopyBuffer(m_h_htf, 0, 1 + m_slope_lookback, 1, htf_old) != 1) return SIG_NONE;
         double htf_slope = htf_now[0] - htf_old[0];
         htf_up = (htf_slope > 0);
         htf_dn = (htf_slope < 0);
      }

      if(slope > 0 && htf_up && low_1 <= ema_1 && close_1 > ema_1)
         return SIG_LONG;

      if(slope < 0 && htf_dn && high_1 >= ema_1 && close_1 < ema_1)
         return SIG_SHORT;

      return SIG_NONE;
   }
};

#endif // GRE_SIGNAL_EMA20_MQH
