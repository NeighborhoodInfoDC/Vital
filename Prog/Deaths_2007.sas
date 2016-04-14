/**************************************************************************
 Program:  Deaths_2006.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian and E. Guernsey
 Created:  4/8/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2006 death records from raw file.

 Modifications:
 Note: Latino Detailed origin should be modified once new formats from Virginia known
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_deaths( infile=d07urban.dat, year=2007)

run;



