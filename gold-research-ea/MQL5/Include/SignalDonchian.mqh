//+------------------------------------------------------------------+
//|                                               SignalDonchian.mqh |
//|  Donchian channel breakout — classical baseline for comparison.  |
//+------------------------------------------------------------------+
#ifndef GRE_SIGNAL_DONCHIAN_MQH
#define GRE_SIGNAL_DONCHIAN_MQH

#property strict

#include "SignalEMA13Pullback.mqh"   // ENUM_SIGNAL_DIR

class CSignalDonchian
{
private:
   string m_symbol;
   ENUM_TIMEFRAMES m_tf;
   int    m_period;     // lookback bars

public:
   void Init(const string symbol, ENUM_TIMEFRAMES tf, int period)
   {
      m_symbol = symbol;
      m_tf     = tf;
      m_period = period;
   }

   //--- Long if close[1] > max(high[2..N+1]); short symmetric.
   ENUM_SIGNAL_DIR CheckSignal()
   {
      double close_1 = iClose(m_symbol, m_tf, 1);
      if(close_1 <= 0) return SIG_NONE;

      // Look at the m_period bars ending one bar before the just-closed bar.
      int idx_high = iHighest(m_symbol, m_tf, MODE_HIGH, m_period, 2);
      int idx_low  = iLowest (m_symbol, m_tf, MODE_LOW,  m_period, 2);
      if(idx_high < 0 || idx_low < 0) return SIG_NONE;

      double prior_high = iHigh(m_symbol, m_tf, idx_high);
      double prior_low  = iLow (m_symbol, m_tf, idx_low);

      if(close_1 > prior_high) return SIG_LONG;
      if(close_1 < prior_low)  return SIG_SHORT;
      return SIG_NONE;
   }
};

#endif // GRE_SIGNAL_DONCHIAN_MQH
