//+------------------------------------------------------------------+
//|                                         SignalEMA20Cross8Bar.mqh |
//|  EMA20 cross + within-N-bars pullback touch + bullish/bearish    |
//|  confirmation candle (pin bar OR strong-close continuation).     |
//|                                                                  |
//|  Inspired by X post (@Cora..., "月600万プロ"). The post leads to |
//|  a LINE-based affiliate funnel and its "win rate" is unverified. |
//|  Implemented as a research candidate to be backtested honestly.  |
//+------------------------------------------------------------------+
#ifndef GRE_SIGNAL_EMA20_CROSS_8BAR_MQH
#define GRE_SIGNAL_EMA20_CROSS_8BAR_MQH

#property strict

#include "SignalEMA13Pullback.mqh"   // ENUM_SIGNAL_DIR

class CSignalEMA20Cross8Bar
{
private:
   string m_symbol;
   ENUM_TIMEFRAMES m_tf;
   int    m_period;             // 20
   int    m_lookback;           // 8 — bars since last cross
   double m_strong_close_ratio; // 0.7 — close within top X of range = bullish
   double m_pin_wick_ratio;     // 2.0 — wick / body for pin bar
   int    m_h_ema;

   //--- Bar geometry helpers (all use shift>=1).
   bool BarOHLC(int shift, double &o, double &h, double &l, double &c)
   {
      o = iOpen (m_symbol, m_tf, shift);
      h = iHigh (m_symbol, m_tf, shift);
      l = iLow  (m_symbol, m_tf, shift);
      c = iClose(m_symbol, m_tf, shift);
      return (o > 0 && h > 0 && l > 0 && c > 0 && h > l);
   }

   //--- Bullish confirmation: pin bar OR strong-close green continuation.
   bool IsBullishConfirmation(int shift)
   {
      double o, h, l, c;
      if(!BarOHLC(shift, o, h, l, c)) return false;
      double range  = h - l;
      if(range <= 0) return false;
      double body   = MathAbs(c - o);
      double upper  = h - MathMax(c, o);
      double lower  = MathMin(c, o) - l;

      // Bullish pin bar (hammer-ish): long lower wick, small body in upper third.
      bool pin = (lower >= m_pin_wick_ratio * MathMax(body, range * 0.01)) &&
                 (lower >= upper * 1.5) &&
                 (MathMin(c, o) >= l + range * 0.6);
      if(pin) return true;

      // Strong-close bullish continuation: green body, close in upper X% of range.
      double close_pos = (c - l) / range;
      bool strong = (c > o) && (close_pos >= m_strong_close_ratio);
      return strong;
   }

   //--- Bearish confirmation: pin bar OR strong-close red continuation.
   bool IsBearishConfirmation(int shift)
   {
      double o, h, l, c;
      if(!BarOHLC(shift, o, h, l, c)) return false;
      double range  = h - l;
      if(range <= 0) return false;
      double body   = MathAbs(c - o);
      double upper  = h - MathMax(c, o);
      double lower  = MathMin(c, o) - l;

      bool pin = (upper >= m_pin_wick_ratio * MathMax(body, range * 0.01)) &&
                 (upper >= lower * 1.5) &&
                 (MathMax(c, o) <= h - range * 0.6);
      if(pin) return true;

      double close_pos = (c - l) / range;
      bool strong = (c < o) && (close_pos <= (1.0 - m_strong_close_ratio));
      return strong;
   }

   //--- True if the last EMA cross within the lookback was upward and price
   //    has remained above EMA since (no close below EMA between cross and now).
   bool RecentUpwardCrossHolding(int lookback, int &cross_shift_out)
   {
      double ema_arr[];
      if(CopyBuffer(m_h_ema, 0, 1, lookback + 2, ema_arr) != lookback + 2) return false;

      // ema_arr is ordered oldest-first when count>1; index i corresponds to shift = (1 + lookback + 1) - 1 - i.
      // Simpler: walk shifts from (lookback+1) down to 2, find the most recent
      // bar where close[shift] crossed above EMA[shift].
      for(int s = 2; s <= lookback + 1; s++)
      {
         int idx_now = (lookback + 1) - (s - 1);   // index for shift=s
         int idx_prv = (lookback + 1) - (s);        // index for shift=s+1
         if(idx_prv < 0 || idx_now < 0) continue;
         double ema_s   = ema_arr[idx_now];
         double ema_sp1 = ema_arr[idx_prv];
         double close_s   = iClose(m_symbol, m_tf, s);
         double close_sp1 = iClose(m_symbol, m_tf, s + 1);
         if(close_s <= 0 || close_sp1 <= 0) continue;

         bool cross_up = (close_sp1 <= ema_sp1) && (close_s > ema_s);
         if(cross_up)
         {
            // Check that no close between (s-1)..1 fell back below EMA.
            for(int k = s - 1; k >= 1; k--)
            {
               int idx_k = (lookback + 1) - (s - 1 - (s - 1 - k));   // = (lookback+1) - (s-1) + (s-1-k) ... simpler:
               // Just CopyBuffer for ema at shift=k.
               double ema_k_buf[1];
               if(CopyBuffer(m_h_ema, 0, k, 1, ema_k_buf) != 1) return false;
               double close_k = iClose(m_symbol, m_tf, k);
               if(close_k <= 0) return false;
               if(close_k < ema_k_buf[0]) return false;   // broke back below
            }
            cross_shift_out = s;
            return true;
         }
      }
      return false;
   }

   bool RecentDownwardCrossHolding(int lookback, int &cross_shift_out)
   {
      double ema_arr[];
      if(CopyBuffer(m_h_ema, 0, 1, lookback + 2, ema_arr) != lookback + 2) return false;

      for(int s = 2; s <= lookback + 1; s++)
      {
         int idx_now = (lookback + 1) - (s - 1);
         int idx_prv = (lookback + 1) - (s);
         if(idx_prv < 0 || idx_now < 0) continue;
         double ema_s   = ema_arr[idx_now];
         double ema_sp1 = ema_arr[idx_prv];
         double close_s   = iClose(m_symbol, m_tf, s);
         double close_sp1 = iClose(m_symbol, m_tf, s + 1);
         if(close_s <= 0 || close_sp1 <= 0) continue;

         bool cross_dn = (close_sp1 >= ema_sp1) && (close_s < ema_s);
         if(cross_dn)
         {
            for(int k = s - 1; k >= 1; k--)
            {
               double ema_k_buf[1];
               if(CopyBuffer(m_h_ema, 0, k, 1, ema_k_buf) != 1) return false;
               double close_k = iClose(m_symbol, m_tf, k);
               if(close_k <= 0) return false;
               if(close_k > ema_k_buf[0]) return false;   // broke back above
            }
            cross_shift_out = s;
            return true;
         }
      }
      return false;
   }

public:
   bool Init(const string symbol, ENUM_TIMEFRAMES tf,
             int period, int lookback,
             double strong_close_ratio, double pin_wick_ratio)
   {
      m_symbol             = symbol;
      m_tf                 = tf;
      m_period             = period;
      m_lookback           = lookback;
      m_strong_close_ratio = strong_close_ratio;
      m_pin_wick_ratio     = pin_wick_ratio;
      m_h_ema = iMA(symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE);
      if(m_h_ema == INVALID_HANDLE) return false;
      return true;
   }

   void Deinit()
   {
      if(m_h_ema != INVALID_HANDLE) IndicatorRelease(m_h_ema);
      m_h_ema = INVALID_HANDLE;
   }

   //--- Returns SIG_LONG/SHORT/NONE. The "just-closed" bar (shift=1) is the
   //    confirmation bar; entry happens at the next bar's open.
   ENUM_SIGNAL_DIR CheckSignal()
   {
      double ema_1[1];
      if(CopyBuffer(m_h_ema, 0, 1, 1, ema_1) != 1) return SIG_NONE;

      double low_1  = iLow (m_symbol, m_tf, 1);
      double high_1 = iHigh(m_symbol, m_tf, 1);
      if(low_1 <= 0 || high_1 <= 0) return SIG_NONE;

      // Confirmation bar must have touched the EMA20 (wick crossed it).
      bool touched_long  = (low_1  <= ema_1[0] && iClose(m_symbol, m_tf, 1) >= ema_1[0]);
      bool touched_short = (high_1 >= ema_1[0] && iClose(m_symbol, m_tf, 1) <= ema_1[0]);

      int cross_shift = 0;
      if(touched_long && IsBullishConfirmation(1) &&
         RecentUpwardCrossHolding(m_lookback, cross_shift))
         return SIG_LONG;

      if(touched_short && IsBearishConfirmation(1) &&
         RecentDownwardCrossHolding(m_lookback, cross_shift))
         return SIG_SHORT;

      return SIG_NONE;
   }
};

#endif // GRE_SIGNAL_EMA20_CROSS_8BAR_MQH
