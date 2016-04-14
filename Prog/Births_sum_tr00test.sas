/**************************************************************************
 Program:  Births_sum_tr00.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/10/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Summarize birth data by census tracts (2000).

 Modifications:
  11/21/06 PAT  Added 3-year moving avg. births for calculating infant
                death rates.
  06/04/07 PAT  Added vars. Births_preterm & Births_w_gest_age.
  11/27/07 EG   Added 2005 data.
  11/27/07 PAT  Added support for 2000 tracts.
  07/30/08 PAT  Added END_YEAR macro variable, which is used when 
                calculating moving averages.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Vital )

rsubmit;

%let end_year = 2007; *change end year;

%let input_data = Vital.Births_1998 Vital.Births_1999 Vital.Births_2000 
                  Vital.Births_2001 Vital.Births_2002 Vital.Births_2003
                  Vital.Births_2004 Vital.Births_2005 Vital.Births_2006
				  Vital.Births_2007; *add new data set;

%let sum_vars = 
  Births_total Tract_alloc Births_white Births_black
  Births_hisp Births_asian Births_oth_rac Births_w_race
  Births_20to24 Births_teen Births_under18 Births_under15
  Births_teen_wht Births_teen_blk Births_teen_hsp
  Births_teen_asn Births_teen_oth Births_under18_wht
  Births_under18_blk Births_under18_hsp Births_under18_asn
  Births_under18_oth Births_under15_wht Births_under15_blk
  Births_under15_hsp Births_under15_asn Births_under15_oth
  Births_20to24_wht Births_20to24_blk Births_20to24_hsp
  Births_20to24_asn Births_20to24_oth Births_w_age
  Births_w_age_wht Births_w_age_blk Births_w_age_hsp
  Births_w_age_asn Births_w_age_oth
  Births_low_wt Births_low_wt_wht Births_low_wt_blk
  Births_low_wt_hsp Births_low_wt_asn Births_low_wt_oth
  Births_w_weight Births_w_weight_wht Births_w_weight_blk
  Births_w_weight_hsp Births_w_weight_asn Births_w_weight_oth
  Births_single Births_single_wht Births_single_blk
  Births_single_hsp Births_single_asn Births_single_oth
  Births_w_mstat Births_w_mstat_wht Births_w_mstat_blk
  Births_w_mstat_hsp Births_w_mstat_asn Births_w_mstat_oth
  Births_prenat_1st Births_prenat_adeq Births_prenat_intr
  Births_prenat_inad Births_prenat_1st_wht
  Births_prenat_1st_blk Births_prenat_1st_hsp
  Births_prenat_1st_asn Births_prenat_1st_oth
  Births_prenat_adeq_wht Births_prenat_adeq_blk
  Births_prenat_adeq_hsp Births_prenat_adeq_asn
  Births_prenat_adeq_oth Births_prenat_intr_wht
  Births_prenat_intr_blk Births_prenat_intr_hsp
  Births_prenat_intr_asn Births_prenat_intr_oth
  Births_prenat_inad_wht Births_prenat_inad_blk
  Births_prenat_inad_hsp Births_prenat_inad_asn
  Births_prenat_inad_oth Births_w_prenat Births_w_prenat_wht
  Births_w_prenat_blk Births_w_prenat_hsp Births_w_prenat_asn
  Births_w_prenat_oth
  Births_preterm Births_w_gest_age
;

%let sum_vars_wc = Births_: ;

** Combine input data **;

%Push_option( compress )

options compress=no;

data All_births;

  set &input_data;
  by year;
  
run;

** Convert data to single obs. per tract **;

proc summary data=All_births nway;
  class tract_yr tract_full year;
  var &sum_vars;
  output out=All_births_tract sum=;


%Super_transpose(  
  data=All_births_tract,
  out=All_births_tract_tr,
  var=&sum_vars,
  id=year,
  by=tract_yr tract_full,
  mprint=N
)




** Combine data and prepare for transforming tracts **;

data All_births_tr70 (compress=no) All_births_tr80 (compress=no) 
     All_births_tr90 (compress=no) All_births_tr00 (compress=no) 
     All_births_notr (compress=no);

  set All_births_tract_tr;
  
  select ( tract_yr );
    when ( 1970 ) output All_births_tr70;
    when ( 1980 ) output All_births_tr80;
    when ( 1990 ) output All_births_tr90;
    when ( 2000 ) output All_births_tr00;
    otherwise output All_births_notr;
  end;
  
  *keep tract_full tract_yr &sum_vars_wc;
  
  ** Remove vars with no data **;
  
  drop
    %include "[dcdata.Vital.Prog]Births_sum_tr00_drop_list.txt";
  ;

run;



%Transform_geo_data(
    dat_ds_name=All_births_tr70,
    dat_org_geo=tract_full,
    dat_count_vars=&sum_vars_wc,
    wgt_ds_name=General.wt_tr70_tr00,
    wgt_org_geo=geo1970,
    wgt_new_geo=geo2000,
    wgt_wgt_var=popwt,
    out_ds_name=All_births_tr70_tr00
  )

%Transform_geo_data(
    dat_ds_name=All_births_tr80,
    dat_org_geo=tract_full,
    dat_count_vars=&sum_vars_wc,
    wgt_ds_name=General.wt_tr80_tr00,
    wgt_org_geo=geo1980,
    wgt_new_geo=geo2000,
    wgt_wgt_var=popwt,
    out_ds_name=All_births_tr80_tr00
  )

%Transform_geo_data(
    dat_ds_name=All_births_tr90,
    dat_org_geo=tract_full,
    dat_count_vars=&sum_vars_wc,
    wgt_ds_name=General.wt_tr90_tr00,
    wgt_org_geo=geo1990,
    wgt_new_geo=geo2000,
    wgt_wgt_var=popwt,
    out_ds_name=All_births_tr90_tr00
  )

run;

endrsubmit;
  rsubmit;
  proc download data=All_births_tr80_tr00
out=birth_test2;
run;endrsubmit;

** Combine transformed tract data into single file **;

data Tract_sums;

  set All_births_tr70_tr00 All_births_tr80_tr00 All_births_tr90_tr00 All_births_tr00(rename=(tract_full=geo2000));
  
run;



proc summary data=Tract_sums nway completetypes;
  class geo2000 / preloadfmt;
  var &sum_vars_wc;
  output out=Births_sum_tr00 sum=;
  format geo2000 $geo00a.;
run;

** Recode missing values to zero (0) and add moving averages **;

%Pop_option( compress )

data Vital.Births_sum_tr00 (label="Births summary, 1998-&end_year, DC, Census tract (2000)" sortedby=geo2000);

  set Births_sum_tr00 (drop=_type_ _freq_);
  
  array a{*} &sum_vars_wc;
  
  do i = 1 to dim( a );
    if missing( a{i} ) then a{i} = 0;
  end;
  
  ** Moving averages (used with infant deaths) **;
  
  %Moving_avg( Births_total, 1998, &end_year, 3, label=Total births )
  %Moving_avg( Births_black, 2001, &end_year, 3, label=Births to non-Hisp. black mothers )
  %Moving_avg( Births_white, 2001, &end_year, 3, label=Births to non-Hisp. white mothers )
  %Moving_avg( Births_hisp, 2001, &end_year, 3, label=Births to Hispanic/Latino mothers )
  %Moving_avg( Births_asian, 2001, &end_year, 3, label=Births to non-Hisp. Asian/PI mothers )
  %Moving_avg( Births_oth_rac, 2001, &end_year, 3, label=Births to non-Hisp. other race mothers )
  
  drop i;
  
run;

x "purge [dcdata.vital.data]Births_sum_tr00.*";

%File_info( data=Vital.Births_sum_tr00, printobs=0 )

run;

endrsubmit;

signoff;

