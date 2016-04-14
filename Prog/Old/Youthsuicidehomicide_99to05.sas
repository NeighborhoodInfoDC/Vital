


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

/*suicides and homicides 12-17*/

rsubmit;

data youth12to17sh99;/* creates a file on the alpha - temp */
set vital.deaths_1999 (keep=year deaths_suicide deaths_homicide age_calc);
where 12<=age_calc<=17;

proc download inlib=work outlib=requests; /* download to PC */
select youth12to17sh99;

run;

endrsubmit;
rsubmit;

data youth12to17sh00;/* creates a file on the alpha - temp */
set vital.deaths_2000 (keep=year deaths_suicide deaths_homicide age_calc);
where 12<=age_calc<=17;

proc download inlib=work outlib=requests; /* download to PC */
select youth12to17sh00;

run;
endrsubmit;

rsubmit;
data youth12to17sh01;/* creates a file on the alpha - temp */
set vital.Deaths_2001 (keep=year deaths_suicide deaths_homicide age_calc);
where 12<=age_calc<=17;

proc download inlib=work outlib=requests; /* download to PC */
select youth12to17sh01;

run;
endrsubmit;

rsubmit;
data youth12to17sh02;/* creates a file on the alpha - temp */
set vital.deaths_2002 (keep=year deaths_suicide deaths_homicide age_calc);
where 12<=age_calc<=17;

proc download inlib=work outlib=requests; /* download to PC */
select youth12to17sh02;

run;
endrsubmit;

rsubmit;
data youth12to17sh03;/* creates a file on the alpha - temp */
set vital.deaths_2003 (keep=year deaths_suicide deaths_homicide age_calc);
where 12<=age_calc<=17;

proc download inlib=work outlib=requests; /* download to PC */
select youth12to17sh03;

run;
endrsubmit;

rsubmit;
data youth12to17sh04;/* creates a file on the alpha - temp */
set vital.deaths_2004 (keep=year deaths_suicide deaths_homicide age_calc);
where 12<=age_calc<=17;

proc download inlib=work outlib=requests; /* download to PC */
select youth12to17sh04;

run;
endrsubmit;

rsubmit;
data youth12to17sh05;/* creates a file on the alpha - temp */
set vital.deaths_2005 (keep=year deaths_suicide deaths_homicide age_calc);
where 12<=age_calc<=17;

proc download inlib=work outlib=requests; /* download to PC */
select youth12to17sh05;

run;
endrsubmit;

/*suicides and homicides 18-24*/

rsubmit;

data youth18to24sh99;/* creates a file on the alpha - temp */
set vital.deaths_1999 (keep=year deaths_suicide deaths_homicide age_calc);
where 18<=age_calc<=24;

proc download inlib=work outlib=requests; /* download to PC */
select youth18to24sh99;

run;

endrsubmit;

rsubmit;

data youth18to24sh00;/* creates a file on the alpha - temp */
set vital.deaths_2000 (keep=year deaths_suicide deaths_homicide age_calc);
where 18<=age_calc<=24;

proc download inlib=work outlib=requests; /* download to PC */
select youth18to24sh00;

run;

endrsubmit;

rsubmit;

data youth18to24sh01;/* creates a file on the alpha - temp */
set vital.deaths_2001 (keep=year deaths_suicide deaths_homicide age_calc);
where 18<=age_calc<=24;

proc download inlib=work outlib=requests; /* download to PC */
select youth18to24sh01;

run;

endrsubmit;

rsubmit;

data youth18to24sh02;/* creates a file on the alpha - temp */
set vital.deaths_2002 (keep=year deaths_suicide deaths_homicide age_calc);
where 18<=age_calc<=24;

proc download inlib=work outlib=requests; /* download to PC */
select youth18to24sh02;

run;

endrsubmit;

rsubmit;

data youth18to24sh03;/* creates a file on the alpha - temp */
set vital.deaths_2003 (keep=year deaths_suicide deaths_homicide age_calc);
where 18<=age_calc<=24;

proc download inlib=work outlib=requests; /* download to PC */
select youth18to24sh03;

run;

endrsubmit;

rsubmit;

data youth18to24sh04;/* creates a file on the alpha - temp */
set vital.deaths_2004 (keep=year deaths_suicide deaths_homicide age_calc);
where 18<=age_calc<=24;

proc download inlib=work outlib=requests; /* download to PC */
select youth18to24sh04;

run;

endrsubmit;

rsubmit;

data youth18to24sh05;/* creates a file on the alpha - temp */
set vital.deaths_2005 (keep=year deaths_suicide deaths_homicide age_calc);
where 18<=age_calc<=24;

proc download inlib=work outlib=requests; /* download to PC */
select youth18to24sh05;

run;

endrsubmit;


proc sort data=requests.youth12to17sh99;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth12to17sh00;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth12to17sh01;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth12to17sh02;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth12to17sh03;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth12to17sh04;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth12to17sh05;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth18to24sh99;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth18to24sh00;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth18to24sh01;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth18to24sh02;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth18to24sh03;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth18to24sh04;
by year age_calc deaths_homicide deaths_suicide;
run;

proc sort data=requests.youth18to24sh05;
by year age_calc deaths_homicide deaths_suicide;
run;

/*merge 12 to 17 youth suicides and homicides for 1999 to 2005*/
data all12to17youth_sh; 
merge requests.youth12to17sh99 requests.youth12to17sh00 requests.youth12to17sh01 requests.youth12to17sh02 requests.youth12to17sh03 requests.youth12to17sh04 requests.youth12to17sh05;
by year age_calc deaths_homicide deaths_suicide;
run;

/*merge 18 to 24 youth suicides and homicides for 1999 to 2005*/

data all18to24youth_sh; 
merge requests.youth18to24sh99 requests.youth18to24sh00 requests.youth18to24sh01 requests.youth18to24sh02 requests.youth18to24sh03 requests.youth18to24sh04 requests.youth18to24sh05;
by year age_calc deaths_homicide deaths_suicide;
run;

**********Export table youth suicides and homicides 1999-2005*******************;

filename fexport "D:\DCData\Libraries\Requests\Doc\all12to17suicidehomicide.csv" lrecl=2000;

proc export data=all12to17youth_sh
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

filename fexport "D:\DCData\Libraries\Requests\Doc\all18to24suicidehomicide.csv" lrecl=2000;

proc export data=all18to24youth_sh
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;

