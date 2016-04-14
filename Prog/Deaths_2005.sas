/**************************************************************************
 Program:  Deaths_2005.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian and E. Guernsey
 Created:  4/8/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2004 death records from raw file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_deaths( infile=dth05.dat, year=2005)

run;


