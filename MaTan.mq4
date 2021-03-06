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
#define MAGICMA  20181010
input double Lots          =0.01;//1ロット十万通貨単位
input int    LossCut=10 ;
input int    TakeProfit=10;
input double OTang=1.2;
input double CTang=1.2;
input int    MovingPeriod  =3;
input int    MovingShift   =0;
input int    RSIPeriod=10;
input double    LotSize=0.01;
input int tyousei=500;

void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue
   
      
       return;
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();//ポジションを持っていなければポジションを得る
   else                                    CheckForClose();//ポジションを持っていれば決済する
  }
//+------------------------------------------------------------------+
void CheckForOpen()
{
   double pema,cema;
   int    res;
 pema=iMA(NULL,1,MovingPeriod,MovingShift,MODE_EMA,PRICE_CLOSE,0);
 cema=iMA(NULL,0,MovingPeriod,MovingShift,MODE_EMA,PRICE_CLOSE,0);
  Print((cema-pema)*(tyousei));
   Print(((cema-pema)*(tyousei)/Period()));
   //Print(Period());
//--- sell conditions
   if(((cema-pema)*(tyousei)/Period())>OTang)//open[0]が現在のバーの始値
     {
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,2,Ask-LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
      return;
     }
//--- buy conditions
   if(((cema-pema)*(tyousei)/Period())<-OTang)
     {
     
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,2,Bid+LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
      return;
   }
}

  void CheckForClose(){
   double pema,cema;
   
 pema=iMA(NULL,1,MovingPeriod,MovingShift,MODE_EMA,PRICE_CLOSE,0);
 cema=iMA(NULL,0,MovingPeriod,MovingShift,MODE_EMA,PRICE_CLOSE,0);
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get Moving Average 
   
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(((cema-pema)*(tyousei)/Period())<CTang)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(((cema-pema)*(tyousei)/Period())>-CTang)
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