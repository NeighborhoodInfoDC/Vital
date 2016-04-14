/**************************************************************************
 Program:  Input_births_03.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/05/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw birth data for 2003.

 Modifications:
**************************************************************************/

/** Macro Input_births_03 - Start Definition **/

%macro Input_births_03;

  input
    Bweight      1-4 
    Tract        5-7
    Ward        $8
    Mage         9-10
    Mstat       $11
    Mrace       $12
    Latino      $13
    Num_visit     14-15
    xPre_care    $16-17
    Gest_age      18-19
    Plural       20
    Meducatn     21-22
    Mtobaccouse $23
    Malcoholuse $24;
    
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
    gest_age = 'Gestational age of child (weeks)' 
    MEDUCATN = "Mother's education level (years)"
    MSTAT = "Mother's marital status"
    MTobaccoUse = "Mother uses tobacco"
    MAlcoholUse = "Mother uses alcohol";

  format 
    ward $ward02a.
    latino MTobaccoUse MAlcoholUse $yesno.
    MSTAT $MMar.
    Mrace racecod.;	

%mend Input_births_03;

/** End Macro Definition **/

