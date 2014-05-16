//+------------------------------------------------------------------+
//|                                           TradingSystems_TRB.mq4 |
//|                                               Y3 Trading Systems |
//|                                                     www.y3web.it |
//+------------------------------------------------------------------+
// EURUSD M5
#property copyright "Y3 Trading Systems"
#property link      "www.y3web.it"
#property version   "1.00"
#property strict

input double POWER=0.1;
input int SIGNATURE=3133;
input string COMMENT="Y3-SimpleEMA";
input int ShortEMAPeriod = 2;
input int LongEMAPeriod = 50;
input bool FiveDigitBroker = true;
input int lowRSILimit = 40;
input int highRSILimit = 60;

string nomIndice= "EURUSD";
bool tradeBuy   = false;
bool entreeBuy  = false;
bool sortieBuy  = false;
bool tradeSell  = false;
bool entreeSell = false;
bool sortieSell = false;
int ticketBuy;
int ticketSell;
int spread;

double entryDS = 1;
double exitDS = 1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   nomIndice = Symbol();
   
   if (FiveDigitBroker == true)
      {
         //entryDS = minEntryDistance * 10 * Point;
         //exitDS = minExitDistance * 10 * Point;
         //Print("dfMA = ",entryDS, "minEntryDistance = ",minEntryDistance);
      }
   else
      {
         //entryDS = minEntryDistance * Point;
         //exitDS = minExitDistance * Point;
      }
   return(0); //return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                           |
//+------------------------------------------------------------------+
void OnTick()
  { 
   paramD1();
   ouvertureBuy();
   fermetureBuy();
   ouvertureSell();
   fermetureSell();
   commentaire();
   
  }
//+------------------------------------------------------------------+

int paramD1()
  {

   double longEMA, shortEMAt, shortEMAy, rsi;

   entreeBuy  = false;
   sortieBuy  = false;
   entreeSell = false;
   sortieSell = false;
   
   longEMA = iMA(NULL,0,LongEMAPeriod,0,MODE_SMMA,PRICE_TYPICAL,0);
   rsi = iRSI(NULL,0,14,PRICE_CLOSE,0);
   spread = SymbolInfoInteger(nomIndice,SYMBOL_SPREAD);

   // BUY ORDER OPEN CONTDITIONS =================================
   if ( Close[1]>Open[1] && Volume[0]<10) {entreeBuy=true; }

   // BUY ODRDER CLOSE CONDITIONS ================================
   if(OrderSelect(ticketBuy, SELECT_BY_TICKET)==true)
     { 

         if (iBarShift(NULL,0,OrderOpenTime(),false) == 1 ) sortieBuy=true; //appena cambia la barra, chiudo l'ordine vecchio
         if ( High[0] - OrderOpenPrice() > 300*Point && MarketInfo(nomIndice,MODE_ASK) == OrderOpenPrice() ) sortieBuy=true; // se ho visto 30 pips e torno a zero, chiudo
         if ( OrderOpenPrice() - Low[0] > 700*Point ) sortieBuy=true; // se perdo più di 60 pip chiudo
     }





   // SELL ORDER OPEN CONTDITIONS =================================
   if ( Close[1]<Open[1] && Volume[0]<10) {entreeSell=true; }


   // SELL ODRDER CLOSE CONDITIONS ================================
   if(OrderSelect(ticketSell, SELECT_BY_TICKET)==true)
      { 

         if (iBarShift(NULL,0,OrderOpenTime(),false) == 1 ) sortieSell=true; //appena cambia la barra, chiudo l'ordine vecchio
         if ( OrderOpenPrice() - Low[0] > 300*Point && MarketInfo(nomIndice,MODE_ASK) == OrderOpenPrice() ) sortieSell=true; // se ho visto 30 pips e torno a zero, chiudo
         if ( High[0] - OrderOpenPrice() > 700*Point ) sortieSell=true; // se perdo più di 60 pip chiudo
      }


   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ouvertureBuy()
  {

   double stoploss,takeprofit;

   if(tradeBuy==false && entreeBuy==true)
     {
      stoploss   = MarketInfo(nomIndice,MODE_ASK) - (MarketInfo(nomIndice,MODE_ASK) * 0.03);
      takeprofit = MarketInfo(nomIndice,MODE_ASK) + (MarketInfo(nomIndice,MODE_ASK) * 0.03);
      stoploss   = NormalizeDouble(stoploss,MarketInfo(nomIndice,MODE_DIGITS));
      takeprofit = NormalizeDouble(takeprofit,MarketInfo(nomIndice,MODE_DIGITS));


      ticketBuy=OrderSend(nomIndice,OP_BUY,POWER,MarketInfo(nomIndice,MODE_ASK),8,stoploss,takeprofit,COMMENT,SIGNATURE,0,MediumBlue);

      if(ticketBuy>0)tradeBuy=true;

     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fermetureBuy()
  {
   bool t;
   if(tradeBuy==true && sortieBuy==true)
     {
      t=OrderClose(ticketBuy,POWER,MarketInfo(nomIndice,MODE_BID),5,Brown);

      if(t==true) { tradeBuy=false; ticketBuy=0; }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ouvertureSell()
  {
   double stoploss,takeprofit;

   if(tradeSell==false && entreeSell==true)
     {
      stoploss   = MarketInfo(nomIndice,MODE_ASK) + (MarketInfo(nomIndice,MODE_ASK) * 0.03);
      takeprofit = MarketInfo(nomIndice,MODE_ASK) - (MarketInfo(nomIndice,MODE_ASK) * 0.03);
      stoploss   = NormalizeDouble(stoploss,MarketInfo(nomIndice,MODE_DIGITS));
      takeprofit = NormalizeDouble(takeprofit,MarketInfo(nomIndice,MODE_DIGITS));

      ticketSell=OrderSend(nomIndice,OP_SELL,POWER,MarketInfo(nomIndice,MODE_BID),8,stoploss,takeprofit,COMMENT,SIGNATURE,0,MediumBlue);

      if(ticketSell>0)tradeSell=true;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fermetureSell()
  {
   bool t;
   if(tradeSell==true && sortieSell==true)
     {
      t=OrderClose(ticketSell,POWER,MarketInfo(nomIndice,MODE_ASK),5,Brown);

      if(t==true){ tradeSell=false; ticketSell=0; }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int commentaire()
  {
   string dj;

   dj=Day()+" / "+Month()+"   "+Hour()+" : "+Minute()+" : "+Seconds();

   Comment("\n +--------------------------------------------------------+\n EXPERT : ",nomIndice,
           "\n DATE : ",dj,
         
           "\n +--------------------------------------------------------+\n   ",
           "\n SPREAD      : ",spread,
           "\n TICKET BUY  : ",ticketBuy,
           "\n TICKET SELL : ",ticketSell,
           "\n +--------------------------------------------------------+\n ");
   return(0);
  }
//+------------------------------------------------------------------+
