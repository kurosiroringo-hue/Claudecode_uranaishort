//+------------------------------------------------------------------+
//|                                                SessionFilter.mqh |
//|  London-NY trading window + Friday forced close.                 |
//+------------------------------------------------------------------+
#ifndef GRE_SESSION_FILTER_MQH
#define GRE_SESSION_FILTER_MQH

#property strict

class CSessionFilter
{
private:
   bool m_enabled;
   int  m_start_hour_utc;     // inclusive, 0-23
   int  m_end_hour_utc;       // exclusive, 0-23
   int  m_friday_close_utc;   // hour (UTC) on Friday to force-close (0-23)
   bool m_use_friday_close;

public:
   void Init(bool enabled, int start_hour_utc, int end_hour_utc,
             int friday_close_utc, bool use_friday_close)
   {
      m_enabled          = enabled;
      m_start_hour_utc   = start_hour_utc;
      m_end_hour_utc     = end_hour_utc;
      m_friday_close_utc = friday_close_utc;
      m_use_friday_close = use_friday_close;
   }

   //--- Allowed to open new positions now?
   bool IsTradingHour()
   {
      if(!m_enabled) return true;
      MqlDateTime mdt;
      TimeToStruct(TimeGMT(), mdt);

      // Block weekends defensively (broker should already do this).
      if(mdt.day_of_week == 0 || mdt.day_of_week == 6) return false;

      // Block Friday after the friday-close hour.
      if(m_use_friday_close && mdt.day_of_week == 5 && mdt.hour >= m_friday_close_utc)
         return false;

      if(m_start_hour_utc < m_end_hour_utc)
         return (mdt.hour >= m_start_hour_utc && mdt.hour < m_end_hour_utc);
      // Wrap-around (e.g., 22..05).
      return (mdt.hour >= m_start_hour_utc || mdt.hour < m_end_hour_utc);
   }

   //--- True if it's time to force-close any open position (Friday wind-down).
   bool ShouldForceClose()
   {
      if(!m_use_friday_close) return false;
      MqlDateTime mdt;
      TimeToStruct(TimeGMT(), mdt);
      return (mdt.day_of_week == 5 && mdt.hour >= m_friday_close_utc);
   }
};

#endif // GRE_SESSION_FILTER_MQH
