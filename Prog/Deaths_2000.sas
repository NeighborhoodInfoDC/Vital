/**************************************************************************
 Program:  Deaths_2000.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/22/06
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2000 death records from raw file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_deaths( infile=D00DCKID.DAT, year=2000,
  corrections=
    if xByear='37' and xBday='29' and xBmonth='02' then xBday='28';
    if xByear='59' and xBday='29' and xBmonth='02' then xBday='28';
    if xByear='06' and xBday='29' and xBmonth='02' then xBday='28';
    if RecordNo=1724 and Age_unit='-' then Age_unit='1';
)

run;
