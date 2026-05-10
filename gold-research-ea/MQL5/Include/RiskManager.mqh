//+------------------------------------------------------------------+
//|                                                  RiskManager.mqh |
//|  Position sizing, daily drawdown circuit breaker.                |
//|  Research/educational template — no profit guarantee.            |
//+------------------------------------------------------------------+
#ifndef GRE_RISK_MANAGER_MQH
#define GRE_RISK_MANAGER_MQH

#property strict

class CRiskManager
{
private:
   string   m_symbol;
   double   m_riskPercent;       // % of balance per trade
   double   m_maxDailyLossPct;   // daily loss circuit breaker
   datetime m_dayStart;          // start of current trading day (UTC midnight)
   double   m_dayStartBalance;   // balance at day start
   bool     m_breakerTripped;

public:
   void Init(const string symbol, double riskPercent, double maxDailyLossPct)
   {
      m_symbol           = symbol;
      m_riskPercent      = riskPercent;
      m_maxDailyLossPct  = maxDailyLossPct;
      m_dayStart         = 0;
      m_dayStartBalance  = AccountInfoDouble(ACCOUNT_BALANCE);
      m_breakerTripped   = false;
   }

   //--- Roll the day window if UTC midnight has passed; reset breaker.
   void OnTickUpdate()
   {
      datetime now = TimeGMT();
      MqlDateTime mdt;
      TimeToStruct(now, mdt);
      mdt.hour = 0; mdt.min = 0; mdt.sec = 0;
      datetime today_utc_midnight = StructToTime(mdt);

      if(today_utc_midnight > m_dayStart)
      {
         m_dayStart        = today_utc_midnight;
         m_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         m_breakerTripped  = false;
      }
   }

   //--- True if we are allowed to open new positions today.
   bool CanTradeToday()
   {
      OnTickUpdate();
      if(m_breakerTripped) return false;

      double current = AccountInfoDouble(ACCOUNT_EQUITY);
      double drop    = m_dayStartBalance - current;
      double limit   = m_dayStartBalance * (m_maxDailyLossPct / 100.0);
      if(drop >= limit)
      {
         m_breakerTripped = true;
         PrintFormat("[RiskManager] Daily loss circuit breaker tripped: drop=%.2f limit=%.2f", drop, limit);
         return false;
      }
      return true;
   }

   //--- Lot size for a given SL distance in price units.
   //    Returns 0 if SL distance is invalid or position is too small.
   double LotForRisk(double sl_distance_price)
   {
      if(sl_distance_price <= 0) return 0;

      double balance     = AccountInfoDouble(ACCOUNT_BALANCE);
      double risk_amount = balance * (m_riskPercent / 100.0);

      double tick_size  = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
      double tick_value = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
      if(tick_size <= 0 || tick_value <= 0) return 0;

      double loss_per_lot = (sl_distance_price / tick_size) * tick_value;
      if(loss_per_lot <= 0) return 0;

      double lot = risk_amount / loss_per_lot;
      return NormalizeLot(lot);
   }

   //--- Round to broker step and clamp to min/max.
   double NormalizeLot(double lot)
   {
      double step = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
      double minv = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
      double maxv = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
      if(step <= 0) step = 0.01;

      lot = MathFloor(lot / step) * step;
      if(lot < minv) return 0;          // refuse rather than open below broker minimum
      if(lot > maxv) lot = maxv;
      return NormalizeDouble(lot, 2);
   }
};

#endif // GRE_RISK_MANAGER_MQH
