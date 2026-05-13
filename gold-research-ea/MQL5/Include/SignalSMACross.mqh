//+------------------------------------------------------------------+
//|                                                SignalSMACross.mqh |
//|  SMA5 x SMA20 crossover on M15 (or any TF).                      |
//|  Inspired by X post (@mzgaangy, "月800万トレーダー"). Performance |
//|  claims are unverified and the post leads to a LINE affiliate    |
//|  funnel — use only as a backtest research candidate.             |
//+------------------------------------------------------------------+
#ifndef GRE_SIGNAL_SMA_CROSS_MQH
#define GRE_SIGNAL_SMA_CROSS_MQH

#property strict

#include "SignalEMA13Pullback.mqh"   // ENUM_SIGNAL_DIR

class CSignalSMACross
{
private:
   string m_symbol;
   ENUM_TIMEFRAMES m_tf;
   int    m_fast_period;     // 5
   int    m_slow_period;     // 20
   int    m_h_fast;
   int    m_h_slow;

public:
   bool Init(const string symbol, ENUM_TIMEFRAMES tf,
             int fast_period, int slow_period)
   {
      m_symbol = symbol;
      m_tf     = tf;
      m_fast_period = fast_period;
      m_slow_period = slow_period;
      m_h_fast = iMA(symbol, tf, fast_period, 0, MODE_SMA, PRICE_CLOSE);
      m_h_slow = iMA(symbol, tf, slow_period, 0, MODE_SMA, PRICE_CLOSE);
      if(m_h_fast == INVALID_HANDLE || m_h_slow == INVALID_HANDLE) return false;
      return true;
   }

   void Deinit()
   {
      if(m_h_fast != INVALID_HANDLE) IndicatorRelease(m_h_fast);
      if(m_h_slow != INVALID_HANDLE) IndicatorRelease(m_h_slow);
      m_h_fast = INVALID_HANDLE;
      m_h_slow = INVALID_HANDLE;
   }

   //--- Long when fast crosses up through slow on the just-closed bar.
   ENUM_SIGNAL_DIR CheckSignal()
   {
      double fast[2], slow[2];
      // shift 1 = just-closed bar, shift 2 = previous bar
      if(CopyBuffer(m_h_fast, 0, 1, 2, fast) != 2) return SIG_NONE;
      if(CopyBuffer(m_h_slow, 0, 1, 2, slow) != 2) return SIG_NONE;

      // CopyBuffer returns oldest first when count > 1: index 0 = older, 1 = newer.
      // We requested 2 values starting at shift=1, so:
      //   fast[0] = SMA at shift=2 (older), fast[1] = SMA at shift=1 (newer)
      double fast_prev = fast[0];
      double fast_now  = fast[1];
      double slow_prev = slow[0];
      double slow_now  = slow[1];

      bool cross_up   = (fast_prev <= slow_prev) && (fast_now > slow_now);
      bool cross_down = (fast_prev >= slow_prev) && (fast_now < slow_now);

      if(cross_up)   return SIG_LONG;
      if(cross_down) return SIG_SHORT;
      return SIG_NONE;
   }
};

#endif // GRE_SIGNAL_SMA_CROSS_MQH
