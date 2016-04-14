/**************************************************************************
 Program:  Tract_list.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/14/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create list of census tracts as basis for tract code
 remappings.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )
%DCData_lib( General )

data Tracts;

  merge
    General.Geo1980 (keep=geo1980 rename=(geo1980=tract))
    General.Geo1990 (keep=geo1990 rename=(geo1990=tract));
  by tract;
  
  format tract;
  
  fed_tract = input( substr( tract, 6, 6 ), 6.2 );
  
  format fed_tract 7.2;
  
  dc_tract_a = int( fed_tract );

  dc_tract_b = 100 * ( fed_tract - dc_tract_a );
  
  if 0 <= dc_tract_b <= 9 then 
    dc_tract = put( dc_tract_a, z2. ) || put( dc_tract_b, z1. );
  else 
    dc_tract = put( dc_tract_a, z2. ) || "*";

  keep tract fed_tract dc_tract;

run;

filename fexport "D:\DCData\Libraries\Vital\Raw\Tract_list.csv" lrecl=256;

proc export data=Tracts
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;

