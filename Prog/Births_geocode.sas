/**************************************************************************
 Program:  Births_geocode
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Yipeng and Rob
 Created:  4/18/2018
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( Vital )
%DCData_lib( Mar )
libname raw "L:\Libraries\Vital\Raw\2018";


/** Use MAR geocoder to geocode address data **/
%DC_mar_geocode(
  data = raw.B9final,
  staddr = address,
  zip = zipcode,
  out = b9geo
  streetalt_file = D:\DCData\Libraries\Vital\Prog\StreetAlt.txt,
);

/** Use MAR geocoder to geocode address data **/
%DC_mar_geocode(
  data = raw.B0308final,
  staddr = address,
  out = b0308geo
);

/** Use MAR geocoder to geocode address data **/
%DC_mar_geocode(
  data = raw.b1016final,
  staddr = address,
  out = b1016geo
);


/*export the geocoded file to excel for Arcgis

proc export data=b9geo (where=(_STATUS_=''))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\09_notfound.csv'
   dbms=csv
   replace;
run;

proc export data=b9geo (where=(_STATUS_='Found'))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\09_found.csv'
   dbms=csv
   replace;
run;

proc export data=B0308final (where=(_STATUS_=''))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\0308_notfound.csv'
   dbms=csv
   replace;
run;

proc export data=B0308final (where=(_STATUS_='Found'))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\0308_found.csv'
   dbms=csv
   replace;
run;

proc export data=b1016final (where=(_STATUS_=''))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\1016_notfound.csv'
   dbms=csv
   replace;
run;
proc export data=b1016final (where=(_STATUS_='Found'))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\1016_found.csv'
   dbms=csv
   replace;
run;
*/
