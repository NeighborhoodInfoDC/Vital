/**************************************************************************
 Program:  Premature death_YPLL.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Yipeng Su
 Created:  9/11/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  calculate YPLL

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

     YPLL = 75-age;


run;

proc summary data=deaths;
class age_group geo2010;
var YPLL 
;
	output	out=YPLL_tract2010	sum= ;
run;
proc sort data= YPLL_tract2010;
by geo2010;
run;

proc transpose data=YPLL_tract2010 out=YPLL_tract2010_new prefix = YPLL_age_group_;
var YPLL; 
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

data YPLL_pop;
merge YPLL_tract2010_new population;
by geo2010;
run;

%Transform_geo_data(
keep_nonmatch=n,
dat_ds_name=work.YPLL_pop,
dat_org_geo=geo2010,
dat_count_vars= agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5 agegroup_6 agegroup_7 agegroup_8 agegroup_9 agegroup_10 agegroup_11 YPLL_age_group_1 YPLL_age_group_2 YPLL_age_group_3 YPLL_age_group_4 YPLL_age_group_5 YPLL_age_group_6 YPLL_age_group_7 YPLL_age_group_8 YPLL_age_group_9 YPLL_age_group_10 YPLL_age_group_11 ,
wgt_ds_name=general.Wt_tr10_ward12,
wgt_org_geo=Geo2010,
wgt_new_geo=ward2012, 
wgt_id_vars=,
wgt_wgt_var=PopWt,
out_ds_name=YPLL_by_ward,
out_ds_label=%str(Population by age group from tract 2010 to ward),
calc_vars= 
,
calc_vars_labels=

)

%Transform_geo_data(
keep_nonmatch=n,
dat_ds_name=work.YPLL_pop,
dat_org_geo=geo2010,
dat_count_vars= agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5 agegroup_6 agegroup_7 agegroup_8 agegroup_9 agegroup_10 agegroup_11 YPLL_age_group_1 YPLL_age_group_2 YPLL_age_group_3 YPLL_age_group_4 YPLL_age_group_5 YPLL_age_group_6 YPLL_age_group_7 YPLL_age_group_8 YPLL_age_group_9 YPLL_age_group_10 YPLL_age_group_11 ,
wgt_ds_name=general.Wt_tr10_cl17,
wgt_org_geo=Geo2010,
wgt_new_geo=cluster2017, 
wgt_id_vars=,
wgt_wgt_var=PopWt,
out_ds_name=YPLL_by_cluster,
out_ds_label=%str(Population by age group from tract 2010 to ward),
calc_vars= 
,
calc_vars_labels=

)

%Transform_geo_data(
keep_nonmatch=n,
dat_ds_name=work.YPLL_pop,
dat_org_geo=geo2010,
dat_count_vars= agegroup_1 agegroup_2 agegroup_3 agegroup_4 agegroup_5 agegroup_6 agegroup_7 agegroup_8 agegroup_9 agegroup_10 agegroup_11 YPLL_age_group_1 YPLL_age_group_2 YPLL_age_group_3 YPLL_age_group_4 YPLL_age_group_5 YPLL_age_group_6 YPLL_age_group_7 YPLL_age_group_8 YPLL_age_group_9 YPLL_age_group_10 YPLL_age_group_11 ,
wgt_ds_name=general.Wt_tr10_city,
wgt_org_geo=Geo2010,
wgt_new_geo=city, 
wgt_id_vars=,
wgt_wgt_var=PopWt,
out_ds_name=YPLL_by_city,
out_ds_label=%str(Population by age group from tract 2010 to ward),
calc_vars= 
,
calc_vars_labels=

)

/*Calculate weighted average of YPLL using DC population composition*/

data directweight_ward;
set YPLL_by_ward;
length indicator $80;
keep indicator year ward2012 numerator denom equityvariable;
indicator = "Weigted average mortality rate";
year = "2016";
denom= sum(agegroup_1, agegroup_2, agegroup_3, agegroup_4, agegroup_5, agegroup_6, agegroup_7, agegroup_8, agegroup_9, agegroup_10, agegroup_11);
numerator= sum(YPLL_age_group_1, YPLL_age_group_2, YPLL_age_group_3, YPLL_age_group_4, YPLL_age_group_5, YPLL_age_group_6, YPLL_age_group_7, YPLL_age_group_8, YPLL_age_group_9, YPLL_age_group_10, YPLL_age_group_11);
equityvariable= numerator/denom;
geo=Ward2012;
format geo $Ward12a.;
run;

data directweight_cluster17;
set YPLL_by_cluster;
length indicator $80;
keep indicator year cluster2017 numerator denom equityvariable;
indicator = "Weigted average mortality rate";
year = "2016";
denom= sum(agegroup_1, agegroup_2, agegroup_3, agegroup_4, agegroup_5, agegroup_6, agegroup_7, agegroup_8, agegroup_9, agegroup_10, agegroup_11);
numerator= sum(YPLL_age_group_1, YPLL_age_group_2, YPLL_age_group_3, YPLL_age_group_4, YPLL_age_group_5, YPLL_age_group_6, YPLL_age_group_7, YPLL_age_group_8, YPLL_age_group_9, YPLL_age_group_10, YPLL_age_group_11);
equityvariable= numerator/denom;
geo=cluster2017;
format cluster2017 $clus17f.;
run;

data directweight_city;
set YPLL_by_city;
length indicator $80;
keep indicator year city numerator denom equityvariable;
indicator = "Weigted average mortality rate";
year = "2016";
denom= sum(agegroup_1, agegroup_2, agegroup_3, agegroup_4, agegroup_5, agegroup_6, agegroup_7, agegroup_8, agegroup_9, agegroup_10, agegroup_11);
numerator= sum(YPLL_age_group_1, YPLL_age_group_2, YPLL_age_group_3, YPLL_age_group_4, YPLL_age_group_5, YPLL_age_group_6, YPLL_age_group_7, YPLL_age_group_8, YPLL_age_group_9, YPLL_age_group_10, YPLL_age_group_11);
equityvariable= numerator/denom;
geo=city;
format geo $city. ;
run;

proc export data=directweight_cluster17
	outfile="&_dcdata_default_path.\Equity\Prog\JPMC feature\YPLL_AW_cl17.csv"
	dbms=csv replace;
run;

proc export data=directweight_city
	outfile="&_dcdata_default_path.\Equity\Prog\JPMC feature\YPLL_AW_city.csv"
	dbms=csv replace;
run;

proc export data=directweight_ward
	outfile="&_dcdata_default_path.\Equity\Prog\JPMC feature\YPLL_AW_ward.csv"
	dbms=csv replace;
run;


/*age adjusted weights using standard weights*/

