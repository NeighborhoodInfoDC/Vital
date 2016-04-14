/**************************************************************************
 Program:  Input_births_02.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/12/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw birth data for 2002.

 Modifications:
**************************************************************************/

/** Macro Input_births_02 - Start Definition **/

%macro Input_births_02;

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
    Plural  19
    Mstat  $20;

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
    gest_age = 'Gestational age of child (weeks)' 
    MSTAT = "Mother's marital status";

  format 
    ward $ward02a.
    latino $yesno.
    mstat $mmar.
    mrace racecod.;	

%mend Input_births_02;

/** End Macro Definition **/

