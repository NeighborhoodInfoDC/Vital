/**************************************************************************
 Program:  Births_2008.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  08/16/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2008 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

%Read_births( infile=B08URBAN_60611, year= 2008 )

run;

