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
input int MAGICMA=  20181230;
input double Lots          =0.1;//1ロット十万通貨単位
int jouken=0;
double valb,vals;
int buyw=0;
int buyl=0;
int sellw=0;
int selll=0;




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
 
   int    res;
   double RSIbuf[21];
   for(int i=0;i<21;i++){
      RSIbuf[i]=iRSI(Symbol(),0,14,0,i);
   }
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
    if(jouken==0){
     
      double up,down;
     
      up=iBandsOnArray(RSIbuf, NULL, 21, 2, NULL, MODE_UPPER, 0);
      down=iBandsOnArray(RSIbuf, NULL, 21, 2, NULL, MODE_LOWER, 0);
   //--- buy conditions
   
      if(iBands(Symbol(),0,10,2,0,PRICE_CLOSE,MODE_LOWER,0)>Close[0]&&down>iRSI(Symbol(),0,14,0,0)
      &&iMA(NULL,0,12,0,MODE_SMA,PRICE_CLOSE,0)>iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,0)
      &&iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,0)>iMA(NULL,0,75,0,MODE_SMA,PRICE_CLOSE,0))
        {
        jouken=1;
         return;
      }
   //--- sell conditions
  

      if(iBands(Symbol(),0,10,2,0,PRICE_CLOSE,MODE_UPPER,0)<Close[0]&&up<iRSI(Symbol(),0,14,0,0)
      &&iMA(NULL,0,12,0,MODE_SMA,PRICE_CLOSE,0)<iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,0)
      &&iMA(NULL,0,50,0,MODE_SMA,PRICE_CLOSE,0)<iMA(NULL,0,75,0,MODE_SMA,PRICE_CLOSE,0))//open[0]が現在のバーの始値
        {
         jouken=2;
         return;
        }
     }
     if(jouken==1&&Volume[0]==2){
      res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"",MAGICMA,0,Red);//戻り値はチケット番号
      jouken=0;
      valb=Ask;
         return;
     }
     if(jouken==2&&Volume[0]==2){
      res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"",MAGICMA,0,Red);//戻り値はチケット番号
      jouken=0;
      vals=Bid;
         return;
     }
     
    
}
void CheckForClose(){
//---
   Print("買いの勝",buyw);
   Print("買いの負",buyl);
   Print("売りの勝",sellw);
   Print("売りの負",selll);
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
         if(Volume[0]==1)
           {
            if(valb<Close[0]){
               buyw++;
            }
            if(valb>=Close[0]){
               buyl++;
            }
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
         if(Volume[0]==1)
           {
            if(vals<Close[0]){
               selll++;
            }
            if(vals>=Close[0]){
               sellw++;
            }
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