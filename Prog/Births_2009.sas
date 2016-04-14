/**************************************************************************
 Program:  Births_2009.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Brianna Losoya
 Created:  12/16/12
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2009 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

%Read_births( infile=Birth_2009, year= 2009 )

** Check values of Num_visit, DOFP_Date, and DOLP_Date **;

proc format;
  value zero
   low -< 0 = '<0'
   0 = '0'
   0 <- high = '>0';

proc freq data=vital.births_2009;
  tables num_visit * DOFP_Date * DOLP_Date / nocum missing list;
  format DOFP_Date DOLP_Date num_visit zero.;
run;



run;

