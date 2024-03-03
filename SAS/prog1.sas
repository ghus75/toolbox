/* uses BASE engine so only for sas files */
libname PG1 "/home/u63793519/EPG1V2/data";

options validvarname=v7;
libname NP XLSX  "/home/u63793519/EPG1V2/data/np_info.xlsx";
proc contents data= NP.parks;
run;
libname NP clear;

proc import datafile="/home/u63793519/EPG1V2/data/storm_damage.tab"
            dbms=tab out=storm_damage_tab replace;
run;

/***********************************************************/
/****************** manips sur tables **********************/
/***********************************************************/

/* import csv */
proc import datafile="/home/u63793519/EPG1V2/data/np_traffic.csv"
			dbms=csv out=traffic replace; guessingrows=max;
run;

proc contents data=traffic; /*descriptor portion will be in work.traffic*/
run;

/* copie d'une table puis filtration des resultats */
libname out "/home/u63793519/EPG1V2/output"; /*pour sauver en permanence*/
data out.Storm_cat5;
	set PG1.Storm_summary;
	where MaxWindMPH>=156 and StartDate>="01JAN2000"d;
	keep Season Basin Name Type MawWindMPH
run;

data eu_occ2016 ;
	set pg1.eu_occ ;
	where YearMon like '2016%';
	format Hotel ShortStay Camp COMMA17.;
	drop Geo;
run;

/* like pour filtrer selon wildcard */
data out.fox;
	set PG1.NP_Species;
	where Category='Mammal' and Common_Names like '%Fox%' and Common_Names not like '%Squirrel%';
	drop Category Record_Status Occurrence Nativeness;
run;

/* créer des  nouvelles colonnes */
data storm_wingavg;
	set pg1.storm_range;
	*Add assignment statements;
	WindAvg= MEAN(Wind1,Wind2,Wind3,Wind4);
	WindRange = RANGE(Wind1,Wind2,Wind3,Wind4); /* ou RANGE(of wind1-wind4); */
run;

/* fonctions avec str */
data pacific;
	set pg1.storm_summary;
	drop Type Hem_EW Hem_NS MinPressure Lat Lon;
	/*Add a WHERE statement that uses the SUBSTR function;*/
	WHERE SUBSTR(Basin, 2, 1) = 'P';
run;

data np_summary_update;
	set pg1.np_summary;
	/*Add assignment statements;*/
	SqMiles = Acres * .0015625;
	Camping = sum(OtherCamping, tentCampers, RVCampers, BackcountryCampers);
	Format SqMiles Comma6. Camping Comma10. ;
	keep Reg ParkName DayVisits OtherLodging Acres SqMiles Camping;	
run;

/* calculs avec dates */
data eu_occ_total;
	set pg1.eu_occ;
	Year = substr(YearMon,1,4);
	Month = substr(YearMon,6,2);
	ReportDate = MDY(Month, 1, Year);
	Total = sum(Hotel, ShortStay, Camp);
	Format Hotel ShortStay Camp Total Comma17. ReportDate monyy7.;
run;


/* if else */
data storm_cat;
	set pg1.storm_summary;
	keep Name Basin MinPressure StartDate PressureGroup;
	/*add ELSE keyword and remove final condition;*/
	if MinPressure=. then PressureGroup=.; /* point = nan */
	else if MinPressure<=920 then PressureGroup=1;
	else PressureGroup=0; /*if MinPressure>920 then PressureGroup=0;*/
run;
proc freq data=storm_cat;
	tables PressureGroup;
run;

/**/
data storm_summary2;
	set pg1.storm_summary;
	*Add a LENGTH statement;
	length Ocean $ 8;
	keep Basin Season Name MaxWindMPH Ocean;
	Basin = upcase(Basin);
	*Add assignment statement;
	OceanCode=substr(Basin,2,1);
	if OceanCode="I" then Ocean="Indian";
	else if OceanCode="A" then Ocean="Atlantic";
	else Ocean="Pacific";
run;

/**/
data park_type;
	set pg1.np_summary;
	*Add IF-THEN-ELSE statements;
	if Type='NM' then ParkType = 'Monument';
	else if Type='NP' then ParkType = 'Park';
	else if Type='NPRE' or Type='PRE' or Type = 'PREERVE' then ParkType = 'Monument';
	else if Type='NS' then ParkType='Seashore';
	else if Type='RVR' or Type='RIVERWAYS' then ParkType='River';
run;
proc freq data=park_type;
	tables Type ParkType;
run;

/**/
data parks monuments;
	set pg1.np_summary;
	where Type in ('NP', 'NM');
	Campers=sum(OtherCamping, RVCampers, TentCampers, BackCountryCampers);
	Format Campers COMMA17.;
	length ParkType $ 8;
	if Type='NP' then do;
		ParkType = 'Park';
		output parks; *write row to parks table;
	end;
	if Type='NM' then do;
		ParkType = 'Monument';
		output monuments; *write row to monuments table;
	end;
	keep Reg ParkName DayVisits OtherLodging Campers 
         ParkType;
run;


/*   titres    */

title "Storm Analysis";
title2 "Summary Statistics for MaxWind and MinPressure.";
proc means data=pg1.storm_final;
	var MaxWindMPH MinPressure;
run;
title2 "Frequency Report for Basin. ";
proc freq data=pg1.storm_final;
	tables BasinName;
run;
title;

data cars_update;
    set sashelp.cars;
	keep Make Model MSRP Invoice AvgMPG;
	AvgMPG=mean(MPG_Highway, MPG_City);
	label MSRP="Manufacturer Suggested Retail Price"
          AvgMPG="Average Miles per Gallon"
          Invoice="Invoice Price";
run;
proc means data=cars_update min mean max;
    var MSRP Invoice;
run;

/* label pour faire changer le nom de la colonne avec print */
proc print data=cars_update label; 
    var Make Model MSRP Invoice AvgMPG;
run;

/* table filtree puis freq et graphique*/
ods graphics on;
ods noproctitle;
title "Categories of Reported species";
title2 "in the Everglades";
proc freq data=pg1.np_species  order=freq ;
	where Species_ID like 'EVER%' and Category ~= 'Vascular Plant';
	tables Category / nocum plots=freqplot;
run;
title;
ods proctitle;

/* 2 way freq report */
ods graphics on;
ods noproctitle;
title "Selected Park Types by Region";
proc freq data=pg1.np_codelookup order=freq;
	tables Type*Region / nopercent crosslist 
	plots=freqplot(orient=horizontal
	scale=grouppercent
	groupby=row); *group res by rows;
	
	*where Type not like '%Other%';
	where Type in('National Historic Site',
					'National Monument', 
					'National Park');
run;
title;
ods proctitle;


/***********************************************************/
/******** summary stats report avec proc means  ************/
/***********************************************************/


proc means data=pg1.storm_final n mean min maxdec=0; *maxdec=0 round to integer;
	var MinPressure;
	where Season >=2010;
	class Season Ocean;
	ways 1;
run;

proc means data=pg1.storm_final noprint;
	var MaxWindMPH;
	class BasinName;
	ways 1;
	output out=wind_stats mean=AvgWind max=MaxWind; *sinon toutes les lignes sont demultipliées avec des stats;
run;

title "Weather Statistics by Year and Park";
proc means data=pg1.np_westweather mean min max maxdec=2;
	var Precip Snow TempMin TempMax;
	class Year Name;
	output out=wind_stats mean=AvgWind max=MaxWind; *sinon toutes les lignes sont demultipliées avec des stats;
run;
title;

proc means data=pg1.np_westweather ;
	where Precip ne 0;
	var Precip;
	class Year Name;
	output out=rainstats n=RainDays sum=TotalRain; *sinon toutes les lignes sont demultipliées avec des stats;
	ways 2;
run;

proc print data=rainstats label; 
    var Name Year RainDays TotalRain;
    label Name="Park Name"
          RainDays="Number of Days Raining"
          TotalRain="Total Rain Amount (inches)";
run;



/***********************************************************/
/************************* maps ****************************/
/***********************************************************/
%let Year=2016;
%let basin=NA;

*Preparing the data for map labels;
data map;
	set pg1.storm_final;
	length maplabel $ 20;
	where season=&year and basin="&basin";
	if maxwindmph<100 then MapLabel=" ";
	else maplabel=cats(name,"-",maxwindmph,"mph");
	keep lat lon maplabel maxwindmph;
run;

*Creating the map;
title1 "Tropical Storms in &year Season";
title2 "Basin=&basin";
footnote1 "Storms with MaxWind>100mph are labeled";

proc sgmap plotdata=map;
    *openstreetmap;
    esrimap url='https://services.arcgisonline.com/arcgis/rest/services/World_Physical_Map';
            bubble x=lon y=lat size=maxwindmph / datalabel=maplabel datalabelattrs=(color=red size=8);
run;
title;footnote;

/***********************************************************/
/************  plotting with sgplot **************/
/***********************************************************/


/**************************************************;
*  Creating a Bar Chart with PROC SGPLOT         *;
**************************************************;/
title "Number of Storms in &year";
proc sgplot data=pg1.storm_final;
	where season=&year;
	vbar BasinName / datalabel dataskin=matte categoryorder=respdesc;
	xaxis label="Basin";
	yaxis label="Number of Storms";
run;

/**************************************************;
*  Creating a Line PLOT with PROC SGPLOT         *;
**************************************************;*/
title "Number of Storms By Season Since 2010";
proc sgplot data=pg1.storm_final;
	where Season>=2010;
	vline Season / group=BasinName lineattrs=(thickness=2);
	yaxis label="Number of Storms";
	xaxis label="Basin";
run;

/*
**************************************************;
*  Creating a Report with PROC TABULATE          *;
**************************************************;*/

proc format;
    value count 25-high="lightsalmon";
    value maxwind 90-high="lightblue";
run;

title "Storm Summary since 2000";
footnote1 "Storm Counts 25+ Highlighted";
footnote2 "Max Wind 90+ Highlighted";

proc tabulate data=pg1.storm_final format=comma5.;
	where Season>=2000;
	var MaxWindMPH;
	class BasinName;
	class Season;
	table Season={label=""} all={label="Total"}*{style={background=white}},
		BasinName={LABEL="Basin"}*(MaxWindMPH={label=" "}*N={label="Number of Storms"}*{style={background=count.}} 
		MaxWindMPH={label=" "}*Mean={label="Average Max Wind"}*{style={background=maxwind.}}) 
		ALL={label="Total"  style={vjust=b}}*(MaxWindMPH={label=" "}*N={label="Number of Storms"} 
		MaxWindMPH={label=" "}*Mean={label="Average Max Wind"})/style_precedence=row;
run;
title;
footnote;



/***********************************************************/
/****************  exporter les données ******************/
/***********************************************************/

/* export en csv 
&outpath est spécifié dans libname.sas avec %let outpath=/home/u63793519/EPG1V2/output;
*/
proc export data=pg1.storm_final 
			outfile="&outpath/storm_final.csv" 
			dbms=csv replace;
run;  

/* export xlsx */
libname xl_lib xlsx "&outpath/storm.xlsx";
data xl_lib.storm_final;
	set pg1.storm_final;
	drop Lat Lon Basin OceanCode;
run;
libname xl_lib clear;

/**/
ods excel file="&outpath/pressure.xlsx" STYLE=ANALYSIS;
title "Minimum Pressure Statistics by Basin";
ods noproctitle;
proc means data=pg1.storm_final mean median min maxdec=0;
    class BasinName;
    var MinPressure;
run;
title "Correlation of Minimum Pressure and Maximum Wind";
proc sgscatter data=pg1.storm_final;
	plot minpressure*maxwindmph;
run;
title;  
*Add ODS statement;
ods proctitle;
ods excel close;

/**/
ODS excel file="&outpath/StormStats.xlsx" style=snow
				options(sheet_name='South Pacific Summary');
proc means data=pg1.storm_detail maxdec=0 median max;
    class Season;
    var Wind;
    where Basin='SP' and Season in (2014,2015,2016);
run;
ods excel options(sheet_name='Detail');
proc print data=pg1.storm_detail noobs;
    where Basin='SP' and Season in (2014,2015,2016);
    by Season;
run;
ods excel close;


/* export rtf file */
ods rtf file="&outpath/ParkReport.rtf" style=journal startpage=no;

ods noproctitle;
options nodate;
title "US National Park Regional Usage Summary";
proc freq data=pg1.np_final;
    tables Region /nocum;
run;

proc means data=pg1.np_final mean median max nonobs maxdec=0;
    class Region;
    var DayVisits Campers;
run;

title2 'Day Visits vs. Camping';
ods rtf style=SASDOCPRINTER;
proc sgplot data=pg1.np_final;
    vbar  Region / response=DayVisits;
    vline Region / response=Campers ;
run;
title;

ods proctitle;
ods rtf close;
options date;


/*  requetes sql avec proc sql    */
title "PROC PRINT Output";
proc print data=pg1.class_birthdate;
	var Name Age Height Birthdate;
	format Birthdate date9.;
run;

title "PROC SQL Output";
proc sql;
select Name, Age, Height*2.54 as HeightCM format=5.1, Birthdate format=date9.
    from pg1.class_birthdate;
quit;
title;

/**/
title "Most Costly Storms";
proc sql;
*Add a SELECT statment;
select Event, Cost format=dollar16., year(Date) as Season 
	from pg1.storm_damage
	where Cost > 25e9
	order by Cost desc;
quit;

/**/
proc sql;
select Season, Name, s.Basin, BasinName, MaxWindMPH 
    from pg1.storm_summary as s inner join pg1.storm_basincodes as b
		on  upcase(s.Basin) = b.Basin
    order by Season desc, Name;
quit;












