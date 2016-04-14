/**************************************************************************
 Program:  Births_2004.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/26/06
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2004 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

%Read_births( infile=bth04.DAT, year=2004 )

run;

