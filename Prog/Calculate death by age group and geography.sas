/**************************************************************************
 Program:  Calculate death by age group and geography.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  9/10/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Summarize total death by age group and geograpy for calculating mortality rate and years of life lost 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital )
%DCData_lib( Census )
** create age groups based on public health research standards https://ibis.health.state.nm.us/resource/AARate.html  **;
data deaths;
	set vital.Deaths_2016;

	if age <=1 then age_group = 1;
		else if 1< age <=4 then age_group = 2;
		else if 5< age <=14 then age_group = 3;
		else if 15< age <=24 then age_group = 4;
		else if 25< age <=34 then age_group = 5;
		else if 35< age <=44 then age_group = 6;
		else if 45< age <=54 then age_group = 7;
		else if 55< age <=64 then age_group = 8;
        else if 65< age <=74 then age_group = 9;
        else if 75< age <=84 then age_group = 10;
        else if age > 85 then age_group = 11;
		else age_group = .;

run;

proc summary data=deaths;
class age_group geo2010;
var deaths_total 
;
	output	out=death_age_tract2010	sum= ;
run;
proc sort data= death_age_tract2010;
by geo2010;
run;

proc transpose data=death_age_tract2010 out=death_age_tract2010_new prefix=total_age_group_;
var age_group; 
by geo2010;
id age_group;
run;

** Repeat for census population data as denominator  **;
data population (where=(geo2010 ne ''));
keep geo2010 agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5 agegroup_6 agegroup_7 agegroup_8 agegroup_9 agegroup_10 agegroup_11 ;
	set census.Census_sf1_2010_dc_ph;
        agegroup_1= sum (pct12i107,pct12i3);
		agegroup_2= sum(pct12i108,pct12i109,pct12i110, pct12i111,pct12i4,pct12i5, pct12i6,pct12i7 );
		agegroup_3= sum(pct13i28, pct13i29,pct13i4,pct13i5  );
		agegroup_4= sum(pct13i30, pct13i31,pct13i32, pct13i33, pct13i6, pct13i7, pct13i8, pct13i9, pct13i10);
		agegroup_5= sum(pct13i11,pct13i12);
		agegroup_6= sum(pct13i13, pct13i14);
		agegroup_7= sum(pct13i15, pct13i16);
		agegroup_8 = sum(pct13i17, pct13i18, pct13i19);
		agegroup_9= sum(pct13i20, pct13i21, pct13i22, pct13i44, pct13i45, pct13i46);
        agegroup_10= sum(pct13i23, pct13i24, pct13i47, pct13i48);
		agegroup_11= sum(pct13i25, pct13i49);

;
	 label agegroup_1="under 1 year old";
	     label  agegroup_2= "1 - 4 Years";
        label   agegroup_3= "5 - 14 Years";
       label    agegroup_4= "15 - 24 Years";
       label    agegroup_5= "25 - 34 Years";
	  label     agegroup_6= "35 - 44 Years";
	 label      agegroup_7= "45 - 54 Years";
      label     agegroup_8= "55 - 64 Years";
      label    agegroup_9= "65 - 74 Years";
    label      agegroup_10 ="75 - 84 Years";
     label     agegroup_11= "85 Years and Over";
run;

proc sort data= population;
by geo2010;
run;

data death_pop;
merge death_age_tract2010_new population;
by geo2010;
run;

%Transform_geo_data(
keep_nonmatch=n,
dat_ds_name=work.death_pop,
dat_org_geo=geo2010,
dat_count_vars= agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5 agegroup_6 agegroup_7 agegroup_8 agegroup_9 agegroup_10 agegroup_11 ,
wgt_ds_name=general.Wt_tr10_ward12,
wgt_org_geo=Geo2010,
wgt_new_geo=ward2012, 
wgt_id_vars=,
wgt_wgt_var=PopWt,
out_ds_name=pop_by_ward,
out_ds_label=%str(Population by age group from tract 2010 to ward),
calc_vars=
,
calc_vars_labels=

)

proc summary data=population;
class ward2012;
var agegroup_1: agegroup_11
;
	output	out=population_age_ward2012	sum= ;
run;

proc summary data=population;
class cluster2017;
var agegroup_1: agegroup_11
;
	output	out=population_age_cluster2017	sum= ;
run;

proc summary data=population;
class city;
var agegroup_1: agegroup_11
;
	output	out=population_age_city	sum= ;
run;


proc export data=
	outfile="&_dcdata_default_path\DMPED\Prog\neighborhood_sfcondo_afford.csv"
	dbms=csv replace;
run;
