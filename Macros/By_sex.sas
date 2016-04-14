/**************************************************************************
 Program:  By_sex.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/14/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to generate summary variables by sex.

 Modifications:
**************************************************************************/

/** Macro By_sex - Start Definition **/

%macro By_sex( var, cat, type=Deaths );

  &var._m = &var * Deaths_male;
  &var._f = &var * Deaths_female;
  
  label 
    &var._m = "&type to males &cat"
    &var._f = "&type to females &cat"
  ;
    
%mend By_sex;

/** End Macro Definition **/

