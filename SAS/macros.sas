/*** macro variables substituted as text in SAS code ***/
options symbolgen; * see subst in log;

%let type=Truck;
%let hp=250;

title1 "Car Type: &type";
title2 "Horsepower > &hp";
proc print data=sashelp.cars;
    var Make Model MSRP Horsepower;
    where Type="&type" and Horsepower>&hp;
run;
title;
options nosymbolgen;

/* 2 periods to escape delimiter of macro var reference */
options symbolgen;

%let type=Truck;
%let hp=250;
%let lib=SASHELP;

* one period to add plural s;
title "&type.s with Horsepower > &hp"; 
*2 periods to escape delimiter;
footnote "Data Source: &lib..CARS";

proc print data=&lib..cars;
    var Make Model MSRP Horsepower;
    where Type="&type" and Horsepower>&hp;
run;
title;footnote;
options nosymbolgen;

/* testing put messages in log*/
%let path=~/EMC1V2;
%put NOTE: &=path;
%put ERROR- Course files are in &path;


/*** automatic macro variables  ***/
data Avg_MPG;
    set sashelp.cars;
    MPG_Average=mean(MPG_City, MPG_Highway);
run;

%put _automatic_; * list auto variables in log;
title1 "Distribution of Average Miles Per Gallon";
/* replace using automatic macro variables */
* title2 "Data Source: <table>"; 
title2 "Data Source: &syslast";
*footnote "Created on <date>";
footnote "Created on &sysdate9";

proc sgplot;
    histogram MPG_Average;
    density MPG_Average;
run;
title;footnote;

/**/
%let country AU;
%let Age1 25;
%let Age2 34;
title "&country Customers Ages &Age1 to &Age2"; 
proc print data=mc1.customers; 
    var Name Age Type; 
    where Country = "&country"
        and Age between &Age1 and &Age2;
run; 
title; 

/**/
%let Lib=mc1;
%Let Dsn=newhires;
%let Var=Employee;

title "Listing of All Employees From &Lib..newhires";
proc print data= &Lib..newhires;
    var &Var._Name &Var._ID;
run;
title

/* use macro function to uppercase */
%let text=class list;
title "%upcase(&text)";
proc print data=sashelp.class;
run;
title;


/* call sas fct from macro fct */
/* example w/ propcase : %sysfunc(propcase(&dt)) 
* no propcase macro fct=> call SAS propcase and wrap it into %sysfunc */
%let dt=front;
data cars_subset;
    set sashelp.cars;
    where upcase(DriveTrain)="%upcase(&dt)";
run;
title "%sysfunc(propcase(&dt)) Wheel Drive Cars";
footnote "Listing from %scan(&syslast,2) Table";
proc print data=&syslast;
run;

/* macro var with special characters inside : escaping */
/* use %str() to escape */
%let location=Buenos Aires%str(,) Argentina;
%let city=%scan(&location, 1,%str(,));
%put &=city;

/**/
%let fullname=AnTHoNY MilLeR;
%let fullname = %upcase(&fullname);
%put &fullname;
%put &fullname in proper case is %sysfunc(propcase(&fullname)).;

%let First= %sysfunc(propcase(%scan(&fullname, 1)));
%put &First;

%let Last= %sysfunc(propcase(%scan(&fullname, 2)));
%put &Last;

%symdel fullname First Last; *erase macro global table
%put _automatic_;

/* using sys variables */
%let d=&sysdate9;
%let t=&systime;
%let Product= %nrstr(R&D);
title1 "Product Names containing '&Product'";
footnote "Report Produced &d &t";
proc print data=mc1.products;
	where Product_Name contains "&Product";
	var Product_Name Product_ID Supplier_Name;
run;
title;footnote;

/**/
%let d=&sysdate9;
%let t=&systime;
title1 "Product Names containing 'Jacket'";
footnote "Report Produced &d &t";
proc print data=mc1.products;
	where Product_Name contains "Jacket";
	var Product_Name Product_ID Supplier_Name;
run;
title;footnote;


/* put sql results into macro var => `into :<macro var>` */
%let start=01Feb2019 ;
%let stop=28Feb2019 ;
proc sql;
	select mean(Quantity) format 4.2 as Qty, 
	       mean(Total_Retail_Price) format=dollar7.2 as Price
	/*into : pas de point-virgule! et avant le from */
	into :Qty trimmed, :Price trimmed 
	from mc1.orders
	where Order_Date between "&start"d and "&stop"d;
quit;

title1 "Orders from &start to &stop";
title2 "Average Quantity: &Qty   Average Price: &Price";
proc print data=mc1.orders;
	where Order_Date between "&start"d and "&stop"d;
	var Order_ID Order_Date Quantity Total_Retail_Price;
	sum Quantity Total_Retail_Price;
	format Total_Retail_Price dollar8.;
run;
title;

/**/
%let year=2015;
%let basincode=EP;

proc sql noprint;
select round(mean(MaxWindMPH)) as AvgWind
	into :AvgWind trimmed
    from mc1.storm_final
    where Season=&year and Basin="&basincode";
    
select BasinName 
	into :BasinName trimmed
	from mc1.storm_basin_codes
	where Basin="&basincode";    
quit;

/**/
title1 "North Atlantic Basin Storms in &year Season";
title2 "Max Wind > Season Average of &AvgWind MPH"; 
proc print data=mc1.storm_final noobs;
	var Name StartDate EndDate MaxWindMPH MinPressure;
	where MaxWindMPH>&AvgWind and Season=&year and Basin="&basincode"; 
run;
title;

proc sgplot data=mc1.storm_final;
    where MaxWindMPH>&AvgWind and Season=&year and Basin="&basincode"; 
	vbar StormType;
	yaxis display=(noline) grid;
run;


/* utilisation de noms de macros dans DATA step*/
/* ne marche pas!
=> il faut remplacer par CALL SYMPUTX*/

%let make=Honda;
data &make(keep=Make Model Type MSRP HybridFlag);
    set sashelp.cars end=lastrow;
    where upcase(Make)="%upcase(&make)";
    retain HybridFlag;
    if Type="Hybrid" then HybridFlag=1;
    if lastrow then do;
        /* les macros %let sont envoyées a la
        global symbol table au moment de l'analyse
        syntaxique, avant la compilation.
        => la derniere valeur du %let ecrase la premiere
        => lors de la compilation du code sas, 
        les do et else do sont déjà vides!*/
        if HybridFlag=1 then do;
            %let foot=&make Offers Hybrid Cars;
            * a remplacer par call symputx ("foot", "&make Offers Hybrid Cars");
        end;
        else do;
            %let foot=&make Does Not Have a Hybrid Car;
            * a remplacer ;
        end;
    end;
run;
title "&make Cars";
footnote "&foot";
proc print data=&make noobs;
	var Model Type MSRP;
run;
title;footnote;


/* affectation de la variable macro avec le contenu d'une colonne  */
%let make=Honda;
proc means data=sashelp.cars noprint maxdec=0;
	where Make="&make";
	var MSRP;
	output out=CarsStat Mean=Mean;
run;

/* ex: affectation avec le contenu de la colonne `Mean` */
data _null_;
	set CarsStat;
	call symputx("AvgMSRP", Mean);
run;

title "&make Cars";
title2 "Average MSRP: &avgmsrp";
proc print data=sashelp.cars noobs;
	where Make="&make";
run;
title;


/* create macro var in data step using symputx */
%let dept=Sales;
data staff;
	keep Employee_ID Department Job_Title Salary;
	set mc1.newhires END=lastrow; *EOF flag;
	where Department="&dept";
	total+Salary; *accumulating column;
	if lastrow then do;
		/* put=> formatting is done before storing 
		macro var in global symbol table */
		call symputx("avg", put(total/_N_, dollar9.));
	end;
run;
/* use macro created in data step to update footnote */
footnote "Average Salary: &avg";
title "New Staff: &dept Department";
proc print data=staff;
	sum salary;
run;
title;

/* use columns from the input table to provide 
both macro variable names and values */
data _null_;
    set mc1.storm_ocean_Codes;
    *macro names taken from Ocean column;
    *macro values taken from OceanName column;
    call symputx(Ocean,OceanName);
run;

proc print data=sashelp.vmacro;
	var name value;
	* like "_" = un seul caractere;
	where name like "_";
run;


/*** indirect references : var macro qui pointe sur une autre reference (ex: valeur dans une dBase) ***/

/* use the value of a macro var to reference another macro var
 =  forward rescan rule */
proc sql noprint;
select MinWind
    into :wind1-
    from mc1.storm_cat;
quit;

%let cat=4;
/* &&wind resolves to &wind, followed by &cat resolving to 4
=> &&wind&cat resolves &wind4 */
%put NOTE: Category &cat storms >= &&wind&cat MPH;

/**/
%let year=2014;
%let cat=3;
%let basin=NA;

/* assign column names from sql query to macro vars */
proc sql noprint;
select MinWind, Damage
    into :wind1-, :damage1-
    from mc1.storm_cat;
quit;

data _null_;
    set mc1.storm_basin_codes;
    call symputx(Basin, BasinName);
run;

/*&&&basin = &SI = South Indian*/
title1 "&&&basin &year Category &cat+ Storms";
footnote "Category &cat storms typically cause %lowcase(&&damage&cat)";
proc print data=mc1.storm_final noobs;
	where Basin="&basin" and
		  /* if cat=2, &&wind&cat = &wind2 = 96*/
		  MaxWindMPH>=&&wind&cat and
		  Season=&year;
run;
title;footnote;

/**/
proc sql noprint;
select Order_Type
    into :Type1-
    from mc1.order_type_codes;
quit;
%put &Type1 &Type2 &Type3;

%let code=3;
title "High Profit Products for &&Type&code Orders";
proc sql number;
select Product_ID format=z12.,
       Sum(Total_Retail_Price) format=dollar10.2 as GrossSales,
       Sum(Total_Retail_Price-CostPrice_Per_Unit) format=dollar10.2 as Profit
    from mc1.orders
    where Order_Type=&code 
    group by Product_ID
    having profit /grosssales > .95
    order by Profit desc;
quit;
title;

/**/
data _null_;
    set mc1.country_codes;
    call symputx(CountryCode, CountryName);
run;

%let code=LU;
/*&&&code = &LU (resolves to macro variable `LU`) = Luxembourg*/
title "Customers Residing in &&&code";
proc print data=mc1.customers;
    id ID;
    var Name Age_Group;
    where Country="&code";
run;
title;

/************ Macro programs *************/

/*Compiling a macro only verifies the syntax 
for the macro statements. */
options MCOMPILENOTE=ALL;
%let dsn=sashelp.cars;
%let obs=5;
%macro pprint / des="prints";
proc print data=&dsn(obs=&obs)   /*pas de point-virgule `;`*/
run;
%mend pprint;

/* display macro-generated code in the log */
options mcompilenote=all;

%macro printtable;
proc print data=&dsn(obs=&obs);
run;
%mend printtable;

%let dsn=sashelp.class;
%let obs=5;

options mprint; /* mprint => display macro code in log */
%printtable
options nomprint;


/* macro fct with parameters and defaults*/
options mcompilenote=all;
%macro stormchart(basin=NA, season=2016, maxwind=20);
title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season, Max Wind > &maxwind MPH"; 
proc sgplot data=mc1.storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season and MaxWindMPH>&maxwind; 
run;
title;
%mend stormchart;

%stormchart
%stormchart(basin=EP, season=2015)

/**/

option mprint;
%macro Customers(Type=inactive);
%let Type =%upcase(&Type); *conversion du param en majuscule;
title "&type Customers"; 
proc sql number;
select Name, Age_Group, Type 
    from mc1.customers 
    where Type contains "%lowcase(&type)"; 
quit; 
title;
%mend Customers;

%Customers(Type=High Activity)

%Customers

/**/

options nolabel; 
title 'Order Stats'; 
proc means data=mc1.orders maxdec=2 mean; 
	var Total_Retail_Price; 
	class Customer_ID; 
run; 
title;
options label;

/*Convert the code to a macro named Orderstats*/
options nolabel; 
%macro OrderStats(var=Total_Retail_Price, class=Customer_ID,
				 stats=mean, decimals=2);
title 'Order Stats'; 
proc means data=mc1.orders maxdec=&decimals &stats; 
	var &var; 
	class &class; 
run; 
title;
%mend;

%OrderStats(var=CostPrice_Per_Unit, class=order_type,
				 stats=mean median, decimals=0) 

options label;


/**** macro var scope *****/
%let X=OutsideMacro; *created in global symbol table;
%put NOTE: &=X before TEST macro execution.;

%macro test; *no param so no local var;
    %let x=InsideMacro; 
    *macro processor finds X in global macro table => updates;
    %put NOTE: &=X during TEST macro execution.;
%mend;
%test
%put NOTE: &=X after TEST macro execution.;

/************************************
* Macro Variable Scope: Practice #5 *
************************************/

 /* Section 1: Macro variables created with %LET */
%macro scope;
%let stormtype1=Some damage;
%let stormtype2=Extensive damage;
%let stormtype3=Devastating damage;
%let stormtype4=Catastrophic damage;
%let stormtype5=Widespread catastrophic damage;
%put _user_;
%mend scope;

%scope

 /* Section 2: Macro variables created with SQL INTO */
%macro scope;
proc sql noprint;
select damage into :stormtype1-
	from mc1.storm_cat
	order by category;
quit;

%let num = &sqlobs; *= # of rows returned by sql;
%put _user_;
%mend scope;

%scope

 /* Section 3: Macro variables created with CALL SYMPUTX */
%macro scope;
data _null_;
	set mc1.storm_cat end=last;
	call symputx(cat('stormtype',_n_),Damage);
	if last=1 then
		call symputx('num',_n_);
run;
%put _user_;
%mend scope;

%scope

%symdel stormtype1 stormtype2 stormtype3 stormtype4 stormtype5 num;

 /* Section 4: Macro variables created with CALL SYMPUTX */
%macro scope;
%local x
data _null_;
	set mc1.storm_cat end=last;
	call symputx(cat('stormtype',_n_),Damage);
	if last=1 then
		call symputx('num',_n_);
run;
%put _user_;
%mend scope;

%scope

%symdel stormtype1 stormtype2 stormtype3 stormtype4 stormtype5 num;

 /* Section 5: Macro variables created with CALL SYMPUTX */
%macro scope;

data _null_;
	set mc1.storm_cat end=last;
	call symputx(cat('stormtype',_n_),Damage, 'L');
	if last=1 then
		call symputx('num',_n_);
run;
%put _user_;
%mend scope;

%scope

%symdel stormtype1 stormtype2 stormtype3 stormtype4 stormtype5 num;



/* check if error in data step before executing macro*/

data sports
    set sashelp.cars;
    where Type="Sports";
    AvgMPG=mean(MPG_City, MPG_Highway);
run;

%if &syserr ne 0 %then %do;
    %put ERROR: The rest of the program will not execute;
%end;
%else %do;
	title "Sports Cars";
	proc print data=sports noobs;	
	    var Make Model AvgMPG MSRP EngineSize;
	run;
	title;
	proc sgplot data=sports;
	    scatter x=MSRP y=EngineSize;
	run;
%end;
title;


/********** Conditional Processing **************/

/* which program steps are generated,
select which individual statements within a SAS program
are executed, and conditionally modify
portions of a SAS statement.*/

/* initial version */
%macro stormchart(basin, season, maxwind);
title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
footnote "Max Wind > &maxwind MPH";
proc sgplot data=mc1.storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season and MaxWindMPH>&maxwind; 
run;
title;footnote;
%mend stormchart;

options mcompilenote=all;
%stormchart(NA,2016,80)


/* Step 2 */
/*use local variable to determine value of other macro var */ 
%macro stormchart(basin, season, cat);
%local maxwind; 
%if &cat=5 %then %let maxwind=157;
%else %if &cat=4 %then %let maxwind=130;
%else %if &cat=3 %then %let maxwind=111;
%else %if &cat=2 %then %let maxwind=96;
%else %if &cat=1 %then %let maxwind=74;

title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
footnote "Max Wind > &maxwind MPH";
proc sgplot data=mc1.storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season and MaxWindMPH>&maxwind; 
run;
title;footnote;
%mend stormchart;

options mcompilenote=all mlogic mprint;
%stormchart(NA,2016,3)
%stormchart(EP,2015) /* error missing params */

/* Step 3 */
/* add test to check macro var isnot nan `%if &cat ne  `*/
%macro stormchart(basin, season, cat);
%local maxwind;
%if &cat=5 %then %let maxwind=157;
%else %if &cat=4 %then %let maxwind=130;
%else %if &cat=3 %then %let maxwind=111;
%else %if &cat=2 %then %let maxwind=96;
%else %if &cat=1 %then %let maxwind=74;

title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
%if &cat ne  %then %do;
   	footnote "Max Wind > &maxwind MPH"; 
%end;
%else %do;
   	footnote "All Storms Included";
%end;
proc sgplot data=mc1.storm_final;
    vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season 
    %if &cat ne %then %do;
         and MaxWindMPH>&maxwind
    %end;
    ;
run;
title;footnote;
%mend stormchart;

options mcompilenote=all mlogic mprint;
%stormchart(SI,2014,2)
/*no error but log shows tests (using MPRINT) on macro var failed*/
%stormchart(EP,2015)

/* restore no print and nologic options */
options nomprint nomlogic;

;

/********** Iterative %DO Loops: Demo Solution *********/

/* Steps 1-2 */
options mcompilenote=all mlogic mprint;

%macro stormchart(basin, season);
title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
proc sgplot data=mc1.storm_final;
	vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season;
run;
title;
%mend stormchart;
;
%stormchart(NA,2015)

/* Step 3 : produce report for a range start, stop of years */

%macro stormchartrange(basin, start, stop);
%local Season;
    %do Season=&start %to &stop;
        %stormchart(&basin, &season)
    %end;
%mend stormchartrange;

%stormchartrange(EP,2011,2013)
%stormchartrange(NA,2010,2016)

options nomlogic nomprint;

/*********** Iterative %DO Loops: 
iterate on arbitrary list of indices, such as given
by an SQL query  **********/

/* storm report for a year */

options mcompilenote=all mlogic mprint;

%macro stormchart(basin, season);
title1 "Storm Frequency by Type";
title2 "&basin Basin, &season Season";
proc sgplot data=mc1.storm_final;
	vbar StormType / dataskin=pressed;
    where Basin="&basin" and Season=&season;
run;
title;
%mend stormchart;

%stormchart(NA,2015)

/* storm reports for all basins that had at least one storm in the season */

%macro allbasins(year);
%local i; /* declare w/ local scope not to corrupt any table*/
/* find all eligible basins using SQL */
proc sql noprint;
select basin
	into :basin1-
	from mc1.storm_basin_codes;
quit;

/* all basins stored in basin1, basin2, ...
call stormchart macro on these basins
=> use indirect reference &&basin&i */
%do i=1 %to &sqlobs;
	%stormchart(&&basin&i, &year)
%end;
%mend allbasins;

%allbasins(2015)
%allbasins(2009)
;
options nomlogic nomprint;


/**/
%macro storms(years); /* list as parameter */
%let i=1;
%let yr=%scan(&years,&i); /* scan years in list*/
%do %until(&yr eq ); /* generate report for each list */
    title "&yr Storms";
    proc means data=mc1.storm_final n min mean max maxdec=0;
        var MaxWindMPH MinPressure;
        where season=&yr;
    run;
    %let i=%eval(&i+1);
    %let yr=%scan(&years,&i);
%end;
title;
%mend storms;
 /* Part c. */
%storms(2011 2014)
;



/*********** Storing Macros **************/

/* utility macro to delete all user-defined macro variables
from the global symbol table
- save in autocall library
- set up autocall facility to make the autocall available
 in any SAS session  */

/* create a series of macro variables based on mc1.country_codes */
data _null_;
    set mc1.country_codes;
    /*macro variables names and values from columns*/
    call symputx(CountryCode, CountryName);
run;
/* info about macro var and values stored in a read-only SAS view
= dictionary table*/
proc sql;
select * 
    from dictionary.macros
    order by Scope, Name;
quit;
/* select global macros and exclude those defined
by SAS applications
=> only user defined macros */
proc sql;
select *
    from dictionary.macros
    where Scope='GLOBAL' and 
          Name not like 'SYS%' and 
          Name not like 'SQL%' and
          Name not like 'SASWORK%' and
          Name not like 'GRAPH%' and
          Name not like 'STUDIO%' and
          Name not like 'OLD%' and
          Name not like '^_%' escape '^' and
          Name ne 'CLIENTMACHINE' and
          Name ne 'USERDIR';
quit;
/* Same but save in a list of macro names
=> generate the list we'll pass to symdel */
proc sql noprint;
select Name
    into :Vars separated by ' '
    from dictionary.macros
    where Scope='GLOBAL' and 
          Name not like 'SYS%' and 
          Name not like 'SQL%' and
          Name not like 'SASWORK%' and
          Name not like 'GRAPH%' and
          Name not like 'STUDIO%' and
          Name not like 'OLD%' and
          Name not like '^_%' escape '^' and
          Name ne 'CLIENTMACHINE' and
          Name ne 'USERDIR';
quit;
%put &=vars;
/* put everything inside a macro statement `%macro deleteall` */
%macro deleteall;
proc sql noprint;
select Name
    into :Vars separated by ' '
    from dictionary.macros
    where Scope='GLOBAL' and 
          Name not like 'SYS%' and 
          Name not like 'SQL%' and
          Name not like 'SASWORK%' and
          Name not like 'GRAPH%' and
          Name not like 'STUDIO%' and
          Name not like 'OLD%' and
          Name not like '^_%' escape '^' and
          Name ne 'CLIENTMACHINE' and
          Name ne 'USERDIR';
quit;
%symdel &vars;
%put NOTE: Macro variables deleted from global table: &vars;
%mend deleteall; 
/* Steps 7-8: 
   7. Save this program as deleteall.sas in the autocall folder 
   8. Add the following statement in the libname.sas program:
      options sasautos=("&path/autocall", sasautos);
*/

/* delete `deleteall` macro from sasmac1 catalog */
proc catalog cat=work.sasmac1;
    delete deleteall.macro;
run;
/* recreate macro variables */
data _null_;
    set mc1.country_codes;
    call symputx(CountryCode, CountryName);
run;
/* call stored macro */
%deleteall
;
/* check vars are deleted */ 
proc sql;
select * 
    from dictionary.macros
    order by Scope, Name;
quit;


/*** autre exemple ***/
%put Testing the PROPCASE macro: %propcase(does PROPCASE WorK?);
proc catalog cat=work.sasmac1;
    contents;
run;
 /*
 %macro propcase(text);
   %sysfunc(propcase(&text))
%mend propcase;

saved in ~/autocall/propcase.sas


=> %PropCase added to catalog
*/


/********* Generating Data-Dependent Code ************/

/* program generated by the macro
is dependent on the data associated with the input
parameters */

%let tab=mc1.storm_final;
%let col=Ocean;
/* generate list of tables from distinct values* of a column */
proc sql noprint;
select distinct &col
    into :tabList separated by " "
    from &tab;

/* creates the macro variable WhenList
=> generates SAS code : `when ("Atlantic") output Atlantic;when ("Indian ") output Indian;when ("Pacific ") output Pacific` */
select distinct 
        cat('when ("', &col, '") output ', &col) 
    into :whenList separated by ";"
    from &tab;
quit;

/*  reads the Name and Value columns
from the dictionary.macros table*/
proc sql;
select name, value
    from dictionary.macros
    where name in ("TABLIST", "WHENLIST");
quit;
/* delete from global macro table*/
%symdel tab col tablist whenlist;

options mprint;

/* Same thing inside a macro stmt
%let statements are replaced by parameters of the macro 

=> save as ~/autocall/splittable_sql.sas */

%macro splittable_sql(tab,col);
	proc sql noprint;
	select distinct &col
	    into :tablist separated by " "
	    from &tab;
	select distinct 
	        cat('when ("', &col, '") output ', &col) 
	    into :whenlist separated by ";"
	    from &tab;
	quit;
	/* build a DATA step using TabList and WhenList. 
	ex:
		data EP NA NI SI SP WP;
	   		set mc1.storm_final;
	   		select(Basin);
			  when ("EP") output EP;
			  when ("NA") output NA;
			  when ("NI") output NI;
			  when ("SI") output SI;
			  when ("SP") output SP;
			  when ("WP") output WP;
	   otherwise;
	   end;
	   run;
	*/
	data &tablist;
	    set &tab;
	    select(&col);
		    &whenlist;
	        otherwise;
	    end;
	run;
%mend splittable_sql;

/* generates several tables one for each col value */
%splittable_sql(sashelp.cars, Type)
%splittable_sql(mc1.storm_final, Basin)

/**/
title "Group: GOLD HIGH ACTIVITY";
proc print data=mc1.customers;
	where upcase(Type)="GOLD HIGH ACTIVITY";
run;
/* generalize using macro */
%macro GroupList(Tab, Col);
	proc sql noprint;
	select distinct upcase(&col)
	    into :Val1-
	    from &tab;
	quit;
	%do i=1 %to &sqlobs;
		title "Group: &&Val&i";
		proc print data=&Tab;
			where upcase(&col)="&&Val&i";
		run;
	%end;
%mend GroupList;
/* call macro */
%GroupList(sashelp.cars, DriveTrain)
%GroupList(mc1.customers, Type)

/* example with excel file */

%macro BasinXLS;

	libname storm xlsx "&path/BasinStorms.xlsx";
	%if &Syslibrc ne 0 %then %do;
	    %put ERROR: The rest of the program will not execute;
	%end;
	%else %do;
		/* create macro variables for ea value of Basin and BasinName*/
		proc sql noprint;
		select Basin, compress(BasinName) /*remove all spaces*/
		    into :basin1-, :basinname1-
		    from mc1.storm_basin_codes;
		quit;
		/* repeat data step for ea value of Basin
		=> write storm for ea Basin in a separate sheet */
		%do i=1 %to &sqlobs;
		data storm.&&basinname&i.._Storms; /*i-th sheet*/
			set mc1.storm_final;
			where Basin="&&basin&i";
		run;
		%end;
	%end;
	
	libname storm clear;
%mend basinxls;

%basinxls


;
/*** adding parameter validation to the `splittable` macro ****/
/* add custom error messages in log */
options mprint;

%macro splittable(tab,col);
	/* include autocall library and sas autos*/
	options sasautos=("&path/autocall",sasautos);
	
	/* Ensure parameter values are uppercase */
	%let tab=%upcase(&tab);
	%let col=%upcase(&col);
	
	/* If only a table name is provided, add prefix WORK. */
	%if %scan(&tab,2)= %then %do;
	    %let tab=WORK.&tab;
	%end;
	
	/* Check if the table exists */
	%if %sysfunc(exist(&tab))=0 %then %do;
		%put ERROR: &tab does not exist.;
		%put ERROR- Macro will stop executing.;
		%return; /* stop macro execution */
	%end;
	
	/* Check if the column exists in the selected table */
	/* use our own macro defined in autocall */
	%else %if %varexist(&tab,&col)=0 %then %do; 
		/* var doesnt exist */
		/* => display list of available columns */
		proc sql noprint;
		select Name
		    into :varlist separated by ", "
			from dictionary.columns
			where libname="%scan(&tab,1)" and 
			      memname="%scan(&tab,2)";
		quit;
		%put ERROR: Column &col does not exist in &tab..;
		%put ERROR- Columns in &tab include &varlist..;
		%put ERROR- Macro will stop executing.;
		%return;
	%end;
	
	/* Create macro variables if COL is numeric */
	/* prefix each column name if it starts with a number*/
	%else %if %vartype(&tab,&col)=N %then %do;
	proc sql noprint;
	select distinct &col, cats("&col._", &col)
	    into :val1-, :table1-
	    from &tab
	    where &col is not missing;
	quit;
	%end;
	
	/* Create macro variables if COL is character */
	%else %if %vartype(&tab,&col)=C %then %do;
	proc sql noprint;
	select distinct &col format=$quote34., /*enclose value of col in quaotationmarks*/
	                compress(&col,,'nk') /* remove invalid char for sas names */
	    into :val1-, :table1-
	    from &tab
	    where &col is not missing;
	quit;
	%end;
		
	/* Build DATA step */
		data 
		    %do i=1 %to &sqlobs;
		        &&table&i
		    %end;
		;
		    set &tab;
		    select(&col);
		    %do i=1 %to &sqlobs;
		        when (&&val&i) output &&table&i;
		    %end;
		    otherwise;
		    end;
		run;

%mend splittable;

options mprint; /* see generated code in the log*/
/* (1) Column with valid table names */
%splittable(mc1.storm_final,Ocean)
/* (2) Table does not exist */
%splittable(false, ID)
/* (3) Column does not exist */
%splittable(sashelp.cars, Test)
/* (4) Column includes values with invalid characters */
%splittable(sashelp.cars, Make)
/* (5) Column is numeric */
%splittable(mc1.orders, Order_Type)

options nomprint;

/**/

%macro stormchart(basin, season) / minoperator; /*allow macro `in` operatot*/
proc sql noprint;
select min(season), max(season)
	into :minseason trimmed, :maxseason trimmed
	from mc1.storm_final;
quit;

%if &season<&minseason or &season>&maxseason %then %do;
    %put ERROR: Valid Seasons are between &minseason and &maxseason;
%end;

%else %do;
	proc sql noprint;
	select Basin
	    into :basinlist separated by " "
	    from mc1.storm_basin_codes;
	quit;
	%if &basin in &basinlist %then %do;
		title1 "Storm Frequency by Type";
		title2 "&basin Basin, &season Season";
		proc sgplot data=mc1.storm_final noborder;
			vbar StormType / filltype=gradient;
		    where Basin="&basin" and Season=&season;
		    yaxis grid;
		run;
		title;
	%end;
	%else %do;
	    %put ERROR: &basin is an invalid basin code. Basin codes include &basinlist..;
	%end;
%end;
%mend stormchart;

%stormchart(NA,2020)
%stormchart(EP,2010)
%stormchart(AA,2010)




