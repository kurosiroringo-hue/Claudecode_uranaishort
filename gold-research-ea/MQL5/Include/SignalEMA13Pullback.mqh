//+------------------------------------------------------------------+
//|                                          SignalEMA13Pullback.mqh |
//|  EMA13 pullback in direction of EMA100 slope.                    |
//|  Inspired by an X (Twitter) post; performance not independently  |
//|  verified — use only as a research candidate.                    |
//+------------------------------------------------------------------+
#ifndef GRE_SIGNAL_EMA13_MQH
#define GRE_SIGNAL_EMA13_MQH

#property strict

enum ENUM_SIGNAL_DIR
{
   SIG_NONE  = 0,
   SIG_LONG  = 1,
   SIG_SHORT = -1
};

class CSignalEMA13Pullback
{
private:
   string m_symbol;
   ENUM_TIMEFRAMES m_tf;
   int    m_fast_period;       // 13
   int    m_slow_period;       // 100
   int    m_slope_lookback;    // bars to compare for slope
   int    m_h_fast;
   int    m_h_slow;

public:
   bool Init(const string symbol, ENUM_TIMEFRAMES tf,
             int fast_period, int slow_period, int slope_lookback)
   {
      m_symbol         = symbol;
      m_tf             = tf;
      m_fast_period    = fast_period;
      m_slow_period    = slow_period;
      m_slope_lookback = slope_lookback;
      m_h_fast = iMA(symbol, tf, fast_period, 0, MODE_EMA, PRICE_CLOSE);
      m_h_slow = iMA(symbol, tf, slow_period, 0, MODE_EMA, PRICE_CLOSE);
      if(m_h_fast == INVALID_HANDLE || m_h_slow == INVALID_HANDLE)
      {
         PrintFormat("[EMA13Pullback] iMA handle failed (err=%d)", GetLastError());
         return false;
      }
      return true;
   }

   void Deinit()
   {
      if(m_h_fast != INVALID_HANDLE) IndicatorRelease(m_h_fast);
      if(m_h_slow != INVALID_HANDLE) IndicatorRelease(m_h_slow);
      m_h_fast = INVALID_HANDLE;
      m_h_slow = INVALID_HANDLE;
   }

   //--- Returns SIG_LONG/SIG_SHORT/SIG_NONE based on the just-closed bar (shift=1).
   ENUM_SIGNAL_DIR CheckSignal()
   {
      double fast[2];
      double slow_now[1];
      double slow_old[1];
      if(CopyBuffer(m_h_fast, 0, 1, 2, fast) != 2) return SIG_NONE;
      if(CopyBuffer(m_h_slow, 0, 1, 1, slow_now) != 1) return SIG_NONE;
      if(CopyBuffer(m_h_slow, 0, 1 + m_slope_lookback, 1, slow_old) != 1) return SIG_NONE;

      double high_1  = iHigh(m_symbol, m_tf, 1);
      double low_1   = iLow(m_symbol, m_tf, 1);
      double close_1 = iClose(m_symbol, m_tf, 1);
      if(high_1 <= 0 || low_1 <= 0 || close_1 <= 0) return SIG_NONE;

      double ema13_1 = fast[0];        // value at shift=1 (latest closed bar)
      double slope   = slow_now[0] - slow_old[0];

      // Long: uptrend, wick touched/crossed below EMA13, but close back above.
      if(slope > 0 && low_1 <= ema13_1 && close_1 > ema13_1)
         return SIG_LONG;

      // Short: downtrend, wick touched/crossed above EMA13, but close back below.
      if(slope < 0 && high_1 >= ema13_1 && close_1 < ema13_1)
         return SIG_SHORT;

      return SIG_NONE;
   }

   //--- Early-exit safety: returns true if EMA13 was breached against position direction.
   //    Caller passes side (+1 long / -1 short) of an existing position.
   bool ShouldEarlyExit(int side)
   {
      double fast[1];
      if(CopyBuffer(m_h_fast, 0, 1, 1, fast) != 1) return false;
      double close_1 = iClose(m_symbol, m_tf, 1);
      if(close_1 <= 0) return false;

      if(side > 0) return (close_1 < fast[0]);   // long: closed below EMA13
      if(side < 0) return (close_1 > fast[0]);   // short: closed above EMA13
      return false;
   }
};

#endif // GRE_SIGNAL_EMA13_MQH
