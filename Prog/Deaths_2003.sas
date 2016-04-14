/**************************************************************************
 Program:  Deaths_2003.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/16/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read in 2003 death records from raw file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_deaths( infile=DTH03.dat, year=2003,
  corrections=
    if Recordno = 3420 and xBmonth = '03' and xBday = '10' and xByear = '03' then xBday = '03';
)

run;
