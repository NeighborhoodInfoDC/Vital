


     /**************************************************************************
 Program:  DCData\Libraries\Vital\prog\Child_trends_data.sas
 Library:  DCData\Libraries\Vital
 Project:  Child Trends 
 Author:   Shelby Kain
 Created:  April 13, 2009
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect

 Description: Child trends birth, death, and TANF data requests by ward and zip.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( vital )
%DCDATA_lib ( Tanf )

****Single mothers, Teen births, Low weight, Adequate prenatal care births for 2002 to 2006 by ward and zip****;

rsubmit;

data births_ct_zip;/* creates a file on the alpha - temp */
set vital.births_sum_zip (keep=zip births_total_2002 births_total_2003 births_total_2004 births_total_2005 births_total_2006
births_single_2002 births_single_2003 births_single_2004 births_single_2005 births_single_2006 births_teen_2002 births_teen_2003 births_teen_2004 births_teen_2005 births_teen_2006
births_low_wt_2002 births_low_wt_2003 births_low_wt_2004 births_low_wt_2005 births_low_wt_2006
births_prenat_adeq_2002 births_prenat_adeq_2003 births_prenat_adeq_2004 births_prenat_adeq_2005 births_prenat_adeq_2006
births_w_prenat_2002 births_w_prenat_2003 births_w_prenat_2004 births_w_prenat_2005 births_w_prenat_2006);

proc download inlib=work outlib=vital; /* download to PC */
select births_ct_zip;

run;
endrsubmit;

rsubmit;
data births_ct_ward;/* creates a file on the alpha - temp */
set vital.births_sum_wd02 (keep=ward2002 births_total_2002 births_total_2003 births_total_2004 births_total_2005 births_total_2006
births_single_2002 births_single_2003 births_single_2004 births_single_2005 births_single_2006 births_teen_2002 births_teen_2003 births_teen_2004 births_teen_2005 births_teen_2006
births_low_wt_2002 births_low_wt_2003 births_low_wt_2004 births_low_wt_2005 births_low_wt_2006
births_prenat_adeq_2002 births_prenat_adeq_2003 births_prenat_adeq_2004 births_prenat_adeq_2005 births_prenat_adeq_2006
births_w_prenat_2002 births_w_prenat_2003 births_w_prenat_2004 births_w_prenat_2005 births_w_prenat_2006);

proc download inlib=work outlib=vital; /* download to PC */
select births_ct_ward;

run;
endrsubmit;

****Infant mortality****;
rsubmit;
data births_total_zip; /*creates a fileon the alpha - temp*/
set vital.births_sum_zip (keep=zip births_total_2000 births_total_2001 births_total_2002 births_total_2003 births_total_2004 births_total_2005);
proc download inlib=work outlib=vital;/* download to pc*/
select births_total_zip;
run;


data deaths_infant_zip;/* creates a file on the alpha - temp */
set vital.deaths_sum_zip (keep=zip deaths_infant_2000 deaths_infant_2001 deaths_infant_2002 deaths_infant_2003 deaths_infant_2004 deaths_infant_2005); 
proc download inlib=work outlib=vital; /* download to PC */
select deaths_infant_zip;
run;

*merge total births with infant mortality to calculate rate for 2000 to 2005 by zip;
data vital.deaths_infantmortality_zip; 
merge vital.births_total_zip vital.deaths_infant_zip;
by zip;
run;

rsubmit;
data births_total_ward; /*creates a fileon the alpha - temp*/
set vital.births_sum_wd02 (keep=ward2002 births_total_2000 births_total_2001 births_total_2002 births_total_2003 births_total_2004 births_total_2005);
proc download inlib=work outlib=vital;/* download to pc*/
select births_total_ward;
run;


data deaths_infant_ward;/* creates a file on the alpha - temp */
set vital.deaths_sum_wd02 (keep=ward2002 deaths_infant_2000 deaths_infant_2001 deaths_infant_2002 deaths_infant_2003 deaths_infant_2004 deaths_infant_2005); 
proc download inlib=work outlib=vital; /* download to PC */
select deaths_infant_ward;
run;

*merge total births with infant mortality to calculate rate for 2000 to 2005 by ward;
data vital.deaths_infantmortality_ward; 
merge vital.births_total_ward vital.deaths_infant_ward;
by ward2002;
run;


****Deaths to children ages 1-5 for 2000 to 2005 by ward****;
rsubmit;

data deaths_child_00;/* creates a file on the alpha - temp */
set vital.deaths_2000 (keep=year ward age_calc);
where 1<=age_calc<6;

proc download inlib=work outlib=vital; /* download to PC */
select deaths_child_00;
run;
endrsubmit;

rsubmit;

data deaths_child_01;/* creates a file on the alpha - temp */
set vital.deaths_2001 (keep=year ward age_calc);
where 1<=age_calc<6;

proc download inlib=work outlib=vital; /* download to PC */
select deaths_child_01;
run;
endrsubmit;

rsubmit;

data deaths_child_02;/* creates a file on the alpha - temp */
set vital.deaths_2002 (keep=year ward age_calc);
where 1<=age_calc<6;

proc download inlib=work outlib=vital; /* download to PC */
select deaths_child_02;
run;
endrsubmit;

rsubmit;

data deaths_child_03;/* creates a file on the alpha - temp */
set vital.deaths_2003 (keep=year ward age_calc);
where 1<=age_calc<6;

proc download inlib=work outlib=vital; /* download to PC */
select deaths_child_03;
run;
endrsubmit;

rsubmit;

data deaths_child_04;/* creates a file on the alpha - temp */
set vital.deaths_2004 (keep=year ward age_calc);
where 1<=age_calc<6;

proc download inlib=work outlib=vital; /* download to PC */
select deaths_child_04;
run;
endrsubmit;

rsubmit;

data deaths_child_05;/* creates a file on the alpha - temp */
set vital.deaths_2005 (keep=year ward age_calc);
where 1<=age_calc<6;

proc download inlib=work outlib=vital; /* download to PC */
select deaths_child_05;
run;
endrsubmit;

*merge 2000 to 2005 deaths for children ages 1 to 5 by ward*;
data vital.deaths_child_00_05;
merge vital.deaths_child_00 vital.deaths_child_01 vital.deaths_child_02 vital.deaths_child_03 vital.deaths_child_04 vital.deaths_child_05;
by year;
run;


****Food stamp and TANF data for children 2000-2008****;

rsubmit;

data Fs_ct_zip;/* creates a file on the alpha - temp */
set Tanf.fs_sum_zip (keep=zip fs_child_2002 fs_child_2003 fs_child_2004 fs_child_2005 fs_child_2006 fs_child_2007 fs_child_2008);


proc download inlib=work outlib=vital; /* download to PC */
select Fs_ct_zip;

run;
endrsubmit;

rsubmit;
data Fs_ct_ward;/* creates a file on the alpha - temp */
set Tanf.fs_sum_wd02 (keep=ward2002 fs_child_2002 fs_child_2003 fs_child_2004 fs_child_2005 fs_child_2006 fs_child_2007 fs_child_2008);


proc download inlib=work outlib=vital; /* download to PC */
select Fs_ct_ward;

run;
endrsubmit;

rsubmit;
data Tanf_ct_zip;/* creates a file on the alpha - temp */
set Tanf.tanf_sum_zip (keep=zip tanf_child_2002 tanf_child_2003 tanf_child_2004 tanf_child_2005 tanf_child_2006 tanf_child_2007 tanf_child_2008
tanf_child_fch_2002 tanf_child_fch_2003 tanf_child_fch_2004 tanf_child_fch_2005 tanf_child_fch_2006 tanf_child_fch_2007 tanf_child_fch_2008
tanf_unborn_2002 tanf_unborn_2003 tanf_unborn_2004 tanf_unborn_2005 tanf_unborn_2006 tanf_unborn_2007 tanf_unborn_2008);


proc download inlib=work outlib=vital; /* download to PC */
select Tanf_ct_zip;

run;
endrsubmit;

rsubmit;
data Tanf_ct_ward;/* creates a file on the alpha - temp */
set Tanf.tanf_sum_wd02 (keep=ward2002 tanf_child_2002 tanf_child_2003 tanf_child_2004 tanf_child_2005 tanf_child_2006 tanf_child_2007 tanf_child_2008
tanf_child_fch_2002 tanf_child_fch_2003 tanf_child_fch_2004 tanf_child_fch_2005 tanf_child_fch_2006 tanf_child_fch_2007 tanf_child_fch_2008);


proc download inlib=work outlib=vital; /* download to PC */
select Tanf_ct_ward;

run;
endrsubmit;
**********Export tables*******************;

filename fexport "D:\DCData\Libraries\Vital\Raw\births_ct_zip2.csv" lrecl=2000;

proc export data=vital.births_ct_zip
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Vital\Raw\births_ct_ward2.csv" lrecl=2000;

proc export data=vital.births_ct_ward
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Vital\Raw\deaths_infantmortality_zip.csv" lrecl=2000;

proc export data=vital.deaths_infantmortality_zip
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Vital\Raw\deaths_infantmortality_ward.csv" lrecl=2000;

proc export data=vital.deaths_infantmortality_ward
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Vital\Raw\deaths_child_00_05_ward.csv" lrecl=2000;
proc export data=vital.deaths_child_00_05
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Vital\Raw\fs_ct_zip.csv" lrecl=2000;
proc export data=vital.fs_ct_zip
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Vital\Raw\fs_ct_ward.csv" lrecl=2000;
proc export data=vital.fs_ct_ward
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Vital\Raw\tanf_ct_zip2.csv" lrecl=2000;
proc export data=vital.tanf_ct_zip
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Vital\Raw\tanf_ct_ward.csv" lrecl=2000;
proc export data=vital.tanf_ct_ward
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;

