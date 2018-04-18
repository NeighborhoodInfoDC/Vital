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
  data = raw.B0308final,
  staddr = address,
  out = b0308geo
);


/** Use MAR geocoder to geocode address data **/
%DC_mar_geocode(
  data = raw.b9final,
  staddr = address,
  zip = zipcode,
  out = b9geo
);


/** Use MAR geocoder to geocode address data **/
%DC_mar_geocode(
  data = raw.b1016final,
  staddr = address,
  out = b1016geo
);
