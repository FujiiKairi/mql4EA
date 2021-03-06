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
#define MAGICMA  20190601
int NumUseIndicator = 0;
double MaximumProfit = 0;//最大の利益
double EntryPrice = 0;//エントリーした価格
input   string              SeparateLot= "";                            // ▼ ロット設定
input double                Lots          =0.1;                         //┣ ロット数(1ロット十万通貨単位)
input int                   LossCut = 10 ;                              // ┗ ロスカット(pip)
input   string              SeparateRikaku= "";                         // ▼ 利確設定
input   int                 MinimumProfit = 5;                          // ┣ 最低獲得pip
input   int                 ProfitPercentage = 30;                      // ┗ 最高から落ちて利確するパーセンテージ

input   string              SeparateBands = "";                         // ▼ 移動平均線設定
input   int                 Ma1 = 25;                                   // ┣ 期間(短期)
input   int                 Ma2 = 50;                                   // ┣ 期間(中期)
input   int                 Ma3 = 75;                                   // ┣ 期間(長期)
input   ENUM_MA_METHOD      EnvMAMethod = MODE_SMA;                     // ┗ 種別

input  int                  bbPlus = 20; //bbの傾き判断を何本前からか
input  int                  bbAngle = 170;//bbの角度
input  int                  bbMaxAngle = 270;//bbの角度
input    string             SeparateSt = "";                            //┣ ストキャスティクス設定
input   int                 StKPeriod=5;                                //┣ %K期間
input   int                 StDPeriod=2;                                //┣ %D期間
input   int                 StSlowing=2;                                //┣ スローイング
input   ENUM_MA_METHOD      StMAMethod = MODE_SMA;                      //┣ 移動平均の種別
input   int                 StUpLine = 80;                              //┣ 上の線(%)
input   int                 StDownLine = 20;                            //┗ 下の線(%)

input   string              SeparateAlert = "";                         // ▼ アラート設定
input   bool                UseAlert = true;                            // ┗ ON/OFF

input   string              SeparateSendMail = "";                      // ▼ メール設定
input   bool                UseSendMail = true;                         // ┗ ON/OFF

void OnTick()
{
//---
     if(Bars<100 || IsTradeAllowed()==false)return;
    
//--- calculate open orders by current symbol
     if(CheckForBuyOpen())
     {
         int res;
         res = OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Red);//戻り値はチケット番号
         MaximumProfit = Ask;
         EntryPrice = Ask;
     }
     if(CheckForSellOpen())
     {
         int res;
         res = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Red);//戻り値はチケット番号
         MaximumProfit = Bid;
         EntryPrice = Bid;
     }
     
     for(int i=0;i<OrdersTotal();i++)
     {
        if(CheckForBuyClose(i) ||CheckForBuyCut(i) )
        {
            MaximumProfit = 0;
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
                  Print("OrderClose error ",GetLastError());
        }
        if(CheckForSellClose(i)||CheckForSellCut(i))
        {   
            MaximumProfit = 0;
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White))
                  Print("OrderClose error ",GetLastError());
        }
    } 
}

bool CheckForBuyOpen()
{
   if(CalculateCurrentOrders(Symbol())!=0)return false;
   if(checkBuy(1) == 7)return true;
   return false;
}
bool CheckForSellOpen()
{
   if(CalculateCurrentOrders(Symbol())!=0)return false;
   if(checkSell(1) == 7)return true;
   return false;

}

bool CheckForBuyClose(int i){
   if(CalculateCurrentOrders(Symbol())==0)return false;
   if(OrderType() != OP_BUY)return false;
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) return false;
   if(OrderMagicNumber()!=MAGICMA )return false;
   if(OrderSymbol()!=Symbol()) return false;
   
   if( Close[0] <= EntryPrice + LossCut*Point*10)return false;
   return true;
   
   if(MaximumProfit  < (Close[0] - EntryPrice) / (Point * 10))MaximumProfit = (Close[0] - EntryPrice) / (Point * 10);
   if(MinimumProfit >= MaximumProfit )return false;
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
   
   if( Close[0] >= EntryPrice - LossCut*Point*10)return false;
   return true;
   
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
int checkBuy(int shift)
{    
     int score = 0;
     if(TimeDayOfWeek(Time[shift]) == 1 && TimeHour(Time[shift]) == 0)return 0;//窓回避
     if(TimeDayOfWeek(Time[shift]) == 5 && TimeHour(Time[shift]) == 23)return 0;//窓回避
     double ma1 = iMA(Symbol(), Period(),Ma1, 0 ,EnvMAMethod ,PRICE_CLOSE ,shift);//短期
     double ma2 = iMA(Symbol(), Period(),Ma2, 0 ,EnvMAMethod ,PRICE_CLOSE ,shift);
     double ma3 = iMA(Symbol(), Period(),Ma3, 0 ,EnvMAMethod ,PRICE_CLOSE ,shift);
     if(ma1 < ma2) return 0;
     if(ma2 < ma3) return 0;

     double PreKLine = iStochastic(NULL,0,StKPeriod , StDPeriod,StSlowing,StMAMethod, 0, MODE_MAIN, shift + 1);
     double PreDLine = iStochastic(NULL,0, StKPeriod, StDPeriod, StSlowing, StMAMethod, 0, MODE_SIGNAL, shift + 1);
     double KLine = iStochastic(NULL, 0, StKPeriod, StDPeriod, StSlowing, StMAMethod, 0, MODE_MAIN, shift);
     double DLine = iStochastic(NULL, 0, StKPeriod, StDPeriod, StSlowing, StMAMethod, 0, MODE_SIGNAL, shift);
     if(StDownLine <= PreKLine)return 0;
     if(StDownLine <= PreDLine)return 0;
     if(PreKLine >= PreDLine)return 0;
     if(DLine >= KLine)return 0;
     
     if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_LOWER, shift)>Close[shift])score = score + 5;
     else if(iBands(NULL,0, 21, 1, 0, PRICE_CLOSE, MODE_LOWER, shift)>Close[shift])score = score + 2;
     if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_MAIN, shift) - 
     iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_MAIN, shift + bbPlus) > 0)score = score + 2;
     //if(-getAngle(shift) > bbAngle && -getAngle(shift) <bbMaxAngle)score = score + 2;

     return score;
}
int checkSell(int shift)
{
     int score = 0;
     if(TimeDayOfWeek(Time[shift]) == 1 && TimeHour(Time[shift]) == 0)return 0;//窓回避
     if(TimeDayOfWeek(Time[shift]) == 5 && TimeHour(Time[shift]) == 23)return 0;//窓回避
     double ma1 = iMA(Symbol(), Period(), Ma1, 0 ,EnvMAMethod ,PRICE_CLOSE ,shift);//短期
     double ma2 = iMA(Symbol(), Period(), Ma2, 0 ,EnvMAMethod ,PRICE_CLOSE ,shift);
     double ma3 = iMA(Symbol(), Period(), Ma3, 0 ,EnvMAMethod ,PRICE_CLOSE ,shift);
     if(ma3 < ma2) return 0;
     if(ma2 < ma1) return 0;
 
     double PreKLine = iStochastic(NULL,0, StKPeriod ,StDPeriod,StSlowing,StMAMethod,0,MODE_MAIN,shift + 1);
     double PreDLine = iStochastic(NULL,0,StKPeriod,StDPeriod,StSlowing,StMAMethod,0,MODE_SIGNAL,shift + 1);
     double KLine = iStochastic(NULL,0,StKPeriod,StDPeriod,StSlowing,StMAMethod,0,MODE_MAIN,shift);
     double DLine = iStochastic(NULL,0,StKPeriod,StDPeriod,StSlowing,StMAMethod,0,MODE_SIGNAL,shift);
     if(PreKLine<=StUpLine)return 0;
     if(PreDLine<=StUpLine)return 0;
     if(PreDLine >= PreKLine)return 0;
     if(KLine >= DLine )return 0;
     

     if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_UPPER, shift)<Close[shift])score = score + 5;
     else if(iBands(NULL,0, 21, 1, 0, PRICE_CLOSE, MODE_UPPER, shift)<Close[shift])score = score + 2;
     if(iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_MAIN, shift) - 
     iBands(NULL,0, 21, 2, 0, PRICE_CLOSE, MODE_MAIN, shift + bbPlus) < 0)score = score + 2;
     //if(getAngle(shift) > bbAngle && getAngle(shift) < bbMaxAngle)score = score + 2;
     
     return score;    
}
