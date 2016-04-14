/**************************************************************************
 Program:  List_of_tracts.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/05/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Compile list of census tracts to create format.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

proc sort data=Vital.Births_2003 (keep=dctract tract) out=Vital.List_of_tracts nodupkey;
  by dctract;

run;
