/**************************************************************************
 Program:  Deaths_ythhomicide_tr00.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Shelby Kain
 Created:  12/8/08
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  

 Modifications:

**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )
%DCData_lib (EORData)
%DCData_lib (requests)

rsubmit;
data deaths_homicide_tr;/* creates a file on the alpha - temp */
set vital.deaths_2005 (keep= deaths_homicide age_calc tract_yr tract_full);

proc download inlib=work outlib=work; /* download to PC */
select deaths_homicide_tr;

run;
endrsubmit;

/*Create variables*/


data requests.deaths_homicide_12to24;
set deaths_homicide_tr;

	if 12<=age_calc<=17 then deaths_teen=1;
	else deaths_teen=0;

	if 18<=age_calc<=24 then deaths_youngad=1;
	else deaths_youngad=0;

run;

proc freq data= requests.deaths_homicide_12to24 (where=(deaths_youngad=1));
table age_calc;run; 

%let end_year = 2005;

%let input_data =requests.deaths_homicide_12to24;

%let sum_vars = deaths_teen deaths_youngad;
  
%let sum_vars_wc = Deaths_: ;

** Combine input data **;

%Push_option( compress )

options compress=no;

data All_deaths;

  set &input_data;
  *by year;
  
run;

** Convert data to single obs. per tract **;

proc summary data=All_deaths nway;
  class tract_yr tract_full;
  var &sum_vars;
  output out=All_deaths_2 sum=;

%Super_transpose(  
  data=All_deaths_2,
  out=All_Deaths_tract_tr,
  var=&sum_vars,
  id=year,
  by=tract_yr tract_full,
  mprint=N
)

** Combine data and prepare for transforming tracts **;

data All_Deaths_tr70 (compress=no) All_Deaths_tr80 (compress=no) 
     All_Deaths_tr90 (compress=no) All_Deaths_notr (compress=no);

  set All_Deaths_tract_tr;
  
  select ( tract_yr );
    when ( 1970 ) output All_Deaths_tr70;
    when ( 1980 ) output All_Deaths_tr80;
    when ( 1990 ) output All_Deaths_tr90;
    otherwise output All_Deaths_notr;
  end;
  
  keep tract_full tract_yr &sum_vars_wc;
  
  drop
    %include "[dcdata.vital.prog]Deaths_sum_tr00_drop_list.txt";
  ;

run;

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

  set All_Deaths_tr70_tr00 All_Deaths_tr80_tr00 All_Deaths_tr90_tr00;
  
run;

proc summary data=Tract_sums nway completetypes;
  class geo2000 / preloadfmt;
  var &sum_vars_wc;
  output out=Deaths_sum_tr00 sum=;
  format geo2000 $geo00a.;
run;


** Recode missing values to zero (0) and add moving averages **;

%Pop_option( compress )

data Vital.Deaths_sum_tr00 (label="Deaths summary, DC, Census tract (2000)" sortedby=geo2000);

  set Deaths_sum_tr00 (drop=_type_ _freq_);
  
  array a{*} &sum_vars_wc;
  
  do i = 1 to dim( a );
    if missing( a{i} ) then a{i} = 0;
  end;
  
  ** Moving averages **;
  
 * %Moving_avg( Deaths_infant, 1998, &end_year, 3, label=Deaths to infants under 1 year old )
  %Moving_avg( Deaths_infant_blk, 2001, &end_year, 3, label=Deaths to non-Hisp. black infants under 1 year old )
  %Moving_avg( Deaths_infant_wht, 2001, &end_year, 3, label=Deaths to non-Hisp. white infants under 1 year old )
  %Moving_avg( Deaths_infant_hsp, 2001, &end_year, 3, label=Deaths to Hispanic/Latino infants under 1 year old )
  %Moving_avg( Deaths_infant_asn, 2001, &end_year, 3, label=Deaths to non-Hisp. Asian/PI infants under 1 year old )
  %Moving_avg( Deaths_infant_oth, 2001, &end_year, 3, label=Deaths to non-Hisp. other race infants under 1 year old )
  
  drop i;
  
run;

* "purge [dcdata.vital.data]Deaths_sum_tr00.*";

%File_info( data=requests.ythhomicide_05tr, printobs=0 )

run;

endrsubmit;

signoff;

