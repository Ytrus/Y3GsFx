//+------------------------------------------------------------------+
//|                                           TradingSystems_TRB.mq4 |
//|                                               Y3 Trading Systems |
//|                                                     www.y3web.it |
//+------------------------------------------------------------------+
#property copyright "Y3 Trading Systems"
#property link      "www.y3web.it"
#property version   "1.00"
#property strict

input double POWER=0.1;
input string SIGNATURE="Y3-TRB";
input int targetDistance = 20;
input int StopLossDistance = 10;
input bool FiveDigitBroker = true;

string nomIndice= "EURUSD";
bool tradeBuy   = false;
bool entreeBuy  = false;
bool sortieBuy  = false;
bool tradeSell  = false;
bool entreeSell = false;
bool sortieSell = false;
int ticketBuy;
int ticketSell;

int tpd = 20;
int sld = 10;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if (FiveDigitBroker == true)
      {
      tpd = targetDistance*10;
      sld = StopLossDistance*10;
      }
   else
      {
      tpd = targetDistance;
      sld = StopLossDistance;
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
   int i;
   double bx, by, sx, sy, upperMA, lowerMA;

   entreeBuy  = false;
   sortieBuy  = false;
   entreeSell = false;
   sortieSell = false;
   
   upperMA = iMA(NULL,0,21,0,MODE_EMA,PRICE_HIGH,0);
   lowerMA = iMA(NULL,0,21,0,MODE_EMA,PRICE_LOW,0);

   // BUY ORDER OPEN CONTDITIONS =================================
   if ( MarketInfo(nomIndice,MODE_BID) > upperMA ) entreeBuy=true;

   // BUY ODRDER CLOSE CONDITIONS ================================
   if(OrderSelect(ticketBuy, SELECT_BY_TICKET)==true)
      { 
         bx = OrderOpenPrice();
         by = bx;
         bx = bx -sld*Point; //Stop Loss
         by = by +tpd*Point; //target
      
         if( MarketInfo(nomIndice,MODE_BID) < bx || MarketInfo(nomIndice,MODE_BID) > by ) 
         {
            sortieBuy=true;
            Print("OpenPrice:",OrderOpenPrice()," bx:",bx," by:",by," bid:",MarketInfo(nomIndice,MODE_BID));
         }
     }





   // SELL ORDER OPEN CONTDITIONS =================================
   if (MarketInfo(nomIndice,MODE_BID) < lowerMA ) entreeSell=true;


   // SELL ODRDER CLOSE CONDITIONS ================================
   if(OrderSelect(ticketSell, SELECT_BY_TICKET)==true)
      { 
         sx = OrderOpenPrice();
         sy = sx;
         sx = sx +sld*Point; //Stop Loss
         sy = sy -tpd*Point; //target

         if( MarketInfo(nomIndice,MODE_ASK) > sx || MarketInfo(nomIndice,MODE_ASK) < sy ) sortieSell=true;    
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


      ticketBuy=OrderSend(nomIndice,OP_BUY,POWER,MarketInfo(nomIndice,MODE_ASK),8,stoploss,takeprofit,"POWER",SIGNATURE,0,MediumBlue);

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

      ticketSell=OrderSend(nomIndice,OP_SELL,POWER,MarketInfo(nomIndice,MODE_BID),8,stoploss,takeprofit,"POWER",SIGNATURE,0,MediumBlue);

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
           "\n TICKET BUY  : ",ticketBuy,
           "\n TICKET SELL : ",ticketSell,
           "\n +--------------------------------------------------------+\n ");
   return(0);
  }
//+------------------------------------------------------------------+
