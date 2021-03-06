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
#define MAGICMA  20190423
int NumUseIndicator = 0;
double MaximumProfit = 0;//最大の利益
double EntryPrice = 0;//エントリーした価格
input   string              SeparateLot= "";                         // ▼ ロット設定
input double                Lots          =0.1;                         //┣ ロット数(1ロット十万通貨単位)
input int                   LossCut = 10 ;                              // ┗ ロスカット(pip)
input   string              SeparateRikaku= "";                         // ▼ 利確設定
input   int                 MinimumProfit = 5;                          // ┣ 最低獲得pip
input   int                 ProfitPercentage = 30;                      // ┗ 最高から落ちて利確するパーセンテージ
input   string              SeparateUseIndicator= "";                   // ▼ 使用インジケーター設定
input   string              SeparateRSI = "";                           //┣ RSI
input   bool                Use1 = true;                                //┃ ┣ON/OFF
input int                   RSIPeriod=14;                               //┃ ┣期間
input int                   UpLine = 70;                                //┃ ┣上の線
input int                   DownLine = 30  ;                            //┃ ┗下の線
input   string              SeparateBands = "";                         //┣ ボリンジャーバンド設定
input   bool                Use2 = true;                                //┃ ┣　ON/OFF
input   uint                BandsPeriod = 14;                           //┃ ┣ 期間
input   double              BandsDeviation = 2;                         //┃ ┗ 偏差
input   string              SeparateMacd = "";                           //┣ MACD設定
input   bool                Use9 = true;                                //┃┣　ON/OFF
input   uint                MacdTanki = 12;                             //┃ ┣　短期EMA
input   uint                MacdTyouki = 26;                            //┃ ┣ 長期EMA
input   uint                MacdSignal = 9;                             //┃ ┗ シグナル
input   string              SeparateCCI   = "";                         //┣ CCI設定
input   bool                Use3 = true;                                //┃┣ ON/OFF
input   uint                CCIPeriod = 14;                             //┃ ┣ 期間
input   int                CCIUPLine = 100;                            //┃ ┣ 上のライン（％）
input   int                CCIDOWNLine = -100;                            //┃ ┗ 下のライン（％）
input   string              SeparateEnvelop = "";                       //┣ エンベロープ設定
input   bool                Use4 = true;                                //┃┣　ON/OFF
input   uint                EnvPeriod = 14;                             //┃ ┣ 期間（移動平均線の）
input   double              EnvDeviation = 0.2;                         //┃ ┣ 偏差
input   ENUM_MA_METHOD      EnvMAMethod = MODE_SMA;                     //┃ ┗ 種別
input    string             SeparatePinber = "";                        //┣ ピンバー設定
input    bool               Use5 = true;                                //┃┣　ON/OFF
input    double             pinPosi = 0.7;                              //┃ ┣ 実体の中心の位置
input    double             pinPer = 30;                                //┃ ┣ 実体が足全体を占める割合(%)
input    double             pinLength = 1;                              //┃ ┣ ピンバーとする最少の長さ（単位はpips）
input    int                preBars = 2;                                //┃ ┗ ピンバーと判断するバーの数
input    string             SeparateSt = "";                            //┣ ストキャスティクス設定
input   bool                Use6 = true;                                //┃┣　ON/OFF
input   int                 StKPeriod=5;                                //┃ ┣ %K期間
input   int                 StDPeriod=3;                                //┃ ┣ %D期間
input   int                 StSlowing=3;                                //┃ ┣ スローイング
input   ENUM_MA_METHOD      StMAMethod = MODE_SMA;                      //┃ ┣ 移動平均の種別
input   int                 StUpLine = 70;                              //┃ ┣ 上の線(%)
input   int                 StDownLine = 30;                            //┃ ┗ 下の線(%)
input   string              SeparateDmi = "";                           //┣ DMI設定
input   bool                Use7 = true;                                //┃┣　ON/OFF
input   uint                DmiPeriod = 21;                             //┃ ┣ 期間（移動平均線の）
input   string              SeparateAdx = "";                           //┣ ADX設定
input   bool                Use8 = true;                                //┃┣　ON/OFF
input   uint                AdxPeriod = 21;                             //┃ ┣ 期間（移動平均線の）
input   int                 AdxLine = 45;                               //┃ ┗ ADXのライン

input   string              SeparateArrow = "";                         // ▼ 矢印設定
input   string              SeparateArrowColor = "";                    // ┣ 色
input   color               ArrowColorBuy = clrAqua;                    // ┃ ┣ 買
input   color               ArrowColorSell = clrMagenta;                // ┃ ┗ 売
input   int                 NumOfSignal = 6;                            // ┗ ○個以上シグナルが重なれば矢印を出す


input   string              Separateindi = "";                          // ▼ インジケーターの名前設定
input   int                 SizeOfText  =  10;                          // ┣ 文字の大きさ
input   color               TextColor = clrAqua;                        // ┃ 文字の色
input   double              LabelsVerticalShift=0.4;                    // ┣ 文字の垂直位置
input   int                 LabelsHorizontalShift = 10;                 // ┗ 文字の水平位置

input   string              SeparateLine = "";                          // ▼ ライン設定
input   string              SeparateLineColor = "";                     // ┣ 色
input   color               LineColorOn = clrRed;                       // ┃ ┣ 買いシグナル
input   color               LineColorOff = clrBlue;                     // ┃ ┃ 売りシグナル
input   color               ADXColor = clrOrange;                       // ┃ ┗ ADX
input   int                 ThickOfText  =  2;                          // ┗ ラインの太さ

input   string              SeparateAlert = "";                         // ▼ アラート設定
input   bool                UseAlert = true;                            // ┗ ON/OFF

input   string              SeparateSendMail = "";                      // ▼ メール設定
input   bool                UseSendMail = true;                         // ┗ ON/OFF

void OnTick()
{
//---
     NumUseIndicator = 0;
     if(Use1 == true)NumUseIndicator++;
     if(Use2 == true)NumUseIndicator++;
     if(Use3 == true)NumUseIndicator++;
     if(Use4 == true)NumUseIndicator++;
     if(Use5 == true)NumUseIndicator++;
     if(Use6 == true)NumUseIndicator++;
     if(Use7 == true)NumUseIndicator++;
     if(Use8 == true)NumUseIndicator++;
     if(Use9 == true)NumUseIndicator++;
     if(NumUseIndicator < NumOfSignal)Print("[○○個以上シグナルが重なれば矢印を出す]が適用するテクニカルの数よりも少ないです。");
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
   if(NumUseIndicator < NumOfSignal)return false;
   int cBuy = CheckBuy(0);
   //--- buy conditions
   if(cBuy < NumOfSignal)return false;
   return true; 
}
bool CheckForSellOpen()
{
   if(CalculateCurrentOrders(Symbol())!=0)return false;
   if(NumUseIndicator < NumOfSignal)return false;
   int cSell = CheckSell(0);  
   //--- buy conditions
   if(cSell < NumOfSignal)return false;
   return true;

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
int CheckBuy(int shift)
{    
     int count = 0;
     if(CheckRSIBuy(shift) && Use1)count++; 
     if(CheckBBBuy(shift)&& Use2)count++; 
     if(CheckMacdBuy(shift)&& Use9)count++; 
     if(CheckCCIBuy(shift)&& Use3)count++; 
     if(CheckEnvelopeBuy(shift)&& Use4)count++; 
     if(CheckPinbarBuy(shift)&& Use5)count++; 
     if(CheckStBuy(shift)&& Use6)count++; 
     if(CheckDmiBuy(shift)&& Use7)count++; 
     if(CheckAdx(shift)&& Use8)count++; 
     return count;   
}
 
int CheckSell(int shift)
{
     int count = 0;
     if(CheckRSISell(shift) && Use1)count++; 
     if(CheckBBSell(shift)&& Use2)count++; 
     if(CheckMacdSell(shift)&& Use9)count++; 
     if(CheckCCISell(shift)&& Use3)count++; 
     if(CheckEnvelopeSell(shift)&& Use4)count++; 
     if(CheckPinbarSell(shift)&& Use5)count++; 
     if(CheckStSell(shift)&& Use6)count++; 
     if(CheckDmiSell(shift)&& Use7)count++; 
     if(CheckAdx(shift)&& Use8)count++; 
     return count;    
}
bool CheckRSIBuy(int shift)
{     
     if(iRSI(Symbol(), 0, RSIPeriod, 0, shift) >= DownLine)return false;
     return true;   
}
 
bool CheckRSISell(int shift)
{
     if(iRSI(Symbol(), 0, RSIPeriod, 0, shift) <= UpLine)return false;
     return true;
}
bool CheckBBBuy(int shift)
{     
     double bands = iBands(Symbol(), Period(), BandsPeriod, BandsDeviation, NULL, PRICE_CLOSE, MODE_LOWER, shift);
     if (Close[shift] >= bands) return false;
     return true;   
}
 
bool CheckBBSell(int shift)
{
     double bands = iBands(Symbol(), Period(), BandsPeriod, BandsDeviation, NULL, PRICE_CLOSE, MODE_UPPER, shift);
     if (Close[shift] <= bands) return false;
     return true;
}
bool CheckMacdBuy(int shift)
{     
     
     if(shift + 1 >= Bars -1)return false;
     double PreMain = iMACD(NULL,0,MacdTanki,MacdTyouki,MacdSignal,PRICE_CLOSE,MODE_MAIN,shift - 1);
     double PreSignal = iMACD(NULL,0,MacdTanki,MacdTyouki,MacdSignal,PRICE_CLOSE,MODE_SIGNAL,shift - 1);
     double Main = iMACD(NULL,0,MacdTanki,MacdTyouki,MacdSignal,PRICE_CLOSE,MODE_MAIN,shift);
     double Signal = iMACD(NULL,0,MacdTanki,MacdTyouki,MacdSignal,PRICE_CLOSE,MODE_SIGNAL,shift);
     if(0 <= Main)return false;
     if( PreMain <= PreSignal )return false;
     if( Signal <= Main )return false;
     return true;   
}
 
bool CheckMacdSell(int shift)
{
     if(shift + 1 >= Bars -1)return false;
     double PreMain = iMACD(NULL,0,MacdTanki,MacdTyouki,MacdSignal,PRICE_CLOSE,MODE_MAIN,shift - 1);
     double PreSignal = iMACD(NULL,0,MacdTanki,MacdTyouki,MacdSignal,PRICE_CLOSE,MODE_SIGNAL,shift - 1);
     double Main = iMACD(NULL,0,MacdTanki,MacdTyouki,MacdSignal,PRICE_CLOSE,MODE_MAIN,shift);
     double Signal = iMACD(NULL,0,MacdTanki,MacdTyouki,MacdSignal,PRICE_CLOSE,MODE_SIGNAL,shift);
     if(Main <= 0)return false;
     if(PreSignal <= PreMain)return false;
     if(Main <= Signal)return false;
     
     return true;   
}
bool CheckCCIBuy(int shift)
{     
     double cci = iCCI(Symbol(), Period(), CCIPeriod, PRICE_CLOSE, shift);
     if (CCIDOWNLine <= cci) return false;
     return true;   
}
 
bool CheckCCISell(int shift)
{
     double cci = iCCI(Symbol(), Period(), CCIPeriod, PRICE_CLOSE, shift);
     if (cci <= CCIUPLine) return false;
     return true;
}
bool CheckEnvelopeBuy(int shift)
{     
     double envelope = iEnvelopes(NULL,0,EnvPeriod,EnvMAMethod,0,PRICE_CLOSE,EnvDeviation,MODE_LOWER,shift);
     if( envelope <= Close[shift])return false;
     return true; 
}
 
bool CheckEnvelopeSell(int shift)
{
     double envelope = iEnvelopes(NULL,0,EnvPeriod,EnvMAMethod,0,PRICE_CLOSE,EnvDeviation,MODE_UPPER,shift);
     if(Close[shift] <=  envelope )return false;
     return true;
}
bool CheckPinbarBuy(int icount )
{   
     if(icount + preBars >= Bars -1)return false;
     if(!(pinLength*Point*10<High[icount]-Low[icount]))return false;
     if(Close[icount]-Open[icount]>0){//買いサイン
                 if ( (MathAbs(Close[icount]-Open[icount])/(High[icount]-Low[icount])<(pinPer*0.01)||Close[icount]==Open[icount])&&
               ((MathAbs(Close[icount]-Open[icount])/2)+Open[icount]-Low[icount])/(High[icount]-Low[icount])>pinPosi ) {  
                     int i=0,hantei=0;
                     for(i=0;i<preBars;i++){
                        if(Low[icount]>Low[icount+i+1]){
                           return false;
                        }   
                     }  
                     return true;
                }
           return false;
      }
      return false;
}   
bool CheckPinbarSell(int icount)
{
     if(icount + preBars >= Bars -1)return false;
     if(!(pinLength*Point*10<High[icount]-Low[icount]))return false;
     if(Open[icount]-Close[icount]>0){
                 if ( (MathAbs(Close[icount]-Open[icount])/(High[icount]-Low[icount])<(pinPer*0.01)||Close[icount]==Open[icount])&&//売りサイン
            (((MathAbs(Close[icount]-Open[icount]))/2)+High[icount]-Open[icount])/(High[icount]-Low[icount])>pinPosi ) {  
             int i=0,hantei=0;
                     for(i=0;i<preBars;i++){
                        if(High[icount]<High[icount+i+1]){
                           return false;
                        }   
                     }
                      return true;
              }
              return false;
           }
        return false;
}       
bool CheckStBuy(int shift)
{     
     if(shift + 1 >= Bars -1)return false;
     double PreKLine = iStochastic(NULL,0,StKPeriod , StDPeriod,StSlowing,StMAMethod, 0, MODE_MAIN, shift - 1);
     double PreDLine = iStochastic(NULL,0, StKPeriod, StDPeriod, StSlowing, StMAMethod, 0, MODE_SIGNAL, shift - 1);
     double KLine = iStochastic(NULL, 0, StKPeriod, StDPeriod, StSlowing, StMAMethod, 0, MODE_MAIN, shift);
     double DLine = iStochastic(NULL, 0, StKPeriod, StDPeriod, StSlowing, StMAMethod, 0, MODE_SIGNAL, shift);
     if(StDownLine <= KLine)return false;
     if(StDownLine <= DLine)return false;
     if(PreKLine <= PreDLine)return false;
     if(DLine <= KLine)return false;
     return true; 
}
 
bool CheckStSell(int shift)
{
     if(shift + 1 >= Bars -1)return false;
     double PreKLine = iStochastic(NULL,0, StKPeriod ,StDPeriod,StSlowing,StMAMethod,0,MODE_MAIN,shift - 1);
     double PreDLine = iStochastic(NULL,0,StKPeriod,StDPeriod,StSlowing,StMAMethod,0,MODE_SIGNAL,shift - 1);
     double KLine = iStochastic(NULL,0,StKPeriod,StDPeriod,StSlowing,StMAMethod,0,MODE_MAIN,shift);
     double DLine = iStochastic(NULL,0,StKPeriod,StDPeriod,StSlowing,StMAMethod,0,MODE_SIGNAL,shift);
     if(KLine<=StUpLine)return false;
     if(DLine<=StUpLine)return false;
     if(PreDLine <= PreKLine)return false;
     if(KLine <= DLine )return false;
     return true; 
}
bool CheckDmiBuy(int shift)
{     
     if(shift + 1 >= Bars -1)return false;
     double Predmiminus = iADX(NULL,0,DmiPeriod,PRICE_CLOSE,MODE_PLUSDI,shift - 1);
     double Predmiplus = iADX(NULL,0,DmiPeriod,PRICE_CLOSE,MODE_MINUSDI,shift - 1);
     double dmiminus = iADX(NULL,0,DmiPeriod,PRICE_CLOSE,MODE_PLUSDI,shift );
     double dmiplus = iADX(NULL,0,DmiPeriod,PRICE_CLOSE,MODE_MINUSDI,shift );
     if( Predmiminus <= Predmiplus)return false;
     if( dmiplus <= dmiminus)return false;
     return true; 
}
 
bool CheckDmiSell(int shift)
{
     if(shift + 1 >= Bars -1)return false;
     double Predmiminus = iADX(NULL,0,DmiPeriod,PRICE_CLOSE,MODE_PLUSDI,shift - 1);
     double Predmiplus = iADX(NULL,0,DmiPeriod,PRICE_CLOSE,MODE_MINUSDI,shift - 1);
     double dmiminus = iADX(NULL,0,DmiPeriod,PRICE_CLOSE,MODE_PLUSDI,shift );
     double dmiplus = iADX(NULL,0,DmiPeriod,PRICE_CLOSE,MODE_MINUSDI,shift );
     if(  Predmiplus <= Predmiminus )return false;
     if( dmiminus <= dmiplus )return false;
     return true; 
}
bool CheckAdx(int shift)
{
     double adx = iADX(NULL,0,AdxPeriod,PRICE_CLOSE,MODE_MAIN,shift);
     if(AdxLine <= adx)return false;
     return true; 
}