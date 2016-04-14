/**************************************************************************
 Program:  Births_2010.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Brianna Losoya
 Created:  12/16/12
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2010 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )
options mprint nosymbolgen nomlogic;
%Read_births( infile=Birth_2010, year= 2010 )

run;

proc format;
  value zero
   low -< 0 = '<0'
   0 = '0'
   0 <- high = '>0';

proc freq data=vital.births_2010;
  tables num_visit * DOFP_Date * DOLP_Date / nocum missing list;
  format DOFP_Date DOLP_Date num_visit zero.;
run;


