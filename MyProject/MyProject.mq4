//+------------------------------------------------------------------+
//|                                                    MyProject.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property strict 
extern int MagicNumber = 10000;
extern int FastMA_Period = 20;
extern int SlowMA_Period = 100;
extern int MA_Mtd = 0;
//data is entered through TeleTrade or it will be 500 by default
input double takeprofit_pips = 500.0;
input double stoploss_pips = 500.0;
input double ordersize = 0.5;
extern int mins_per_trade = 60;
double current_FASTMA, current_SLOWMA, prev_FASTMA, prev_SLOWMA;
bool Free_to_trade = true;
int Total_min_Diff, Mins_Diff, Hours_Diff;
datetime Order_Date = D'2001.01.01';
//3task
extern double trade_size_percent = 10.0;
extern double loss_size_percent = 20.0;

//a function for calculating the percentage (did not make it selectable through the console and you need to un/comment it in order not to/change it)
/*void CalculateTradeSize()
{
   Print("Ou Account Balance is ", AccountBalance(), " and my current trade percentage is ", trade_size_percent);
   Print("Ou Account Balance is ", AccountBalance(), " and my current risk percentage is ", loss_size_percent);
   double trade_risked = trade_size_percent/100.0;
   double percent_risked = loss_size_percent/100.0;
   takeprofit_pips = AccountBalance() * trade_risked;
   stoploss_pips = AccountBalance() * percent_risked;
}
*/
//Custom functions
void PlaceBuyOrder()
{
double takeprofit = (Ask + takeprofit_pips*Point);
double stoploss = (Ask - takeprofit_pips*Point);

int ticket = OrderSend(Symbol(), OP_BUY, ordersize, Ask, 3, stoploss, takeprofit, "My order", MagicNumber, 0, clrGreen);
if(ticket < 0)
   {
   Print("OrderSend failed with error #", GetLastError());
   }
   else{
   Print("OrderSend plased sussessfully");
   Free_to_trade = False;
   Order_Date = TimeCurrent();
   }
}

void PlaceSellOrder()
{
double takeprofit = ( Bid - takeprofit_pips*Point);
double stoploss = (Bid + stoploss_pips*Point);
//3 task. Uncomment to apply
//CalculateTradeSize();
int ticket = OrderSend(Symbol(), OP_SELL, ordersize, Bid, 3, stoploss, takeprofit, "My order", MagicNumber, 0, clrRed);
if(ticket < 0)
   {
   Print("OrederSend failed with error #", GetLastError());
   }
   else
   {
   Print("OrderSend failed wit error #", GetLastError());
   Free_to_trade = false;
   Order_Date = TimeCurrent();
   }
}

void CheckBuyBreakEvenStop()
{
   for( int b = OrdersTotal()-1; b >= 0; b--)
   {
      if(OrderSelect(b,SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == OP_BUY)
         {
            if(OrderStopLoss() < OrderOpenPrice())
            {
               if(Ask > OrderOpenPrice()+30*_Point)
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(),(OrderOpenPrice() + 4*_Point), OrderTakeProfit(), 0, CLR_NONE);
               }
            }
         }
      }
   }
}   
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //function Trailing Stop
   if( OrdersTotal() < 1)
   {
      int buyticket_TS = OrderSend(Symbol(), OP_BUY, 0.10, Ask, 3,0,0, NULL, 0,0,Green);
   }
   for ( int b = OrdersTotal() -1; b >= 0; b--)
   {
      if(OrderSelect(b, SELECT_BY_POS, MODE_TRADES))
         {
         if(OrderSymbol() == Symbol())
            {
            if(OrderType() == OP_BUY)
            {
               if(OrderStopLoss() - Ask -(150*_Point))
                  OrderModify(OrderTicket(), OrderOpenPrice(), Ask - (150*_Point), OrderTakeProfit(), 0, CLR_NONE);
            }
            } 
         }
   }
   //end func Traling stop
   //star func Break-Even
   if(OrdersTotal() ==0)
   {
   int buyticket_BE = OrderSend(_Symbol, OP_BUY, 0.10, Ask, 3, Ask - 300*_Point, Ask+300*_Point, NULL, 0, 0, Green);
   }
   //end func Break-Even
   CheckBuyBreakEvenStop();
   current_FASTMA = iMA(NULL, 0, FastMA_Period, 0, MA_Mtd, PRICE_MEDIAN, 0);
   prev_FASTMA = iMA(NULL, 0, FastMA_Period, 0, MA_Mtd, PRICE_MEDIAN, 1);
   current_SLOWMA = iMA(NULL, 0, SlowMA_Period, 0, MA_Mtd, PRICE_MEDIAN, 0);
   prev_SLOWMA = iMA(NULL, 0, SlowMA_Period, 0, MA_Mtd, PRICE_MEDIAN, 1);
   
   Mins_Diff = (TimeMinute(TimeCurrent()) - TimeMinute(Order_Date));
   if(Mins_Diff < 0)
      Mins_Diff =(Mins_Diff + 60);
      
   Hours_Diff = (TimeHour(TimeCurrent()) - TimeHour(Order_Date));
   if(Hours_Diff < 0)
      Hours_Diff =( Hours_Diff + 24);
      
   Total_min_Diff =((Hours_Diff*60)+Mins_Diff);
   if (Total_min_Diff > mins_per_trade)
      Free_to_trade = True;
      
   
   if( (current_FASTMA > current_SLOWMA) && (Free_to_trade))
   {
      if (prev_FASTMA < prev_SLOWMA)
         {
            PlaceBuyOrder();
         }
   }
   if((current_FASTMA < current_SLOWMA) && (Free_to_trade))
   {
      if(prev_FASTMA > prev_SLOWMA)
      {
         PlaceSellOrder();
      }
   }
}
//+------------------------------------------------------------------+
