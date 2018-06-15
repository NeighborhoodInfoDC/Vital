/**************************************************************************
 Program:  Make_formats.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/10/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create formats for vital statistics birth & death data.

 Modifications:
  10/30/06  Corrected $ageunit (added '0').
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( VITAL )

proc format library=VITAL;

value $yesno (notsorted)
  'Y' = 'Yes'
  'N' = 'No'
  ' ' = 'Unknown';

value yesno (notsorted) 
  1 = 'Yes'
  0 = 'No'
  .u = 'Unknown';

value $MMar
'N'='Unmarried' 
'Y'='Married';

value $racecod
'0'='Other race'
'1'='White'
'2'='Black'
'3'='American Indian'
'4'='Chinese'
'5'='Japanese'
'6'='Hawaiian'
'7'='Philippino'
'8'='Other Asian/Pacific Islander'
'9', ' '='Race unknown';

value hispD
  0 = 'Non-Hispanic'
  1 = 'Mexican'
  2 = 'Puerto Rican'
  3 = 'Cuban'	
  4 = 'Salvadorian'
  5 = 'Nicaraguan'
  6 = 'Other Central & South American'
  7 = 'Other Hispanic origin'
  .u = 'Hispanic origin unknown';

value sexD
1='Male'
2='Female';

value precare (notsorted)
  1 = 'Adequate'
  2 = 'Intermediate'
  3 = 'Inadequate'
  .u = 'Unknown';
  
value $ageunit
  '0'='100+ years'
  '1'='Years' '2'='Months' '3'='Days' '4'='Hours' '5'='Minutes';
  
  value $yn12f (notsorted)
  '1' = 'Yes'
  '2' = 'No'
  '9' = 'Unknown';

value $race09f (notsorted)
'1'='White'
'2'='Black'
'3'='American Indian'
'4'='Asian'
'0'='Other race'
'9', ' '='Race unknown';


run; 

proc catalog catalog=Vital.formats;
  modify precare (desc="Prenatal care quality") / entrytype=format;
  modify ageunit (desc="Unit of time for age") / entrytype=formatc;
  modify hispd (desc="Hispanic origin, detailed") / entrytype=format;
  modify yn12f (desc="1=Yes/2=No") / entrytype=formatc;
  modify race09f (desc="Mother 's race (2009)") / entrytype=formatc;

  contents;

quit;

