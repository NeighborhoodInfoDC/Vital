/**************************************************************************
 Program:  fix_tracts_2008.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  08/16/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to correct bad tracts in 2008 raw data.

 Modifications:
**************************************************************************/

/** Macro fix_tracts_2008 - Start Definition **/

%macro fix_tracts_2008 ;

data vital.births_2008;
	set vital.births_2008;

	if tract_full = '11001003801' then tract_full = '11001003800' ;
	if tract_full = '11001007001' then tract_full = '11001007000' ;
	if tract_full = '11001007607' then tract_full = '11001007605' ;
	if tract_full = '11001009600' then tract_full = '11001009601' ;

run;
    
%mend fix_tracts_2008;

/** End Macro Definition **/

