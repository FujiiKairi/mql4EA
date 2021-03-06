//+------------------------------------------------------------------+
//|                                                        GBP5M.mq4 |
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
#define MAGICMA  20181114
input double Lots          =0.1;//1ロット十万通貨単位
input int    LossCut=10 ;
input int    TakeProfit=20 ;
//losscut10で１pip
input double handan=5;
input double losshan=0.3;
//出た利益の@@割マイナスになったら確定
input double minTP=50;
double mintp=0;
double orderprice=0;
//50は5pips
/*
int OnInit(){
int i=1;

double mc,mp,sc,sp,mp2,sp2,x;

   
while(i<1000){
   
   mc=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
   mp=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
   mp2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i+2);
   sc=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);
   sp=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i+1);
   sp2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i+2);
   if((mp>sp&&mc<sc)||(mp<sp&&mc>sc)){
   Print(i);
      x=((MathAbs(mp2-sp2)+MathAbs(mc-sc))*100);
      x=x*x;

      Print(x);
   }
   i++;
}

return(INIT_SUCCEEDED);
}
*/
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
   double mc,mp,sc,sp,mp2,sp2,x;
   int    res;
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
   if(Volume[0]==1){
      mc=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
      mp=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
      mp2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,2);
      sc=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
      sp=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
      sp2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2);
   
      x=((MathAbs(mp2-sp2)+MathAbs(mc-sc))*100);
      x=x*x;
     
     
      
      
   //--- sell conditions
     
   
         if(mc>0&&sc>0&&mp>sp&&mc<sc&&x>handan)//売り
           {
            res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+LossCut*Point*10,Ask-TakeProfit*Point*10,"",MAGICMA,0,Red);//戻り値はチケット番号
            orderprice=Bid;
            return;
           }
      //--- buy conditions
         if(mc<0&&sc<0&&mp<sp&&mc>sc&&x>handan)//買い
           {
            res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-LossCut*Point*10,Bid+TakeProfit*Point*10,"",MAGICMA,0,Red);//戻り値はチケット番号
            orderprice=Ask;
            return;
         }
    }
    
}
void CheckForClose(){
  


//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      
     
      if(OrderType()==OP_BUY)
      {
      
          if(mintp==0&&(Ask-orderprice)>=minTP*Point){
            mintp=(Ask-orderprice)/Point;
           }
          
        if(mintp!=0&&mintp<((Ask-orderprice)/Point)){
           mintp=((Ask-orderprice)/Point);
        }
        if(mintp!=0&&((Ask-orderprice)/Point)<mintp*losshan){
            mintp=0;
            orderprice=0;
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
            
        }
        
         break;
      }
      if(OrderType()==OP_SELL)
        {
           if(mintp==0&&(orderprice-Bid)>=minTP*Point){
            mintp=(orderprice-Bid)/Point;
            
          }
        if(mintp!=0&&mintp<((orderprice-Bid)/Point)){
           mintp=((orderprice-Bid)/Point);
        }
        if(mintp!=0&&((orderprice-Bid)/Point)<mintp*losshan){
            mintp=0;
            orderprice=0;
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