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
input int MAGICMA=  20181220;
input double Lots          =0.1;//1ロット十万通貨単位
input int    LossCut=500 ;
input int losshan=300;
double min;
double max;
double orderprice;

int jotaiB=0,jotaiS=0;//0→トレンドと反対→1→トレンド方向→2→トレンドと反対→3→トレンド方向→4でエントリー
int num1=0;//wの1画目
int num2=0;//wの2画目
int num3=0;//wの3画目
int kai=0;
int uri=0;
double takai=0;
double hikui=0;




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
   
   double ema1,ema2,ema3,haopen1,haclose1,haopen2,haclose2;
    ema1=iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0);
    ema2=iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,0);
    ema3=iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,0);
    haopen1 = iCustom(NULL,0,"Heiken Ashi",2,1);//１つ前の足の平均足始値
    haclose1 = iCustom(NULL,0,"Heiken Ashi",3,1);//１つ前の足の平均足終値
    haopen2 = iCustom(NULL,0,"Heiken Ashi",2,2);//2つ前の足の平均足始値
    haclose2 = iCustom(NULL,0,"Heiken Ashi",3,2);//2つ前の足の平均足終値値
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
   

         if(kai==1){
            if(Ask>takai+50*Point){
               res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
               max=Ask;
               orderprice=Ask;
               kai=0;
            }
            if(iCustom(NULL,0,"Heiken Ashi",3,1)- iCustom(NULL,0,"Heiken Ashi",2,1)<0){
               kai=0;
            }
         }
         if(uri==1){
             if(Bid<hikui-50*Point){
                res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
                max=Bid;
                orderprice=Bid;
                uri=0;
             }
             if(iCustom(NULL,0,"Heiken Ashi",3,1)- iCustom(NULL,0,"Heiken Ashi",2,1)>0){
               uri=0;
             }
         }
         if(Volume[0]==1&&kai==0&&uri==0){ //新しい足ができたとき   
         //--- buy conditions
         
         
         if(ema3<ema2&&ema2<ema1 && iCustom(NULL,0,"Heiken Ashi",3,1)- iCustom(NULL,0,"Heiken Ashi",2,1)>0
         &&iCustom(NULL,0,"Heiken Ashi",2,2)-iCustom(NULL,0,"Heiken Ashi",3,2)>0
         &&iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,1)-iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0)<0){//買い
            while(iCustom(NULL,0,"Heiken Ashi",2,num3+2)-iCustom(NULL,0,"Heiken Ashi",3,num3+2)>0){
               num3++;
            }
            while(iCustom(NULL,0,"Heiken Ashi",2,num3+2+num2)-iCustom(NULL,0,"Heiken Ashi",3,num3+2+num2)<0){
               num2++;
            }
            while(iCustom(NULL,0,"Heiken Ashi",2,num3+2+num2+num1)-iCustom(NULL,0,"Heiken Ashi",3,num3+2+num2+num1)>0){
               num1++;
            }
            for(int i=0;i<num3+num2+num1+2;i++){
               if(iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,i)>iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i)||
               iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i)>iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i)){
                  handan=1;
                  break;
               }
            }
            if(handan==0&&num1+num2+num3>5){
               double sum1=0;//wの1画目
               double sum2=0;//wの2画目
               double sum3=0;//wの3画目
               for(int i=0;i<num1;i++){
                  sum1=sum1+MathAbs(iCustom(NULL,0,"Heiken Ashi",2,i+2+num3+num2)-iCustom(NULL,0,"Heiken Ashi",3,i+2+num3+num2));
               }
               for(int i=0;i<num2;i++){
                  sum2=sum2+MathAbs(iCustom(NULL,0,"Heiken Ashi",2,i+2+num3)-iCustom(NULL,0,"Heiken Ashi",3,i+2+num3));
               }
               for(int i=0;i<num3;i++){
                  sum3=sum3+MathAbs(iCustom(NULL,0,"Heiken Ashi",2,i+2)-iCustom(NULL,0,"Heiken Ashi",3,i+2));
               }
               
               if(sum1*1<sum2&&sum2>sum3*1){
                  
                  takai=Close[num3+2];
                  for(int i=num3+2;i<num2+num3+2;i++){
                     if(takai<Close[i]){
                        takai=Close[i];
                     }
                  }
                  kai=1;
               }  
            }
         num1=0;
         num2=0;
         num3=0;
         handan=0; 
         
         }
         if(ema3>ema2&&ema2>ema1 && iCustom(NULL,0,"Heiken Ashi",3,1)- iCustom(NULL,0,"Heiken Ashi",2,1)<0
         &&iCustom(NULL,0,"Heiken Ashi",2,2)-iCustom(NULL,0,"Heiken Ashi",3,2)<0
         &&iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,1)-iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0)>0){//売り
            while(iCustom(NULL,0,"Heiken Ashi",2,num3+2)-iCustom(NULL,0,"Heiken Ashi",3,num3+2)<0){
               num3++;
            }
            while(iCustom(NULL,0,"Heiken Ashi",2,num3+2+num2)-iCustom(NULL,0,"Heiken Ashi",3,num3+2+num2)>0){
               num2++;
            }
            while(iCustom(NULL,0,"Heiken Ashi",2,num3+2+num2+num1)-iCustom(NULL,0,"Heiken Ashi",3,num3+2+num2+num1)<0){
               num1++;
            }
            for(int i=0;i<num3+num2+num1+2;i++){
               if(iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,i)<iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i)||
               iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,i)<iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i)){
                  handan=1;
                  break;
               }
            }
            if(handan==0&&num1+num2+num3>5){
               double sum1=0;//wの1画目
               double sum2=0;//wの2画目
               double sum3=0;//wの3画目
               for(int i=0;i<num1;i++){
                  sum1=sum1+MathAbs(iCustom(NULL,0,"Heiken Ashi",2,i+2+num3+num2)-iCustom(NULL,0,"Heiken Ashi",3,i+2+num3+num2));
               }
               for(int i=0;i<num2;i++){
                  sum2=sum2+MathAbs(iCustom(NULL,0,"Heiken Ashi",2,i+2+num3)-iCustom(NULL,0,"Heiken Ashi",3,i+2+num3));
               }
               for(int i=0;i<num3;i++){
                  sum3=sum3+MathAbs(iCustom(NULL,0,"Heiken Ashi",2,i+2)-iCustom(NULL,0,"Heiken Ashi",3,i+2));
               }
               
               if(sum1*1<sum2&&sum2>sum3*1){
                  
                  hikui=Close[num3+2];
                  for(int i=num3+2;i<num2+num3+2;i++){
                     if(hikui>Close[i]){
                        hikui=Close[i];
                     }
                  }
                  uri=1;
               }  
            }
         num1=0;
         num2=0;
         num3=0;
         handan=0; 
         
         }
         
         
      
     
     }
            
         
       
}
void CheckForClose(){
  double ema1,ema2,ema3;
    ema1=iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0);
    ema2=iMA(NULL,0,30,0,MODE_EMA,PRICE_CLOSE,0);
    ema3=iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,0);

    
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
         if(((((max-orderprice)*0.3<(max-Bid))&&((Bid-orderprice)>(losshan*Point))&&orderprice<Bid&&Bid<max))||(ema3>ema2||ema2>ema1))
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
        
         if(((((orderprice-min)*0.3<(Ask-min))&&((orderprice-Ask)>(losshan*Point))&&min<Ask&&Ask<orderprice))||(ema3<ema2||ema2<ema1))
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