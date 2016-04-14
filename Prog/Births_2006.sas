/**************************************************************************
 Program:  Births_2006.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   E.Guernsey
 Created:  09/24/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2005 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

options mprint symbolgen mlogic;

%Read_births( infile=bth06.DAT, year=2006 )

run;

