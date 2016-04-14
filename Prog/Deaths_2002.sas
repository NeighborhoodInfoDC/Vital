/**************************************************************************
 Program:  Deaths_2002.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/16/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read in 2002 death records from raw file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_deaths( infile=D02URBAN.DAT, year=2002 )

run;
