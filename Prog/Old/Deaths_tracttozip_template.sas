/**************************************************************************
 Program:  DCData\Libraries\Vital\prog\Deaths_tract_template.sas
 Library:  Vital
 Project:  Child Trends
 Author:   P. Tatian
 Created:  04/13/09
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Summarize death data by census tracts (2000).
 
 TEMPLATE PROGRAM FOR COMPLETING CUSTOM DATA REQUESTS.
 >> Modify user-defined parameters and new variable section.

 Modifications: by S. Kain on 4/14/09 to sum deaths to children ages 1-5 by zip
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Vital )
%DCData_lib( Requests )

rsubmit;

%******* USER-DEFINED PARAMETERS *******;

%** List all input data sets needed;
%** NOTE: Vars will be created for all of the included years;

%let input_data = Vital.Deaths_2000 
                  Vital.Deaths_2001 Vital.Deaths_2002 Vital.Deaths_2003
                  Vital.Deaths_2004 Vital.Deaths_2005;
                  
%** List all variables to be summarized **;

%let sum_vars = 
  Deaths_1_5;

%** Output data set **;

%let output_data = Vital.Deaths_1_5;
%let output_label = "Deaths children 1-5, DC";

** Combine input data **;

data All_deaths;

  set &input_data;
  by year;

  ******* CREATE ANY NEW VARIABLES HERE *******;
if 1<=age_calc<6 then Deaths_1_5=1;
else Deaths_1_5=0;

run;


************ DO NOT MODIFY BELOW THIS LINE ************;

%let sum_vars_wc = %ListChangeDelim( &sum_vars, old_delim = %str( ), new_delim = %str( ), suffix = _: );

%sysrput output_data=&output_data;
%sysrput output_label=&output_label;
%sysrput sum_vars_wc=&sum_vars_wc;

** Convert data to single obs. per tract **;

proc summary data=All_deaths nway;
  class tract_yr tract_full year;
  var &sum_vars;
  output out=All_Deaths_tract sum=;

%Super_transpose(  
  data=All_Deaths_tract,
  out=All_Deaths_tract_tr,
  var=&sum_vars,
  id=year,
  by=tract_yr tract_full,
  mprint=N
)

** Combine data and prepare for transforming tracts **;

data All_Deaths_tr70 (compress=no) All_Deaths_tr80 (compress=no) 
     All_Deaths_tr90 (compress=no) All_Deaths_tr00 (compress=no) 
     All_Deaths_notr (compress=no);

  set All_Deaths_tract_tr;
  
  select ( tract_yr );
    when ( 2000 ) output All_Deaths_tr00;
    when ( 1990 ) output All_Deaths_tr90;
    when ( 1980 ) output All_Deaths_tr80;
    when ( 1970 ) output All_Deaths_tr70;
    otherwise output All_Deaths_notr;
  end;
  
  *drop
    /** DROP VARS IF NECESSARY **/
  ;

run;

** Transform data to 2000 tracts **;

%Transform_geo_data(
    dat_ds_name=All_Deaths_tr70,
    dat_org_geo=tract_full,
    dat_count_vars=&sum_vars_wc,
    wgt_ds_name=General.wt_tr70_tr00,
    wgt_org_geo=geo1970,
    wgt_new_geo=geo2000,
    wgt_wgt_var=popwt,
    out_ds_name=All_Deaths_tr70_tr00
  )

%Transform_geo_data(
    dat_ds_name=All_Deaths_tr80,
    dat_org_geo=tract_full,
    dat_count_vars=&sum_vars_wc,
    wgt_ds_name=General.wt_tr80_tr00,
    wgt_org_geo=geo1980,
    wgt_new_geo=geo2000,
    wgt_wgt_var=popwt,
    out_ds_name=All_Deaths_tr80_tr00
  )

%Transform_geo_data(
    dat_ds_name=All_Deaths_tr90,
    dat_org_geo=tract_full,
    dat_count_vars=&sum_vars_wc,
    wgt_ds_name=General.wt_tr90_tr00,
    wgt_org_geo=geo1990,
    wgt_new_geo=geo2000,
    wgt_wgt_var=popwt,
    out_ds_name=All_Deaths_tr90_tr00
  )

run;

** Combine transformed tract data into single file **;

data Tract_sums;

  set All_Deaths_tr70_tr00 All_Deaths_tr80_tr00 All_Deaths_tr90_tr00 
      All_Deaths_tr00 (rename=(tract_full=geo2000));
  
run;

proc summary data=Tract_sums nway completetypes;
  class geo2000 / preloadfmt;
  var &sum_vars_wc;
  output out=Deaths_sum_tr00 sum=;
  format geo2000 $geo00a.;
run;


** Recode missing values to zero (0) **;

data Deaths_sum_tr00_b (label="&output_label, Census tract (2000)" sortedby=geo2000);

  set Deaths_sum_tr00 (drop=_type_ _freq_);
  
  array a{*} &sum_vars_wc;
  
  do i = 1 to dim( a );
    if missing( a{i} ) then a{i} = 0;
  end;
  
  drop i;
  
run;

proc download status=no
  data=Deaths_sum_tr00_b 
  out=&output_data._tr00;

run;

endrsubmit;

%File_info( data=&output_data._tr00 )

run;

** Summarize to other geographic levels (optional) **;

** Zip **;

%Transform_geo_data
(dat_ds_name=&output_data._tr00,
    dat_org_geo=geo2000,
    dat_count_vars=&sum_vars_wc,
    wgt_ds_name=General.wt_tr00_zip,
    wgt_org_geo=geo2000,
    wgt_new_geo=zip,
    wgt_wgt_var=popwt,
    out_ds_name=&output_data._zipcode)

%File_info( data=&output_data._zipcode )

run;

filename fexport "D:\DCData\Libraries\Vital\Raw\deaths_child_00_05_zip.csv" lrecl=2000;
proc export data=vital.deaths_1_5_zipcode
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;


signoff;

