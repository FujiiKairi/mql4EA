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
input int MAGICMA=  20181227;
input double Lots          =0.1;//1ロット十万通貨単位
input int    LossCut=500 ;
input int losshan=300;
double min;
double max;
double orderprice;
int countu[3][3][3][3]={0};//アップのカウント,中身の０はプラス１は中立２はマイナス
int countd[3][3][3][3]={0};//ダウンのカウント
int countso[3][3][3][3]={0};//アップもダウンもしなかった

int countema[4][3]={0};
int a=0,aa=0;







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
void CountVal()
{
    double han1,han2,han3,han4,val;   
    int youso1,youso2,youso3,youso4;
    
   
    han1=iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,5)+iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,6)+iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,7)
               +iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,8) +iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,9)-
               (5*iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,10));
    han2=iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,5)+iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,6)+iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,7)
               +iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,8)+iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,9)-
               (5*iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,10));
    han3=iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,5)+iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,6)+iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,7)
               +iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,8)+iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,9)-
               (5*iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,10));
    han4=iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,5)+iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,6)+iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,7)
               +iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,8)+iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,9)-
               (5*iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,10));
    
    if(han1>45*Point){
      youso1=0;
    }
    else if(han1<-45*Point){
      youso1=2;
    }
    else{
      youso1=1;
    }
    
    if(han2>25*Point){
      youso2=0;
    }
    else if(han2<-25*Point){
      youso2=2;
    }
    else{
      youso2=1;
    }
    
    if(han3>15*Point){
      youso3=0;
    }
    else if(han3<-15*Point){
      youso3=2;
    }
    else{
      youso3=1;
    }
    
    if(han4>10*Point){
      youso4=0;
    }
    else if(han4<-10*Point){
      youso4=2;
    }
    else{
      youso4=1;
    }
               
    
    val=Close[0]+Close[1]+Close[2]+Close[3]+Close[4]-(5*Close[5]);
    if(val>0){
      countu[youso1][youso2][youso3][youso4]++;
    }
    else if((val*(-1))>0){
      countd[youso1][youso2][youso3][youso4]++;
    }
    else{
      countso[youso1][youso2][youso3][youso4]++;
    }
    aa++;
    if(aa>459026){
       Print("↑上がったカウント中立カウント下がったカウント");
       for(int v=0;v<3;v++){
         for(int b=0;b<3;b++){
            for(int n=0;n<3;n++){
               for(int m=0;m<3;m++){
               Print(m,n,b,v," ",countu[m][n][b][v]," ",countso[m][n][b][v]," ",countd[m][n][b][v]);
               }
            }
         }
       
       }
       
    }
    
}
void CountEma(){
    double han1,han2,han3,han4;   
   
    
   
    han1=iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,5)+iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,6)+iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,7)
               +iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,8) +iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,9)-
               (5*iMA(NULL,0,4,0,MODE_EMA,PRICE_CLOSE,10));
    han2=iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,5)+iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,6)+iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,7)
               +iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,8)+iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,9)-
               (5*iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,10));
    han3=iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,5)+iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,6)+iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,7)
               +iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,8)+iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,9)-
               (5*iMA(NULL,0,60,0,MODE_EMA,PRICE_CLOSE,10));
    han4=iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,5)+iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,6)+iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,7)
               +iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,8)+iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,9)-
               (5*iMA(NULL,0,240,0,MODE_EMA,PRICE_CLOSE,10));
    
    if(han1>45*Point){
      countema[0][0]++;
    }
    else if(han1<-45*Point){
      countema[0][2]++;
    }
    else{
      countema[0][1]++;
    }
    
    if(han2>25*Point){
      countema[1][0]++;
    }
    else if(han2<-25*Point){
      countema[1][2]++;
    }
    else{
      countema[1][1]++;
    }
    
    if(han3>15*Point){
      countema[2][0]++;
    }
    else if(han3<-15*Point){
      countema[2][2]++;
    }
    else{
      countema[2][1]++;
    }
    
    if(han4>10*Point){
      countema[3][0]++;
    }
    else if(han4<-10*Point){
      countema[3][2]++;
    }
    else{
      countema[3][1]++;
    }
    a++;           
    if(a>59026){ 
       for(int n=0;n<4;n++){
         for(int m=0;m<3;m++){
            Print(countema[n][m]);
         }
       }
       Print("間");
    }
}
void CheckForOpen()
{
   //int    res,handan=0;

   
    
//--- go trading only for first tiks of new bar
   
//--- get Moving Average 
   

   
     if(Volume[0]==1){ //新しい足ができたとき  買い 
        //CountEma();
        CountVal();     
         
               
               /*if(iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,1)-iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0)<0){
                  res=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
                  max=Ask;
                  orderprice=Ask;
               }
               
               
               if(iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,1)-iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,0)>0){
                  res=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+LossCut*Point,0,"",MAGICMA,0,Red);//戻り値はチケット番号
                  max=Bid;
                  orderprice=Bid;
               }
               */
      
     
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