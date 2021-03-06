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
#define MAGICMA  20171010
input double Lots          =0.01;//1ロット十万通貨単位
input int    LossCut=50 ;
//losscut=10で1pip
input int    RSIPeriod=10;
input int    TakeProfit=10;
input double DecreaseFactor=3;
input int    MovingPeriod  =20;
input int    MovingShift   =0;



void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue
   
      Print("ゆるされてない");
       return;
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();//ポジションを持っていなければポジションを得る
  // else                                    CheckForClose();//ポジションを持っていれば決済する
  }
//+------------------------------------------------------------------+
void CheckForOpen()
{
   
   int    res;
   double sum=0;
   int    i=0,k=0;
   int    count=1;
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
   
//買いの時
   
   while(i==0){
      if(Close[count]-Open[count]>0){
         count++;
      }
      else{
         i=1;
      }
   }
   if(count!=1&&Close[count]-Open[count]<0&&Close[count+1]-Open[count+1]<0&&Close[count+2]-Open[count+2]<0&&iRSI(Symbol(),0,RSIPeriod,0,0)<=30)//open[0]が現在のバーの始値
     {
     for(k=2;k<12;k++){
         sum=sum+MathAbs(Close[k]-Open[k]);
     }
     if((sum/6)>MathAbs(Close[1]-Open[1])){
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-LossCut*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
         return;
        }
     }
//--- 売りの時
   sum=0;
   i=0;
   k=0;
   count=1;
   while(i==0){
      if(Close[count]-Open[count]<0){
         count++;
      }
      else{
         i=1;
      }
   }
   if(count!=1&&Close[count]-Open[count]>0&&Close[count+1]-Open[count+1]>0&&Close[count+2]-Open[count+2]>0&&iRSI(Symbol(),0,RSIPeriod,0,0)>=70)//open[0]が現在のバーの始値
     {
     for(k=2;k<12;k++){
         sum=sum+MathAbs(Close[k]-Open[k]);
     }
     if((sum/6)>MathAbs(Close[1]-Open[1])){
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+LossCut*Point,Bid-TakeProfit*Point,"",MAGICMA,0,Red);//戻り値はチケット番号
      return;
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