//+------------------------------------------------------------------+
//|                                                     ATRStops.mqh |
//|  ATR-based stop loss / take profit calculation.                  |
//+------------------------------------------------------------------+
#ifndef GRE_ATR_STOPS_MQH
#define GRE_ATR_STOPS_MQH

#property strict

class CATRStops
{
private:
   string m_symbol;
   ENUM_TIMEFRAMES m_tf;
   int    m_period;
   int    m_handle;

public:
   bool Init(const string symbol, ENUM_TIMEFRAMES tf, int atr_period)
   {
      m_symbol = symbol;
      m_tf     = tf;
      m_period = atr_period;
      m_handle = iATR(symbol, tf, atr_period);
      if(m_handle == INVALID_HANDLE)
      {
         PrintFormat("[ATRStops] iATR handle failed (err=%d)", GetLastError());
         return false;
      }
      return true;
   }

   void Deinit()
   {
      if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle);
      m_handle = INVALID_HANDLE;
   }

   //--- ATR value at the just-closed bar (shift=1). Returns 0 on failure.
   double Value(int shift = 1)
   {
      double buf[];
      if(CopyBuffer(m_handle, 0, shift, 1, buf) != 1) return 0;
      return buf[0];
   }

   //--- SL / TP prices for a long entry.
   //    sl = entry - atr*sl_mult
   //    tp = entry + (entry - sl) * rr
   bool LongStops(double entry, double sl_mult, double rr,
                  double &sl_out, double &tp_out)
   {
      double atr = Value(1);
      if(atr <= 0) return false;
      double sl_dist = atr * sl_mult;
      sl_out = entry - sl_dist;
      tp_out = entry + sl_dist * rr;
      return true;
   }

   //--- SL / TP prices for a short entry.
   bool ShortStops(double entry, double sl_mult, double rr,
                   double &sl_out, double &tp_out)
   {
      double atr = Value(1);
      if(atr <= 0) return false;
      double sl_dist = atr * sl_mult;
      sl_out = entry + sl_dist;
      tp_out = entry - sl_dist * rr;
      return true;
   }
};

#endif // GRE_ATR_STOPS_MQH
