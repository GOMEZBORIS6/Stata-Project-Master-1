***************************************************
*	Projet STATA réaliser par : 				  *	
*	-GOMEZ Jean-Baptiste Boris					  *	
*	-KOFFI Kablan Kan Max						  *	
*	-ZINSOU-DAHO Berich							  *	
*	Enseignant logiciel : LEFEBVRE Mathieu		  *	
***************************************************
import excel "C:\Users\gomez\OneDrive\Documents\STATA Project Master1\Project stata\Basesfinale.xlsx", sheet("Sheet1") firstrow clear 

br /*br  for browse */
describe
/*
Contains data
 Observations:           647                  
    Variables:             5                  
----------------------------------------------------------------------------------------------------------------------------------------------------
Variable      Storage   Display    Value
    name         type    format    label      Variable label
----------------------------------------------------------------------------------------------------------------------------------------------------
metroreg        str7    %9s                   metroreg
ID_Country      byte    %10.0g                ID_Country
Year            int     %10.0g                Year
PIB_HT          double  %10.0g                PIB_HT
POP_ACT         double  %10.0g                POP_ACT
----------------------------------------------------------------------------------------------------------------------------------------------------

 5 variables et 647 observations.*/
*combien d'année?
codebook Year
/*

----------------------------------------------------------------------------------------------------------------------------------------------------
Year                                                                                                                                            Year
----------------------------------------------------------------------------------------------------------------------------------------------------

                  Type: Numeric (int)

                 Range: [2012,2021]                   Units: 1
         Unique values: 9                         Missing .: 0/647

            Tabulation: Freq.  Value
                           89  2012
                           89  2013
                           24  2014
                           24  2015
                           89  2016
                           89  2017
                           89  2018
                           89  2019
                           65  2021


9 années.
*/
*Combien de regions et combien d'observations par pays?
codebook metroreg ID_Country
/*
----------------------------------------------------------------------------------------------------------------------------------------------------
metroreg                                                                                                                                    metroreg
----------------------------------------------------------------------------------------------------------------------------------------------------

                  Type: String (str7)

         Unique values: 89                        Missing "": 0/647

              Examples: "DE027M"
                        "DE059M"
                        "DE529M"
                        "UK008M"

----------------------------------------------------------------------------------------------------------------------------------------------------
ID_Country                                                                                                                                ID_Country
----------------------------------------------------------------------------------------------------------------------------------------------------

                  Type: Numeric (byte)

                 Range: [1,2]                         Units: 1
         Unique values: 2                         Missing .: 0/647

            Tabulation: Freq.  Value
                          455  1
                          192  2

.*/
tabulate ID_Country
/*
 ID_Country |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |        455       70.32       70.32
          2 |        192       29.68      100.00
------------+-----------------------------------
      Total |        647      100.00
*/ 

gen Log_PIB_HT =log( PIB_HT )
gen Log_POP_ACT =log( POP_ACT )

/*box-plot*/
graph box Log_PIB_HT , over( ID_Country ) ytitle("PIB par Habitant") title("Boîte à moustache par pays ") subtitle("(1-groupe de contrôle , 2-groupe de traitement)" " ") note("Source: Eurostat")

graph box Log_POP_ACT , over( ID_Country ) ytitle("Population active") title("Boîte à moustache par pays ") subtitle("(1-groupe de contrôle , 2-groupe de traitement)" " ") note("Source: Eurostat")
***** Analyse descriptive ************

summarize Log_PIB_HT Log_POP_ACT
/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
  Log_PIB_HT |        582    9.760998    1.122708   7.879337   16.09064
 Log_POP_ACT |        632    3.694839    .8376399    1.94591   6.752971

*/
tabstat Log_PIB_HT Log_POP_ACT, by ( ID_Country )
/*
Summary statistics: Mean
Group variable: ID_Country (ID_Country)


ID_Country |  Log_PI~T  Log_PO~T
-----------+--------------------
         1 |  9.372459  3.453203
         2 |  10.55022  4.261212
-----------+--------------------
     Total |  9.760998  3.694839
--------------------------------

*/


/*PLACEBO Test pour verification de l'hypothèse de tendance commune*/
drop if(Year!=2012 & Year!=2016)
gen POST=(Year==2016)
gen DI=(ID_Country==2)
gen POST_DI=POST*DI


reg Log_PIB_HT POST DI POST_DI Log_POP_ACT
/*
      Source |       SS           df       MS      Number of obs   =       171
-------------+----------------------------------   F(4, 166)       =     77.93
       Model |  132.249999         4  33.0624997   Prob > F        =    0.0000
    Residual |  70.4262482       166  .424254507   R-squared       =    0.6525
-------------+----------------------------------   Adj R-squared   =    0.6441
       Total |  202.676247       170  1.19221322   Root MSE        =    .65135

------------------------------------------------------------------------------
  Log_PIB_HT | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        POST |   .1351878   .1160876     1.16   0.246    -.0940107    .3643864
          DI |   .3444939   .1736213     1.98   0.049     .0017033    .6872845
     POST_DI |   .0295823   .2266018     0.13   0.896    -.4178107    .4769752
 Log_POP_ACT |   .9483737   .0664377    14.27   0.000      .817202    1.079545
       _cons |   6.004033   .2446141    24.54   0.000     5.521077    6.486989
------------------------------------------------------------------------------

*/

/*DIFF IN DIFF l'annonce du BREXIT*/
import excel "C:\Users\gomez\OneDrive\Documents\STATA Project Master1\Project stata\Basesfinale.xlsx", sheet("Sheet1") firstrow clear 

gen Log_PIB_HT =log( PIB_HT )
gen Log_POP_ACT =log( POP_ACT )

/* Diff in Diff année de reference 2016 t+2=2018 (Après) et t-3=2013 (avant)
DI : 1 si groupe de traitement (Royaume-Uni)et 0 si groupe de contrôle (Allemagne)
POST: 0 si Log_PIB_HT est mesuré avant le traitement ie 2013 et 1 si après...2018
le DD c'est le coefficient associé à POST_DI.
*/
drop if(Year!=2013 & Year!=2018)
gen POST=(Year==2018)
gen DI=(ID_Country==2)
gen POST_DI=POST*DI
br


reg Log_PIB_HT POST DI POST_DI Log_POP_ACT
/*

      Source |       SS           df       MS      Number of obs   =       175
-------------+----------------------------------   F(4, 170)       =     75.99
       Model |  132.518456         4  33.1296139   Prob > F        =    0.0000
    Residual |  74.1166071       170  .435980042   R-squared       =    0.6413
-------------+----------------------------------   Adj R-squared   =    0.6329
       Total |  206.635063       174  1.18755783   Root MSE        =    .66029

------------------------------------------------------------------------------
  Log_PIB_HT | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
        POST |   .1509265   .1171931     1.29   0.200    -.0804146    .3822677
          DI |   .3788546   .1681345     2.25   0.026     .0469544    .7107548
     POST_DI |   .0794968   .2238191     0.36   0.723    -.3623258    .5213195
 Log_POP_ACT |   .9243778   .0664059    13.92   0.000     .7932913    1.055464
       _cons |   6.119185   .2443626    25.04   0.000     5.636809    6.601561
------------------------------------------------------------------------------
*/

*********************************** Fin du code STATA *************************************




