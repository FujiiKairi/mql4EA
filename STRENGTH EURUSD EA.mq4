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
#define MAGICMA  20190611
#define PI 3.14159265
int NumUseIndicator = 0;
double MaximumProfit = 0;//最大の利益
double EntryPrice = 0;//エントリーした価格
input   string              SeparateLot= "";                            // ▼ ロット設定
input double                Lots          =1;                         //┣ ロット数(1ロット十万通貨単位)

input int takeProfit = 30;
input int LossCut = 60;
input   string              SeparateRikaku= "";                         // ▼ 利確設定
input   int                 MinimumProfit = 5;                          // ┣ 最低獲得pip
input   int                 ProfitPercentage = 30;                      // ┗ 最高から落ちて利確するパーセンテージ

input   string              SeparateRSI = "";                           // ▼ ma設定
input   int                 MAPeriod1 = 4;
input   int                 MAPeriod2 = 8;
input   int                 MAPeriod3 = 16;
input   int                 MAPeriod4 = 32;
input   double              BBPeriod = 2;
input   int                 sum = 200; //useとeurの差
input   int                 sumAngle = 60;           //角度の合計
input   int                 okCount = 10;                //条件にかぶってるものの数
input   int                 continueNum = 20;//〇連続で出れば矢印出す

input   string              SeparateAlert = "";                         // ▼ アラート設定
input   bool                UseAlert = true;                            // ┗ ON/OFF

input   string              SeparateSendMail = "";                      // ▼ メール設定
input   bool                UseSendMail = true;                         // ┗ ON/OFF

void OnTick()
{
//---
     if(Bars<100 || IsTradeAllowed()==false)return;
     if(Volume[0] != 1)return;
//--- calculate open orders by current symbol
     bool CB = CheckBuy(0);
     bool CS = CheckSell(0);
     
     for(int i=0;i<OrdersTotal();i++)
     {
        //if(CS || CheckForBuyClose(i) ||CheckForBuyCut(i))
        if(CS)
        {
            MaximumProfit = 0;
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
                  Print("OrderClose error ",GetLastError());
        }

        //if(CB || CheckForSellClose(i)||CheckForSellCut(i))
        if(CB){   
            MaximumProfit = 0;
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
                  Print("OrderClose error ",GetLastError());
        }
    } 
    if(CalculateCurrentOrders(Symbol())==0)
     {   
        if(CB)
        {
            int res;
            res = OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Red);//戻り値はチケット番号
            MaximumProfit = Ask;
            EntryPrice = Ask;
        }
        if(CS)
        {
            int res;
            res = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Red);//戻り値はチケット番号
            MaximumProfit = Bid;
            EntryPrice = Bid;
        }
     }
}



bool CheckForBuyClose(int i){
   if(CalculateCurrentOrders(Symbol())==0)return false;
   if(OrderType() != OP_BUY)return false;
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) return false;
   if(OrderMagicNumber()!=MAGICMA )return false;
   if(OrderSymbol()!=Symbol()) return false;

      
   //if( Close[0] <= EntryPrice + LossCut*Point*10)return false;
   //if((MaximumProfit - EntryPrice)  < (Close[0] - EntryPrice) / (Point * 10))MaximumProfit = (Close[0] - EntryPrice) / (Point * 10);
   if( MaximumProfit  < (Close[0] - EntryPrice) /(Point * 10) )MaximumProfit = (Close[0] - EntryPrice)/(Point * 10);
   if(MinimumProfit >= MaximumProfit)return false;
   if(((Close[0] - EntryPrice) / (Point * 10)) <= (MaximumProfit * (100 - ProfitPercentage) * 0.01 ))return false;
   return true;
}


bool CheckForSellClose(int i)
{
   if(CalculateCurrentOrders(Symbol())==0)return false;
   if(OrderType() != OP_SELL)return false;
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) return false;
   if(OrderMagicNumber()!=MAGICMA )return false;
   if(OrderSymbol()!=Symbol()) return false;
   
   //if( Close[0] >= EntryPrice - LossCut*Point*10)return false;
   
   if(MaximumProfit  < (EntryPrice - Close[0]) / (Point * 10))MaximumProfit = (EntryPrice - Close[0]) / (Point * 10);
   if(MinimumProfit >= MaximumProfit )return false;
   if(((EntryPrice - Close[0]) / (Point * 10)) <= (MaximumProfit * (100 - ProfitPercentage) * 0.01 ))return false;
   return true;
}
bool CheckForBuyCut(int i){
   if(CalculateCurrentOrders(Symbol())==0)return false;
   if(OrderType() != OP_BUY)return false;
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) return false;
   if(OrderMagicNumber()!=MAGICMA )return false;
   if(OrderSymbol()!=Symbol()) return false;
   if( Close[0] >= EntryPrice - LossCut*Point*10)return false;
   return true;
}
bool CheckForSellCut(int i)
{
   if(CalculateCurrentOrders(Symbol())==0)return false;
   if(OrderType() != OP_SELL)return false;
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) return false;
   if(OrderMagicNumber()!=MAGICMA )return false;
   if(OrderSymbol()!=Symbol()) return false;
   if( EntryPrice + LossCut*Point*10 >= Close[0])return false;
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
bool timeCheck(int icount)
 {
 //日本時間の6時から14時のみ取引
   if(TimeHour(Time[icount]) == 0)return true;
   if(TimeHour(Time[icount]) == 1)return true;
   if(TimeHour(Time[icount]) == 2)return true;
   if(TimeHour(Time[icount]) == 3)return true;
   if(TimeHour(Time[icount]) == 4)return true;
   if(TimeHour(Time[icount]) == 5)return true;
   if(TimeHour(Time[icount]) == 6)return true;
   if(TimeHour(Time[icount]) == 7)return true;
   if(TimeHour(Time[icount]) == 8)return true;
   return false;
 }
 
 
bool CheckBuy(int icount)
 {   
    // if(ArrayRange(VolumeEUD,0) < continueNum + icount + 10) return false;
        //if(!timeCheck(icount))return false;
        if(Bars <=  icount + 5)return false;
        
        //USDが弱いとき
        //if(VolumeUSD[icount + continueNum] < VolumeEUD[icount + continueNum])return false;
        
        //----------------------------------------------------------------------------------------
        
        //if(MathAbs(VolumeUSD[icount] - VolumeEUD[icount]) < sum)return false;
        if(CheckUSD(icount + 2) > CheckEUD(icount + 2))return false;
        if(CheckUSD(icount + 1) <= CheckEUD(icount + 1))return false;
        double suma = 0;
        for(int i = 1; i < 6 ; i++)
        {
            suma = suma + MathAbs(Close[i + 1] - Open[i + 1]);
        }
        if(suma / 5.0 * 5 < MathAbs(Close[1] - Open[1]))return false;
        return true;
     
     
 }
 
bool CheckSell(int icount)
 {
      //if(ArrayRange(VolumeEUD,0) < continueNum + icount + 10) return false;
        //if(!timeCheck(icount))return false;
        if(Bars <=  icount + 5)return false;
        
        
        //if(CheckUSD(icount + continueNum) > CheckEUD(icount + continueNum))return false;
        //--------------------------------------------------------------------------------------
        
        //if(MathAbs(VolumeUSD[icount] - VolumeEUD[icount]) < sum)return false;
        if(CheckUSD(icount + 2) < CheckEUD(icount + 2))return false;
        if(CheckUSD(icount + 1) >= CheckEUD(icount + 1))return false;
        double suma = 0;
        for(int i = 1; i < 6 ; i++)
        {
            suma = suma + MathAbs(Close[i + 1] - Open[i + 1]);
        }
        if(suma / 5.0 * 5 < MathAbs(Close[1] - Open[1]))return false;
        return true;
     
     
   
 }
 
   double CheckUSD(int icount)
    {   
        //if(!timeCheck(icount))return false;
        if(Bars <=  icount + 25)return false;
        //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, icount) < Close[icount])return false;
        //USDが弱いとき
        double i = 0;
        //usd
        //if(countBuySt(icount) < okCount)return false;
        
        i = i - getAngle("USDCHF",MAPeriod1,icount);//プラスならグラフが右肩上がり
        i = i - getAngle("USDJPY",MAPeriod1,icount);
        i = i - getAngle("USDCAD",MAPeriod1,icount);
        i = i + getAngle("GBPUSD",MAPeriod1,icount); 
        i = i + getAngle("EURUSD",MAPeriod1,icount); 
        i = i + getAngle("AUDUSD",MAPeriod1,icount); 
        i = i + getAngle("NZDUSD",MAPeriod1,icount); 
        
        //--------------------------------------------
        i = i - getAngle("USDCHF",MAPeriod2,icount);//プラスならグラフが右肩上がり
        i = i - getAngle("USDJPY",MAPeriod2,icount);
        i = i - getAngle("USDCAD",MAPeriod2,icount);
        i = i + getAngle("GBPUSD",MAPeriod2,icount); 
        i = i + getAngle("EURUSD",MAPeriod2,icount); 
        i = i + getAngle("AUDUSD",MAPeriod2,icount); 
       i = i + getAngle("NZDUSD",MAPeriod2,icount);
       
       i = i - getAngle("USDCHF",MAPeriod3,icount);//プラスならグラフが右肩上がり
        i = i - getAngle("USDJPY",MAPeriod3,icount);
        i = i - getAngle("USDCAD",MAPeriod3,icount);
        i = i + getAngle("GBPUSD",MAPeriod3,icount); 
        i = i + getAngle("EURUSD",MAPeriod3,icount); 
        i = i + getAngle("AUDUSD",MAPeriod3,icount); 
       i = i + getAngle("NZDUSD",MAPeriod3,icount); 
       
       i = i - getAngle("USDCHF",MAPeriod4,icount);//プラスならグラフが右肩上がり
        i = i - getAngle("USDJPY",MAPeriod4,icount);
        i = i - getAngle("USDCAD",MAPeriod4,icount);
        i = i + getAngle("GBPUSD",MAPeriod4,icount); 
        i = i + getAngle("EURUSD",MAPeriod4,icount); 
        i = i + getAngle("AUDUSD",MAPeriod4,icount); 
       i = i + getAngle("NZDUSD",MAPeriod4,icount); 
        //eudが強いとき
        //eur
        /*
        i = i + getAngle("EURUSD",MAPeriod1,icount);
        i = i + getAngle("EURGBP",MAPeriod1,icount);
        i = i + getAngle("EURAUD",MAPeriod1,icount);
        i = i + getAngle("EURCHF",MAPeriod1,icount);
        i = i + getAngle("EURJPY",MAPeriod1,icount);
        i = i + getAngle("EURNZD",MAPeriod1,icount);
        i = i + getAngle("EURCAD",MAPeriod1,icount);

        i = i + getAngle("EURUSD",MAPeriod2,icount);
        i = i + getAngle("EURGBP",MAPeriod2,icount);
        i = i + getAngle("EURAUD",MAPeriod2,icount);
        i = i + getAngle("EURCHF",MAPeriod2,icount);
        i = i + getAngle("EURJPY",MAPeriod2,icount);
        i = i + getAngle("EURNZD",MAPeriod2,icount);
        i = i + getAngle("EURCAD",MAPeriod2,icount);
        */
        //if( i < sumAngle)return false;
       
        return i;
        
        
    }
    
    double CheckEUD(int icount)
    {
    //USDが強いとき
        //if(!timeCheck(icount))return false;
        if(Bars <=  icount + 25)return false;
        //if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, icount) > Close[icount])return false;
        double i = 0;
        //usd
        //if(countSellSt(icount) < okCount)return false;
        /*
        i = i - getAngle("USDCHF",MAPeriod1,icount);//プラスならグラフが右肩上がり
        i = i - getAngle("USDJPY",MAPeriod1,icount);
        i = i - getAngle("USDCAD",MAPeriod1,icount);
        i = i + getAngle("GBPUSD",MAPeriod1,icount); 
        i = i + getAngle("EURUSD",MAPeriod1,icount); 
        i = i + getAngle("AUDUSD",MAPeriod1,icount); 
        i = i + getAngle("NZDUSD",MAPeriod1,icount); 
        
        //--------------------------------------------
        i = i - getAngle("USDCHF",MAPeriod2,icount);//プラスならグラフが右肩上がり
        i = i - getAngle("USDJPY",MAPeriod2,icount);
        i = i - getAngle("USDCAD",MAPeriod2,icount);
        i = i + getAngle("GBPUSD",MAPeriod2,icount); 
        i = i + getAngle("EURUSD",MAPeriod2,icount); 
        i = i + getAngle("AUDUSD",MAPeriod2,icount); 
        i = i + getAngle("NZDUSD",MAPeriod2,icount); 
        //eurが強いとき
        //eur
        */
        
        i = i + getAngle("EURUSD",MAPeriod1,icount);
        i = i + getAngle("EURGBP",MAPeriod1,icount);
        i = i + getAngle("EURAUD",MAPeriod1,icount);
        i = i + getAngle("EURCHF",MAPeriod1,icount);
        i = i + getAngle("EURJPY",MAPeriod1,icount);
        i = i + getAngle("EURNZD",MAPeriod1,icount);
        i = i + getAngle("EURCAD",MAPeriod1,icount);
        
        i = i + getAngle("EURUSD",MAPeriod2,icount);
        i = i + getAngle("EURGBP",MAPeriod2,icount);
        i = i + getAngle("EURAUD",MAPeriod2,icount);
        i = i + getAngle("EURCHF",MAPeriod2,icount);
        i = i + getAngle("EURJPY",MAPeriod2,icount);
        i = i + getAngle("EURNZD",MAPeriod2,icount);
        i = i + getAngle("EURCAD",MAPeriod2,icount);
        
        i = i + getAngle("EURUSD",MAPeriod3,icount);
        i = i + getAngle("EURGBP",MAPeriod3,icount);
        i = i + getAngle("EURAUD",MAPeriod3,icount);
        i = i + getAngle("EURCHF",MAPeriod3,icount);
        i = i + getAngle("EURJPY",MAPeriod3,icount);
        i = i + getAngle("EURNZD",MAPeriod3,icount);
        i = i + getAngle("EURCAD",MAPeriod3,icount);
        
        i = i + getAngle("EURUSD",MAPeriod4,icount);
        i = i + getAngle("EURGBP",MAPeriod4,icount);
        i = i + getAngle("EURAUD",MAPeriod4,icount);
        i = i + getAngle("EURCHF",MAPeriod4,icount);
        i = i + getAngle("EURJPY",MAPeriod4,icount);
        i = i + getAngle("EURNZD",MAPeriod4,icount);
        i = i + getAngle("EURCAD",MAPeriod4,icount);
        //f( -i < sumAngle)return false;
        return -i;
        
        
      
    }

