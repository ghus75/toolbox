/*****************************************/
/********     simple program      ********/
/*****************************************/
/* 	- has 3 steps: DATA, PROC, PROC
	- each steps has statements ending with `;` */

/* for global statements: options, settings... no need to `run;`*/

/* DATA step reads from a source,
 creates SAS table, filter rows, join, etc*/
/* affiche la table dans `output data` */
data work.shoes;
	set sashelp.shoes; /*copier la table*/
	NetSales=Sales-Returns; /*ajouter une colonne*/
run;

/* PROC step = procedure run on SAS table*/
/* affiche la table mise en forme dans `results` */
proc print data=shoes; /*work.shoes par defaut*/
	/*var x y z ...   optionnel pour selectionner les colonnes à afficher */
run;

/* stats descriptives affichées dans `results` */
proc means data=work.shoes mean sum maxdec=2; /**moy et somme*/
	var NetSales; /*colonne concernée*/
	class region; /* décomposer mean et sum par région */
run;


/**** properties of dataset (= table) ****/
proc contents data=work.shoes;
run;
proc contents data = "/home/u63793519/EPG1V2/data/storm_summary.sas7bdat";
run;

/**** declare a library ****/
/* libname <libref> <engine> <path>*/

libname PG1 "/home/u63793519/EPG1V2/data"; /* uses BASE engine by default */

options validvarname=v7; /* formats column names to adhere to strict SAS naming conventions*/
libname NP XLSX "/home/u63793519/EPG1V2/data/np_info.xlsx"; /* with xlsx engine */

/* automatic SAS libs:
- work lib deleted at end of session 
- sashelp
- other libs created by admin */

/* clear a libref (good practice at end of program) */
proc contents data=NP.parks;
run;
libname NP clear;




/*****************************************/
/*****       importing data          *****/
/*****************************************/
proc import datafile="/home/u63793519/EPG1V2/data/storm_damage.tab" dbms=tab 
		out=storm_damage_tab replace; /* replace = overwrite */
run;

/**** import xlsx ****/
/* using proc instead of libname xlsx => creates a copy of the xls file,
will not be updated upon modif of the original file */
proc import datafile="/home/u63793519/EPG1V2/data/eu_sport_trade.xlsx"
            dbms=xlsx out=eu_sport_trade replace;
run;
proc contents data=eu_sport_trade ;
run;

/**** import csv ****/
proc import datafile="/home/u63793519/EPG1V2/data/np_traffic.csv" dbms=csv 
		out=traffic replace;
	guessingrows=max; /* use all rows to guess types */
run;
proc contents data=traffic;
	/*descriptor portion will be in work.traffic*/
run;




/*****************************************/
/*****       inspecting data         *****/
/*****************************************/
/* look for errors in table columns */
proc print data=pg1.np_summary(obs=20);
	var Reg Type ParkName DayVisits TentCampers RVCampers; 
run;
/* basics stats */
proc means data=pg1.np_summary;
	var DayVisits TentCampers RVCampers; 
run;
/* desc stats on each columns => look for errors in extreme values */
proc univariate data=pg1.np_summary;
	var DayVisits TentCampers RVCampers; 
run;
/* look for error in codes or values that occur only once */
proc freq data=pg1.np_summary;
	tables reg Type;  /* use tables instead of var to produce tables */
run;




/*****************************************/
/*****   subsetting data with WHERE  *****/
/*****************************************/
proc print data=pg1.storm_summary(obs=50);
	*where MinPressure is missing; /*same as MinPressure = .*/
	*where Type is not missing; /*same as Type ne " "*/
	*where MaxWindMPH between 150 and 155;
	*where Basin like "_I"; /* `_` =  single character*/
	where Name like "Z%"; /* `%` any number of char */
run;

/* using macro var in WHERE */
%let BasinCode=SP;
proc means data=pg1.storm_summary;
	where Basin="&BasinCode"; /* !!!! use double quotes !!!!*/
	var MaxWindMPH MinPressure;
run;




/*****************************************/
/***  formatting data in output table  ***/
/*****************************************/
proc print data=pg1.storm_summary(obs=20);
	format Lat Lon 4. StartDate EndDate date11.;
run;

proc freq data=pg1.storm_summary order=freq; /*order Specifies the order for reporting variable values */
	tables StartDate;
	*Add a FORMAT statement;
	*format StartDate MONNAME.; /* display month name only*/
	format StartDate date7.;
run;




/*****************************************/
/***   sorting data in output table    ***/
/*****************************************/
proc sort data=pg1.storm_summary out=storm_sort;
	where Basin in ("NA", "na");
	by descending MAxWindMPH;
run;
/**/
proc sort data=pg1.np_summary  out=np_sort;
	by Reg descending DayVisits; /* descending 2nd key */
	where Type = "NP";
run;

/* removing duplicates */
proc sort data=pg1.np_largeparks out=park_clean
               dupout=park_dups nodupkey;
    by _all_; /* remove entirely duplicated rows */
run;





/*****************************************/
/***            DATA step              ***/
/*****************************************/

/* copie d'une table et traitements rangées par rangées */
libname out "/home/u63793519/EPG1V2/output"; /* pour sauver en permanence */
/* execute les traitements pour chaque ligne de la table
en entrée PG1.Storm_summary */
data out.Storm_cat5;
	set PG1.Storm_summary;
	where MaxWindMPH>=156 and StartDate>="01JAN2000"d;
	keep Season Basin Name Type MawWindMPH;
run;

data eu_occ2016;
	set pg1.eu_occ;
	where YearMon like '2016%'; /* selectionner année = 2016*/
	format Hotel ShortStay Camp COMMA17.;
	drop Geo;
run;
/**/
data out.fox;
	set pg1.np_species;
	where Category = "Mammal" and Common_Names like "%Fox%" and Common_Names not like "%Squirrel%";
	drop Category Record_Status Occurrence Nativeness;
run;
proc sort data=out.fox;
	by Common_Names ;
run;

/* ajout de nouvelles colonnes*/
data storm_wingavg;
	set pg1.storm_range;
	*Add assignment statements;
	WindAvg=MEAN(Wind1, Wind2, Wind3, Wind4);
	WindRange=RANGE(Wind1, Wind2, Wind3, Wind4); * = RANGE(of wind1-wind4);
run;


/* fonctions avec str */
data pacific;
	set pg1.storm_summary;
	drop Type Hem_EW Hem_NS MinPressure Lat Lon;
	Basin = upcase(basin);
	Name = propcase(Name);
	Hemisphere = cats(Hem_NS, Hem_NW); /*concat de 2 colonnes texte*/
	*Add a WHERE statement that uses the SUBSTR function;
	WHERE SUBSTR(Basin, 2, 1)='P';
run;
/**/
data np_summary_update;
	set pg1.np_summary;
	*Add assignment statements;
	SqMiles=Acres * .0015625;
	Camping=sum(OtherCamping, tentCampers, RVCampers, BackcountryCampers);
	Format SqMiles Comma6. Camping Comma10.;
	keep Reg ParkName DayVisits OtherLodging Acres SqMiles Camping;
run;


/* calculs avec dates */
data eu_occ_total;
	set pg1.eu_occ;
	Year=substr(YearMon, 1, 4);
	Month=substr(YearMon, 6, 2);
	ReportDate=MDY(Month, 1, Year);
	Total=sum(Hotel, ShortStay, Camp);
	Format Hotel ShortStay Camp Total Comma17. ReportDate monyy7.;
run;

/* if else */
data storm_cat;
	set pg1.storm_summary;
	keep Name Basin MinPressure StartDate PressureGroup;

	if MinPressure=. then
		PressureGroup=.;
	else if MinPressure<=920 then
		PressureGroup=1;
	else
		PressureGroup=0;
run;
/**/
data storm_summary2;
	set pg1.storm_summary;
	/*Add a LENGTH statement = explicitely define length of data otherwise default to length of first data*/
	length Ocean $ 8;
	keep Basin Season Name MaxWindMPH Ocean;
	Basin=upcase(Basin);
	*Add assignment statement;
	OceanCode=substr(Basin, 2, 1);

	if OceanCode="I" then
		Ocean="Indian";
	else if OceanCode="A" then
		Ocean="Atlantic";
	else
		Ocean="Pacific";
run;
/**/
data park_type;
	set pg1.np_summary;
	*Add IF-THEN-ELSE statements;

	if Type='NM' then
		ParkType='Monument';
	else if Type='NP' then
		ParkType='Park';
	else if Type='NPRE' or Type='PRE' or Type='PREERVE' then
		ParkType='Monument';
	else if Type='NS' then
		ParkType='Seashore';
	else if Type='RVR' or Type='RIVERWAYS' then
		ParkType='River';
run;

proc freq data=park_type;
	tables Type ParkType;
run;


/* multiple conditions : if...then...do; */
data parks monuments;
	set pg1.np_summary;
	where Type in ('NP', 'NM');
	Campers=sum(OtherCamping, RVCampers, TentCampers, BackCountryCampers);
	Format Campers COMMA17.;
	length ParkType $ 8;

	if Type='NP' then
		do;
			ParkType='Park';
			output parks;
			*write row to parks table;
		end;

	if Type='NM' then
		do;
			ParkType='Monument';
			output monuments;
			*write row to monuments table;
		end;
	keep Reg ParkName DayVisits OtherLodging Campers ParkType;
run;




/*****************************************/
/***   Analyzing and reporting data    ***/
/*****************************************/

/* titres */
title "Storm Analysis";
title2 "Summary Statistics for MaxWind and MinPressure.";
footnote "blabla";
proc means data=pg1.storm_final;
	var MaxWindMPH MinPressure;
run;
footnote;/* null title => clear titles for the current SAS session*/

title2 "Frequency Report for Basin. ";
proc freq data=pg1.storm_final;
	tables BasinName;
run;

title; /* null title => clear titles for the current SAS session*/
title2;


/* label columns : replace name by explicit text
ex: MSRP  ----> "Manufacturer Suggested Retail Price"   */
data cars_update;
	set sashelp.cars;
	keep Make Model MSRP Invoice AvgMPG;
	AvgMPG=mean(MPG_Highway, MPG_City);
	label MSRP="Manufacturer Suggested Retail Price" 
		AvgMPG="Average Miles per Gallon" 
		Invoice="Invoice Price";
run;
/**/
proc means data=cars_update min mean max;/* label shows in `label` column */
	var MSRP Invoice;
run;
/**/
proc print data=cars_update label; /*show label in print */
	var Make Model MSRP Invoice AvgMPG;
run;


/* frequency tables */

ods graphics on; /* add graphics */
ods noproctitle; /* remove default title */
title "Categories of Reported species";
title2 "in the Everglades";
proc freq data=pg1.np_species order=freq nlevels; /* by default ordered in alphabetical order*/
	where Species_ID like 'EVER%' and Category ~='Vascular Plant';
	tables Category / nocum plots=freqplot;
run;
title;
ods proctitle; /* reset settings*/

/* 2 way freq report */
/* ex Type*Region détailler par région */
ods graphics on;
ods noproctitle;
title "Selected Park Types by Region";

proc freq data=pg1.np_codelookup order=freq;
	tables Type*Region / nopercent crosslist plots=freqplot(orient=horizontal 
		scale=grouppercent groupby=row);
	*group res by rows;
	*where Type not like '%Other%';
	where Type in('National Historic Site', 'National Monument', 'National Park');
run;
title;
ods proctitle;

/* summary stats report*/
proc means data=pg1.storm_final mean median min max mexdec=0;
	var MaxWindMPH ;
	class BasinName StormType; /* détailler stats par bassin et par type*/
	ways 2; /* ways of combining tables 0=all aggregates, 1=2 tables, */
*	output out=wind_stats mean=AvgWind max=MaxWind;
	*sinon toutes les lignes sont demultipliées avec des stats;
run;
/**/
proc means data=pg1.storm_final n mean min maxdec=0;
	*maxdec=0 round to integer;
	var MinPressure;
	where Season >=2010;
	class Season Ocean;
	ways 1;
run;

/* generate stats using the print statement */
proc means data=pg1.np_westweather noprint; 
	where Precip ne 0;
	var Precip;
	class Year Name;
	output out=rainstats n=RainDays sum=TotalRain; /* custom columns*/
	ways 2;
run;
proc print data=rainstats label; /* print custom stats*/
	var Name Year RainDays TotalRain;
	label Name="Park Name" RainDays="Number of Days Raining" 
		TotalRain="Total Rain Amount (inches)";
run;





/*****************************************/
/***          exporting data           ***/
/*****************************************/


/* export en csv */
/* &outpath est spécifié dans libname.sas avec %let outpath=... */
proc export data=pg1.storm_final 
	outfile="&outpath/storm_final.csv" dbms=csv 
	replace; /* overwrite */
run;

/* export xlsx */
libname xl_lib xlsx "&outpath/storm.xlsx";
data xl_lib.storm_final;
	set pg1.storm_final;
	drop Lat Lon Basin OceanCode;
run;
libname xl_lib clear;

/* export xlsx : écriture d'une nouvelle table dans xlsx */
	/* création fichier xlsx */
libname xlout xlsx "&outpath/southpacific.xlsx";
data xlout.South_Pacific;
	set pg1.storm_final;
	where Basin="SP";
run;
	/* création de la nouvelle table avec means*/
proc means data=pg1.storm_final noprint maxdec=1;
	where Basin="SP";
	var MaxWindKM;
	class Season;
	ways 1;
	/* table créée en sortie va dans le fichier xlsx*/
	output out=xlout.Season_Stats n=Count mean=AvgMaxWindKM max=StrongestWindKM;
run;
libname xlout clear


/* ods output delivery system */
/*
ods <dest> xlsx, pdf, ppt, rtf ....
.... sas code that produces output ....
ods <dest> close;
*/

;
ods excel file="&outpath/pressure.xlsx" STYLE=ANALYSIS
	options(sheet_name='min pressure'); /* file to write to */

	/* SAS code to produce data*/
	title "Minimum Pressure Statistics by Basin";
	ods noproctitle;
	proc means data=pg1.storm_final mean median min maxdec=0;
		class BasinName;
		var MinPressure;
	run;

	ods excel options(sheet_name='corr pressure and max wind');	
	title "Correlation of Minimum Pressure and Maximum Wind";
	proc sgscatter data=pg1.storm_final;
		plot minpressure*maxwindmph;
	run;
	title;
	ods proctitle;

ods excel close;


/*****************************************/
/***         using SQL in SAS          ***/
/*****************************************/

/* similar actions using print or sql */
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

/* filtering output in sql */
title "Most Costly Storms";
proc sql;
	select Event, Cost format=dollar16., year(Date) as Season 
	from pg1.storm_damage
	where Cost > 25e9
	order by Cost desc; /* in SAS: proc sort, then proc print */
quit;

/**/
proc sql;
	select Season, Name, s.Basin, BasinName, MaxWindMPH 
	from pg1.storm_summary as s /* table aliases*/
	inner join pg1.storm_basincodes as b 
	on upcase(s.Basin)=b.Basin 
	order by Season desc, Name;
quit;
