%let path=~/EPG2V2/data;
libname PG2 "&path";

/* put statements if no debugger */

data storm_complete;
	set pg2.storm_summary_small(obs=2); 
    putlog "NOTE:PDV after SET statement";
	putlog _all_; 
	length Ocean $ 8;
	drop EndDate;
	where Name is not missing;
	Basin=upcase(Basin);
	StormLength=EndDate-StartDate;
	putlog StormLength=;
	if substr(Basin,2,1)="I" then Ocean="Indian";
	else if substr(Basin,2,1)="A" then Ocean="Atlantic";
	else Ocean="Pacific";
	*Add PUTLOG statements;
	putlog "PDV Before RUN statement";
	putlog _all_; 
run;

/**/
data np_parks;
	set pg2.np_final(obs=5);
	putlog "NOTE:PDV after SET statement"
	putlog _all_;
	keep Region ParkName AvgMonthlyVisitors Acres Size;
    where Type="PARK";
	format AvgMonthlyVisitors Acres comma10.;
    Type=propcase(Type);
	AvgMonthlyVisitors=sum(DayVisits,Campers,OtherLodging)/12;
	length Size $ 6;
	if Acres<1000 then Size="Small";
	else if Acres<100000 then Size="Medium";
	else Size="Large";
	putlog "NOTE:PDV Before RUN statement";
	putlog _all_; 
run;


/* controler sortie */
data forecast;
	set sashelp.shoes;
	keep Region Product Subsidiary Year ProjectedSales;
	format ProjectedSales dollar10.;
    Year=1;
	ProjectedSales=Sales*1.05;
	OUTPUT; *sinon seule la 3e année est affichée (calculée en dernier dans le PDV)
	Year=2;
	ProjectedSales=ProjectedSales*1.05;
	OUTPUT;*sinon seule la 3e année est affichée (calculée en dernier dans le PDV)
	Year=3;
	ProjectedSales=ProjectedSales*1.05;
	OUTPUT;*sinon seule la 3e année est affichée (calculée en dernier dans le PDV)
run;


/* output dans differentes tables */
data monument(drop=ParkType) park(drop=ParkType) other ;
	set pg2.np_yearlytraffic;
	if ParkType='National Monument' then output monument;
	else if ParkType='National Park' then output park;
	else output other;
	drop Region;
run;

data camping(keep=ParkName Month DayVisits CampTotal) 
	lodging(keep= ParkName Month DayVisits LodgingOther );
	set pg2.np_2017;
	CampTotal=sum(CampingOther, CampingTent,  CampingRV, CampingBackcountry);
	format CampTotal comma17.;
	if CampTotal > 0 then output camping;
	if LodgingOther > 0 then output lodging;
run;	


/* somme courante avec des NaN (covnertis en zero) */
data zurich2017;
	set pg2.weather_zurich;
	*Add a RETAIN statement;
	*retain TotalRain 0;
	*TotalRain=sum(TotalRain,Rain_mm);
	TotalRain+Rain_mm;
run;

data zurich2017;
    set pg2.weather_zurich;
    YTDRain_mm+Rain_mm;
    DayNum+1; *crée DayNum et l'incrémrente à chaque rangée;
run;


/* premier dernier du groupe (apres sort) */
proc sort data=pg2.storm_2017 out=storm2017_sort;
	by Basin MaxWindMPH;
run;
data storm2017_max;
	set storm2017_sort;
	by Basin;
	if last.Basin=1; *dernier du groupe: sinon pas de output
	StormLength=EndDate-StartDate;
	MaxWindKM=MaxWindMPH*1.60934;
run;
/**/
data houston_monthly;
	set pg2.weather_houston;
	keep Date Month DailyRain MTDRain;
	by Month;
	if first.Month=1 then MTDRain=0;
	MTDRain+DailyRain;
	if last.Month=1; *genere la rangée que si dernier jour du mois
run; 

/* somme courante sur des groupes */      
proc sort data=pg2.np_yearlyTraffic   
          out=sortedTraffic(keep=ParkType ParkName 
                                      Location Count);
    *Insert BY statement;
    by ParkType ParkName;
run;

data TypeTraffic;
    set sortedTraffic;
    by ParkType ;
    if First.ParkType=1 then TypeCount=0;
    TypeCount+Count;
    if last.ParkType=1;
    Format TypeCount comma17.;
    Keep ParkType TypeCount;
run;

/**/
proc sort data=sashelp.shoes
			out=sortedShoes;
			by Region Product;
data profitsummary;
	set sortedShoes;
	by Region Product;
	Profit=Sales-Returns;
	if First.Product=1 then TotalProfit=0;
	TotalProfit+Profit;
	if last.Product=1;  *output que si dernier produit;
	keep Region Product TotalProfit;
	format TotalProfit Dollar8.;
run;


/***** fonctions ****/
/* call routine */
/* assigner des valeurs par défaut (hard-codé)*/
data quiz_report;
    set pg2.class_quiz;
	if Name in("Barbara", "James") then do;
		Quiz1=.;
		Quiz2=.;
		Quiz3=.;
		Quiz4=.;
		Quiz5=.;
	end;
run;
/* equivalent */
data quiz_report;
    set pg2.class_quiz;
	if Name in("Barbara", "James") then call missing(of Q:);
run;

/* moyennes de colonnes */
data wind_avg;
	set pg2.storm_top4_wide;
	WindAvg1=round(mean(of Wind1-Wind4), .1); 
	WindAvg2=mean(of Wind1-Wind4); 
	format WindAvg2 5.1;
run;
/**/
proc print data=pg2.np_lodging(obs=10);
	where CL2010>0;
run;

data stays;
	set pg2.np_lodging;
	*Add assignment statements;
	Stay1=largest(1, of CL:);
	Stay2=largest(2, of CL:);
	Stay3=largest(3, of CL:);
	StayAvg=round(MEAN(of CL:));
	format Stay: comma11.;
	keep Park Stay:;
	if StayAvg > 0;
run;


/***** dates *****/

/*diff en semaines*/
data storm_length;
	set pg2.storm_final(obs=10);
	keep Season Name StartDate Enddate StormLength Weeks;
	Weeks=intck('week', StartDate, EndDate,'c');
run;

/*extraction de formats datetime*/
data rainsummary;
	set pg2.np_hourlyrain;
	by Month;
	if first.Month=1 then MonthlyRainTotal=0;
	MonthlyRainTotal+Rain;
	if last.Month=1;
	date=datepart(Datetime);
	MonthEnd=intnx('Month', date, 0, 'end');
	format date MonthEnd date9.;*dernier jour du mois;
run;


/***** strings *****/
data weather_japan_clean;
    set pg2.weather_japan;
    NewLocation= compbl(Location);
    NewStation= compress(Station, "- ");
run;
/**/
data weather_japan_clean;
	set pg2.weather_japan;
	Location=compbl(Location);
	City=propcase(scan(Location, 1, ','), ' ');
	Prefecture=strip(scan(Location, 2, ','));
	putlog Prefecture $quote20.;
	if Prefecture="Tokyo";
run;
/**/

data storm_damage2;
	set pg2.storm_damage;
	drop Date Cost;
	CategoryLoc=find(Summary, 'category', 'i');*case insensitive search;
	if CategoryLoc > 0 then Category=substr(Summary,CategoryLoc, 10);
run;

proc print data=storm_damage2;
	var Event Summary Cat:;
run;

/**** concat ****/
data storm_id;
	set pg2.storm_final;
	keep StormID: ;
	Day=StartDate-intnx('year', StartDate, 0);
	StormID1=cat(Name, Season, Day);
	StormID2=cats(Name, Season, Day);
	*stormID3=cat(catx('-', Name, Season), Day);
	StormID3=catx("-", Name, Season, Day);
run;


	
	
	
	
	
	
	
	











