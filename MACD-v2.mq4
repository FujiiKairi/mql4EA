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
#define MAGICMA  20181008
input double Lots          =0.03;//1ロット十万通貨単位
input double haba=0.001;//交差の角度を測る指標
input int    LossCut=10 ;
input int    TakeProfit=10;
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
   double MacdCurrent,MacdPrevious;
    double MacdPrevious2,SignalPrevious2;
   double SignalCurrent,SignalPrevious;

 Print("openは");
   Print(Open[0]);
    Print("closeは");
   Print(Close[0]);
   Print(Bid);
   
   MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   MacdPrevious2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,3);
   SignalPrevious2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,3);
   int    res;
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
   
//--- sell conditions


      if(SignalPrevious-MacdPrevious<0&&SignalCurrent-MacdCurrent>0&&MacdPrevious2-SignalPrevious2>haba)//open[0]が現在のバーの始値
        {
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+LossCut*Point,Ask-TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
         return;
        }
   //--- buy conditions
      if(SignalPrevious-MacdPrevious>0&&SignalCurrent-MacdCurrent<0&&SignalPrevious2-MacdPrevious2>haba)
        {
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-LossCut*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
         return;
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