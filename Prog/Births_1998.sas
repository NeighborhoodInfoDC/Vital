/**************************************************************************
 Program:  Births_1998.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/16/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read in 1998 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_births( infile= B98PLAN.DAT, year=1998 )

run;
