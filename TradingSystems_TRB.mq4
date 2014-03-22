//+------------------------------------------------------------------+
//|                                           TradingSystems_TRB.mq4 |
//|                                               Y3 Trading Systems |
//|                                                     www.y3web.it |
//+------------------------------------------------------------------+
#property copyright "Y3 Trading Systems"
#property link      "www.y3web.it"
#property version   "1.00"
#property strict

input double POWER = 0.1;
input string SIGNATURE = "Y3-TRB";

string nomIndice = "EURUSD";
bool tradeBuy   = false;
bool entreeBuy  = false;
bool sortieBuy  = false;
bool tradeSell  = false;
bool entreeSell = false;
bool sortieSell = false;
int ticketBuy;
int ticketSell;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   double x;
  
   entreeBuy  = false;
   sortieBuy  = false;
   entreeSell = false;
   sortieSell = false;
   
   x = iClose(nomIndice, PERIOD_M5, 1);

   for (i = 1; i <= 10; i ++)
      {
      if(iClose(nomIndice, PERIOD_M5, i) > x) x = iClose(nomIndice, PERIOD_M5, i);
      }

   if(MarketInfo(nomIndice,MODE_BID) > x * 1.0010) entreeBuy = true;
   
   
   
   x = iClose(nomIndice, PERIOD_M5, 1);
   
   for (i = 1; i <= 10; i ++)
      {
      if(iClose(nomIndice, PERIOD_M5, i) < x) x = iClose(nomIndice, PERIOD_M5, i);
      }   
   
    if(MarketInfo(nomIndice,MODE_BID) < x ) sortieBuy = true;
    
    
    
   x = iClose(nomIndice, PERIOD_M5, 1);    
    
   for (i = 1; i <= 10; i ++)
      {
      if(iClose(nomIndice, PERIOD_M5, i) < x) x = iClose(nomIndice, PERIOD_M5, i);
      }
   
   if(MarketInfo(nomIndice,MODE_BID) < x * 0.9990) entreeSell = true;
   
   
   x = iClose(nomIndice, PERIOD_M5, 1);
   
   for (i = 1; i <= 10; i ++)
      {
      if(iClose(nomIndice, PERIOD_M5, i) > x) x = iClose(nomIndice, PERIOD_M5, i);
      }

   if(MarketInfo(nomIndice,MODE_BID) > x ) sortieSell = true;
   
  return(0);
}


int ouvertureBuy()
{
 
double stoploss, takeprofit;
 
if(tradeBuy == false && entreeBuy == true)
   {
      stoploss   = MarketInfo(nomIndice,MODE_ASK) - (MarketInfo(nomIndice,MODE_ASK) * 0.03);
      takeprofit = MarketInfo(nomIndice,MODE_ASK) + (MarketInfo(nomIndice,MODE_ASK) * 0.03);
      stoploss   = NormalizeDouble(stoploss,MarketInfo(nomIndice,MODE_DIGITS));
      takeprofit = NormalizeDouble(takeprofit,MarketInfo(nomIndice,MODE_DIGITS));
 
 
ticketBuy = OrderSend(nomIndice,OP_BUY,POWER,MarketInfo(nomIndice,MODE_ASK),8,stoploss,takeprofit,"POWER" ,SIGNATURE,0,MediumBlue);
     
      if(ticketBuy > 0)tradeBuy = true;
 
   }
   return(0);
}


int fermetureBuy()
{
   bool t;
   if(tradeBuy == true && sortieBuy == true)
   {
   t = OrderClose(ticketBuy,POWER,MarketInfo(nomIndice,MODE_BID),5,Brown);
  
   if (t == true) { tradeBuy = false; ticketBuy = 0; }
   }
   return(0);
}


int ouvertureSell()
{
   double stoploss, takeprofit;
  
   if(tradeSell == false && entreeSell == true)
   {
      stoploss   = MarketInfo(nomIndice,MODE_ASK) + (MarketInfo(nomIndice,MODE_ASK) * 0.03);
      takeprofit = MarketInfo(nomIndice,MODE_ASK) - (MarketInfo(nomIndice,MODE_ASK) * 0.03);
      stoploss   = NormalizeDouble(stoploss,MarketInfo(nomIndice,MODE_DIGITS));
      takeprofit = NormalizeDouble(takeprofit,MarketInfo(nomIndice,MODE_DIGITS));
     
      ticketSell = OrderSend(nomIndice,OP_SELL,POWER,MarketInfo(nomIndice,MODE_BID),8,stoploss,takeprofit,"POWER" ,SIGNATURE,0,MediumBlue);
     
      if(ticketSell > 0)tradeSell = true;
   }
   return(0);
}


int fermetureSell()
{
   bool t;
   if(tradeSell == true && sortieSell == true)
   {
   t = OrderClose(ticketSell,POWER,MarketInfo(nomIndice,MODE_ASK),5,Brown);
  
   if (t == true){ tradeSell = false; ticketSell = 0; }
   }
   return(0);
}

int commentaire()
   {
   string dj;
 
   dj = Day()+ " / " + Month() + "   " + Hour() + " : " + Minute()+ " : " + Seconds();
 
    Comment( "\n +--------------------------------------------------------+\n EXPERT : ",nomIndice,
            "\n DATE : ", dj,
          
            "\n +--------------------------------------------------------+\n   ",
            "\n TICKET BUY  : ",ticketBuy,
            "\n TICKET SELL : ",ticketSell,
            "\n +--------------------------------------------------------+\n ");
   return(0);
   }




