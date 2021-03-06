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
input int    numPosisions = 1;  //最大ポジション数　(1~3)
input int    SummerGMT = 3;     //夏のGMT(バックテスト用)
input int    WinterGMT = 2;     //冬のGMT(バックテスト用)
input int    LossCut=40 ;        
input int    TakeProfit = 20;
input int    biginTimeSummer = 7;
input int    endTimeSummer = 14;
 

double TMidiumPips = 10;
int hour1 = 0;
int minute1 = 0;
int dayofweek = 1;
double boxMax = 0;
double boxMin = 0;



void OnTick()
  {
//---
Comment(boxMin);
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue   
       return;
   }
   if(TimeHour(Time[0]) == endTimeSummer && TimeMinute(Time[0]) == 0 && Volume[0] == 1)
      {
         boxMax = High[20];            
         for(int i = 0; i < 28 ;i++)
         {
            if(boxMax < High[i])boxMax = High[i];
         }
      }
    if(TimeHour(Time[0]) == endTimeSummer  && TimeMinute(Time[0]) == 0 && Volume[0] == 1)
      {
         boxMin = Low[20];
         for(int i = 0; i < 28 ;i++)
         {
            if(boxMin > Low[i])boxMin = Low[i];
         }
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol()) == 0) CheckForOpen();//ポジションを持っていなければポジションを得る
   //else                                    CheckForClose();//ポジションを持っていれば決済する
  }
//+------------------------------------------------------------------+
void CheckForOpen()
{
   int    res;
     
     static datetime lastOrderTime = TimeCurrent();

        if(CheckBuy())
        {
            if(TimeCurrent() > lastOrderTime + Period()*60 * 50)
            {
               res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-PipsToPrice(LossCut),Bid + PipsToPrice(TakeProfit),"",MAGICMA,0,Red);//戻り値はチケット番号
               lastOrderTime = TimeCurrent();
            }
            return;
        }
        if(CheckSell())//open[0]が現在のバーの始値
        {
            if(TimeCurrent() > lastOrderTime + Period()*60* 50)
            {
               res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid + PipsToPrice(LossCut),Ask - PipsToPrice(TakeProfit),"",MAGICMA,0,Red);//戻り値はチケット番号
               lastOrderTime = TimeCurrent();
            }
            return;
        }
      
}
bool CheckBuy()
{
   
   //if(DayOfWeek() != dayofweek)return false;
   //if(!(IsIncludeTime(Time[0],hour1,minute1,hour1,minute1 + 14) ))return false;
      if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         
         if(!(IsIncludeTime(Time[0],endTimeSummer,0,endTimeSummer + 8 ,0) ))return false;
         if(Close[0] < boxMax)return false;
         return true;
      }
      else//サマータイムじゃないとき
      {
         
         if(!(IsIncludeTime(Time[0],endTimeSummer ,0,endTimeSummer + 8 ,0) ))return false;
         if(Close[0] < boxMax)return false;
         return true;
      }
      return false;
}
bool CheckSell()
{
   
   //if(DayOfWeek() != dayofweek)return false;
   if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         
         if(!(IsIncludeTime(Time[0],endTimeSummer,0,endTimeSummer + 8 ,0) ))return false;
         if(Close[0] > boxMin)return false;
         return true;
      }
      else//サマータイムじゃないとき
      {
         
         if(!(IsIncludeTime(Time[0],endTimeSummer ,0,endTimeSummer + 8 ,0) ))return false;
         if(Close[0] > boxMin)return false;
         return true;
      }
      
   return false;
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