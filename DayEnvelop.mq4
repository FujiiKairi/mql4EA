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
input int    LossCut=1000 ;
input double envHensa=1;
input int    MovingPeriod  =20;
input int    EnvPeriod  =10;
input int    RSIPeriod=10;
input int    haba=1000;
input int    RSI=90;


void OnTick()
  {
//---
   if(Bars<100 || IsTradeAllowed()==false){//bars チャートに表示されてるバーの本数 istradeallowed 自動売買が許可されているかどうか　されてるならtrue
   
      Print("ゆるされてない");
       return;
      }
//--- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();//ポジションを持っていなければポジションを得る
   else                                    CheckForClose();//ポジションを持っていれば決済する
  }
//+------------------------------------------------------------------+
void CheckForOpen()
{
   double uenv,denv;
   int    res;
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
   uenv=iEnvelopes(NULL,1440,EnvPeriod,1,0,PRICE_CLOSE,envHensa,1,0);//上のエンベロープ
   denv=iEnvelopes(NULL,1440,EnvPeriod,1,0,PRICE_CLOSE,envHensa,2,0);//上のエンベロープ
//--- sell conditions
  

      if(Close[0]>uenv&&High[0]-Close[0]>0&&iRSI(Symbol(),0,RSIPeriod,0,0)>=RSI&&Close[0]-uenv<haba)//open[0]が現在のバーの始値
        {
         res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
         return;
        }
   //--- buy conditions
      if(Close[0]<denv&&Close[0]-Low[0]>0&&iRSI(Symbol(),0,RSIPeriod,0,0)<=100-RSI&&denv-Close[0]<haba)
        {
         res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
         return;
      }
    
}
void CheckForClose(){
   double ema,uenv,denv;
//--- go trading only for first tiks of new bar
   if(Volume[0]>1) return;
//--- get Moving Average 
uenv=iEnvelopes(NULL,1440,EnvPeriod,1,0,PRICE_CLOSE,envHensa,1,0);//上のエンベロープ
   denv=iEnvelopes(NULL,1440,EnvPeriod,1,0,PRICE_CLOSE,envHensa,2,0);//上のエンベロープ
   ema=iMA(NULL,1440,MovingPeriod,0,MODE_EMA,PRICE_CLOSE,0);
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