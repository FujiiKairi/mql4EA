
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
input   int                 hard = 0;                                  //条件を厳しく 
input int minute1 = 0;
input int hour1 = 0;
string first = StringSubstr(Symbol(), 0 ,3);
string second = StringSubstr(Symbol(), 3 ,3);
         
                        
void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue
   
      Print("ゆるされてない");
       return;
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0 && Volume[0] == 1) CheckForOpen();//ポジションを持っていなければポジションを得る
   //else                                    CheckForClose();//ポジションを持っていれば決済する
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
      BuyArrow = CheckBuy(0);
      SellArrow = CheckSell(0);
      if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         if(BuyArrow)
         {
            res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-TrailingStop*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
         if(SellArrow)//open[0]が現在のバーの始値
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
         if(SellArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],11,0,15,0) ))//open[0]が現在のバーの始値
         {
            res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+TrailingStop*Point,Bid-TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
      }

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
  if(!(IsIncludeTime(Time[icount],hour1,minute1,hour1,minute1 + 14) ))return false;
  double before1 = Check11(icount + 2) + Check12(icount + 2) + Check13(icount + 2);
  double before2 = Check21(icount + 2) + Check22(icount + 2) + Check23(icount + 2);
  double now1 = Check11(icount + 1) + Check12(icount + 1) + Check13(icount + 1);
  double now2 = Check21(icount + 1) + Check22(icount + 1) + Check23(icount + 1);
  
  if(now1 > hard && before2 > -hard && now2 < -hard)return true;
  if(now2 < -hard && before1 < hard && now1 > hard)return true;

  return false;
  
  
  
  //-------------------------------------------------------------------------------------------------
}

bool CheckSell(int icount)
{
//USDが強いとき

  if(!(IsIncludeTime(Time[icount],hour1,minute1,hour1,minute1 + 14) ))return false;
  double before1 = Check11(icount + 2) + Check12(icount + 2) + Check13(icount + 2);
  double before2 = Check21(icount + 2) + Check22(icount + 2) + Check23(icount + 2);
  double now1 = Check11(icount + 1) + Check12(icount + 1) + Check13(icount + 1);
  double now2 = Check21(icount + 1) + Check22(icount + 1) + Check23(icount + 1);
  
  if(now1 < -hard && before2 < hard && now2 > hard)return true;
  if(now2 > hard && before1 > -hard && now1 < -hard)return true;


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
double Check11(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;

     double i = 0;
    
     if(first == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod1,icount);
           i = i - getAngle("EURGBP",MAPeriod1,icount);
           i = i + getAngle("GBPCHF",MAPeriod1,icount);
           i = i + getAngle("GBPJPY",MAPeriod1,icount);
           i = i + getAngle("GBPCAD",MAPeriod1,icount);
           i = i + getAngle("GBPAUD",MAPeriod1,icount);
           
        }
        if(first == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod1,icount);
           i = i - getAngle("GBPUSD",MAPeriod1,icount);
           i = i - getAngle("EURUSD",MAPeriod1,icount);
           i = i + getAngle("USDJPY",MAPeriod1,icount);
           i = i + getAngle("USDCAD",MAPeriod1,icount);
           i = i - getAngle("AUDUSD",MAPeriod1,icount);
           
         
        }
        if(first == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod1,icount);
           i = i + getAngle("EURAUD",MAPeriod1,icount);
           i = i + getAngle("EURGBP",MAPeriod1,icount);
           i = i + getAngle("EURCHF",MAPeriod1,icount);
           i = i + getAngle("EURJPY",MAPeriod1,icount);
           i = i + getAngle("EURNZD",MAPeriod1,icount);
           i = i + getAngle("EURCAD",MAPeriod1,icount);
         
        }
      
        if(first == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod1,icount);
           i = i - getAngle("EURAUD",MAPeriod1,icount);
           i = i + getAngle("AUDNZD",MAPeriod1,icount);
           i = i + getAngle("AUDCAD",MAPeriod1,icount);
           i = i + getAngle("AUDCHF",MAPeriod1,icount);
           i = i + getAngle("AUDJPY",MAPeriod1,icount);
           i = i - getAngle("GBPAUD",MAPeriod1,icount);
           
         
        }
        if(first == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod1,icount);
           i = i + getAngle("CADJPY",MAPeriod1,icount);
           i = i - getAngle("EURCAD",MAPeriod1,icount);
           i = i - getAngle("GBPCAD",MAPeriod1,icount);
           i = i + getAngle("CADCHF",MAPeriod1,icount);
      

        }
        if(first == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod1,icount);
           i = i - getAngle("EURCHF",MAPeriod1,icount);
           i = i - getAngle("GBPCHF",MAPeriod1,icount);
           i = i - getAngle("AUDCHF",MAPeriod1,icount);
           i = i + getAngle("CHFJPY",MAPeriod1,icount);
           i = i - getAngle("CADCHF",MAPeriod1,icount);
           
        
        }
        
        if(first == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod1,icount);
           i = i - getAngle("EURNZD",MAPeriod1,icount);
           i = i + getAngle("NZDJPY",MAPeriod1,icount);
           i = i + getAngle("NZDUSD",MAPeriod1,icount);
           
         
         
        }
        if(first == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod1,icount);
           i = i - getAngle("EURJPY",MAPeriod1,icount);
           i = i - getAngle("CADJPY",MAPeriod1,icount);
           i = i - getAngle("GBPJPY",MAPeriod1,icount);
           i = i - getAngle("AUDJPY",MAPeriod1,icount);
           i = i - getAngle("CHFJPY",MAPeriod1,icount);
           i = i - getAngle("NZDJPY",MAPeriod1,icount);

        }
     
    
    
     
    
     return -i;
     
     
 }
 double Check12(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;

     double i = 0;
     
     if(first == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod2,icount);
           i = i - getAngle("EURGBP",MAPeriod2,icount);
           i = i + getAngle("GBPCHF",MAPeriod2,icount);
           i = i + getAngle("GBPJPY",MAPeriod2,icount);
           i = i + getAngle("GBPCAD",MAPeriod2,icount);
           i = i + getAngle("GBPAUD",MAPeriod2,icount);
           
        }
        if(first == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod2,icount);
           i = i - getAngle("GBPUSD",MAPeriod2,icount);
           i = i - getAngle("EURUSD",MAPeriod2,icount);
           i = i + getAngle("USDJPY",MAPeriod2,icount);
           i = i + getAngle("USDCAD",MAPeriod2,icount);
           i = i - getAngle("AUDUSD",MAPeriod2,icount);
           
         
        }
        if(first == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod2,icount);
           i = i + getAngle("EURAUD",MAPeriod2,icount);
           i = i + getAngle("EURGBP",MAPeriod2,icount);
           i = i + getAngle("EURCHF",MAPeriod2,icount);
           i = i + getAngle("EURJPY",MAPeriod2,icount);
           i = i + getAngle("EURNZD",MAPeriod2,icount);
           i = i + getAngle("EURCAD",MAPeriod2,icount);
         
        }
      
        if(first == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod2,icount);
           i = i - getAngle("EURAUD",MAPeriod2,icount);
           i = i + getAngle("AUDNZD",MAPeriod2,icount);
           i = i + getAngle("AUDCAD",MAPeriod2,icount);
           i = i + getAngle("AUDCHF",MAPeriod2,icount);
           i = i + getAngle("AUDJPY",MAPeriod2,icount);
           i = i - getAngle("GBPAUD",MAPeriod2,icount);
           
         
        }
        if(first == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod2,icount);
           i = i + getAngle("CADJPY",MAPeriod2,icount);
           i = i - getAngle("EURCAD",MAPeriod2,icount);
           i = i - getAngle("GBPCAD",MAPeriod2,icount);
           i = i + getAngle("CADCHF",MAPeriod2,icount);
      

        }
        if(first == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod2,icount);
           i = i - getAngle("EURCHF",MAPeriod2,icount);
           i = i - getAngle("GBPCHF",MAPeriod2,icount);
           i = i - getAngle("AUDCHF",MAPeriod2,icount);
           i = i + getAngle("CHFJPY",MAPeriod2,icount);
           i = i - getAngle("CADCHF",MAPeriod2,icount);
           
        
        }
        
        if(first == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod2,icount);
           i = i - getAngle("EURNZD",MAPeriod2,icount);
           i = i + getAngle("NZDJPY",MAPeriod2,icount);
           i = i + getAngle("NZDUSD",MAPeriod2,icount);
           
         
         
        }
        if(first == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod2,icount);
           i = i - getAngle("EURJPY",MAPeriod2,icount);
           i = i - getAngle("CADJPY",MAPeriod2,icount);
           i = i - getAngle("GBPJPY",MAPeriod2,icount);
           i = i - getAngle("AUDJPY",MAPeriod2,icount);
           i = i - getAngle("CHFJPY",MAPeriod2,icount);
           i = i - getAngle("NZDJPY",MAPeriod2,icount);

        }
    
     
    
     
    
     return -i;
     
     
 }
 double Check13(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;

     double i = 0;

    
    if(first == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod3,icount);
           i = i - getAngle("EURGBP",MAPeriod3,icount);
           i = i + getAngle("GBPCHF",MAPeriod3,icount);
           i = i + getAngle("GBPJPY",MAPeriod3,icount);
           i = i + getAngle("GBPCAD",MAPeriod3,icount);
           i = i + getAngle("GBPAUD",MAPeriod3,icount);
           
        }
        if(first == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod3,icount);
           i = i - getAngle("GBPUSD",MAPeriod3,icount);
           i = i - getAngle("EURUSD",MAPeriod3,icount);
           i = i + getAngle("USDJPY",MAPeriod3,icount);
           i = i + getAngle("USDCAD",MAPeriod3,icount);
           i = i - getAngle("AUDUSD",MAPeriod3,icount);
           
         
        }
        if(first == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod3,icount);
           i = i + getAngle("EURAUD",MAPeriod3,icount);
           i = i + getAngle("EURGBP",MAPeriod3,icount);
           i = i + getAngle("EURCHF",MAPeriod3,icount);
           i = i + getAngle("EURJPY",MAPeriod3,icount);
           i = i + getAngle("EURNZD",MAPeriod3,icount);
           i = i + getAngle("EURCAD",MAPeriod3,icount);
         
        }
      
        if(first == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod3,icount);
           i = i - getAngle("EURAUD",MAPeriod3,icount);
           i = i + getAngle("AUDNZD",MAPeriod3,icount);
           i = i + getAngle("AUDCAD",MAPeriod3,icount);
           i = i + getAngle("AUDCHF",MAPeriod3,icount);
           i = i + getAngle("AUDJPY",MAPeriod3,icount);
           i = i - getAngle("GBPAUD",MAPeriod3,icount);
           
         
        }
        if(first == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod3,icount);
           i = i + getAngle("CADJPY",MAPeriod3,icount);
           i = i - getAngle("EURCAD",MAPeriod3,icount);
           i = i - getAngle("GBPCAD",MAPeriod3,icount);
           i = i + getAngle("CADCHF",MAPeriod3,icount);
      

        }
        if(first == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod3,icount);
           i = i - getAngle("EURCHF",MAPeriod3,icount);
           i = i - getAngle("GBPCHF",MAPeriod3,icount);
           i = i - getAngle("AUDCHF",MAPeriod3,icount);
           i = i + getAngle("CHFJPY",MAPeriod3,icount);
           i = i - getAngle("CADCHF",MAPeriod3,icount);
           
        
        }
        
        if(first == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod3,icount);
           i = i - getAngle("EURNZD",MAPeriod3,icount);
           i = i + getAngle("NZDJPY",MAPeriod3,icount);
           i = i + getAngle("NZDUSD",MAPeriod3,icount);
           
         
         
        }
        if(first == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod3,icount);
           i = i - getAngle("EURJPY",MAPeriod3,icount);
           i = i - getAngle("CADJPY",MAPeriod3,icount);
           i = i - getAngle("GBPJPY",MAPeriod3,icount);
           i = i - getAngle("AUDJPY",MAPeriod3,icount);
           i = i - getAngle("CHFJPY",MAPeriod3,icount);
           i = i - getAngle("NZDJPY",MAPeriod3,icount);

        }
    
     
    
     return -i;
     
     
 }
 
double Check21(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     double i = 0;

     
     if(second == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod1,icount);
           i = i - getAngle("EURGBP",MAPeriod1,icount);
           i = i + getAngle("GBPCHF",MAPeriod1,icount);
           i = i + getAngle("GBPJPY",MAPeriod1,icount);
           i = i + getAngle("GBPCAD",MAPeriod1,icount);
           i = i + getAngle("GBPAUD",MAPeriod1,icount);
           
        }
        if(second == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod1,icount);
           i = i - getAngle("GBPUSD",MAPeriod1,icount);
           i = i - getAngle("EURUSD",MAPeriod1,icount);
           i = i + getAngle("USDJPY",MAPeriod1,icount);
           i = i + getAngle("USDCAD",MAPeriod1,icount);
           i = i - getAngle("AUDUSD",MAPeriod1,icount);
           
         
        }
        if(second == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod1,icount);
           i = i + getAngle("EURAUD",MAPeriod1,icount);
           i = i + getAngle("EURGBP",MAPeriod1,icount);
           i = i + getAngle("EURCHF",MAPeriod1,icount);
           i = i + getAngle("EURJPY",MAPeriod1,icount);
           i = i + getAngle("EURNZD",MAPeriod1,icount);
           i = i + getAngle("EURCAD",MAPeriod1,icount);
         
        }
      
        if(second == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod1,icount);
           i = i - getAngle("EURAUD",MAPeriod1,icount);
           i = i + getAngle("AUDNZD",MAPeriod1,icount);
           i = i + getAngle("AUDCAD",MAPeriod1,icount);
           i = i + getAngle("AUDCHF",MAPeriod1,icount);
           i = i + getAngle("AUDJPY",MAPeriod1,icount);
           i = i - getAngle("GBPAUD",MAPeriod1,icount);
           
         
        }
        if(second == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod1,icount);
           i = i + getAngle("CADJPY",MAPeriod1,icount);
           i = i - getAngle("EURCAD",MAPeriod1,icount);
           i = i - getAngle("GBPCAD",MAPeriod1,icount);
           i = i + getAngle("CADCHF",MAPeriod1,icount);
      

        }
        if(second == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod1,icount);
           i = i - getAngle("EURCHF",MAPeriod1,icount);
           i = i - getAngle("GBPCHF",MAPeriod1,icount);
           i = i - getAngle("AUDCHF",MAPeriod1,icount);
           i = i + getAngle("CHFJPY",MAPeriod1,icount);
           i = i - getAngle("CADCHF",MAPeriod1,icount);
           
        
        }
        
        if(second == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod1,icount);
           i = i - getAngle("EURNZD",MAPeriod1,icount);
           i = i + getAngle("NZDJPY",MAPeriod1,icount);
           i = i + getAngle("NZDUSD",MAPeriod1,icount);
           
         
         
        }
        if(second == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod1,icount);
           i = i - getAngle("EURJPY",MAPeriod1,icount);
           i = i - getAngle("CADJPY",MAPeriod1,icount);
           i = i - getAngle("GBPJPY",MAPeriod1,icount);
           i = i - getAngle("AUDJPY",MAPeriod1,icount);
           i = i - getAngle("CHFJPY",MAPeriod1,icount);
           i = i - getAngle("NZDJPY",MAPeriod1,icount);

        }
     return -i  *a;
     
     
   
 }
 double Check22(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     
     
     if(second == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod2,icount);
           i = i - getAngle("EURGBP",MAPeriod2,icount);
           i = i + getAngle("GBPCHF",MAPeriod2,icount);
           i = i + getAngle("GBPJPY",MAPeriod2,icount);
           i = i + getAngle("GBPCAD",MAPeriod2,icount);
           i = i + getAngle("GBPAUD",MAPeriod2,icount);
           
        }
        if(second == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod2,icount);
           i = i - getAngle("GBPUSD",MAPeriod2,icount);
           i = i - getAngle("EURUSD",MAPeriod2,icount);
           i = i + getAngle("USDJPY",MAPeriod2,icount);
           i = i + getAngle("USDCAD",MAPeriod2,icount);
           i = i - getAngle("AUDUSD",MAPeriod2,icount);
           
         
        }
        if(second == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod2,icount);
           i = i + getAngle("EURAUD",MAPeriod2,icount);
           i = i + getAngle("EURGBP",MAPeriod2,icount);
           i = i + getAngle("EURCHF",MAPeriod2,icount);
           i = i + getAngle("EURJPY",MAPeriod2,icount);
           i = i + getAngle("EURNZD",MAPeriod2,icount);
           i = i + getAngle("EURCAD",MAPeriod2,icount);
         
        }
      
        if(second == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod2,icount);
           i = i - getAngle("EURAUD",MAPeriod2,icount);
           i = i + getAngle("AUDNZD",MAPeriod2,icount);
           i = i + getAngle("AUDCAD",MAPeriod2,icount);
           i = i + getAngle("AUDCHF",MAPeriod2,icount);
           i = i + getAngle("AUDJPY",MAPeriod2,icount);
           i = i - getAngle("GBPAUD",MAPeriod2,icount);
           
         
        }
        if(second == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod2,icount);
           i = i + getAngle("CADJPY",MAPeriod2,icount);
           i = i - getAngle("EURCAD",MAPeriod2,icount);
           i = i - getAngle("GBPCAD",MAPeriod2,icount);
           i = i + getAngle("CADCHF",MAPeriod2,icount);
      

        }
        if(second == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod2,icount);
           i = i - getAngle("EURCHF",MAPeriod2,icount);
           i = i - getAngle("GBPCHF",MAPeriod2,icount);
           i = i - getAngle("AUDCHF",MAPeriod2,icount);
           i = i + getAngle("CHFJPY",MAPeriod2,icount);
           i = i - getAngle("CADCHF",MAPeriod2,icount);
           
        
        }
        
        if(second == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod2,icount);
           i = i - getAngle("EURNZD",MAPeriod2,icount);
           i = i + getAngle("NZDJPY",MAPeriod2,icount);
           i = i + getAngle("NZDUSD",MAPeriod2,icount);
           
         
         
        }
        if(second == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod2,icount);
           i = i - getAngle("EURJPY",MAPeriod2,icount);
           i = i - getAngle("CADJPY",MAPeriod2,icount);
           i = i - getAngle("GBPJPY",MAPeriod2,icount);
           i = i - getAngle("AUDJPY",MAPeriod2,icount);
           i = i - getAngle("CHFJPY",MAPeriod2,icount);
           i = i - getAngle("NZDJPY",MAPeriod2,icount);

        }
     

     return -i  * a;

     
     
   
 }
 double Check23(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     
     if(second == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod3,icount);
           i = i - getAngle("EURGBP",MAPeriod3,icount);
           i = i + getAngle("GBPCHF",MAPeriod3,icount);
           i = i + getAngle("GBPJPY",MAPeriod3,icount);
           i = i + getAngle("GBPCAD",MAPeriod3,icount);
           i = i + getAngle("GBPAUD",MAPeriod3,icount);
           
        }
        if(second == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod3,icount);
           i = i - getAngle("GBPUSD",MAPeriod3,icount);
           i = i - getAngle("EURUSD",MAPeriod3,icount);
           i = i + getAngle("USDJPY",MAPeriod3,icount);
           i = i + getAngle("USDCAD",MAPeriod3,icount);
           i = i - getAngle("AUDUSD",MAPeriod3,icount);
           
         
        }
        if(second == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod3,icount);
           i = i + getAngle("EURAUD",MAPeriod3,icount);
           i = i + getAngle("EURGBP",MAPeriod3,icount);
           i = i + getAngle("EURCHF",MAPeriod3,icount);
           i = i + getAngle("EURJPY",MAPeriod3,icount);
           i = i + getAngle("EURNZD",MAPeriod3,icount);
           i = i + getAngle("EURCAD",MAPeriod3,icount);
         
        }
      
        if(second == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod3,icount);
           i = i - getAngle("EURAUD",MAPeriod3,icount);
           i = i + getAngle("AUDNZD",MAPeriod3,icount);
           i = i + getAngle("AUDCAD",MAPeriod3,icount);
           i = i + getAngle("AUDCHF",MAPeriod3,icount);
           i = i + getAngle("AUDJPY",MAPeriod3,icount);
           i = i - getAngle("GBPAUD",MAPeriod3,icount);
           
         
        }
        if(second == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod3,icount);
           i = i + getAngle("CADJPY",MAPeriod3,icount);
           i = i - getAngle("EURCAD",MAPeriod3,icount);
           i = i - getAngle("GBPCAD",MAPeriod3,icount);
           i = i + getAngle("CADCHF",MAPeriod3,icount);
      

        }
        if(second == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod3,icount);
           i = i - getAngle("EURCHF",MAPeriod3,icount);
           i = i - getAngle("GBPCHF",MAPeriod3,icount);
           i = i - getAngle("AUDCHF",MAPeriod3,icount);
           i = i + getAngle("CHFJPY",MAPeriod3,icount);
           i = i - getAngle("CADCHF",MAPeriod3,icount);
           
        
        }
        
        if(second == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod3,icount);
           i = i - getAngle("EURNZD",MAPeriod3,icount);
           i = i + getAngle("NZDJPY",MAPeriod3,icount);
           i = i + getAngle("NZDUSD",MAPeriod3,icount);
           
         
         
        }
        if(second == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod3,icount);
           i = i - getAngle("EURJPY",MAPeriod3,icount);
           i = i - getAngle("CADJPY",MAPeriod3,icount);
           i = i - getAngle("GBPJPY",MAPeriod3,icount);
           i = i - getAngle("AUDJPY",MAPeriod3,icount);
           i = i - getAngle("CHFJPY",MAPeriod3,icount);
           i = i - getAngle("NZDJPY",MAPeriod3,icount);

        }
 

     return -i  *a;
     
     
   
 }
 double getAngle(string Pare ,int period ,int icount)
 {
   double value1 =iMA(Pare, Period(), period, NULL, MODE_EMA, PRICE_CLOSE, icount + period);
   double value2 =iMA(Pare, Period(), period, NULL, MODE_EMA, PRICE_CLOSE, icount);
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
input   double              hard = 0;                                 //条件を厳しく
        
string first;
string second;
string                      pare = Symbol();                            //通貨ペア                
void OnTick()
  {
//---
      
      if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue
   
      Print("ゆるされてない");
       return;
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0 && Volume[0] == 1) 
   {
   CheckForOpen();//ポジションを持っていなければポジションを得る
   first = StringSubstr(pare, 0 ,3);
   second = StringSubstr(pare, 3 ,3);
   }
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
      
      
      BuyArrow = CheckBuy(0);
      SellArrow = CheckSell(0);
      if(IsDST(Time[0],False))//米国式サマータイムの時
      {
         if(BuyArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) ) )
         {
            res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-TrailingStop*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
         if(SellArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],10,0,14,0) ) )//open[0]が現在のバーの始値
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
         if(SellArrow && (IsIncludeTime(Time[0],3,0,8,0) || IsIncludeTime(Time[0],11,0,15,0) ))//open[0]が現在のバーの始値
         {
            res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Ask+TrailingStop*Point,Bid-TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
            return;
         }
      }

      
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
      
      if(OrderType()==OP_BUY && Volume[0] == 1)
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
      if(OrderType()==OP_SELL && Volume[0] == 1)
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
   double sumBefore1 = Check11(2) + Check12(2) + Check13(2) - hard;
      double sumBefore2 = Check21(2) + Check22(2) + Check23(2) - hard;
      double sum1 = Check11(1) + Check12(1) + Check13(1) - hard;
      double sum2 = Check21(1) + Check22(1) + Check23(1) - hard;
  if( (sum1 > 0 && sumBefore2 > 0 && sum2  < 0 )  || (sum2 < 0 && sumBefore1 < 0 && sum1  > 0 ) )return true;

  return false;
  
  
  
  //-------------------------------------------------------------------------------------------------
}

bool CheckSell(int icount)
{
//USDが強いとき
  double sumBefore1 = Check11(2) + Check12(2) + Check13(2) - hard;
      double sumBefore2 = Check21(2) + Check22(2) + Check23(2) - hard;
      double sum1 = Check11(1) + Check12(1) + Check13(1) - hard;
      double sum2 = Check21(1) + Check22(1) + Check23(1) - hard;
   if( (sum1 < 0 && sumBefore2 < 0 && sum2  > 0 )  || (sum2 > 0 && sumBefore1 > 0 && sum1  < 0 ) )return true;

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

 
double Check11(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
     
     if(first == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod1,icount);
           i = i - getAngle("EURGBP",MAPeriod1,icount);
           i = i + getAngle("GBPCHF",MAPeriod1,icount);
           i = i + getAngle("GBPJPY",MAPeriod1,icount);
           i = i + getAngle("GBPCAD",MAPeriod1,icount);
           i = i + getAngle("GBPAUD",MAPeriod1,icount);
           
        }
        if(first == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod1,icount);
           i = i - getAngle("GBPUSD",MAPeriod1,icount);
           i = i - getAngle("EURUSD",MAPeriod1,icount);
           i = i + getAngle("USDJPY",MAPeriod1,icount);
           i = i + getAngle("USDCAD",MAPeriod1,icount);
           i = i - getAngle("AUDUSD",MAPeriod1,icount);
           
         
        }
        if(first == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod1,icount);
           i = i + getAngle("EURAUD",MAPeriod1,icount);
           i = i + getAngle("EURGBP",MAPeriod1,icount);
           i = i + getAngle("EURCHF",MAPeriod1,icount);
           i = i + getAngle("EURJPY",MAPeriod1,icount);
           i = i + getAngle("EURNZD",MAPeriod1,icount);
           i = i + getAngle("EURCAD",MAPeriod1,icount);
         
        }
      
        if(first == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod1,icount);
           i = i - getAngle("EURAUD",MAPeriod1,icount);
           i = i + getAngle("AUDNZD",MAPeriod1,icount);
           i = i + getAngle("AUDCAD",MAPeriod1,icount);
           i = i + getAngle("AUDCHF",MAPeriod1,icount);
           i = i + getAngle("AUDJPY",MAPeriod1,icount);
           i = i - getAngle("GBPAUD",MAPeriod1,icount);
           
         
        }
        if(first == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod1,icount);
           i = i + getAngle("CADJPY",MAPeriod1,icount);
           i = i - getAngle("EURCAD",MAPeriod1,icount);
           i = i - getAngle("GBPCAD",MAPeriod1,icount);
           i = i + getAngle("CADCHF",MAPeriod1,icount);
      

        }
        if(first == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod1,icount);
           i = i - getAngle("EURCHF",MAPeriod1,icount);
           i = i - getAngle("GBPCHF",MAPeriod1,icount);
           i = i - getAngle("AUDCHF",MAPeriod1,icount);
           i = i + getAngle("CHFJPY",MAPeriod1,icount);
           i = i - getAngle("CADCHF",MAPeriod1,icount);
           
        
        }
        
        if(first == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod1,icount);
           i = i - getAngle("EURNZD",MAPeriod1,icount);
           i = i + getAngle("NZDJPY",MAPeriod1,icount);
           i = i + getAngle("NZDUSD",MAPeriod1,icount);
           
         
         
        }
        if(first == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod1,icount);
           i = i - getAngle("EURJPY",MAPeriod1,icount);
           i = i - getAngle("CADJPY",MAPeriod1,icount);
           i = i - getAngle("GBPJPY",MAPeriod1,icount);
           i = i - getAngle("AUDJPY",MAPeriod1,icount);
           i = i - getAngle("CHFJPY",MAPeriod1,icount);
           i = i - getAngle("NZDJPY",MAPeriod1,icount);

        }
 
    
     
     

     return i * a;
     
     
   
 }
 double Check12(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
   if(first == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod2,icount);
           i = i - getAngle("EURGBP",MAPeriod2,icount);
           i = i + getAngle("GBPCHF",MAPeriod2,icount);
           i = i + getAngle("GBPJPY",MAPeriod2,icount);
           i = i + getAngle("GBPCAD",MAPeriod2,icount);
           i = i + getAngle("GBPAUD",MAPeriod2,icount);
           
        }
        if(first == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod2,icount);
           i = i - getAngle("GBPUSD",MAPeriod2,icount);
           i = i - getAngle("EURUSD",MAPeriod2,icount);
           i = i + getAngle("USDJPY",MAPeriod2,icount);
           i = i + getAngle("USDCAD",MAPeriod2,icount);
           i = i - getAngle("AUDUSD",MAPeriod2,icount);
           
         
        }
        if(first == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod2,icount);
           i = i + getAngle("EURAUD",MAPeriod2,icount);
           i = i + getAngle("EURGBP",MAPeriod2,icount);
           i = i + getAngle("EURCHF",MAPeriod2,icount);
           i = i + getAngle("EURJPY",MAPeriod2,icount);
           i = i + getAngle("EURNZD",MAPeriod2,icount);
           i = i + getAngle("EURCAD",MAPeriod2,icount);
         
        }
      
        if(first == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod2,icount);
           i = i - getAngle("EURAUD",MAPeriod2,icount);
           i = i + getAngle("AUDNZD",MAPeriod2,icount);
           i = i + getAngle("AUDCAD",MAPeriod2,icount);
           i = i + getAngle("AUDCHF",MAPeriod2,icount);
           i = i + getAngle("AUDJPY",MAPeriod2,icount);
           i = i - getAngle("GBPAUD",MAPeriod2,icount);
           
         
        }
        if(first == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod2,icount);
           i = i + getAngle("CADJPY",MAPeriod2,icount);
           i = i - getAngle("EURCAD",MAPeriod2,icount);
           i = i - getAngle("GBPCAD",MAPeriod2,icount);
           i = i + getAngle("CADCHF",MAPeriod2,icount);
      

        }
        if(first == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod2,icount);
           i = i - getAngle("EURCHF",MAPeriod2,icount);
           i = i - getAngle("GBPCHF",MAPeriod2,icount);
           i = i - getAngle("AUDCHF",MAPeriod2,icount);
           i = i + getAngle("CHFJPY",MAPeriod2,icount);
           i = i - getAngle("CADCHF",MAPeriod2,icount);
           
        
        }
        
        if(first == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod2,icount);
           i = i - getAngle("EURNZD",MAPeriod2,icount);
           i = i + getAngle("NZDJPY",MAPeriod2,icount);
           i = i + getAngle("NZDUSD",MAPeriod2,icount);
           
         
         
        }
        if(first == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod2,icount);
           i = i - getAngle("EURJPY",MAPeriod2,icount);
           i = i - getAngle("CADJPY",MAPeriod2,icount);
           i = i - getAngle("GBPJPY",MAPeriod2,icount);
           i = i - getAngle("AUDJPY",MAPeriod2,icount);
           i = i - getAngle("CHFJPY",MAPeriod2,icount);
           i = i - getAngle("NZDJPY",MAPeriod2,icount);

        }
 
     return i * a;
  
     
   
 }
 double Check13(int icount)
 {
 //USDが強いとき
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
     double i = 0;
if(first == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod3,icount);
           i = i - getAngle("EURGBP",MAPeriod3,icount);
           i = i + getAngle("GBPCHF",MAPeriod3,icount);
           i = i + getAngle("GBPJPY",MAPeriod3,icount);
           i = i + getAngle("GBPCAD",MAPeriod3,icount);
           i = i + getAngle("GBPAUD",MAPeriod3,icount);
           
        }
        if(first == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod3,icount);
           i = i - getAngle("GBPUSD",MAPeriod3,icount);
           i = i - getAngle("EURUSD",MAPeriod3,icount);
           i = i + getAngle("USDJPY",MAPeriod3,icount);
           i = i + getAngle("USDCAD",MAPeriod3,icount);
           i = i - getAngle("AUDUSD",MAPeriod3,icount);
           
         
        }
        if(first == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod3,icount);
           i = i + getAngle("EURAUD",MAPeriod3,icount);
           i = i + getAngle("EURGBP",MAPeriod3,icount);
           i = i + getAngle("EURCHF",MAPeriod3,icount);
           i = i + getAngle("EURJPY",MAPeriod3,icount);
           i = i + getAngle("EURNZD",MAPeriod3,icount);
           i = i + getAngle("EURCAD",MAPeriod3,icount);
         
        }
      
        if(first == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod3,icount);
           i = i - getAngle("EURAUD",MAPeriod3,icount);
           i = i + getAngle("AUDNZD",MAPeriod3,icount);
           i = i + getAngle("AUDCAD",MAPeriod3,icount);
           i = i + getAngle("AUDCHF",MAPeriod3,icount);
           i = i + getAngle("AUDJPY",MAPeriod3,icount);
           i = i - getAngle("GBPAUD",MAPeriod3,icount);
           
         
        }
        if(first == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod3,icount);
           i = i + getAngle("CADJPY",MAPeriod3,icount);
           i = i - getAngle("EURCAD",MAPeriod3,icount);
           i = i - getAngle("GBPCAD",MAPeriod3,icount);
           i = i + getAngle("CADCHF",MAPeriod3,icount);
      

        }
        if(first == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod3,icount);
           i = i - getAngle("EURCHF",MAPeriod3,icount);
           i = i - getAngle("GBPCHF",MAPeriod3,icount);
           i = i - getAngle("AUDCHF",MAPeriod3,icount);
           i = i + getAngle("CHFJPY",MAPeriod3,icount);
           i = i - getAngle("CADCHF",MAPeriod3,icount);
           
        
        }
        
        if(first == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod3,icount);
           i = i - getAngle("EURNZD",MAPeriod3,icount);
           i = i + getAngle("NZDJPY",MAPeriod3,icount);
           i = i + getAngle("NZDUSD",MAPeriod3,icount);
           
         
         
        }
        if(first == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod3,icount);
           i = i - getAngle("EURJPY",MAPeriod3,icount);
           i = i - getAngle("CADJPY",MAPeriod3,icount);
           i = i - getAngle("GBPJPY",MAPeriod3,icount);
           i = i - getAngle("AUDJPY",MAPeriod3,icount);
           i = i - getAngle("CHFJPY",MAPeriod3,icount);
           i = i - getAngle("NZDJPY",MAPeriod3,icount);

        }
 
   
    
     
     
     //f( -i < sumAngle)return false;
     return i * a;
     
     
   
 }
 
 double Check21(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
    
        if(second == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod1,icount);
           i = i - getAngle("EURGBP",MAPeriod1,icount);
           i = i + getAngle("GBPCHF",MAPeriod1,icount);
           i = i + getAngle("GBPJPY",MAPeriod1,icount);
           i = i + getAngle("GBPCAD",MAPeriod1,icount);
           i = i + getAngle("GBPAUD",MAPeriod1,icount);
           
        }
        if(second == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod1,icount);
           i = i - getAngle("GBPUSD",MAPeriod1,icount);
           i = i - getAngle("EURUSD",MAPeriod1,icount);
           i = i + getAngle("USDJPY",MAPeriod1,icount);
           i = i + getAngle("USDCAD",MAPeriod1,icount);
           i = i - getAngle("AUDUSD",MAPeriod1,icount);
           
         
        }
        if(second == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod1,icount);
           i = i + getAngle("EURAUD",MAPeriod1,icount);
           i = i + getAngle("EURGBP",MAPeriod1,icount);
           i = i + getAngle("EURCHF",MAPeriod1,icount);
           i = i + getAngle("EURJPY",MAPeriod1,icount);
           i = i + getAngle("EURNZD",MAPeriod1,icount);
           i = i + getAngle("EURCAD",MAPeriod1,icount);
         
        }
      
        if(second == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod1,icount);
           i = i - getAngle("EURAUD",MAPeriod1,icount);
           i = i + getAngle("AUDNZD",MAPeriod1,icount);
           i = i + getAngle("AUDCAD",MAPeriod1,icount);
           i = i + getAngle("AUDCHF",MAPeriod1,icount);
           i = i + getAngle("AUDJPY",MAPeriod1,icount);
           i = i - getAngle("GBPAUD",MAPeriod1,icount);
           
         
        }
        if(second == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod1,icount);
           i = i + getAngle("CADJPY",MAPeriod1,icount);
           i = i - getAngle("EURCAD",MAPeriod1,icount);
           i = i - getAngle("GBPCAD",MAPeriod1,icount);
           i = i + getAngle("CADCHF",MAPeriod1,icount);
      

        }
        if(second == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod1,icount);
           i = i - getAngle("EURCHF",MAPeriod1,icount);
           i = i - getAngle("GBPCHF",MAPeriod1,icount);
           i = i - getAngle("AUDCHF",MAPeriod1,icount);
           i = i + getAngle("CHFJPY",MAPeriod1,icount);
           i = i - getAngle("CADCHF",MAPeriod1,icount);
           
        
        }
        
        if(second == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod1,icount);
           i = i - getAngle("EURNZD",MAPeriod1,icount);
           i = i + getAngle("NZDJPY",MAPeriod1,icount);
           i = i + getAngle("NZDUSD",MAPeriod1,icount);
           
         
         
        }
        if(second == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod1,icount);
           i = i - getAngle("EURJPY",MAPeriod1,icount);
           i = i - getAngle("CADJPY",MAPeriod1,icount);
           i = i - getAngle("GBPJPY",MAPeriod1,icount);
           i = i - getAngle("AUDJPY",MAPeriod1,icount);
           i = i - getAngle("CHFJPY",MAPeriod1,icount);
           i = i - getAngle("NZDJPY",MAPeriod1,icount);

        }
 
     
    
    
     
    
     return -i;
     
     
 }
 double Check22(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
    if(second == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod2,icount);
           i = i - getAngle("EURGBP",MAPeriod2,icount);
           i = i + getAngle("GBPCHF",MAPeriod2,icount);
           i = i + getAngle("GBPJPY",MAPeriod2,icount);
           i = i + getAngle("GBPCAD",MAPeriod2,icount);
           i = i + getAngle("GBPAUD",MAPeriod2,icount);
           
        }
        if(second == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod2,icount);
           i = i - getAngle("GBPUSD",MAPeriod2,icount);
           i = i - getAngle("EURUSD",MAPeriod2,icount);
           i = i + getAngle("USDJPY",MAPeriod2,icount);
           i = i + getAngle("USDCAD",MAPeriod2,icount);
           i = i - getAngle("AUDUSD",MAPeriod2,icount);
           
         
        }
        if(second == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod2,icount);
           i = i + getAngle("EURAUD",MAPeriod2,icount);
           i = i + getAngle("EURGBP",MAPeriod2,icount);
           i = i + getAngle("EURCHF",MAPeriod2,icount);
           i = i + getAngle("EURJPY",MAPeriod2,icount);
           i = i + getAngle("EURNZD",MAPeriod2,icount);
           i = i + getAngle("EURCAD",MAPeriod2,icount);
         
        }
      
        if(second == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod2,icount);
           i = i - getAngle("EURAUD",MAPeriod2,icount);
           i = i + getAngle("AUDNZD",MAPeriod2,icount);
           i = i + getAngle("AUDCAD",MAPeriod2,icount);
           i = i + getAngle("AUDCHF",MAPeriod2,icount);
           i = i + getAngle("AUDJPY",MAPeriod2,icount);
           i = i - getAngle("GBPAUD",MAPeriod2,icount);
           
         
        }
        if(second == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod2,icount);
           i = i + getAngle("CADJPY",MAPeriod2,icount);
           i = i - getAngle("EURCAD",MAPeriod2,icount);
           i = i - getAngle("GBPCAD",MAPeriod2,icount);
           i = i + getAngle("CADCHF",MAPeriod2,icount);
      

        }
        if(second == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod2,icount);
           i = i - getAngle("EURCHF",MAPeriod2,icount);
           i = i - getAngle("GBPCHF",MAPeriod2,icount);
           i = i - getAngle("AUDCHF",MAPeriod2,icount);
           i = i + getAngle("CHFJPY",MAPeriod2,icount);
           i = i - getAngle("CADCHF",MAPeriod2,icount);
           
        
        }
        
        if(second == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod2,icount);
           i = i - getAngle("EURNZD",MAPeriod2,icount);
           i = i + getAngle("NZDJPY",MAPeriod2,icount);
           i = i + getAngle("NZDUSD",MAPeriod2,icount);
           
         
         
        }
        if(second == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod2,icount);
           i = i - getAngle("EURJPY",MAPeriod2,icount);
           i = i - getAngle("CADJPY",MAPeriod2,icount);
           i = i - getAngle("GBPJPY",MAPeriod2,icount);
           i = i - getAngle("AUDJPY",MAPeriod2,icount);
           i = i - getAngle("CHFJPY",MAPeriod2,icount);
           i = i - getAngle("NZDJPY",MAPeriod2,icount);

        }
     
    
     return -i;
     
     
 }
 double Check23(int icount)
 {   
     //if(!timeCheck(icount))return false;
     if(Bars <=  icount + 25)return false;
     //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
     //USDが弱いとき
     double i = 0;
    
    
    
    if(second == "GBP")
        {
           i = i + getAngle("GBPUSD",MAPeriod3,icount);
           i = i - getAngle("EURGBP",MAPeriod3,icount);
           i = i + getAngle("GBPCHF",MAPeriod3,icount);
           i = i + getAngle("GBPJPY",MAPeriod3,icount);
           i = i + getAngle("GBPCAD",MAPeriod3,icount);
           i = i + getAngle("GBPAUD",MAPeriod3,icount);
           
        }
        if(second == "USD")
        {
           i = i + getAngle("USDCHF",MAPeriod3,icount);
           i = i - getAngle("GBPUSD",MAPeriod3,icount);
           i = i - getAngle("EURUSD",MAPeriod3,icount);
           i = i + getAngle("USDJPY",MAPeriod3,icount);
           i = i + getAngle("USDCAD",MAPeriod3,icount);
           i = i - getAngle("AUDUSD",MAPeriod3,icount);
           
         
        }
        if(second == "EUR")
        {
           i = i + getAngle("EURUSD",MAPeriod3,icount);
           i = i + getAngle("EURAUD",MAPeriod3,icount);
           i = i + getAngle("EURGBP",MAPeriod3,icount);
           i = i + getAngle("EURCHF",MAPeriod3,icount);
           i = i + getAngle("EURJPY",MAPeriod3,icount);
           i = i + getAngle("EURNZD",MAPeriod3,icount);
           i = i + getAngle("EURCAD",MAPeriod3,icount);
         
        }
      
        if(second == "AUD")
        {
           i = i + getAngle("AUDUSD",MAPeriod3,icount);
           i = i - getAngle("EURAUD",MAPeriod3,icount);
           i = i + getAngle("AUDNZD",MAPeriod3,icount);
           i = i + getAngle("AUDCAD",MAPeriod3,icount);
           i = i + getAngle("AUDCHF",MAPeriod3,icount);
           i = i + getAngle("AUDJPY",MAPeriod3,icount);
           i = i - getAngle("GBPAUD",MAPeriod3,icount);
           
         
        }
        if(second == "CAD")
        {
           i = i - getAngle("USDCAD",MAPeriod3,icount);
           i = i + getAngle("CADJPY",MAPeriod3,icount);
           i = i - getAngle("EURCAD",MAPeriod3,icount);
           i = i - getAngle("GBPCAD",MAPeriod3,icount);
           i = i + getAngle("CADCHF",MAPeriod3,icount);
      

        }
        if(second == "CHF")
        {
           i = i - getAngle("USDCHF",MAPeriod3,icount);
           i = i - getAngle("EURCHF",MAPeriod3,icount);
           i = i - getAngle("GBPCHF",MAPeriod3,icount);
           i = i - getAngle("AUDCHF",MAPeriod3,icount);
           i = i + getAngle("CHFJPY",MAPeriod3,icount);
           i = i - getAngle("CADCHF",MAPeriod3,icount);
           
        
        }
        
        if(second == "NZD")
        {
           i = i - getAngle("AUDNZD",MAPeriod3,icount);
           i = i - getAngle("EURNZD",MAPeriod3,icount);
           i = i + getAngle("NZDJPY",MAPeriod3,icount);
           i = i + getAngle("NZDUSD",MAPeriod3,icount);
           
         
         
        }
        if(second == "JPY")
        {
           i = i - getAngle("USDJPY",MAPeriod3,icount);
           i = i - getAngle("EURJPY",MAPeriod3,icount);
           i = i - getAngle("CADJPY",MAPeriod3,icount);
           i = i - getAngle("GBPJPY",MAPeriod3,icount);
           i = i - getAngle("AUDJPY",MAPeriod3,icount);
           i = i - getAngle("CHFJPY",MAPeriod3,icount);
           i = i - getAngle("NZDJPY",MAPeriod3,icount);

        }
 
   
    
     
    
     return -i;
     
     
 }
 double getAngle(string Pare ,int period ,int icount)
 {
   double value1 =iMA(Pare, Period(), period, NULL, MODE_EMA, PRICE_CLOSE, icount + period);
   double value2 =iMA(Pare, Period(), period, NULL, MODE_EMA, PRICE_CLOSE, icount);
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
