/**************************************************************************
 Program:  Deaths_2004.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/17/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read in 2004 death records from raw file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

%Read_deaths( infile=DTH04.dat, year=2004,
  corrections=
    if Recordno = 2703 and xBmonth = '02' and xBday = '29' and xByear = '02' then xBday = '28';
    if Recordno = 3433 and xBmonth = '05' and xBday = '34' and xByear = '70' then xBday = '31';
)

run;

/*
data Vital.Infant_deaths_2004;
  set Vital.Deaths_2004;
  where Deaths_infant = 1;
run;

proc print data=Vital.Infant_Deaths_2004 noobs n='Total = ';
  id RecordNo;
  var birth_dt death_dt age_calc age age_unit Icd10_4d;
  format Icd10_4d $4.;
  title2 'Infant Deaths, 2004';
run;

