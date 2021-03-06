//+------------------------------------------------------------------+
//|                                                      envelop.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "KUROHUNE"
#property link      "https://www.gogojungle.co.jp/users/154643"
#property version   "1.00"
#property strict
#property description "5分足の「GBPJPY」専用です"
#property description "DLLの使用を許可するにチェックを入れてください"
#property description "最大保有ポジション数:3"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//v2にぼりんじゃーバンドによるトレンド時は取引しないようにした
#define MAGICMA  201910251
input double Lots =0.1;         //適用ロット数
input double MaxSpread = 2.0;   //スプレッドの制限(Pips)
input int    numPosisions = 3;  //最大ポジション数　(1~3)
input int    SummerGMT = 3;     //夏のGMT(バックテスト用)
input int    WinterGMT = 2;     //冬のGMT(バックテスト用)
input int    LossCutBB=30 ;        
input int    TakeProfitBB = 12;

int    LossCutW=10 ;           //
int    TakeProfitW = 30;
int    LossCutT=10 ;           //
int    TakeProfitT = 30;
int    LossCutTM=15 ;           //
int    TakeProfitTM = 15;

double TMidiumPips = 10;
int hour1 = 0;
int minute1 = 0;
int dayofweek = 1;
int    BBPeriod = 24;
int    WindowPips = 30;
int    TodaiPips = 20;


void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue   
       return;
   }
   if(Symbol() != "GBPJPY")return;
   if(numPosisions <= 0 || numPosisions > 3)return;
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol()) < numPosisions) CheckForOpen();//ポジションを持っていなければポジションを得る
   //else                                    CheckForClose();//ポジションを持っていれば決済する
  }
//+------------------------------------------------------------------+
void CheckForOpen()
{
   int    res;
   
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
//--- sell conditions
      //--- buy conditions
      static datetime lastOrderTimeBB = TimeCurrent();
      static datetime lastOrderTimeTM = TimeCurrent();
   /*
   if(CheckBuyWindow())
   {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-PipsToPrice(LossCutW),Bid + PipsToPrice(TakeProfitW),"",MAGICMA,0,Red);//戻り値はチケット番号
      return;
   }
   if(CheckSellWindow())//open[0]が現在のバーの始値
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid + PipsToPrice(LossCutW),Ask - PipsToPrice(TakeProfitW),"",MAGICMA,0,Red);//戻り値はチケット番号
      return;
     }
     
     if(CheckBuyTodai())
   {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-PipsToPrice(LossCutT),Bid + PipsToPrice(TakeProfitT),"",MAGICMA,0,Red);//戻り値はチケット番号
      return;
   }
   if(CheckSellTodai())//open[0]が現在のバーの始値
     {
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid + PipsToPrice(LossCutT),Ask - PipsToPrice(TakeProfitT),"",MAGICMA,0,Red);//戻り値はチケット番号
      return;
     }
     if(CheckBuyTodaiMidium())
   {
      if(TimeCurrent() > lastOrderTimeTM + Period()*60)
      {
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-PipsToPrice(LossCutTM),Bid + PipsToPrice(TakeProfitTM),"",MAGICMA,0,Red);//戻り値はチケット番号
         lastOrderTimeTM = TimeCurrent();
      }
      return;
   }
   if(CheckSellTodaiMidium())//open[0]が現在のバーの始値
     {
      if(TimeCurrent() > lastOrderTimeTM + Period()*60)
      {
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid + PipsToPrice(LossCutTM),Ask - PipsToPrice(TakeProfitTM),"",MAGICMA,0,Red);//戻り値はチケット番号
         lastOrderTimeTM = TimeCurrent();
      }
      return;
     }
     */
     if(IsTesting())
     {
        if(CheckBuyBBTest())
        {
            if(TimeCurrent() > lastOrderTimeBB + Period()*60)
            {
               res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-PipsToPrice(LossCutBB),Bid + PipsToPrice(TakeProfitBB),"",MAGICMA,0,Red);//戻り値はチケット番号
               lastOrderTimeBB = TimeCurrent();
            }
            return;
        }
        if(CheckSellBBTest())//open[0]が現在のバーの始値
        {
            if(TimeCurrent() > lastOrderTimeBB + Period()*60)
            {
               res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid + PipsToPrice(LossCutBB),Ask - PipsToPrice(TakeProfitBB),"",MAGICMA,0,Red);//戻り値はチケット番号
               lastOrderTimeBB = TimeCurrent();
            }
            return;
        }
      }
      else
      {
         if(CheckBuyBB())
        {
            if(TimeCurrent() > lastOrderTimeBB + Period()*60)
            {
               res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-PipsToPrice(LossCutBB),Bid + PipsToPrice(TakeProfitBB),"",MAGICMA,0,Red);//戻り値はチケット番号
               lastOrderTimeBB = TimeCurrent();
            }
            return;
        }
        if(CheckSellBB())//open[0]が現在のバーの始値
        {
            if(TimeCurrent() > lastOrderTimeBB + Period()*60)
            {
               res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid + PipsToPrice(LossCutBB),Ask - PipsToPrice(TakeProfitBB),"",MAGICMA,0,Red);//戻り値はチケット番号
               lastOrderTimeBB = TimeCurrent();
            }
            return;
        }
      }
     
     
   
}
//バックテスト中
bool CheckBuyBBTest()
{
   double bb = iBands(Symbol(),Period(),BBPeriod,2,0,PRICE_CLOSE,MODE_LOWER,0);
   //if(DayOfWeek() != dayofweek)return false;
   //if(!(IsIncludeTime(Time[0],hour1,minute1,hour1,minute1 + 14) ))return false;
   if(PointToPips(MarketInfo(Symbol(),MODE_SPREAD)) > MaxSpread)return false;
   if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         //if(!(IsIncludeTime(Time[0],23,0,0,0) ))return false;//サーバー時間
         if(!(TimeHour(Time[0]) - SummerGMT  == 20 || TimeHour(Time[0]) - SummerGMT  == -4))return false;
         if(bb <= Close[0])return false;
         if(bb > Close[1])return false;
         return true;
      }
      else//サマータイムじゃないとき
      {
         //if(!(IsIncludeTime(Time[0],23,0,0,0) ))return false;
         if(!(TimeHour(Time[0]) - WinterGMT  == 21 || TimeHour(Time[0]) - WinterGMT  == -3))return false;
         if(bb <= Close[0])return false;
         if(bb > Close[1])return false;
         return true;
      }
      return false;
}
bool CheckSellBBTest()
{
   double bb = iBands(Symbol(),Period(),BBPeriod,2,0,PRICE_CLOSE,MODE_UPPER,0);
   //if(DayOfWeek() != dayofweek)return false;
   if(PointToPips(MarketInfo(Symbol(),MODE_SPREAD)) > MaxSpread)return false;
   if(IsDST(Time[0],False))//米国式サマータイムの時
   {
      //if(!(IsIncludeTime(Time[0],23,0,0,0) ))return false;
      //if(!(IsIncludeTime(TimeLocal(),5,0,6,0) ))return false;
      if(!(TimeHour(Time[0]) - SummerGMT  == 20|| TimeHour(Time[0]) - SummerGMT  == -4))return false;
      if(bb >= Close[0])return false;
      if(bb < Close[1])return false;
      return true;
   }
   else//サマータイムじゃないとき
   {
      //if(!(IsIncludeTime(Time[0],23,0,0,0) ))return false;
      //if(!(IsIncludeTime(TimeLocal(),5,0,6,0) ))return false;
      if(!(TimeHour(Time[0]) - WinterGMT  == 21 || TimeHour(Time[0]) - WinterGMT  == -3))return false;
      if(bb >= Close[0])return false;
      if(bb < Close[1])return false;
      return true;
   }
   return false;
}
bool CheckBuyBB()
{
   double bb = iBands(Symbol(),Period(),BBPeriod,2,0,PRICE_CLOSE,MODE_LOWER,0);
   //if(DayOfWeek() != dayofweek)return false;
   //if(!(IsIncludeTime(Time[0],hour1,minute1,hour1,minute1 + 14) ))return false;
   if(PointToPips(MarketInfo(Symbol(),MODE_SPREAD)) > MaxSpread)return false;
   if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         //if(!(IsIncludeTime(Time[0],23,0,0,0) ))return false;//サーバー時間
         if(!(IsIncludeTime(TimeGMT() ,20,0,21,0) ))return false;
         if(bb <= Close[0])return false;
         if(bb > Close[1])return false;
         return true;
      }
      else//サマータイムじゃないとき
      {
         //if(!(IsIncludeTime(Time[0],23,0,0,0) ))return false;
         if(!(IsIncludeTime(TimeGMT() ,21,0,22,0) ))return false;
         if(bb <= Close[0])return false;
         if(bb > Close[1])return false;
         return true;
      }
      return false;
}
bool CheckSellBB()
{
   double bb = iBands(Symbol(),Period(),BBPeriod,2,0,PRICE_CLOSE,MODE_UPPER,0);
   //if(DayOfWeek() != dayofweek)return false;
   if(PointToPips(MarketInfo(Symbol(),MODE_SPREAD)) > MaxSpread)return false;
   if(IsDST(Time[0],False))//米国式サマータイムの時
   {
      //if(!(IsIncludeTime(Time[0],23,0,0,0) ))return false;
      //if(!(IsIncludeTime(TimeLocal(),5,0,6,0) ))return false;
      if(!(IsIncludeTime(TimeCurrent() - TimeGMT() ,20,0,21,0) ))return false;
      if(bb >= Close[0])return false;
      if(bb < Close[1])return false;
      return true;
   }
   else//サマータイムじゃないとき
   {
      //if(!(IsIncludeTime(Time[0],23,0,0,0) ))return false;
      //if(!(IsIncludeTime(TimeLocal(),5,0,6,0) ))return false;
      if(!(IsIncludeTime(TimeCurrent() - TimeGMT() ,21,0,22,0) ))return false;
      if(bb >= Close[0])return false;
      if(bb < Close[1])return false;
      return true;
   }
   return false;
}
//東大生の順張りの期間の半分までが上向きならその方向にエントリー
bool CheckBuyTodaiMidium()
{
   int i;
   
   if(IsDST(Time[0],False))//米国式サマータイムの時
   {
      if(TimeHour(Time[0]) == 6 && TimeMinute(Time[0]) == 45)
      {
       i = 1;  
         while(true)
         {
            if(TimeHour(Time[i]) == 3 && TimeMinute(Time[i]) == 0)
            {
               if(Close[0] - Close[i] > PipsToPrice(TMidiumPips))return true;
               break;
            }
            i++;
         }
      }
      if(TimeHour(Time[0]) == 12 && TimeMinute(Time[0]) == 45)
      {
       i = 1;  
         while(true)
         {
            if(TimeHour(Time[i]) == 10 && TimeMinute(Time[i]) == 0)
            {
               
               if(Close[0] - Close[i] > PipsToPrice(TMidiumPips))return true;
               break;
            }
            i++;
         }
      }
   }
   else//サマータイムじゃないとき
   {
      if(TimeHour(Time[0]) == 6 && TimeMinute(Time[0]) == 45)
      {
       i = 1;  
         while(true)
         {
            if(TimeHour(Time[i]) == 3 && TimeMinute(Time[i]) == 0)
            {
               if(Close[0] - Close[i] > PipsToPrice(TMidiumPips))return true;
               break;
            }
            i++;
         }
      }
      if(TimeHour(Time[0]) == 13 && TimeMinute(Time[0]) == 45)
      {
       i = 1;  
         while(true)
         {
            if(TimeHour(Time[i]) == 11 && TimeMinute(Time[i]) == 0)
            {
               if(Close[0] - Close[i] > PipsToPrice(TMidiumPips))return true;
               break;
            }
            i++;
         }
      }
   }
   return false;
}
bool CheckSellTodaiMidium()
{
   int i;
   if(IsDST(Time[0],False))//米国式サマータイムの時
   {
      if(TimeHour(Time[0]) == 6 && TimeMinute(Time[0]) == 45)
      {
       i = 1;  
         while(true)
         {
            if(TimeHour(Time[i]) == 3 && TimeMinute(Time[i]) == 0)
            {
               if(Close[i] - Close[0] > PipsToPrice(TMidiumPips))return true;
               break;
            }
            i++;
         }
      }
      if(TimeHour(Time[0]) == 12 && TimeMinute(Time[0]) == 45)
      {
       i = 1;  
         while(true)
         {
            if(TimeHour(Time[i]) == 10 && TimeMinute(Time[i]) == 0)
            {
               if(Close[i] - Close[0] > PipsToPrice(TMidiumPips))return true;
               break;
            }
            i++;
         }
      }
   }
   else//サマータイムじゃないとき
   {
      if(TimeHour(Time[0]) == 6 && TimeMinute(Time[0]) == 45)
      {
       i = 1;  
         while(true)
         {
            if(TimeHour(Time[i]) == 3 && TimeMinute(Time[i]) == 0)
            {
               if(Close[i] - Close[0] > PipsToPrice(TMidiumPips))return true;
               break;
            }
            i++;
         }
      }
      if(TimeHour(Time[0]) == 13 && TimeMinute(Time[0]) == 45)
      {
       i = 1;  
         while(true)
         {
            if(TimeHour(Time[i]) == 11 && TimeMinute(Time[i]) == 0)
            {
               if(Close[i] - Close[0] > PipsToPrice(TMidiumPips))return true;
               break;
            }
            i++;
         }
      }
   }
   return false;
   
}

//順張り期間の向きの逆を、逆張り期間にエントリー
bool CheckBuyTodai()
{
      double bb = iBands(Symbol(),Period(),BBPeriod,2,0,PRICE_CLOSE,MODE_LOWER,0);
      if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         if(TimeHour(Time[0]) == 14 && TimeMinute(Time[0]) == 0)
         {
            int i = 1;
            while(true)
            {
               i++;
               if(Bars <= i)return false;
               if(TimeHour(Time[i]) == 9 && TimeMinute(Time[0]) == 0)
               {
                  if(Close[i] < Close[0])return false;
                  if(PriceToPips(Close[i] - Close[0]) > TodaiPips && bb > Close[0])return true;
               }
            }
         }
         if(TimeHour(Time[0]) == 20 && TimeMinute(Time[0]) == 0)
         {
            int i = 1;
            while(true)
            {
               i++;
               if(Bars <= i)return false;
               if(TimeHour(Time[i]) == 16 && TimeMinute(Time[0]) == 0)
               {
                  if(Close[i] < Close[0])return false;
                  if(PriceToPips(Close[i] - Close[0]) > TodaiPips&& bb > Close[0])return true;
               }
            }
         }
         
      }
      
      else//サマータイムじゃないとき
      {
         if(TimeHour(Time[0]) == 14 && TimeMinute(Time[0]) == 0)
         {
            int i = 1;
            while(true)
            {
               i++;
               if(Bars <= i)return false;
               if(TimeHour(Time[i]) == 9 && TimeMinute(Time[0]) == 0)
               {
                  if(Close[i] < Close[0])return false;
                  if(PriceToPips(Close[i] - Close[0]) > TodaiPips&& bb > Close[0])return true;
               }
            }
         }
         if(TimeHour(Time[0]) == 21 && TimeMinute(Time[0]) == 0)
         {
            int i = 1;
            while(true)
            {
               i++;
               if(Bars <= i)return false;
               if(TimeHour(Time[i]) == 17 && TimeMinute(Time[0]) == 0)
               {
                  if(Close[i] < Close[0])return false;
                  if(PriceToPips(Close[i] - Close[0]) > TodaiPips&& bb > Close[0])return true;
               }
            }
         }
         
      }
      return false;
}
bool CheckSellTodai()
{
   double bb = iBands(Symbol(),Period(),BBPeriod,2,0,PRICE_CLOSE,MODE_UPPER,0);
   if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         if(TimeHour(Time[0]) == 14 && TimeMinute(Time[0]) == 0)
         {
            int i = 1;
            while(true)
            {
               i++;
               if(Bars <= i)return false;
               if(TimeHour(Time[i]) == 9 && TimeMinute(Time[0]) == 0)
               {
                  
                  if(Close[i] > Close[0])return false;
                  if(PriceToPips(Close[0] - Close[i]) > TodaiPips&& bb < Close[0])return true;
               }
            }
         }
         if(TimeHour(Time[0]) == 20 && TimeMinute(Time[0]) == 0)
         {
            int i = 1;
            while(true)
            {
               i++;
               if(Bars <= i)return false;
               if(TimeHour(Time[i]) == 16 && TimeMinute(Time[0]) == 0)
               {

                  if(Close[i] > Close[0])return false;
                  if(PriceToPips(Close[0] - Close[i]) > TodaiPips&& bb < Close[0])return true;
               }
            }
         }
         
      }
      
      else//サマータイムじゃないとき
      {
         if(TimeHour(Time[0]) == 14 && TimeMinute(Time[0]) == 0)
         {
            int i = 1;
            while(true)
            {
               i++;
               if(Bars <= i)return false;
               if(TimeHour(Time[i]) == 9 && TimeMinute(Time[0]) == 0)
               {
                  if(Close[i] > Close[0])return false;
                  if(PriceToPips(Close[0] - Close[i]) > TodaiPips&& bb < Close[0])return true;
               }
            }
         }
         if(TimeHour(Time[0]) == 21 && TimeMinute(Time[0]) == 0)
         {
            int i = 1;
            while(true)
            {
               i++;
               if(Bars <= i)return false;
               if(TimeHour(Time[i]) == 17 && TimeMinute(Time[0]) == 0)
               {
                  if(Close[i] > Close[0])return false;
                  if(PriceToPips(Close[0] - Close[i]) > TodaiPips&& bb < Close[0])return true;
               }
            }
         }
      }
      return false;
}
bool CheckBuyWindow()
{
   if(Volume[0] != 1)return false;
   //if(TimeHour(TimeLocal()) != 6)return false;
   //if(TimeMinute(TimeLocal()) != 0)return false;
   if(MathAbs(Open[0] - Close[1]) <= PipsToPrice(WindowPips))return false;
   double bb = iBands(Symbol(),Period(),BBPeriod,2,0,PRICE_CLOSE,MODE_LOWER,0);
   if(bb <= Open[0])return false;
   return true;
}
bool CheckSellWindow()
{
   if(Volume[0] != 1)return false;
   //if(TimeHour(TimeLocal()) != 6)return false;
   //if(TimeMinute(TimeLocal()) != 0)return false;
   if(MathAbs(Open[0] - Close[1]) <= PipsToPrice(WindowPips))return false;
   double bb = iBands(Symbol(),Period(),BBPeriod,2,0,PRICE_CLOSE,MODE_UPPER,0);
   if(bb >= Open[0])return false;
   return true;
}
void CheckForClose(){
   double ema;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get Moving Average 
   ema=iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0);
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(Close[0]>ema)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(Close[0]<ema)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
     }
}
int CalculateCurrentOrders(string symbol)//symbol通貨ペア名 オープンポジション数計算関数
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)//orderstotal保有ポジションと待機注文の合計
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      //orderselect（インデックス、インデックスを使用して注文する、現在保有している注文）注文出す。注文が成功したらtrue
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)//ordersymbol()通貨ペア名を取得
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
   }
double PriceToPips(double price, int digits = EMPTY)
 {
     if (digits == EMPTY) digits = Digits;
     return NormalizeDouble(price * MathPow(10, digits - 1), 1);
 }
 double PipsToPrice(double pips, int digits = EMPTY)
 {
     if (digits == EMPTY) digits = Digits;
     return NormalizeDouble(pips * MathPow(0.1, digits - 1), digits);
 }
 double PointToPips(double point)
    {
        return NormalizeDouble(point * 0.1, 1);
    }
bool IsDST(datetime CurrentTime, bool IsUK){
   datetime StartDate;
   datetime EndDate;
   bool DST;

   string CurrentYear = (string)(TimeYear(CurrentTime));

   if(!IsUK && (int)CurrentYear >= 2007){
      StartDate = (datetime)(CurrentYear + ".3." + (string)(14 - TimeDayOfWeek((datetime)(CurrentYear + ".3.14"))));
      EndDate = (datetime)(CurrentYear + ".11." + (string)(7 - TimeDayOfWeek((datetime)(CurrentYear + ".11.7"))));
   }else{
      if(IsUK){
         StartDate = (datetime)(CurrentYear + ".3." + (string)(31 - TimeDayOfWeek((datetime)(CurrentYear + ".3.31"))));
      }else{
         StartDate = (datetime)(CurrentYear + ".4." + (string)(7 - TimeDayOfWeek((datetime)(CurrentYear + ".4.7"))));
      }

      EndDate = (datetime)(CurrentYear + ".10." + (string)(31 - TimeDayOfWeek((datetime)(CurrentYear + ".10.31"))));
   }


   if(CurrentTime >= StartDate && CurrentTime < EndDate) DST = true;
   else DST = false;

   return(DST);
}
int GetGMTOffset()
  {
 
   // 日付処理で使用
   MqlDateTime current;
   MqlDateTime gmt;
 
   // 補正処理で使用
   int offset = 0;
    
   // MT4時刻を取得する
   TimeCurrent( current );
 
   // GMT時刻を取得する
   TimeGMT( gmt );
 
   // 日付が異なる場合の補正処理
   if( ( current.day - gmt.day ) > 0 )
     {
      offset =  24;
     }
   if( ( current.day - gmt.day ) < 0 )
     {
      offset = -24;
     }
 
   // GMTOffset値を返却
   return ( current.hour - gmt.hour + offset );
  }
bool IsIncludeTime(datetime target, uint begin_hour, uint begin_minute, uint end_hour, uint end_minute)//時間内ならTrue
 {
     // 現在の時刻
     uint hour = TimeHour(target);
     uint minute = TimeMinute(target);
     
     string message = "time filter is ng (time=" + TimeToString(TimeCurrent(), TIME_MINUTES) + ")";
 
     // 開始時 < 終了時 の場合
     if (begin_hour < end_hour)
     {
         if (hour < begin_hour) return false;
         if (hour == begin_hour && minute < begin_minute) return false;
         if (hour == end_hour && end_minute <= minute) return false;
         if (end_hour < hour) return false;
     }
 
     // 終了時 < 開始時 の場合
     if (end_hour < begin_hour)
     {
         if (end_hour < hour && hour < begin_hour) return false;
         if (hour == begin_hour && minute < begin_minute) return false;
         if (hour == end_hour && end_minute <= minute) return false;
     }
 
     // 開始時 == 終了時 の場合
     if (begin_hour == end_hour)
     {
         // 開始分 < 終了分 の場合
         if (begin_minute < end_minute)
         {
             if (hour < begin_hour) return false;
             if (hour == begin_hour && minute < begin_minute) return false;
             if (hour == end_hour && end_minute <= minute) return false;
             if (end_hour < hour) return false;
         }
 
         // 終了分 < 開始分 の場合
         if (end_minute < begin_minute)
         {
             if (hour == begin_hour && hour == end_hour && end_minute <= minute && minute < begin_minute) return false;
         }
 
         // 開始分 == 終了分 の場合
         if (begin_minute == end_minute)
         {
             if (hour != begin_hour) return false;
             if (hour != end_hour) return false;
             if (minute != begin_minute) return false;
             if (minute != end_minute) return false;
         }
     }

     // 終了
     return true;
 }