/**************************************************************************
 Program:  Births_1999.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/16/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read in 1999 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_births( infile=B99DCKID.DAT, year=1999 )

run;

