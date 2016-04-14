/**************************************************************************
 Program:  Births_2005.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   E.Guernsey
 Created:  09/26/06
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2005 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

%Read_births( infile=bth05.DAT, year=2005 )

run;

