/**************************************************************************
 Program:  Format_vtrcnv.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/05/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create format $vtrcnv. for converting 1980/1990 3-digit 
 DC tract codes in vital stats data to standard 11-digit Census format.
 
 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital )


filename inf_xls "L:\Libraries\Vital\Raw\Tract_list.csv" lrecl=256;

data vtrcnv;

  infile inf_xls stopover dsd firstobs=3;

  length tract $ 11 dc_tract $ 3;
  
  input tract fed_tract dc_tract_num;
  
  if missing( tract ) or missing( dc_tract_num ) then delete;
  
  dc_tract = put( dc_tract_num, z3. );
  
run;


%Data_to_format(
  FmtLib=Vital,
  FmtName=$vtrcnv,
  Data=vtrcnv,
  Value=dc_tract,
  Label=tract,
  OtherLabel="",
  DefaultLen=11,
  MaxLen=.,
  MinLen=.,
  Print=Y,
  Desc="Convert 3-digit tract code to Census std",
  Contents=Y
  )

