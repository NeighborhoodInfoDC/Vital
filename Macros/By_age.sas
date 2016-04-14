/**************************************************************************
 Program:  By_age.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  08/16/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to generate summary variables by age.

 Modifications:
**************************************************************************/

/** Macro By_age - Start Definition **/

%macro By_age ( var, cat, type, var2=, pop=mothers );

  %if &var2 = %then %let var2 = &type;

  &var._0to14 = &var. * &var2._0to14;
  &var._15to19 = &var. * &var2._15to19;
  &var._20to24 = &var. * &var2._20to24;
  &var._25to29 = &var. * &var2._25to29;
  &var._30to34 = &var. * &var2._30to34;
  &var._35to39 = &var. * &var2._35to39;
  &var._40to44 = &var. * &var2._40to44;
  &var._45plus = &var. * &var2._45plus;
  
  label 
    &var._0to14 = "&type to under 15 year old &pop &cat"
    &var._15to19 = "&type to 15-19 year old &pop &cat"
    &var._20to24 = "&type to 20-24 year old &pop &cat"
    &var._25to29 = "&type to 25-29 year old &pop &cat"
    &var._30to34 = "&type to 30-34 year old &pop &cat"
	&var._35to39 = "&type to 35-39 year old &pop &cat"
	&var._40to44 = "&type to 40-44 year old &pop &cat"
	&var._45plus = "&type to 45 and over years old &pop &cat"
  ;
    
%mend By_age;

/** End Macro Definition **/

