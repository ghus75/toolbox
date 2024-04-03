%let path=~/EPG2V2/data;
libname PG2 "&path";

/*****************************************/
/***** DATA step processing with PDV *****/
/*****************************************/

/* Compilation:
- check syntax
- PDV = prgm data vector : col and attributes, one row at a time 
- rules for processing PDV (KEEP, WHERE, and FORMAT stmtsset flags for drop, filter rows, etc) 
- write descriptor (meta data)

Execution:
- init PDV
- read row into PDV
- process statements and update pdv
- output
*/

/* Using put statements to watch PDV (if no debugger) */
data np_parks;
	set pg2.np_final(obs=5);
	putlog "NOTE:PDV after SET statement" /* `NOTE` writes in blue in log */
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

/* implicit/explicit output */
data forecast;
	set sashelp.shoes;
	keep Region Product Subsidiary Year ProjectedSales;
	format ProjectedSales dollar10.;
    Year=1;
	ProjectedSales=Sales*1.05;
	OUTPUT; /* write explicit output in table*/
	Year=2;
	ProjectedSales=ProjectedSales*1.05;
	OUTPUT;
	Year=3;
	ProjectedSales=ProjectedSales*1.05;
	OUTPUT;
	/*sinon seule la 3e année (implicit output) est affichée
	(calculée en dernier dans le PDV)*/
run;

/* output dans differentes tables (avec de drop de col specifiques pour chq table) */
data monument(drop=ParkType) park(drop=ParkType) other ;
	set pg2.np_yearlytraffic;
	if ParkType='National Monument' then output monument;
	else if ParkType='National Park' then output park;
	else output other;
	drop Region;
run;

data camping(keep=ParkName Month DayVisits CampTotal) /* use keep to filter columns needed */
	lodging(keep= ParkName Month DayVisits LodgingOther );
	set pg2.np_2017;
	CampTotal=sum(CampingOther, CampingTent,  CampingRV, CampingBackcountry);
	format CampTotal comma17.;
	if CampTotal > 0 then output camping;
	if LodgingOther > 0 then output lodging;
run;	

/*   Running quantities   */

/* somme courante avec des NaN (convertis en zero)*/
data zurich2017;
	set pg2.weather_zurich;
	*Add a RETAIN statement; /* compile time stmt */
	*retain TotalRain 0; /* init to 0 and keeps from resetting at each step of the PDV */
	*TotalRain=sum(TotalRain,Rain_mm);
	
	/* equivalent syntax: 
	<accumulating col>+<col to add> statement 
	(init to 0 and ignoers missing values
	*/
	TotalRain+Rain_mm; 
	run;
/**/
data zurich2017;
    set pg2.weather_zurich;
    YTDRain_mm+Rain_mm;
    DayNum+1; *crée DayNum et l'incrémente à chaque rangée;
run;

/* Running sum by group */
proc sort data=pg2.storm_2017 out=storm2017_sort;
	by Basin MaxWindMPH;
run;
data storm2017_max;
	set storm2017_sort;
	by Basin; /* `by` => booleans first.basin and last.basin are added to the PDV */
	if last.Basin=1; *dernier du groupe: sinon pas de output
	StormLength=EndDate-StartDate;
	MaxWindKM=MaxWindMPH*1.60934;
run;

/* accumulate and reset for each group */
/* ex: reset accumulation for each month */
data houston_monthly;
	set pg2.weather_houston;
	keep Date Month DailyRain MTDRain;
	by Month;
	if first.Month=1 then MTDRain=0; /* reset for each month */
	MTDRain+DailyRain;
	if last.Month=1; /* output only of last day of month */
run; 

/* subsetting rows in the execution phase => use if */
/* 1. proc sort to group data */
proc sort data=pg2.np_yearlyTraffic   
          out=sortedTraffic(keep=ParkType ParkName 
                                      Location Count);
    by ParkType ParkName;
run;
/* 2. accumulate by group */
data TypeTraffic;
    set sortedTraffic;
    by ParkType ;
    /* first.X and last.X cannot be used with `where`, 
    which is based on columns in the input table*/
    if First.ParkType=1 then TypeCount=0;
    TypeCount+Count;
    if last.ParkType=1;
    Format TypeCount comma17.;
    Keep ParkType TypeCount;
run;



/*****************************************/
/*****          Functions            *****/
/*****************************************/

/* column lists 
mean(of Q:) => all cols qtarting with `Q`
mean(of Quiz1-Quiz5)
format Quiz1--AvgQuiz 3.1 => cols in the PDV
*/
/* ex: moyennes de colonnes */
data wind_avg;
	set pg2.storm_top4_wide;
	WindAvg1=round(mean(of Wind1-Wind4), .1); 
	WindAvg2=mean(of Wind1-Wind4); 
	format WindAvg2 5.1;
run;
/* ex: n + grands de colonnes */
data quiz_analysis;
    StudentID=rand('integer',1000,9999);
	set pg2.class_quiz;
	drop Quiz1-Quiz5 Name;
    Quiz1st=largest(1, of Quiz1-Quiz5); /*3 best grades*/
    Quiz2nd=largest(2, of Quiz1-Quiz5);
    Quiz3rd=largest(3, of Quiz1-Quiz5);
    Top3Avg=round(mean(Quiz1st, Quiz2nd, Quiz3rd), .1);
run;

/* call routine modifies cols in place */
data quiz_report;
    set pg2.class_quiz;
    /* pas de notes si "Barbara", "James" */
	if Name in("Barbara", "James") then call missing(of Q:);
run;


/*  dates   */

/* compter intervalles INTCK() */
data storm_length; /* diff en semaines */
	set pg2.storm_final(obs=10);
	keep Season Name StartDate Enddate StormLength Weeks;
	Weeks=intck('week', StartDate, EndDate,'c'); /* 'c' for continuous */
run;

/* ajouter periodes INTNX() */
data storm_damage2;
    set pg2.storm_damage;
    keep Event Date AssessmentDate: Anniversary;
    AssessmentDate=intnx('month', Date, -1, 'middle'); /* previous month, taken in hte middle */
    Anniversary=intnx('year', Date, 10, 'same'); /* 10-yr anniv */
    format Date AssessmentDate: Anniversary date9.;
run;

/* SAS datetime => datepart() pour la date, et timepart() pour l'heure */
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


/*   character functions   */

data weather_japan_clean; /* compress strings */
    set pg2.weather_japan;
    NewLocation= compbl(Location); /* removes duplicate blanks */
    NewStation= compress(Station, "- "); /* removes specified chars */
run;

data weather_japan_clean; /* extract word from string with SCAN() */
	set pg2.weather_japan;
	Location=compbl(Location); /* extract city and pref from this col */
	City=propcase(scan(Location, 1, ','), ' ');
	Prefecture=strip(scan(Location, 2, ','));
	Country=scan(Location, -1, ',');
	putlog Prefecture $quote20.;
	if Prefecture="Tokyo";
run;

data storm_damage2; /* location of substring witgh FIND() */
	set pg2.storm_damage;
	drop Date Cost;
	CategoryLoc=find(Summary, 'category', 'i');*case insensitive search;
	/* use location in substr()  */
	if CategoryLoc > 0 then Category=substr(Summary, CategoryLoc, 10);
run;

proc print data=storm_damage2;
	var Event Summary Cat:;
run;

/* concatenation CAT / CATS (strips blanks) / CATX ( CATS + insert delims)*/
data storm_id;
	set pg2.storm_final;
	keep StormID: ;
	Day=StartDate-intnx('year', StartDate, 0);
	StormID1=cat(Name, Season, Day); /* ALFRED       201746*/
	StormID2=cats(Name, Season, Day); /* ALFRED201746 */
	*stormID3=cat(catx('-', Name, Season), Day);
	StormID3=catx("-", Name, Season, Day); /* ALFRED-2017-46 */
run;
/**/
data parks;
	set pg2.np_monthlytraffic;
	where ParkName like '%NP';
	Park=substr(ParkName, 1, find(ParkName, 'NP') - 1);
	Location = Propcase(compbl(Location));
	Gate = Tranwrd(Location, 'Traffic Count At', ' '); /* replace string */
	GateCode = catx("-", ParkCode, Gate);
run;


/*   Converting columns types   */

/* read a column by specifying its informat => return numeric value */
data stocks2;
	/* use rename with temp cols to change foramt inplace */
   set pg2.stocks2(rename=(Volume=CharVolume Date=CharDate));
   Volume=input(CharVolume,comma12.); /* convert to num using specified in-format*/
   Date = input(CharDate, date9.);
   drop Char:; /* drop temp cols */
run;
proc contents data=stocks2; /* inspect summary of output table */
run;


/*****************************************/
/*****       Custom formats          *****/
/*****************************************/

proc format; /* define custom fmt using proc format */
    value $HIGHREG 'IM'='Intermountain' 	/* char fmt starts with $ sign */
                  'PW'='Pacific'
                  'SE' ='Southeast'
                  other='All Other Regions';
run;

title 'High Frequency Regions';
proc freq data=pg2.np_summary order=freq;
    tables Reg;
    label Reg='Region';
    format Reg $HIGHREG.; /* use custom fmt in format stmt. */
run;
title;
/**/
proc format; /* custom fmt for ranges of values */
	value 	psize low-<10000 ='Small' /* no $ sign needed for numeric fmt */
			10000-500000= 'Average' 
			500000<-high ='Large';
run;
data np_parksize;
    set pg2.np_acres;
    ParkSize = put(GrossAcres, psize.); /* create new col using custom fmt */
    format GrossAcres comma16.;
run;

/* saving fmts to library */
proc format LIBRARY=pg2.formats ; /* save fmts to catalog */
    value $reg 'C' = 'Complete'
               'I' = 'Incomplete'                             
             other = 'Miscoded';
    value hght low-<58  = 'Below Average'
                58-60   = 'Average'
               60<-high = 'Above Average';
run;

options fmtsearch=(pg2.formats); /* option to find specified fmts */
proc print data=pg2.class_birthdate noobs;
    where Age=12;
    var Name Registration Height;
    format Registration $reg. Height hght.;
run;

/* create custom format from table */
data type_lookup;
	Retain FmtName "$TypeFmt"; /* fmt name */
    /* rename columns to mandatory names for format table */
    set pg2.np_codeLookup (rename=(ParkCode=Start Type=Label));
    keep Start Label FmtName; /* mandatory cols of fmt table */
run;

proc format cntlin=type_lookup; /* build fmt from fmt table */
run;

title 'Traffic Statistics';
proc means data=pg2.np_monthlyTraffic maxdec=0 mean sum nonobs;
    var Count;
    class ParkCode Month;
    label ParkCode='Name';
    format ParkCode $TypeFmt. /* use fmt defined intable */
run;
title;



/*****************************************/
/*****      Combining tables         *****/
/*****************************************/
	
/* concat tables */			

/* tables should have the same column names (or else there will be blanks)*/
data class_current;
	/* change length before set stmt so that attributes
	are established in the PDV */
    length Name $ 10; 
    /* use rename to have the same col names */
    set sashelp.class pg2.class_new2(rename=(Student=Name));   
run;

/* merge tables */

/* tables should be sorted before merging 
PDV iterates in both tables when merging */
proc sort data=pg2.class_teachers out=teachers_sort;
	by Name;
run;
proc sort data=pg2.class_test2 out=test2_sort;
	by Name;
run;
data class2;
	*Complete the MERGE and BY statements;
	merge teachers_sort test2_sort; /* ajouter un rename si noms de col differents*/
	by Name;
run;

/**/
proc sort data=pg2.np_CodeLookup
          out=work.sortedCodes;
    by ParkCode;
run;
proc sort data=pg2.np_2016
          out=work.sorted_code_2016;
    by ParkCode;
run;

data work.parkStats(keep=ParkCode ParkName Year Month DayVisits)
     work.parkOther(keep=ParkCode ParkName);
    merge work.sorted_code_2016(in=inStats) work.sortedCodes;
    by ParkCode;
    /* utiliser flag in= pour ne garder que les rangées dont l'origine est sorted_code_2016*/
   if inStats=1 then output work.parkStats; 
    else output work.parkOther;
run;


/*****************************************/
/*****           DO loops            *****/
/*****************************************/
	
data YearlySavings;
   Amount=200;
   do Month=1 to 12; /* crée la colonne Month et incremente ses valeurs */
      Savings+Amount;
	  *add a SUM Statement;
	  Savings + (Savings*0.02/12);
	  output; /* écrit chq mois (sinon n'affiche que le mois 12+1)*/
   end;
   format Savings 12.2;
run;
	

/* conditional DO */	
data Savings3K;
   set pg2.savings;
   Month=0; /* reset these values for each person in the Name column */
   Savings=0;
   do until (Savings>3000); /* checked at bottom of loop */
   /* or do while (Savings<=3000);  checked at top of loop */
      Month+1;
      Savings+Amount;
      Savings+(Savings*0.02/12);
   end;
   format Savings comma12.2;
run;


/* iterative and conditional loop */
data IncrExports;
    set pg2.eu_sports;
    where Year=2015 and Country='Belgium' 
          and Sport_Product in ('GOLF','RACKET');
	do Year = 2016 to 2025 while(Amt_Export<=Amt_Import);
    	Amt_Export=Amt_Export*1.07;
    	output;
	end;
    format Amt_Import Amt_Export comma12.;
    *drop i;
run; 



/*****************************************/
/*****     Restructuring data        *****/
/*****************************************/
/*
narrow table:
1	Alfred	Math	82	
2	Alfred	Reading	79	
3	Alice	Math	71	
4	Alice	Reading	67	

wide table:
			Math	Reading
1	Alfred	82		79
2	Alice	71		67
*/

/* narrow to wide */
data class_wide;
	set pg2.class_test_narrow;
	by Name;
	/*The RETAIN statement holds values in the PDV across multiple 
	iterations of the DATA step. The last row for each student includes
	both test scores.*/
	retain Name Math Reading;
	keep Name Math Reading;
	if TestSubject="Math" then Math=TestScore;
	else if TestSubject="Reading" then Reading=TestScore;
	/* include only the last row per student in the output table. */
	if last.Name; /* =1 then output; */
run;

/* wide to narrow */
proc print data=pg2.np_2017camping(obs=10);
run;

data work.camping_narrow(drop=Tent RV Backcountry);
	set pg2.np_2017Camping;
	format CampCount comma12.;
	length CampType $ 16;
	CampType='Tent';
	CampCount=Tent;
	output;
	*Add statements to output rows for RV and Backcountry;
	CampType='RV';
	CampCount=RV;
	output;
	CampType='Backcountry';
	CampCount=Backcountry;
	output;
run;


/* transpose */
proc print data=sashelp.class; /* names in rows */
run;

proc transpose data=sashelp.class out=class_t; 
	id Name; /* names in columns */
	var Height Weight; /* rows for Height and Weight only */
run;

/* transpose by group: wide to narrow */
proc print data=pg2.np_2017camping(obs=5);
run;

proc transpose data=pg2.np_2017camping name=Location 
		out=work.camping2017_t(rename =(COL1=Count));
	by ParkName;
	Var tent RV;

run;

/* transpose by group: narrow to wide */
proc transpose data=pg2.np_2016camping out=work.camping2016_t(drop=_name_);
	var CampCount;
	id Camptype;
	by ParkName;	
run;

