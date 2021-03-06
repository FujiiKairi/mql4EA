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
input int MAGICMA=  20190227;
input double Lots          =0.01;//1ロット十万通貨単位
input int    LossCut=50 ;
input int    TakeProfit=50 ;

//losscut=10で1pip






void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue
   
      Print("ゆるされてない");
       return;
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();//ポジションを持っていなければポジションを得る
   //else                                    CheckForClose();//ポジションを持っていれば決済する
  }
//+------------------------------------------------------------------+
void CheckForOpen()
{
   
   int    res;

   if(CheckSell())//open[0]が現在のバーの始値
   {
      res=OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, Bid + LossCut * Point , Ask - TakeProfit * Point , "", MAGICMA, 0, Red);//戻り値はチケット番号
      return;
   }
}
void CheckForClose(){
 
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      
      /*if(OrderType()==OP_SELL)
        {
         if(Ask<ema)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
        */
     }
}

bool CheckSell()
 {
    int shift = 0;
     if(TimeMonth(Time[shift]) == 4 || TimeMonth(Time[shift]) == 6 || TimeMonth(Time[shift]) == 9 || TimeMonth(Time[shift]) == 11)
     {
        for(int i = 5; i< 31 ; i = i + 5)
        {
      
           if(TimeDayOfWeek(Time[shift]) == 5 && (TimeDay(Time[shift]) == i-1 || TimeDay(Time[shift]) == i-2)  )//5は金曜日
           {
              return CheckTime();
           }
           else if(TimeDay(Time[shift]) == i &&(TimeDayOfWeek(Time[shift]) != 6 && TimeDayOfWeek(Time[shift]) != 0)  )//5は金曜日
           {
               return CheckTime();
           }
           
        }
        return false;     
          
     }
     
     if(TimeMonth(Time[shift]) == 1 || TimeMonth(Time[shift]) == 3 || TimeMonth(Time[shift]) == 5 
     ||TimeMonth(Time[shift]) == 7 || TimeMonth(Time[shift]) == 8 || TimeMonth(Time[shift]) == 10 || TimeMonth(Time[shift]) == 12)
     {
        for(int i = 5; i< 26 ; i = i + 5)
        {
      
           if(TimeDayOfWeek(Time[shift]) == 5 && (TimeDay(Time[shift]) == i-1 || TimeDay(Time[shift]) == i-2)  )//5は金曜日
           {
              return CheckTime();
           }
           else if(TimeDay(Time[shift]) == i &&(TimeDayOfWeek(Time[shift]) != 6 && TimeDayOfWeek(Time[shift]) != 0)  )//5は金曜日
           {
               return CheckTime();
           }
           
        }
        if(TimeDayOfWeek(Time[shift]) == 5 && (TimeDay(Time[shift]) == 30 || TimeDay(Time[shift]) == 29)  )//5は金曜日
        {
           return CheckTime();
        }
        else if(TimeDay(Time[shift]) == 31 &&(TimeDayOfWeek(Time[shift]) != 6 && TimeDayOfWeek(Time[shift]) != 0)  )//5は金曜日
        {
            return CheckTime();
        }
        return false;
     }
     
     else
     {
        for(int i = 5; i< 26 ; i = i + 5)
        {
           if(TimeDayOfWeek(Time[shift]) == 5 && (TimeDay(Time[shift]) == i-1 || TimeDay(Time[shift]) == i-2)  )//5は金曜日
           {
              return CheckTime();
           }
           else if(TimeDay(Time[shift]) == i &&(TimeDayOfWeek(Time[shift]) != 6 && TimeDayOfWeek(Time[shift]) != 0)  )//5は金曜日
           {
               return CheckTime();
           }
        }
        
        if(TimeYear(Time[shift]) % 4 != 0)//うるう年じゃない
        {
           if(TimeDayOfWeek(Time[shift]) == 5 && (TimeDay(Time[shift]) == 27 || TimeDay(Time[shift]) == 26)  )//5は金曜日
           {
              return CheckTime();
           }
           else if(TimeDay(Time[shift]) == 28 &&(TimeDayOfWeek(Time[shift]) != 6 && TimeDayOfWeek(Time[shift]) != 0)  )//5は金曜日
           {
               return CheckTime();
           }
        }
        else
        {
            if(TimeDayOfWeek(Time[shift]) == 5 && (TimeDay(Time[shift]) == 28 || TimeDay(Time[shift]) == 27)  )//5は金曜日
           {
              return CheckTime();
           }
           else if(TimeDay(Time[shift]) == 29 &&(TimeDayOfWeek(Time[shift]) != 6 && TimeDayOfWeek(Time[shift]) != 0)  )//5は金曜日
           {
               return CheckTime();
           }
        }
        return false;
     }
 
     return true;
 }
    
bool CheckTime()
{
   int shift = 0;
   if(TimeSeconds(Time[shift]) != 0 )return false;
   if(TimeMinute(Time[shift]) != 55 )return false;
   if(TimeHour(Time[shift]) != 2 )return false;
   return true;
      
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