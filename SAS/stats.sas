%let interval=BodyTemp HeartRate;

/* PROC UNIVARIATE provides summary statistics and plots */
ods graphics;
ods select histogram;
proc univariate data=STAT1.NormTemp noprint;
    var &interval;
    histogram &interval / normal kernel;
    inset n mean std / position=ne;
    title "Interval Variable Distribution Analysis";
run;
title;

/* one-sample t test to determine whether the mean of 
body temperatures is 98.6. */
ods graphics;

proc ttest data=STAT1.normtemp 
           plots( shownull)=interval
           H0=98.6; *reference used in null hypothesis;
    var BodyTemp;
    title "One-Sample t-test testing whether mean BodyTemp=98.6";
run;
title;

/****************************/
/* 2 sided t-test */
ods graphics;
*No H0 here;
proc ttest data=STAT1.ameshousing3 plots(shownull)=interval;
    class Masonry_Veneer; *class needed must be a 2-level variable;
    var SalePrice;
    format Masonry_Veneer $NoYes.; *format the 2 levels;
    title "Two-Sample t-test Comparing Masonry Veneer, No vs. Yes";
run;

title;
/**/
ods graphics;
*No H0 here;
proc ttest data=STAT1.German plots(shownull)=interval;
    class Group; *class needed must be a 2-level variable;
    var Change;
    *format Masonry_Veneer $NoYes.; *format the 2 levels;
    title "German Grammar Training, Comparing Treatment to Control";
run;
title;

/*****************************/
/* 1 way ANOVA */

/*box plot */
/* sgplot pour superposer des graphiques */
*vbox pour box plot;
proc sgplot data=STAT1.ameshousing3;
    vbox SalePrice / category=Central_Air 
                     connect=mean;
    title "Sale Price Differences across Central Air";
run;

/***** general linear model proc GLM  ******/
ods graphics;

proc glm data=STAT1.ameshousing3 plots=diagnostics;
    class Heating_QC;
    *linear model: SalePrice=f(Heating_QC);
    * /solution option = to see the regression
    equation estimates for the design variables;
    model SalePrice=Heating_QC / SOLUTION; 
    *test equal variance of residuals;
	means Heating_QC / hovtest=levene;
	*utilise catalogue de formats stat1.myfmts;
    format Heating_QC $Heating_QC.; 
    title "One-Way ANOVA with Heating Quality as Predictor";
run;
quit;
title;

/**/
proc means data=stat1.garlic; 
   var BulbWt;
   class Fertilizer; *stats pour chaque groupe selon fertiliseur;
   title 'Descriptive Statistics of BulbWt by Fertilizer';
run;

*vbox pour box plot;
proc sgplot data=STAT1.garlic;
    vbox BulbWt / category=Fertilizer 
                     connect=mean;
    title "Bulb Weight Differences across Fertilizers";
run;

*1 way ANOVA;
ods graphics;
proc glm data=STAT1.garlic plots=diagnostics;
    class Fertilizer;
    *linear model: SalePrice=f(Heating_QC);
    * /solution option = to see the regression
    equation estimates for the design variables;
    model BulbWt=Fertilizer ; */ SOLUTION; 
    *test equal variance of residuals;
	means Fertilizer / hovtest=levene;
	*utilise catalogue de formats stat1.myfmts;
    *format Fertilizer $Fertilizer.; 
    title "One-Way ANOVA with Fertilizers as Predictor";
run;
quit;
title;

/******* post-hoc tests *************/
ods graphics;

ods select lsmeans diff diffplot controlplot;
proc glm data=STAT1.ameshousing3 
         plots(only)=(diffplot(center) controlplot);
    class Heating_QC;
    model SalePrice=Heating_QC;
    *control EER using Tukey (alpha always=0.05 for all pairs);
    lsmeans Heating_QC / pdiff=all 
                         adjust=tukey;
	*control EER using Dunnet (use reference );                         
    lsmeans Heating_QC / pdiff=control('Average/Typical') 
                         adjust=dunnett;
    format Heating_QC $Heating_QC.;
    title "Post-Hoc Analysis of ANOVA - Heating Quality as Predictor";
run;
quit;

title;

/**/
ods graphics;
ods select lsmeans diff diffplot controlplot;
proc glm data=STAT1.garlic 
         plots(only)=(diffplot(center) controlplot);
    class Fertilizer;
    model BulbWt=Fertilizer;
    *control EER using Tukey (alpha always=0.05 for all pairs);
    lsmeans Fertilizer / pdiff=all 
                         adjust=tukey;
	*control EER using Dunnet (use chemical=4 as reference );                         
    lsmeans Fertilizer / pdiff=control('4') 
                         adjust=dunnett;
    
    title "Post-Hoc Analysis of ANOVA - Fertilizers as Predictor";
run;
quit;

title;


/*********** pearson correlation   *********************/
/* pearson correlation and scatter plots */
%let interval= Age Weight Height Neck Chest Abdomen Hip 
				Thigh Knee Ankle Biceps Forearm Wrist;

ods graphics / reset=all imagemap; *imagemap to hover over points;
proc corr data=STAT1.bodyfat2 rank
          plots(only)=scatter(nvar=all ellipse=none);
   var &interval;
   with PctBodyFat2;
   *id PID;
   title "Correlations and Scatter Plots with PctBodyFat2";
run;

title;

/*corr matrix for best predictors*/
ods graphics off;
proc corr data=STAT1.bodyfat2 
          nosimple 
          best=5;
   var &interval;
   title "Correlations and Scatter Plot Matrix of Predictors";
run;

title;


/********** simple linear regression **********/
/*st102d05.sas*/
ods graphics;

proc reg data=STAT1.bodyfat2;
    model PctBodyFat2=Weight;
    title "Simple Regression with Weight as Regressor";
run;
quit;

title;



/************* 2 way ANOVA *************/

/* exploratory graph */
/* plot price = f(season), group by heating
 ( = one curve for a given heating) */
/* price with heating=fair depends on season*/
proc sgplot data=STAT1.ameshousing3;
    vline Season_Sold / group=Heating_QC 
                        stat=mean 
                        response=SalePrice 
                        markers;
    format Season_Sold season.;
run; 

/* without interactions */
/* impose main effect model y=aX1 + bx2
without interactions => shows no dependence of price */
ods graphics on;

/* testing to see if all means are equal for ea predictor variable */
proc glm data=STAT1.ameshousing3 order=internal;
    class Season_Sold Heating_QC;
    model SalePrice = Heating_QC Season_Sold;
    lsmeans Season_Sold / diff adjust=tukey;
    format Season_Sold season.;
    title "Model with Heating Quality and Season as Predictors";
run;
quit;

title;


/* linear model with interaction term X1X2 */
ods graphics on;

proc glm data=STAT1.ameshousing3 
         order=internal 
         plots(only)=intplot;
    class Season_Sold Heating_QC;
    model SalePrice = Heating_QC Season_Sold Heating_QC*Season_Sold;
    * slice interaction effect by different levels of heating;
    lsmeans Heating_QC*Season_Sold / diff slice=Heating_QC;
    format Season_Sold Season.;
    * store results in an item store for further study;
    store out=interact; *by default in work;
    title "Model with Heating Quality and Season as Interacting Predictors";
run;
quit;


/* postprocessing ANOVA results */

*restore specifies item store;
proc plm restore=interact plots=all; 
    *different tables for interaction terme, sliced by heating_QC;
    *use Tukey adjustment for the p-values for multiple comparison tests;
    slice Heating_QC*Season_Sold / sliceby=Heating_QC adjust=tukey;
    *clm = confidence limites for the means;
    effectplot interaction(sliceby=Heating_QC) / clm;
run; 

title;

/**/
/*blood P as fct of drug dose, for different diseases*/
proc sgplot data=stat1.drug;
	vline DrugDose / group= Disease
	stat=mean
	response=BloodP markers; 
   format DrugDose dosefmt.; 
run;
/* lm with interactions */
/* global F-test shows bloodP depends on factors*/
proc glm data=stat1.drug plots(only)=intplot;
	class DrugDose Disease;
	model BloodP = DrugDose*Disease;
	lsmeans DrugDose*Disease / diff adjust=Tukey;
run;
/* effect of drugdose => slice by disease*/
/* => add slice statement */
ods graphics on;
proc glm data=STAT1.drug plots(only)=intplot;
   class DrugDose Disease;
   model BloodP=DrugDose|Disease;
   lsmeans DrugDose*Disease / slice=Disease;

run;
quit;



/************* multiple regression *************/

ods graphics off;

proc reg data=STAT1.bodyfat2 ;
    model PctBodyFat2= Age Weight Height Neck Chest Abdomen Hip Thigh Knee Ankle Biceps Forearm Wrist;
    title "Model with lots of predictors";
run;
quit;

/* remove knee w/ highest p value */
proc reg data=STAT1.bodyfat2 ;
    model PctBodyFat2= Age Weight Height Neck Chest Abdomen Hip Thigh Ankle Biceps Forearm Wrist;
    title "Model with lots of predictors";
run;
quit;

/* remove chest w/ highest p value */
proc reg data=STAT1.bodyfat2 ;
    model PctBodyFat2= Age Weight Height Neck Abdomen Hip Thigh Ankle Biceps Forearm Wrist;
    title "Model with lots of predictors";
run;
quit;


/* contour plot of bilinear regression plane */
proc glm data=STAT1.ameshousing3 
         plots(only)=(contourfit);
    model SalePrice=Basement_Area Lot_Area;
    store out=multiple;
    title "Model with Basement Area and Gross Living Area";
run;
quit;


proc plm restore=multiple plots=all;
    effectplot contour (y=Basement_Area x=Lot_Area);
    effectplot slicefit(x=Lot_Area sliceby=Basement_Area=250 to 1000 by 250);
run; 

title;

/******** model selection **************/
%let interval=Age Weight Height Neck Chest Abdomen Hip
	 Thigh Knee Ankle Biceps Forearm Wrist;


ods graphics on; 
proc glmselect data=STAT1.bodyfat2 plots=all;
	STEPWISE: model PctBodyFat2 = &interval / selection=stepwise details=steps select=SL ;
	title "Stepwise Model Selection for PctBodyFat2 - default SL 0.15";
run;

ods graphics on; 
proc glmselect data=STAT1.bodyfat2 plots=all;
	FORWARD: model PctBodyFat2 = &interval / selection=FORWARD details=steps select=SL SLENTRY=0.05;
	title "forward Model Selection for PctBodyFat2 - SL 0.05";
run;

/* using info criteria */

proc glmselect data=STAT1.bodyfat2 plots=all;
	STEPWISESBC: model PctBodyFat2 = &interval / selection=stepwise details=steps select=SBC;
	title "Stepwise Model Selection for PctBodyFat2 - SBC";
run;

proc glmselect data=STAT1.bodyfat2 plots=all;
	STEPWISEAIC: model PctBodyFat2 = &interval / selection=stepwise details=steps select=AIC;
	title "Stepwise Model Selection for PctBodyFat2 - AIC";
run;


/****** verifying assumptions of LR **********/
%let interval=Age Weight Height Neck Chest Abdomen Hip
	 Thigh Knee Ankle Biceps Forearm Wrist;

ods graphics on;
proc reg data=STAT1.bodyfat2;
    CONTINUOUS: model PctBodyFat2 = Abdomen Weight Wrist Forearm / selection=rsquare adjrsq cp;;
    title 'PctBodyFat2 Model - Plots of Diagnostic Statistics';
run;
quit;


/*  focus sur les plots residuals */
proc reg data=STAT1.BodyFat2 
         plots(only)=(QQ RESIDUALBYPREDICTED RESIDUALS);
    CONTINUOUS: model PctBodyFat2 
                  = Abdomen Weight Wrist Forearm;
   
    title 'SalePrice Model - Plots of Diagnostic Statistics';
run;
quit;


/******* outliers or influential observations ******/
/* model selection
 produces macro variable _GLSIND => stores list of effects selected */
ods select none; *we don't need output here;
proc glmselect data=STAT1.ameshousing3 plots=all;
	STEPWISE: model SalePrice = &interval / selection=stepwise details=steps select=SL slentry=0.05 slstay=0.05;
	title "Stepwise Model Selection for SalePrice - SL 0.05";
run;
quit;
ods select all;

ods graphics on; *put ods back on;
*write plot data in separate datasets;
ods output RSTUDENTBYPREDICTED=Rstud 
           COOKSDPLOT=Cook
           DFFITSPLOT=Dffits 
           DFBETASPANEL=Dfbs;
proc reg data=STAT1.ameshousing3 
         /*selected plots*/
         plots(only label)=
              (RSTUDENTBYPREDICTED 
               COOKSD 
               DFFITS 
               DFBETAS);
    * uses selected effects during model selection;
    SigLimit: model SalePrice = &_GLSIND; 
    title 'SigLimit Model - Plots of Diagnostic Statistics';
run;
quit;

/******* processing data from plots ************/
/* datasets produced by ods output statement*/
title;
proc print data=Rstud;
run;

proc print data=Cook;
run;

proc print data=Dffits;
run;

proc print data=Dfbs;
run;
/* dfbs is split in 2 because plots were 
printed in 2 separate panels*/
data Dfbs01;
	set Dfbs (obs=300);
run;

data Dfbs02;
	set Dfbs (firstobs=301);
run;
/* merge both datasets from the 2 panels*/
data Dfbs2;
	update Dfbs01 Dfbs02;
	by Observation;
run;

/* table containing subset of data w/ obs that are potential outliers*/
data influential;
/*  Merge datasets from above.*/
    merge Rstud
          Cook 
          Dffits
		  Dfbs2;
    by observation;

/*  Flag observations that have exceeded at least one cutpoint;*/
    if (ABS(Rstudent)>3) or (Cooksdlabel ne ' ') or Dffitsout then flag=1;
    array dfbetas{*} _dfbetasout: ;
    do i=2 to dim(dfbetas);
         if dfbetas{i} then flag=1;
    end;

/*  Set to missing values of influence statistics for those*/
/*  that have not exceeded cutpoints;*/
    if ABS(Rstudent)<=3 then RStudent=.;
    if Cooksdlabel eq ' ' then CooksD=.;

/*  Subset only observations that have been flagged.*/
    if flag=1;
    drop i flag;
run;

title;
proc print data=influential;
    id observation;
    var Rstudent CooksD Dffitsout _dfbetasout:; 
run;

/**/
/*practice w/ bodyFat*/
/*outliers or influential observations */
/* model selection
 produces macro variable _GLSIND => stores list of effects selected */
ods select none; *we don't need output here;
proc glmselect data=STAT1.bodyfat2 plots=all;
	STEPWISE: model PctBodyFat2 = Abdomen Weight Wrist Forearm / selection=stepwise details=steps select=SL slentry=0.05 slstay=0.05;
	title "Stepwise Model Selection for PctBodyFat2 - SL 0.05";
run;
quit;
ods select all;

ods graphics on; *put ods back on;
*write plot data in separate datasets;
ods output RSTUDENTBYPREDICTED=Rstud 
           COOKSDPLOT=Cook
           DFFITSPLOT=Dffits 
           DFBETASPANEL=Dfbs;
proc reg data=STAT1.bodyfat2 
         /*selected plots*/
         plots(only label)=
              (RSTUDENTBYPREDICTED 
               COOKSD 
               DFFITS 
               DFBETAS);
    * uses selected effects during model selection;
    SigLimit: model PctBodyFat2 = &_GLSIND; 
    title 'SigLimit Model - Plots of Diagnostic Statistics';
run;
quit;
/* generated datasets*/
title;
proc print data=Rstud;
run;
proc print data=Cook;
run;
proc print data=Dffits;
run;
proc print data=Dfbs;
run;

/* table containing subset of data w/ obs that are potential outliers*/
data influential;
/*  Merge datasets from above.*/
    merge Rstud
          Cook 
          Dffits
		  Dfbs;
    by observation;
/*  Flag observations that have exceeded at least one cutpoint;*/
    if (ABS(Rstudent)>3) or (Cooksdlabel ne ' ') or Dffitsout then flag=1;
    array dfbetas{*} _dfbetasout: ;
    do i=2 to dim(dfbetas);
         if dfbetas{i} then flag=1;
    end;
/*  Set to missing values of influence statistics for those*/
/*  that have not exceeded cutpoints;*/
    if ABS(Rstudent)<=3 then RStudent=.;
    if Cooksdlabel eq ' ' then CooksD=.;
/*  Subset only observations that have been flagged.*/
    if flag=1;
    drop i flag;
run;

title;
proc print data=influential;
    id observation;
    var Rstudent CooksD Dffitsout _dfbetasout:; 
run;


ods graphics on;
ods output RSTUDENTBYPREDICTED=Rstud 
           COOKSDPLOT=Cook
           DFFITSPLOT=Dffits 
           DFBETASPANEL=Dfbs;
proc reg data=STAT1.BodyFat2 
         plots(only label)=
              (RSTUDENTBYPREDICTED 
               COOKSD 
               DFFITS 
               DFBETAS);
   FORWARD: model PctBodyFat2
                 = Abdomen Weight Wrist Forearm;
   id Case;
   title 'FORWARD Model - Plots of Diagnostic Statistics';
run;
quit;

/**/

data influential;
/*  Merge datasets from above.*/
    merge Rstud
          Cook 
          Dffits
		  Dfbs;
    by observation;

/*  Flag observations that have exceeded at least one cutpoint;*/
    if (ABS(Rstudent)>3) or (Cooksdlabel ne ' ') or Dffitsout then flag=1;
    array dfbetas{*} _dfbetasout: ;
    do i=2 to dim(dfbetas);
        if dfbetas{i} then flag=1;
    end;

/*  Set to missing values of influence statistics for those*/
/*  who have not exceeded cutpoints;*/
    if ABS(Rstudent)<=3 then RStudent=.;
    if Cooksdlabel eq ' ' then CooksD=.;

/*  Subset only observations that have been flagged.*/
    if flag=1;
    drop i flag;
run;

proc print data=influential;
    id observation ID1;
    var Rstudent CooksD Dffitsout _dfbetasout:; 
   run;


/************ colinearity *************/
%let interval=Age Weight Height Neck Chest Abdomen Hip
	 Thigh Knee Ankle Biceps Forearm Wrist;

proc reg data=STAT1.bodyfat2;
	* /vif = variance inflation factor;
    model PctBodyFat2 = &interval  / vif;
    title 'Collinearity Diagnostics';
run;
quit;

/*removing vif>10 including weight, 
but maybe it should be left because itis a significant predictor*/
proc reg data=STAT1.bodyfat2;
	* /vif = variance inflation factor;
    model PctBodyFat2 = Age Height Neck 
	 Thigh Knee Ankle Biceps Forearm Wrist  / vif;
    title 'Collinearity Diagnostics';
run;
quit;

/*************** predictive model ****************/

/*st106d01.sas*/

%let interval=Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
         Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;
%let categorical=House_Style2 Overall_Qual2 Overall_Cond2 Fireplaces 
         Season_Sold Garage_Type_2 Foundation_2 Heating_QC 
         Masonry_Veneer Lot_Shape_2 Central_Air;

ods graphics;
/* uses training and validation datasets */
/* seed to split data => different results upon seed value
 (esp. with a small dataset) */
proc glmselect data=STAT1.ameshousing3
               plots=all 
               seed=86753091; *valdata=STAT1.ameshousing4;
    *class var :glm=> dummy one-hot for ea categ variable;
    class &categorical / param=glm ref=first;
    /*model : regress on &categ and &interval variable
    use backward selection with SBC info criteria to determine which
    variable stay in the model */
    model SalePrice=&categorical &interval / 
               selection=stepwise
               select=aic 
               choose=validate;
    partition fraction(validate=.33);
    store out=STAT1.amesstore; /*stores model in permanent table*/
    title "Selecting the Best Model using Honest Assessment";
run;


/*** scoring model for infernce on new data ***/

/* uses previously saved model trained on ameshousing3*/
proc plm restore=STAT1.amesstore;
    score data=STAT1.ameshousing4 out=scored;
    *sas file containing model parameters to apply;
    code file="&homefolder\scoring.sas"; 
run;

/* re-test scoring using generated sas file*/
data scored2;
    set STAT1.ameshousing4;
    %include "&homefolder\scoring.sas";
run;
/* compare both scores */
proc compare base=scored compare=scored2 criterion=0.0001;
    var Predicted;
    with P_SalePrice;
run;
* => no difference;

/*practice*/
%let interval=Gr_Liv_Area Basement_Area Garage_Area Deck_Porch_Area 
         Lot_Area Age_Sold Bedroom_AbvGr Total_Bathroom;
%let categorical=House_Style2 Overall_Qual2 Overall_Cond2 Fireplaces 
         Season_Sold Garage_Type_2 Foundation_2 Heating_QC 
         Masonry_Veneer Lot_Shape_2 Central_Air;

*score ameshousing4 data and store it in scored1;
proc glmselect data=STAT1.ameshousing3
               seed=8675309
               noprint;
    class &categorical / param=ref ref=first;
    model SalePrice=&categorical &interval / 
               selection=stepwise
               (select=aic 
               choose=validate) hierarchy=single;
    partition fraction(validate=0.3333);
    score data=STAT1.ameshousing4 out=scored1;
    store out=store1; *in work;
run;
*score ameshousing4 data using store1 model;
proc plm restore=store1;
    score data=STAT1.ameshousing4 out=scored2;
run;
/* compare both scores */
proc compare base=scored1 compare=scored2 criterion=0.0001;
    var P_SalePrice;
    with Predicted;
run;

/************* categorical data analysis *************/
title;
proc format;
    value bonusfmt 1 = "Bonus Eligible"
                   0 = "Not Bonus Eligible"
                  ;
run;
 /*investigate whether bonus depends on cross-effect
 => look at row pct for possible associations (ex fireplace=>bonus)*/
proc freq data=STAT1.ameshousing3;
    tables Bonus Fireplaces Lot_Shape_2
           Fireplaces*Bonus Lot_Shape_2*Bonus/
           plots(only)=freqplot(scale=percent);
    format Bonus bonusfmt.;
run;


/* distrib of basement_area for houses with bonus and 
without bonus*/
proc univariate data=STAT1.ameshousing3 noprint;
    class Bonus; /* use to distinguish w/ and w/o bonus */
    var Basement_Area ;
    histogram Basement_Area;
    inset mean std median min max / format=5.2 position=nw;
    format Bonus bonusfmt.;
run;


/* chi2 test of association between categorical variables */
ods graphics off;
proc freq data=STAT1.ameshousing3;
    tables (Lot_Shape_2 Fireplaces)*Bonus
          / chisq expected cellchi2 nocol nopercent 
            relrisk;
    format Bonus bonusfmt.;
    title 'Associations with Bonus';
run;

ods graphics on;

/* chi2 for ordinal variables*/
/* test if more fireplaces => more bonus */
ods graphics off;
proc freq data=STAT1.ameshousing3;
    tables Fireplaces*Bonus / chisq measures cl; *measures for spearmen, cl for conf limits;
    format Bonus bonusfmt.;
    title 'Association between FIREPLACES and BONUS?';
run;
/* maentel chi2 p-value<0.05 => evidence for ordinal assoc
=> spearman = strength of assoc, its CI doenst contain 0 so
relationship is significant*/
ods graphics on;

/*practice*/
proc format;
    value safefmt 1 = "unsafe"
                   0 = "safe"
                  ;
run;

ods graphics off;
proc freq data=STAT1.safety;
    tables region*Unsafe / expected chisq relrisk;
    format Unsafe safefmt.;
    title 'Ordinal Association between region Unsafe?';
run;
ods graphics on;
/* - row pct shows of the cars made in Asia,
 42.86% have a Below Average safety score.
- Col Pct shows of the cars with an Average or
 Above safety score, 69.70% were made in North America.
- no assoc of safety and region p(chi2)=0.0631 */

/*chi2 for ordinal*/
ods graphics off;
proc freq data=STAT1.safety;
    tables size*Unsafe / chisq measures cl; *measures for spearmen, cl for conf limits;
    format Unsafe safefmt.;
    title 'Ordinal Association between size Unsafe?';
run;
/* maentel chi2 p-value<0.05 => evidence for ordinal assoc
=> spearman = strength of assoc, its CI doenst contain 0 so
relationship is significant*/
ods graphics on;


/************** logistic regression **************/

ods graphics on;
proc logistic data=STAT1.ameshousing3 alpha=0.05
              plots(only)=(effect oddsratio);
    model Bonus(event='1')=Basement_Area / clodds=pl;* conf iterval for odds;
    title 'LOGISTIC MODEL (1):Bonus=Basement_Area';
run;
/*look at # of concordant and discordant pairs to qualify model, 
or use Somer's D ans other indicators*/

/**/
ods graphics on;
proc logistic data=STAT1.safety alpha=0.05
              plots(only)=(effect oddsratio);
    model Unsafe(event='1')=Weight / clodds=pl;* conf iterval for odds;
    title 'LOGISTIC MODEL (1):Bonus=Basement_Area';
run;
/*
The p-value for the Likelihood Ratio test is <.0001, and therefore, the global null hypothesis is rejected.
Logit(Unsafe) = 3.5422 + (-1.3901) * Weight
The odds ratio for Weight (0.249) says that the odds for being unsafe (having a Below Average safety rating) are 75.1% lower for each thousand-pound increase in weight. 

The confidence interval (0.102 , 0.517) does not contain 1,which indicates that the odds ratio is statistically significant.
*/


/********* multiple logistic regression model **********/
ods graphics on;
proc logistic data=STAT1.ameshousing3 
				plots(only)=(effect oddsratio);
    class Fireplaces(ref='0') Lot_Shape_2(ref='Regular') 
    	/ param=ref; *ref cell coding;
    model Bonus(event='1')=Basement_Area Fireplaces Lot_Shape_2 / clodds=pl;
    units Basement_Area=100; *specified unit of change;
    title 'LOGISTIC MODEL (2):Bonus= Basement_Area Fireplaces Lot_Shape_2';
run;
/*
SC AIC... smaller than in simple log reg
type 3 analysis of effects=> which predictors are significant
*/
ods graphics on;
proc logistic data=STAT1.safety 
				plots(only)=(effect oddsratio);
    class Size(ref='3') Region(ref='Asia') 
    	/ param=ref; *ref cell coding;
    model Unsafe(event='1')=Weight Size Region  / clodds=pl;
    title 'LOGISTIC MODEL (2):Unsafe=Weight Size Region';
run;
/*
max likelihood estimate:Only Size is significantly predictive of Unsafe.
odds ratios :  Size=1 (Small or Sports) cars have 14.560 times the odds of having a Below Average safety rating compared to the reference category 3
this contrast is significant because 1 is not inside CI
*/


/*  model selection  */

/*using backward selection*/
proc logistic data=STAT1.ameshousing3 plots(only)=(effect oddsratio);
    class Fireplaces(ref='0') Lot_Shape_2(ref='Regular') / param=ref;
    * @2 = only include 2-factor interactions;
    model Bonus(event='1')=Basement_Area|Fireplaces|Lot_Shape_2 @2 / 
          selection=backward clodds=pl slstay=0.10;
    units Basement_Area=100;
    title 'LOGISTIC MODEL (3): Backward Elimination '
           'Bonus=Basement_Area|Fireplaces|Lot_Shape_2';
run;

/* account for odds ration of interactions*/
proc logistic data=STAT1.ameshousing3 
              plots(only)=oddsratio(range=clip);
    class Fireplaces(ref='0') Lot_Shape_2(ref='Regular') / param=ref;
    model Bonus(event='1')=Basement_Area|Lot_Shape_2 Fireplaces;
    units Basement_Area=100;
    * at specifies fixed levels of one or more interacting variables;
    oddsratio Basement_Area / at (Lot_Shape_2=ALL) cl=pl;
    oddsratio Lot_Shape_2 / at (Basement_Area=1000 1500) cl=pl;
    title 'LOGISTIC MODEL (3.1): Bonus=Basement_Area|Lot_Shape_2 Fireplaces';
run;


/******* saving model information and use to predict *******/

ods select none; *no output;
proc logistic data=STAT1.ameshousing3;
    class Fireplaces(ref='0') Lot_Shape_2(ref='Regular') / param=ref;
    model Bonus(event='1')=Basement_Area|Lot_Shape_2 Fireplaces;
    units Basement_Area=100;
	store out=isbonus; *name of item store we want to save
run;
ods select all; *output in next step;

*dataset for scoring;
data newhouses;
	length Lot_Shape_2 $9;
	input Fireplaces Lot_Shape_2 $ Basement_Area;
	datalines;
	0  Regular    1060
	2  Regular     775
	2  Irregular  1100
	1  Irregular   975
	1  Regular     800
	;
run;

*use plm to generate predictions for the scoring dataset;
proc plm restore=isbonus;
	* /ILINK = predictions on a probability scale instead of logits;
	score data=newhouses out=scored_houses / ILINK;
	title 'Predictions using PROC PLM';
run;

* view score data;
proc print data=scored_houses;
run;


/**/
ods graphics on;
proc logistic data=STAT1.safety 
			  plots(only)=(effect oddsratio);
    class Region(ref='Asia') Size(ref='1') / param=ref;
    * @2 = only include 2-factor interactions;
    model Unsafe(event='1')=Weight|Size|Region @2 / 
          selection=backward clodds=pl slstay=0.10;
    *format Size sizefmt.;
    units weight=-1;
    store out=isSafe; *name of item store we want to save;
run;

data checkSafety;
   length Region $9.;
   input Weight Size Region $ 5-13;
   datalines;
   4 1 N America
   3 1 Asia     
   5 3 Asia     
   5 2 N America
	 ;
run;
*use plm to generate predictions for the scoring dataset;
proc plm restore=isSafe;
	* /ILINK = predictions on a probability scale instead of logits;
	score data=checkSafety out=scored_checkSafety / ILINK;
	title 'Predictions using PROC PLM';
run;

* view score data;
proc print data=scored_checkSafety;
run;



