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

proc mapimport out=Oldboudnary_map
  datafile="D:\DCData\Libraries\Vital\Maps\OLD\School_Attendance_Zones_Elementary__Old.shp";  
run;

proc sort data=Oldboudnary_map; by OBJECTID_1;
run;

goptions reset=global border;

proc ginside includeborder
  data=b9geo
  map=Oldboudnary_map
  out=Oldboudnary_map_join;
  id OBJECTID_1;
run;

proc freq data = Oldboudnary_map_join;
	tables OBJECTID_1;
run;


goptions reset=global border;

proc ginside includeborder
  data=b0308geo
  map=Oldboudnary_map
  out=Oldboudnary_map_join;
  id OBJECTID_1;
run;

proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2003'));
	tables OBJECTID_1 ;
run;

proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2004'));
	tables OBJECTID_1 ;
run;

proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2005'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2006'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2007'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2008'));
	tables OBJECTID_1 ;
run;
goptions reset=global border;

proc ginside includeborder
  data=b1016geo
  map=Oldboudnary_map
  out=Oldboudnary_map_join;
  id OBJECTID_1;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2010'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2011'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2012'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2013'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2014'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2015'));
	tables OBJECTID_1 ;
run;
proc freq data = Oldboudnary_map_join (where=(BIRTHYR='2016'));
	tables OBJECTID_1 ;
run;
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
