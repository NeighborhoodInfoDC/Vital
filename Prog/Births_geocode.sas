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
  debug=n,
  streetalt_file = &_dcdata_default_path\Vital\Prog\StreetAlt_041918_new.txt,
  data = raw.B9final,
  staddr = address,
  zip = zipcode,
  out = b9geo
);

proc export data=b9geo (where=(_STATUS_='Found'))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\09_found.csv'
   dbms=csv
   replace;
run;


/** Use MAR geocoder to geocode address data **/
%DC_mar_geocode(
  debug=n,
  streetalt_file = &_dcdata_default_path\Vital\Prog\StreetAlt_041918_new.txt,
  data = raw.B0308final,
  staddr = address,
  out = b0308geo
);

proc export data=b0308geo (where=(_STATUS_='Found'))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\0308_found.csv'
   dbms=csv
   replace;
run;

/** Use MAR geocoder to geocode address data **/
%DC_mar_geocode(
  debug=n,
  streetalt_file = &_dcdata_default_path\Vital\Prog\StreetAlt_041918_new.txt,
  data = raw.b1016final,
  staddr = address,
  out = b1016geo
);

proc export data=b1016geo (where=(_STATUS_='Found'))
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\1016_found.csv'
   dbms=csv
   replace;
run;

proc sort data=Mar.Address_points_2017_08 out=Mar_streetnames nodupkey;
  where address_type = 'A' and fulladdress ~= '';
  by stname;
run;

proc export data=Mar_streetnames
   outfile='L:\Libraries\Vital\Raw\2018\geocoded\mar street names.csv'
   dbms=csv
   replace;
run;


/* Import ArcMap shapefile with parcel polygons */
/*can't find physical path?
proc mapimport out=Occ.Newboundary_map
  datafile="D:\DCData\Libraries\Vital\Maps\CURRENT\School_Attendance_Zones_Elementary";
run;
*/

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
