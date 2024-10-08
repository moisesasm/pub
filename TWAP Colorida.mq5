//+------------------------------------------------------------------+
//|                                                         TWAP.mq5 |
//|                             Copyright 2000-2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2000-2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  Green,Red,Silver,Aqua
#property indicator_width1  3
#property indicator_label1  "TWAP Colorida"
//--- indicator buffers
input int diasparatras = 0;
input int intervaloremseg = 22; //Intervalo de atualização em MiliSegundos
int counter=0;
double calc=0;
datetime lastbar_time=0;
double ExtOBuffer[];
double ExtColorBuffer[];
datetime candletime,candletimeold;
input double inpdeslocamentocriteria = 0; //Criterio em cents para corolação
//bool firstcalc = true;
int barnum=1;
double lastexecsimb = 0;
input bool ancorada=false;
enum times  // enumeration of named constants
  {
   M4,
   M5,
   M6,
   M10,
   M12,
   M15,
   M20,
   M30,
   H1,
   H2,
   H4,
   H3,
   H6,
   H8,
   H12
  };

input times stimes=M4;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtOBuffer,INDICATOR_DATA);

   SetIndexBuffer(1,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   IndicatorSetString(INDICATOR_SHORTNAME,"TWAP Colorida");
//--- don't show indicator data in DataWindow
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- sets first candle from what index will be drawn
// PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,DATA_LIMIT);
//--- get handles

  }
//+------------------------------------------------------------------+
//| Trade zone by Bill Williams                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   EventSetTimer(intervaloremseg);

   if((int(GlobalVariableGet("LASTEXEC"+_Symbol)) != int(lastexecsimb)) || (lastbar_time != SeriesInfoInteger(_Symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE)))
     {
      //  Print(1);
      if(int(GlobalVariableGet("LASTEXEC"+_Symbol)) != int(lastexecsimb))
        {
         lastexecsimb = GlobalVariableGet("LASTEXEC"+_Symbol);
        }
      lastbar_time=SeriesInfoInteger(_Symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE);


      for(int i=0; i<rates_total; i++)
        {

         if(time[i] > SeriesInfoInteger(_Symbol,PERIOD_D1,SERIES_LASTBAR_DATE))
           {



            counter=counter+1;


            calc=calc+((close[i]+open[i]+low[i]+high[i])/4);


            ExtOBuffer[i]=NormalizeDouble(calc/counter,_Digits);


            if(i>=1)
              {
               if(ExtOBuffer[i] > (ExtOBuffer[i-1]+inpdeslocamentocriteria))
                 {
                  ExtColorBuffer[i]=0.0;


                 }
               else
                  if(ExtOBuffer[i] < (ExtOBuffer[i-1]-inpdeslocamentocriteria))
                    {
                     ExtColorBuffer[i]=1.0;
                    }
                  else
                    {
                     ExtColorBuffer[i]=2.0;

                    }
              }


            if(ancorada==true)
              {

               if(stimes == M4)
                 {
                  barnum=Bars(_Symbol,PERIOD_M4,time[i],time[i]);
                 }
               else
                  if(stimes == M5)
                    {
                     barnum=Bars(_Symbol,PERIOD_M5,time[i],time[i]);
                    }
                  else
                     if(stimes == M6)
                       {
                        barnum=Bars(_Symbol,PERIOD_M6,time[i],time[i]);
                       }
                     else
                        if(stimes == M10)
                          {
                           barnum=Bars(_Symbol,PERIOD_M10,time[i],time[i]);
                          }
                        else
                           if(stimes == M12)
                             {
                              barnum=Bars(_Symbol,PERIOD_M12,time[i],time[i]);
                             }
                           else
                              if(stimes == M15)
                                {
                                 barnum=Bars(_Symbol,PERIOD_M15,time[i],time[i]);
                                }
                              else
                                 if(stimes == M20)
                                   {
                                    barnum=Bars(_Symbol,PERIOD_M20,time[i],time[i]);
                                   }
                                 else
                                    if(stimes == M30)
                                      {
                                       barnum=Bars(_Symbol,PERIOD_M30,time[i],time[i]);
                                      }
                                    else
                                       if(stimes == H1)
                                         {
                                          barnum=Bars(_Symbol,PERIOD_H1,time[i],time[i]);
                                         }
                                       else
                                          if(stimes == H2)
                                            {
                                             barnum=Bars(_Symbol,PERIOD_H2,time[i],time[i]);
                                            }
                                          else
                                             if(stimes == H3)
                                               {
                                                barnum=Bars(_Symbol,PERIOD_H3,time[i],time[i]);
                                               }
                                             else
                                                if(stimes == H4)
                                                  {
                                                   barnum=Bars(_Symbol,PERIOD_H4,time[i],time[i]);
                                                  }
                                                else
                                                   if(stimes == H6)
                                                     {
                                                      barnum=Bars(_Symbol,PERIOD_H6,time[i],time[i]);
                                                     }
                                                   else
                                                      if(stimes == H8)
                                                        {
                                                         barnum=Bars(_Symbol,PERIOD_H8,time[i],time[i]);
                                                        }
                                                      else
                                                         if(stimes == H12)
                                                           {
                                                            barnum=Bars(_Symbol,PERIOD_H12,time[i],time[i]);
                                                           }





               if(barnum == 1 && candletime!= time[i])
                 {






                  calc=0;
                  counter=0;
                  ExtColorBuffer[i]=3.0;







                  candletime=time[i];


                 }




              }
            else
               if(Bars(_Symbol,PERIOD_CURRENT,StringToTime(TimeToString(time[i], TIME_DATE)),time[i]) ==1)
                 {


                  calc=0;
                  counter=0;
                  ExtOBuffer[i]=EMPTY_VALUE;


                 }
               else
                 {



                 }
           }
        }
     }


   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   GlobalVariableSet("LASTEXEC"+_Symbol,GlobalVariableGet("LASTEXEC"+_Symbol)+1);


  }
//+------------------------------------------------------------------+
