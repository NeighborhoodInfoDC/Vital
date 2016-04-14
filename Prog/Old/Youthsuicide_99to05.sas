


     /**************************************************************************
 Program:  DCData\Requests\Prog\2008\youthsuicides.sas
 Library:  DCData\Libraries\Requests
 Project:  NeighborhoodInfo DC
 Author:   Shelby Kain
 Created:  November 14, 2008
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect

 Description: Number of suicides and homicides for youth ages 12-17 and 18-24 for 1999-2005

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( vital )
%DCData_lib( requests );

rsubmit;

data causesofdeath99;/* creates a file on the alpha - temp */
set vital.deaths_1999 (keep=year icd10_3d age_calc);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath99;

run;


rsubmit;

data causesofdeath00;/* creates a file on the alpha - temp */
set vital.deaths_2000 (keep=year icd10_3d age_calc);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath00;

run;


rsubmit;
data causesofdeath01;/* creates a file on the alpha - temp */
set vital.Deaths_2001 (keep=year icd10_3d age_calc);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath01;

run;

rsubmit;
data causesofdeath02;/* creates a file on the alpha - temp */
set vital.deaths_2002 (keep=year icd10_3d age_calc);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath02;

run;


rsubmit;
data causesofdeath03;/* creates a file on the alpha - temp */
set vital.deaths_2003 (keep=year icd10_3d age_calc);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath03;

run;


rsubmit;
data causesofdeath04;/* creates a file on the alpha - temp */
set vital.deaths_2004 (keep=year icd10_3d age_calc);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath04;

run;


rsubmit;
data causesofdeath05;/* creates a file on the alpha - temp */
set vital.deaths_2005 (keep=year icd10_3d age_calc);

proc download inlib=work outlib=requests; /* download to PC */
select causesofdeath05;

run;
endrsubmit;

*want to see frequency of causes of death;
proc freq data=requests.causesofdeath99;
 table Icd10_3d;
run;
proc sort data=requests.causesofdeath99;
by year Icd10_3d age_calc;
run;

proc summary data=requests.causesofdeath99;
by year Icd10_3d age_calc;
output out=youthsuicides99;
run;

proc sort data=requests.causesofdeath00;
by year Icd10_3d age_calc;
run;
proc summary data=requests.causesofdeath00;
by year Icd10_3d age_calc;
output out=youthsuicides00;
run;

proc sort data=requests.causesofdeath01;
by year Icd10_3d age_calc;
run;
proc summary data=requests.causesofdeath01;
by year Icd10_3d age_calc;
output out=youthsuicides01;
run;

proc sort data=requests.causesofdeath02;
by year Icd10_3d age_calc;
run;
proc summary data=requests.causesofdeath02;
by year Icd10_3d age_calc;
output out=youthsuicides02;
run;

proc sort data=requests.causesofdeath03;
by year Icd10_3d age_calc;
run;
proc summary data=requests.causesofdeath03;
by year Icd10_3d age_calc;
output out=youthsuicides03;
run;

proc sort data=requests.causesofdeath04;
by year Icd10_3d age_calc;
run;
proc summary data=requests.causesofdeath04;
by year Icd10_3d age_calc;
output out=youthsuicides04;
run;

proc sort data=requests.causesofdeath05;
by year Icd10_3d age_calc;
run;
proc summary data=requests.causesofdeath05;
by year Icd10_3d age_calc;
output out=youthsuicides05;
run;

*merge youth suicides for 1999 to 2005;
data allyouthsuicide; 
merge youthsuicides99 youthsuicides00 youthsuicides01 youthsuicides02 youthsuicides03 youthsuicides04 youthsuicides05;
by year Icd10_3d age_calc;
run;

**********Export table youth suicides 1999-2005*******************;

filename fexport "D:\DCData\Libraries\Requests\Raw\youth_suicide.csv" lrecl=2000;

proc export data=allyouthsuicide
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;

