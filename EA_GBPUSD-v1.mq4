
//+------------------------------------------------------------------+
//|                                                      envelop.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//v2にぼりんじゃーバンドによるトレンド時は取引しないようにした
#define MAGICMA  20190909
#define PI 3.14159265
input double Lots          =0.01;   //1ロット十万通貨単位
input int    TakeProfit=1500 ;
input double TrailingStop  =1000;     //トレーリングストップ
input   int                 MAPeriod1 = 15;                             //短期
input   int                 MAPeriod2 = 45;                             //中期
input   int                 MAPeriod3 = 75;                             //長期
input   double              a = 1.4;                                      
void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue
   
      Print("ゆるされてない");
       return;
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0 && Volume[0] == 1) CheckForOpen();//ポジションを持っていなければポジションを得る
   else                                    CheckForClose();//ポジションを持っていれば決済する
  }
//+------------------------------------------------------------------+
void CheckForOpen()
{
   int    res;
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
//--- sell conditions
      static bool BuyArrow ;
      static bool SellArrow ;
      static bool beforBuyArrow = CheckBuy(1) ;
      static bool beforSellArrow = CheckSell(1);
      BuyArrow = CheckBuy(0);
      SellArrow = CheckSell(0);
      if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         if(BuyArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) ) )
         {
            res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-TrailingStop*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
         if(SellArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) ) && !beforBuyArrow)//open[0]が現在のバーの始値
         {
            res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+TrailingStop*Point,Bid-TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
      }
      else//サマータイムじゃないとき
      {
         if(BuyArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) ) )
         {
            res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-TrailingStop*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
         if(SellArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],11,0,15,0) ) && !beforSellArrow)//open[0]が現在のバーの始値
         {
            res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+TrailingStop*Point,Bid-TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
      }
      beforBuyArrow = BuyArrow;
      beforSellArrow = SellArrow;
      
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
void CheckForClose(){
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get Moving Average 
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      //時事ネタがある時間帯に入ったらクローズ
      if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         if(IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0)  )
         {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
               Print("OrderModify error ",GetLastError());
               return;
         }
         
      }
      else//サマータイムじゃないとき
      {
         if(IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) )
         {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
               Print("OrderModify error ",GetLastError());
               return;
         }
         
      }
      
      if(OrderType()==OP_BUY)
        {
        if(CheckSell(0))
        {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
               Print("OrderModify error ",GetLastError());
               return;
        }
        
        if(TrailingStop>0)
           {
            if(Bid-OrderOpenPrice()>Point*TrailingStop)
              {
               if(OrderStopLoss()<Bid-Point*TrailingStop)
                 {
                  //--- modify order and exit
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
                     Print("OrderModify error ",GetLastError());
                  return;
                 }
              }
           }
         if(Close[0]<0)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
        if(CheckBuy(0))
        {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                Print("OrderModify error ",GetLastError());
                return;
        }
        if(TrailingStop>0)
           {
            if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
              {
               if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                 {
                  //--- modify order and exit
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                     Print("OrderModify error ",GetLastError());
                  return;
                 }
              }
           }
         if(Close[0]<0)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
     }
}
bool CheckBuy(int icount)
{   
   
   double sumBeforeGBP = CheckGBP1(icount + 2) + CheckGBP2(icount + 2) + CheckGBP3(icount + 2);
   double sumBeforeUSD = CheckUSD1(icount + 2) + CheckUSD2(icount + 2) + CheckUSD3(icount + 2);
   double sumGBP = CheckGBP1(icount + 1) + CheckGBP2(icount + 1) + CheckGBP3(icount + 1);
   double sumUSD = CheckUSD1(icount + 1) + CheckUSD2(icount + 1) + CheckUSD3(icount + 1);
   
  //if(VolumeUSD[icount + continueNum] < VolumeEUD[icount + continueNum])return false;

  //----------------------------------------------------------------------------------------
  //if(VolumeUSD[icount + 1] < VolumeGBP[icount + 1] && VolumeUSD[icount] >= VolumeGBP[icount])Common.CreateVLine(time,Time[icount], clrRed, 1,STYLE_SOLID, false, true);
  
  
  //if(MathAbs(VolumeUSD[icount] - VolumeGBP[icount]) < sum)return false;
  //if(MathAbs(VolumeUSD[icount + 1] - VolumeGBP[icount + 1]) < sum)return false;
  
  //if(CheckUSD(icount + 2) > CheckGBP(icount + 2) && CheckUSD(icount + 1) <= CheckGBP(icount + 1))return true;
  if( (sumGBP > 0 && sumBeforeUSD > 0 && sumUSD  < 0 )  || (sumUSD < 0 && sumBeforeGBP < 0 && sumGBP  > 0 ) )return true;
 

  
  return false;
  
  
  
  //-------------------------------------------------------------------------------------------------
}

bool CheckSell(int icount)
{
//USDが強いとき
   double sumBeforeGBP = CheckGBP1(icount + 2) + CheckGBP2(icount + 2) + CheckGBP3(icount + 2);
   double sumBeforeUSD = CheckUSD1(icount + 2) + CheckUSD2(icount + 2) + CheckUSD3(icount + 2);
   double sumGBP = CheckGBP1(icount + 1) + CheckGBP2(icount + 1) + CheckGBP3(icount + 1);
   double sumUSD = CheckUSD1(icount + 1) + CheckUSD2(icount + 1) + CheckUSD3(icount + 1);
  
  //if(CheckUSD(icount + continueNum) > CheckEUD(icount + continueNum))return false;
  //--------------------------------------------------------------------------------------

  //----------------------------------------------------------------------------------------
  //if(VolumeUSD[icount + 1] > VolumeGBP[icount + 1] && VolumeUSD[icount] <= VolumeGBP[icount])Common.CreateVLine(time,Time[icount], clrBlue, 1,STYLE_SOLID, false, true);

  
  //if(MathAbs(VolumeUSD[icount] - VolumeGBP[icount]) < sum)return false;
  //if(MathAbs(VolumeUSD[icount + 1] - VolumeGBP[icount + 1]) < sum)return false;
  
  //if(CheckUSD(icount + 2) < CheckGBP(icount + 2) && CheckUSD(icount + 1) >= CheckGBP(icount + 1))return true;
   if( (sumGBP < 0 && sumBeforeUSD < 0 && sumUSD  > 0 )  || (sumUSD > 0 && sumBeforeGBP > 0 && sumGBP  < 0 ) )return true;

  return false;
  
  //------------------------------------------------------------------------------------

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
double CheckUSD1(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
     //usd
     //if(countBuySt(icount) < okCount)return false;
     int ashi = 5;
     i = i - getAngle("USDCHF",MAPeriod1,icount,ashi);//プラスならグラフが右肩上がり
     i = i - getAngle("USDJPY",MAPeriod1,icount,ashi);
     i = i - getAngle("USDCAD",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPUSD",MAPeriod1,icount,ashi); 
     i = i + getAngle("EURUSD",MAPeriod1,icount,ashi); 
     i = i + getAngle("AUDUSD",MAPeriod1,icount,ashi); 
     i = i + getAngle("NZDUSD",MAPeriod1,icount,ashi); 
     
    
    
     
    
     return i;
     
     
 }
 double CheckUSD2(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
     int ashi = 30;
     //usd
     //if(countBuySt(icount) < okCount)return false;
     
    
     
     //--------------------------------------------
     i = i - getAngle("USDCHF",MAPeriod2,icount,ashi);//プラスならグラフが右肩上がり
     i = i - getAngle("USDJPY",MAPeriod2,icount,ashi);
     i = i - getAngle("USDCAD",MAPeriod2,icount,ashi);
     i = i + getAngle("GBPUSD",MAPeriod2,icount,ashi); 
     i = i + getAngle("EURUSD",MAPeriod2,icount,ashi); 
     i = i + getAngle("AUDUSD",MAPeriod2,icount,ashi); 
    i = i + getAngle("NZDUSD",MAPeriod2,icount,ashi);
    
     
    
     
    
     return i;
     
     
 }
 double CheckUSD3(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
     //usd
     //if(countBuySt(icount) < okCount)return false;
     int ashi = 60;
    
    
     i = i - getAngle("USDCHF",MAPeriod3,icount,ashi);//プラスならグラフが右肩上がり
     i = i - getAngle("USDJPY",MAPeriod3,icount,ashi);
     i = i - getAngle("USDCAD",MAPeriod3,icount,ashi);
     i = i + getAngle("GBPUSD",MAPeriod3,icount,ashi); 
     i = i + getAngle("EURUSD",MAPeriod3,icount,ashi); 
     i = i + getAngle("AUDUSD",MAPeriod3,icount,ashi); 
    i = i + getAngle("NZDUSD",MAPeriod3,icount,ashi);
    
     
    
     return i;
     
     
 }
 
double CheckGBP1(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     int ashi = 5;
     
     i = i + getAngle("GBPUSD",MAPeriod1,icount,ashi);
     i = i - getAngle("EURGBP",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPCHF",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPJPY",MAPeriod1,icount,ashi);
 
    
     
     
     //f( -i < sumAngle)return false;
     return -i * (7/4) *a;
     
     
   
 }
 double CheckGBP2(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     int ashi = 30;
     
     
     i = i + getAngle("GBPUSD",MAPeriod2,icount,ashi);
     i = i - getAngle("EURGBP",MAPeriod2,icount,ashi);
     i = i + getAngle("GBPCHF",MAPeriod2,icount,ashi);
     i = i + getAngle("GBPJPY",MAPeriod2,icount,ashi);
     

     
     
     //f( -i < sumAngle)return false;
     return -i * (7/4) * a;
     //return -i * (7/4) ;
     
     
   
 }
 double CheckGBP3(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     int ashi = 60;
     
     i = i + getAngle("GBPUSD",MAPeriod1,icount,ashi);
     i = i - getAngle("EURGBP",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPCHF",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPJPY",MAPeriod1,icount,ashi);
     
   
    
     
     
     //f( -i < sumAngle)return false;
     return -i * (7/4) *a;
     
     
   
 }
 double getAngle(string Pare ,int period ,int icount,int ashi)
 {
   double value1 =iMA(Pare, ashi, period, NULL, MODE_EMA, PRICE_CLOSE, icount + period);
   double value2 =iMA(Pare, ashi, period, NULL, MODE_EMA, PRICE_CLOSE, icount);
   return Angle(value2 ,value1 ,period);//符号はvalue2 - value1
 }
 double Angle(double value1, double value2, uint bars = 1)
 {
     if (bars == 0) return 0.0;
     return (MathArctan((value2 - value1) / (Point * 10 * bars)) * 180 / PI);
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
   
 
/*
//+------------------------------------------------------------------+
//|                                                      envelop.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//v2にぼりんじゃーバンドによるトレンド時は取引しないようにした
#define MAGICMA  20190909
#define PI 3.14159265
input double Lots          =0.01;   //1ロット十万通貨単位
input int    TakeProfit=1500 ;
input double TrailingStop  =1000;     //トレーリングストップ
input   int                 MAPeriod1 = 15;                             //短期
input   int                 MAPeriod2 = 45;                             //中期
input   int                 MAPeriod3 = 75;                             //長期
input   double              a = 1.4;                                      
void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue
   
      Print("ゆるされてない");
       return;
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0 && Volume[0] == 1) CheckForOpen();//ポジションを持っていなければポジションを得る
   else                                    CheckForClose();//ポジションを持っていれば決済する
  }
//+------------------------------------------------------------------+
void CheckForOpen()
{
   int    res;
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
//--- sell conditions
      static bool BuyArrow ;
      static bool SellArrow ;
      static bool beforBuyArrow = CheckBuy(1) ;
      static bool beforSellArrow = CheckSell(1);
      BuyArrow = CheckBuy(0);
      SellArrow = CheckSell(0);
      if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         if(BuyArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) ) )
         {
            res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-TrailingStop*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
         if(SellArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) ) && !beforBuyArrow)//open[0]が現在のバーの始値
         {
            res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+TrailingStop*Point,Bid-TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
      }
      else//サマータイムじゃないとき
      {
         if(BuyArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) ) )
         {
            res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-TrailingStop*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
         if(SellArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],11,0,15,0) ) && !beforSellArrow)//open[0]が現在のバーの始値
         {
            res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+TrailingStop*Point,Bid-TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
      }
      beforBuyArrow = BuyArrow;
      beforSellArrow = SellArrow;
      
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
void CheckForClose(){
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get Moving Average 
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      //時事ネタがある時間帯に入ったらクローズ
      if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         if(IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0)  )
         {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
               Print("OrderModify error ",GetLastError());
               return;
         }
         
      }
      else//サマータイムじゃないとき
      {
         if(IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) )
         {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
               Print("OrderModify error ",GetLastError());
               return;
         }
         
      }
      
      if(OrderType()==OP_BUY)
        {
        if(CheckSell(0))
        {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
               Print("OrderModify error ",GetLastError());
               return;
        }
        
        if(TrailingStop>0)
           {
            if(Bid-OrderOpenPrice()>Point*TrailingStop)
              {
               if(OrderStopLoss()<Bid-Point*TrailingStop)
                 {
                  //--- modify order and exit
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
                     Print("OrderModify error ",GetLastError());
                  return;
                 }
              }
           }
         if(Close[0]<0)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
        if(CheckBuy(0))
        {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                Print("OrderModify error ",GetLastError());
                return;
        }
        if(TrailingStop>0)
           {
            if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
              {
               if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                 {
                  //--- modify order and exit
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                     Print("OrderModify error ",GetLastError());
                  return;
                 }
              }
           }
         if(Close[0]<0)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
     }
}
bool CheckBuy(int icount)
{   

  //if(VolumeUSD[icount + continueNum] < VolumeEUD[icount + continueNum])return false;

  //----------------------------------------------------------------------------------------
  //if(VolumeUSD[icount + 1] < VolumeGBP[icount + 1] && VolumeUSD[icount] >= VolumeGBP[icount])Common.CreateVLine(time,Time[icount], clrRed, 1,STYLE_SOLID, false, true);
  
  
  //if(MathAbs(VolumeUSD[icount] - VolumeGBP[icount]) < sum)return false;
  //if(MathAbs(VolumeUSD[icount + 1] - VolumeGBP[icount + 1]) < sum)return false;
  
  //if(CheckUSD(icount + 2) > CheckGBP(icount + 2) && CheckUSD(icount + 1) <= CheckGBP(icount + 1))return true;
  if(CheckUSD1(icount + 1) <= CheckGBP1(icount + 1) && CheckUSD2(icount + 1) <= CheckGBP2(icount + 1)&&
  CheckUSD3(icount + 1) <= CheckGBP3(icount + 1) )return true;

  
  return false;
  
  
  
  //-------------------------------------------------------------------------------------------------
}

bool CheckSell(int icount)
{
//USDが強いとき

  
  //if(CheckUSD(icount + continueNum) > CheckEUD(icount + continueNum))return false;
  //--------------------------------------------------------------------------------------

  //----------------------------------------------------------------------------------------
  //if(VolumeUSD[icount + 1] > VolumeGBP[icount + 1] && VolumeUSD[icount] <= VolumeGBP[icount])Common.CreateVLine(time,Time[icount], clrBlue, 1,STYLE_SOLID, false, true);

  
  //if(MathAbs(VolumeUSD[icount] - VolumeGBP[icount]) < sum)return false;
  //if(MathAbs(VolumeUSD[icount + 1] - VolumeGBP[icount + 1]) < sum)return false;
  
  //if(CheckUSD(icount + 2) < CheckGBP(icount + 2) && CheckUSD(icount + 1) >= CheckGBP(icount + 1))return true;
  if(CheckUSD1(icount + 1) >= CheckGBP1(icount + 1) && CheckUSD2(icount + 1) >= CheckGBP2(icount + 1)
  &&CheckUSD3(icount + 1) >= CheckGBP3(icount + 1))return true;

  return false;
  
  //------------------------------------------------------------------------------------

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
double CheckUSD1(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
     //usd
     //if(countBuySt(icount) < okCount)return false;
     int ashi = 5;
     i = i - getAngle("USDCHF",MAPeriod1,icount,ashi);//プラスならグラフが右肩上がり
     i = i - getAngle("USDJPY",MAPeriod1,icount,ashi);
     i = i - getAngle("USDCAD",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPUSD",MAPeriod1,icount,ashi); 
     i = i + getAngle("EURUSD",MAPeriod1,icount,ashi); 
     i = i + getAngle("AUDUSD",MAPeriod1,icount,ashi); 
     i = i + getAngle("NZDUSD",MAPeriod1,icount,ashi); 
     
    
    
     
    
     return i;
     
     
 }
 double CheckUSD2(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
     int ashi = 30;
     //usd
     //if(countBuySt(icount) < okCount)return false;
     
    
     
     //--------------------------------------------
     i = i - getAngle("USDCHF",MAPeriod2,icount,ashi);//プラスならグラフが右肩上がり
     i = i - getAngle("USDJPY",MAPeriod2,icount,ashi);
     i = i - getAngle("USDCAD",MAPeriod2,icount,ashi);
     i = i + getAngle("GBPUSD",MAPeriod2,icount,ashi); 
     i = i + getAngle("EURUSD",MAPeriod2,icount,ashi); 
     i = i + getAngle("AUDUSD",MAPeriod2,icount,ashi); 
    i = i + getAngle("NZDUSD",MAPeriod2,icount,ashi);
    
     
    
     
    
     return i;
     
     
 }
 double CheckUSD3(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
     //usd
     //if(countBuySt(icount) < okCount)return false;
     int ashi = 60;
    
    
     i = i - getAngle("USDCHF",MAPeriod3,icount,ashi);//プラスならグラフが右肩上がり
     i = i - getAngle("USDJPY",MAPeriod3,icount,ashi);
     i = i - getAngle("USDCAD",MAPeriod3,icount,ashi);
     i = i + getAngle("GBPUSD",MAPeriod3,icount,ashi); 
     i = i + getAngle("EURUSD",MAPeriod3,icount,ashi); 
     i = i + getAngle("AUDUSD",MAPeriod3,icount,ashi); 
    i = i + getAngle("NZDUSD",MAPeriod3,icount,ashi);
    
     
    
     return i;
     
     
 }
 
double CheckGBP1(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     int ashi = 5;
     
     i = i + getAngle("GBPUSD",MAPeriod1,icount,ashi);
     i = i - getAngle("EURGBP",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPCHF",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPJPY",MAPeriod1,icount,ashi);
 
    
     
     
     //f( -i < sumAngle)return false;
     return -i * (7/4) *a;
     
     
   
 }
 double CheckGBP2(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     int ashi = 30;
     
     
     i = i + getAngle("GBPUSD",MAPeriod2,icount,ashi);
     i = i - getAngle("EURGBP",MAPeriod2,icount,ashi);
     i = i + getAngle("GBPCHF",MAPeriod2,icount,ashi);
     i = i + getAngle("GBPJPY",MAPeriod2,icount,ashi);
     

     
     
     //f( -i < sumAngle)return false;
     return -i * (7/4) * a;
     //return -i * (7/4) ;
     
     
   
 }
 double CheckGBP3(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     int ashi = 60;
     
     i = i + getAngle("GBPUSD",MAPeriod1,icount,ashi);
     i = i - getAngle("EURGBP",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPCHF",MAPeriod1,icount,ashi);
     i = i + getAngle("GBPJPY",MAPeriod1,icount,ashi);
     
   
    
     
     
     //f( -i < sumAngle)return false;
     return -i * (7/4) *a;
     
     
   
 }
 double getAngle(string Pare ,int period ,int icount,int ashi)
 {
   double value1 =iMA(Pare, ashi, period, NULL, MODE_EMA, PRICE_CLOSE, icount + period);
   double value2 =iMA(Pare, ashi, period, NULL, MODE_EMA, PRICE_CLOSE, icount);
   return Angle(value2 ,value1 ,period);//符号はvalue2 - value1
 }
 double Angle(double value1, double value2, uint bars = 1)
 {
     if (bars == 0) return 0.0;
     return (MathArctan((value2 - value1) / (Point * 10 * bars)) * 180 / PI);
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
   
   */