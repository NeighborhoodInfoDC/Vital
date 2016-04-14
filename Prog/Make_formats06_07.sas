/**************************************************************************
 Program:  Make_formats06_07.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/10/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create formats for vital statistics birth & death data.
			   Updated for 2007 birth data and 2006 death data
 Modifications:
  10/30/06  Corrected $ageunit (added '0').
  09/17/09  Updated for 2007 birth data and 2006 death data
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

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

value $MMarrd
'2'='Unmarried' 
'1'='Married';

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
  
run; 

proc catalog catalog=Vital.formats;
  modify precare (desc="Prenatal care quality") / entrytype=format;
  modify ageunit (desc="Unit of time for age") / entrytype=formatc;
  modify hispd (desc="Hispanic origin, detailed") / entrytype=format;
  contents;

quit;

