/**************************************************************************
 Program:  Births_2009_test.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Brianna Losoya
 Created:  12/16/12
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2009 birth records from raw data file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

data Test;

  set Vital.Births_2009;

  %Fedtractno_geo2000

run;

proc print data=Test;
  where geo2000 = '' and fedtractno > 0;
  var FEDTRACTNO /*geo2000 tract_full tract_yr tract_alloc ward*/;
run;

proc freq data=Test;
  tables ward;
run;
