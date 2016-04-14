/**************************************************************************
 Program:  Input_births_00.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/12/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw birth data for 1999-2000.

 Modifications:
**************************************************************************/

/** Macro Input_births_00 - Start Definition **/

%macro Input_births_00;

  input
    Mage 1-2
    Mrace $3
    Bweight 4-7
    xPre_care $8-9
    Num_visit 10-11
    Plural  12
    Gest_age 13-14
    Tract  15-17
    Ward $18;

  Latino = ' ';    ***** LATINO STATUS NOT PROVIDED THIS YEAR *****;

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
    Pre_care ='Week of first prenatal care visit' 
    num_visit ='Number of prenatal visits' 
    gest_age = 'Gestational age of child (weeks)';

  format 
    ward $ward02a.
    latino $yesno.
    mrace racecod.;	

%mend Input_births_00;

/** End Macro Definition **/

