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
input int MAGICMA=  20181211;
input double Lots          =0.1;//1ロット十万通貨単位
input int    LossCut=500 ;
input int num=15;
input int  jo=-1;
input int losshan=500;
double min;
double max;
double orderprice;
//losscut10で１pip






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
   int    res,handan=0;
   double ema1,ema2,ema3;
    ema1=iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0);
    ema2=iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,0);
    ema3=iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,0);
    
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
   
//--- sell conditions
      
      if(ema3>ema2&&ema2>ema1&&iRSI(Symbol(),0,14,0,0)>50)//売りの時
        {
              for(int i=0;i<num;i++){//売り
               if(iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i)>iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i)
               ||iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i)>iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,i)){
                  handan=1;
               }
            }
      if(handan==0&&MathAbs(Close[0]-Close[num])>jo*Point&&iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,num)-iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0)>0){
            res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
            max=Bid;
            orderprice=Bid;
            return;
          }
        }
   //--- buy conditions
      if(ema3<ema2&&ema2<ema1&&iRSI(Symbol(),0,14,0,0)<50)
        {
        for(int i=0;i<num;i++){//買い
               if(iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i)<iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i)
               ||iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i)<iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,i)){
                  handan=1;
               }
            }
         if(handan==0&&MathAbs(Close[0]-Close[num])>jo*Point&&iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,num)-iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0)<0){
               res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
               min=Ask;
               orderprice=Ask;
               return;
           }
      }
    
}
void CheckForClose(){
  
//--- go trading only for first tiks of new bar
   //if(Volume[0]>1) return;
//--- get Moving Average 
  
//---
   double ema1,ema2,ema3,ema11,ema21,ema31;
    ema1=iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0);
    ema2=iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,0);
    ema3=iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,0);
    ema11=iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,1);
    ema21=iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,1);
    ema31=iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,1);
    
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
      //--- check order type 
      if(OrderType()==OP_BUY)
        {
        if(max<Bid){
           max=Bid;
        }
         if(((ema3>ema2||ema2>ema1)&&(ema31>ema21||ema21>ema11))  ||(((max-orderprice)*0.5<(max-Bid))&&((Bid-orderprice)>(losshan*Point))
         &&orderprice<Bid&&Bid<max))
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,White))
               Print("OrderClose error ",GetLastError());
           }
         break;
        }
      if(OrderType()==OP_SELL)
        {
        if(min>Ask){
            min=Ask;
        }
        
         if(((ema3<ema2||ema2<ema1)&&(ema31<ema21||ema21<ema11))  ||(((orderprice-min)*0.5<(Ask-min))&&((orderprice-Ask)>(losshan*Point))
         &&min<Ask&&Ask<orderprice))
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