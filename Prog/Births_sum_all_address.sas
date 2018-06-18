/**************************************************************************
 Program:  Birth_sum_all.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  6/18/18
 Version:  SAS 9.2
 Environment:  Remote Windows session (SAS1)
 
 Description:  Create summary birth records for all
 geographic levels.

 Modifications:

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital )

/** Update with latest full year and quarter of sales data available **/
data Births;
   set Vital.Births_1998 Vital.Births_1999 Vital.Births_2000 Vital.Births_2001 Vital.Births_2002 Vital.Births_2003 
       Vital.Births_2004 Vital.Births_2005 Vital.Births_2006 Vital.Births_2007 Vital.Births_2008 Vital.Births_2009
	   Vital.Births_2010 Vital.Births_2011 Vital.Births_2012 Vital.Births_2013 Vital.Births_2014 Vital.Births_2015
	   Vital.Births_2016 
	   ;
run;

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

proc summary data=Births;
    class &level /preloadfmt;
    class BIRTHYR;
    format &level &level_fmt;
  var Births_: ;
  output 
    out=Births&filesuf (drop=_freq_ _type_  compress=no) 
    sum(Births_:)=
run;

** Recode missing number of sales to 0 **;

data Births&filesuf (compress=no);

  set Births&filesuf;
  
  array Births ;
  
  do i = 1 to dim( a_sales );
    if missing( a_sales{i} ) then a_sales{i} = 0;
  end;
  
  drop i;
  
run;

** For tract file, keep only DC tracts **;

%if &level. = GEO2000 or &level. = GEO2010 %then %do;
data Births&filesuf;
	set Births&filesuf;
	state = substr(&level.,1,2);
	if state = "11";
	drop state;
run;
%end;

%let file_lbl = Birhts summary, DC, &level_lbl;

%Super_transpose( 
  data=Births&filesuf,
  out=Births_sum&filesuf,
  var=Births_:,
  id=BIRTHYR,
  by=&level,
  mprint=y
)

quit;

%let revisions=Updated through 2016.

 %put revisions=&revisions;

data Births_sum&filesuf._final;
  set Births_sum&filesuf;
  format &level &level_fmt;
run;

  %Finalize_data_set( 
	  /** Finalize data set parameters **/
	  data=Births_sum&filesuf._final,
	  out=Births_sum&filesuf,
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
%Summarize( level=eor )
%Summarize( level=geo2000 )
%Summarize( level=geo2010 )
%Summarize( level=cluster_tr2000 )
%Summarize( level=ward2002 )
%Summarize( level=ward2012 )
%Summarize( level=zip )
%Summarize( level=voterpre2012 )
%Summarize( level=bridgepk )
%Summarize( level=Cluster2017 )
%Summarize( level=stantoncommons )

run;



