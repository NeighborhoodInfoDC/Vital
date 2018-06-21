/**************************************************************************
 Program:  Deaths_sum_all_address.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  6/21/18
 Version:  SAS 9.4
 Environment:  Remote Windows session (SAS1)
 
 Description:  Create summary death records for all
 geographic levels.

 Modifications:

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital )


/** Update with latest full year and quarter of sales data available **/
data Deaths ;
   set Vital.Deaths_1998 Vital.Deaths_1999 Vital.Deaths_2000 Vital.Deaths_2001 Vital.Deaths_2002 Vital.Deaths_2003
       Vital.Deaths_2004 Vital.Deaths_2005 Vital.Deaths_2006 Vital.Deaths_2007 Vital.Deaths_2008 Vital.Deaths_2009
	   Vital.Deaths_2010 Vital.Deaths_2011 Vital.Deaths_2012 Vital.Deaths_2013 Vital.Deaths_2014 Vital.Deaths_2015
	   Vital.Deaths_2016 
	   ;
run;


/** Use proc contents to create varlist for transpose **/
proc contents data = deaths out=deaths_contents noprint; run;
proc sort data = deaths_contents; by varnum; run;

data deaths_vars;
	set deaths_contents;
	keep name;
	name_u = upcase(name);
    if find(name_u, "DEATHS_"); 
run;

proc sql noprint;
	select name
	into :blist separated by " "
	from deaths_vars;
quit;

%put &dlist.;


/** Macro Summarize - Start Definition **/

%macro Summarize( level= );

%local filesuf level_lbl level_fmt;

%let level = %upcase( &level );

%if %sysfunc( putc( &level, $geoval. ) ) ~= %then %do;
  %let filesuf = %sysfunc( putc( &level, $geosuf. ) );
  %let level_lbl = %sysfunc( putc( &level, $geolbl. ) );
  %let level_fmt = %sysfunc( putc( &level, $geoafmt. ) );
%end;
%else %do;
  %err_mput( macro=Summarize, msg=Level (LEVEL=&level) is not recognized. )
  %goto exit;
%end;

** Summarize by specified geographic level **;

proc summary data=Deaths;
    class &level /preloadfmt;
    class year;
    format &level &level_fmt;
  var Deaths_: ;
  output 
    out=Deaths&filesuf (drop=_freq_ _type_  compress=no) 
    sum(Deaths_:)=;
run;

** Recode missing number of sales to 0 **;

data Deaths&filesuf (compress=no);

  set Deaths&filesuf (where=(&level ^= " " and year ^= " "));
  
 array a_deaths{*} deaths_: ;
  
  do i = 1 to dim( a_deaths );
    if missing( a_deaths{i} ) then a_deaths{i} = 0;
  end;
  
  drop i;
  
run;

** For tract file, keep only DC tracts **;

%if &level. = GEO2000 or &level. = GEO2010 %then %do;
data Deaths&filesuf;
	set Deaths&filesuf;
	state = substr(&level.,1,2);
	if state = "11";
	drop state;
run;
%end;

%let file_lbl = Deaths summary, DC, &level_lbl;

%Super_transpose( 
  data=Deaths&filesuf,
  out=Deaths_sum&filesuf,
  var=&dlist.,
  id=year,
  by=&level,
  mprint=y
)

quit;

%let revisions=Updated through 2016.;

 %put revisions=&revisions;

data Deaths_sum&filesuf._final;
  set Deaths_sum&filesuf;
  format &level &level_fmt;
run;

  %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=Deaths_sum&filesuf._final,
	  out=Deaths_sum&filesuf,
	  outlib=Vital,
	  label="&file_lbl",
	  sortby=&level ,
	  /** Metadata parameters **/
	  restrictions=None,
	  revisions=%str(&revisions),
	  /** File info parameters **/
	  printobs=0,
	  freqvars=&level
	  );

%exit:

%mend Summarize;

/** End Macro Definition **/

%Summarize( level=city )
%Summarize( level=anc2002 )
%Summarize( level=anc2012 )
%Summarize( level=psa2004 )
%Summarize( level=psa2012 )
%Summarize( level=geo2000 )
%Summarize( level=geo2010 )
%Summarize( level=cluster_tr2000 )
%Summarize( level=ward2002 )
%Summarize( level=ward2012 )
%Summarize( level=voterpre2012 )
%Summarize( level=bridgepk )
%Summarize( level=Cluster2017 )
%Summarize( level=stantoncommons )

run;



