/**************************************************************************
 Program:  Input_births_01.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/12/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw birth data for 2001.

 Modifications:
**************************************************************************/

/** Macro Input_births_01 - Start Definition **/

%macro Input_births_01;

  input
    Bweight 1-4
    Tract   5-7
    Ward   $8
    Mage    9-10
    Mrace  $11
    Latino $12
    Num_visit 13-14
    xPre_care $15-16
    Gest_age 17-18
    Plural  19;

  ** Pre_care **;
  
  if xPre_care ~= '-' then Pre_care = input( xPre_care, 2. );
  
  drop xPre_care;
  
  label
    Mage = "Mother's age at birth (years)"
    Bweight = "Child's birth weight (grams)"
    tract = "Mother's census tract of residence (DC format)"
    Ward  = "Mother's ward of residence" 
    Mrace  = "Mother's race" 
    latino = "Mother's Hispanic/Latino origin"
    plural ='Count of single/plural births' 
    pre_care ='Week of first prenatal care visit' 
    num_visit ='Number of prenatal visits' 
    gest_age = 'Gestational age of child (weeks)';

  format 
    ward $ward02a.
    latino $yesno.
    mrace racecod.;	

%mend Input_births_01;

/** End Macro Definition **/

