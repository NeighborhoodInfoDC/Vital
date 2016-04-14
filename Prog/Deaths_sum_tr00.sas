/**************************************************************************
 Program:  Deaths_sum_tr00.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/25/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Summarize death data by census tracts (2000).

 Modifications:
  11/18/06 PAT  Removed variables without data in particular years
                (Deaths_sum_tr00_drop_list.txt).
                Added 3-year moving averages.
  10/23/08 PAT  Added 15-19 violent deaths by race.
                Corrected problem with deletion of obs. w/2000 tracts.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Vital )

rsubmit;

%let end_year = 2007;

%let input_data = Vital.Deaths_1998 Vital.Deaths_1999 Vital.Deaths_2000 
                  Vital.Deaths_2001 Vital.Deaths_2002 Vital.Deaths_2003
                  Vital.Deaths_2004 Vital.Deaths_2005 Vital.Deaths_2006
				  Vital.Deaths_2007;

%let sum_vars = 
  Deaths_total Deaths_male Deaths_female
  Deaths_w_sex Deaths_white Deaths_black Deaths_hisp
  Deaths_asian Deaths_oth_rac Deaths_w_race Deaths_w_age
  Deaths_infant Deaths_1to14 Deaths_15to19 Deaths_20to24
  Deaths_under18 Deaths_adult Deaths_senior Deaths_infant_wht
  Deaths_infant_blk Deaths_infant_hsp Deaths_infant_asn
  Deaths_infant_oth Deaths_under18_wht Deaths_under18_blk
  Deaths_under18_hsp Deaths_under18_asn Deaths_under18_oth
  Deaths_adult_wht Deaths_adult_blk Deaths_adult_hsp
  Deaths_adult_asn Deaths_adult_oth Deaths_senior_wht
  Deaths_senior_blk Deaths_senior_hsp Deaths_senior_asn
  Deaths_senior_oth Deaths_1to14_wht Deaths_1to14_blk
  Deaths_1to14_hsp Deaths_1to14_asn Deaths_1to14_oth
  Deaths_15to19_wht Deaths_15to19_blk Deaths_15to19_hsp
  Deaths_15to19_asn Deaths_15to19_oth Deaths_20to24_wht
  Deaths_20to24_blk Deaths_20to24_hsp Deaths_20to24_asn
  Deaths_20to24_oth Deaths_w_age_wht Deaths_w_age_blk
  Deaths_w_age_hsp Deaths_w_age_asn Deaths_w_age_oth
  Deaths_15to19_m Deaths_15to19_f Deaths_20to24_m
  Deaths_20to24_f Deaths_15to19_w_sex Deaths_20to24_w_sex
  Deaths_heart Deaths_cancer Deaths_hiv Deaths_diabetes
  Deaths_hypert Deaths_cereb Deaths_liver Deaths_respitry
  Deaths_oth_caus Deaths_w_cause Deaths_homicide
  Deaths_suicide Deaths_accident Deaths_violent Deaths_heart_m
  Deaths_heart_f Deaths_cancer_m Deaths_cancer_f Deaths_hiv_m
  Deaths_hiv_f Deaths_diabetes_m Deaths_diabetes_f
  Deaths_hypert_m Deaths_hypert_f Deaths_cereb_m
  Deaths_cereb_f Deaths_liver_m Deaths_liver_f
  Deaths_respitry_m Deaths_respitry_f Deaths_oth_caus_m
  Deaths_oth_caus_f Deaths_w_cause_m Deaths_w_cause_f
  Deaths_violent_wht Deaths_violent_blk Deaths_violent_hsp
  Deaths_violent_asn Deaths_violent_oth Deaths_violent_m
  Deaths_violent_f 
  Deaths_violent_15to19
  Deaths_violent_15to19_asn Deaths_violent_15to19_blk
  Deaths_violent_15to19_hsp Deaths_violent_15to19_oth
  Deaths_violent_15to19_wht
  Deaths_homicide_15to19 
  Deaths_homicide_15to19_asn Deaths_homicide_15to19_blk
  Deaths_homicide_15to19_hsp Deaths_homicide_15to19_oth
  Deaths_homicide_15to19_wht
  Deaths_suicide_15to19
  Deaths_suicide_15to19_asn Deaths_suicide_15to19_blk
  Deaths_suicide_15to19_hsp Deaths_suicide_15to19_oth
  Deaths_suicide_15to19_wht
  Deaths_accident_15to19 
  Deaths_accident_15to19_asn Deaths_accident_15to19_blk
  Deaths_accident_15to19_hsp Deaths_accident_15to19_oth
  Deaths_accident_15to19_wht
  Deaths_w_cause_15to19 
  Deaths_violent_20to24 Deaths_homicide_20to24
  Deaths_suicide_20to24 Deaths_accident_20to24
  Deaths_w_cause_20to24    
;

%let sum_vars_wc = Deaths_: ;

** Combine input data **;

%Push_option( compress )

options compress=no;

data All_deaths;

  set &input_data;
  by year;
  
  ** 15-19 deaths by cause and race **;
  %By_race( Deaths_violent_15to19, 15-19 years old, Violent deaths, var2=deaths, pop=persons  )
  %By_race( Deaths_homicide_15to19, 15-19 years old, Deaths from homicide, var2=deaths, pop=persons  )
  %By_race( Deaths_suicide_15to19, 15-19 years old, Deaths from suicide, var2=deaths, pop=persons  )
  %By_race( Deaths_accident_15to19, 15-19 years old, Accidental deaths, var2=deaths, pop=persons  )
  
run;

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
  
  *keep tract_full tract_yr &sum_vars_wc;
  
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

  set All_Deaths_tr70_tr00 All_Deaths_tr80_tr00 All_Deaths_tr90_tr00 
      All_Deaths_tr00 (rename=(tract_full=geo2000));
  
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
  
  %Moving_avg( Deaths_infant, 1998, &end_year, 3, label=Deaths to infants under 1 year old )
  %Moving_avg( Deaths_infant_blk, 2001, &end_year, 3, label=Deaths to non-Hisp. black infants under 1 year old )
  %Moving_avg( Deaths_infant_wht, 2001, &end_year, 3, label=Deaths to non-Hisp. white infants under 1 year old )
  %Moving_avg( Deaths_infant_hsp, 2001, &end_year, 3, label=Deaths to Hispanic/Latino infants under 1 year old )
  %Moving_avg( Deaths_infant_asn, 2001, &end_year, 3, label=Deaths to non-Hisp. Asian/PI infants under 1 year old )
  %Moving_avg( Deaths_infant_oth, 2001, &end_year, 3, label=Deaths to non-Hisp. other race infants under 1 year old )
  
  drop i;
  
run;

x "purge [dcdata.vital.data]Deaths_sum_tr00.*";

%File_info( data=Vital.Deaths_sum_tr00, printobs=0 )

run;

endrsubmit;

signoff;

