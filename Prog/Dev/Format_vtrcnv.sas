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
 
 NB:  Excel workbook must be open before running program:
      D:\DCData\Libraries\Vital\Raw\Tract_list.xls

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%let lastrow = 261;

filename inf_xls dde "excel|D:\DCData\Libraries\Vital\Raw\[Tract_list.xls]Tract_list!r2c1:r&lastrow.c3" lrecl=256 notab;

data vtrcnv;

  infile inf_xls stopover dsd dlm='09'x;
  
  length tract $ 11 dc_tract $ 3;
  
  input tract fed_tract dc_tract_num;
  
  if missing( dc_tract_num ) then delete;
  
  dc_tract = put( dc_tract_num, z3. );
  
run;

*proc print;

%Data_to_format(
  FmtLib=work,
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


/********** OLD METHOD FROM NOAH ***************

proc transpose data=General.Geo1980 out=tract80 prefix=tr;
  var Geo1980;
run;

data vtrcnv;

set Vital.List_of_tracts;
if _n_=1 then set tract80;
array trct{*} tr1-tr183;
if dctract in ('011','012','11','12') then  Geo1980='11001000100';
else if dctract in ('053','054','53','54') then Geo1980='11001000501';
else if dctract in ('623','624') then   Geo1980='11001006202';
else if dctract in ('753','754') then   Geo1980='11001007502';
else if dctract in ('771','772') then   Geo1980='11001007709';
else if dctract in ('833','834') then   Geo1980='11001008301';
else if dctract in ('835','836') then   Geo1980='11001008302';
else if dctract in ('843','844') then   Geo1980='11001008401';
else if dctract in ('861','862') then   Geo1980='11001008600';
else if dctract in ('948','949') then   Geo1980='11001009508';
else if dctract in ('954','956') then   Geo1980='11001009501';
else do;

do _i_=1 to dim(trct);
if (substr(dctract,1,2)=substr(trct{_i_},8,2)) and
((substr(dctract,3,1)=substr(trct{_i_},10,1))or (substr(dctract,3,1)=substr(trct{_i_},11,1)))
then do;
Geo1980=trct{_i_};
end;
end;
end;

keep tract dctract Geo1980;

run;

proc print;

run;

***************************************************************************/
