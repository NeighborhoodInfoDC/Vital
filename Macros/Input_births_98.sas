/**************************************************************************
 Program:  Input_births_98.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/16/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw birth data for 1998.

 Modifications:
**************************************************************************/

/** Macro Input_births_98 - Start Definition **/

%macro Input_births_98;

  input
    Mage 1-2
    Bweight 3-6
    Tract  7-9
    Ward $10;

  Mrace = ' ';     ***** RACE NOT PROVIDED THIS YEAR          *****;
  Latino = ' ';    ***** LATINO STATUS NOT PROVIDED THIS YEAR *****;

  label
    Mage = "Mother's age at birth (years)"
    Bweight = "Child's birth weight (grams)"
    Tract = "Mother's census tract of residence (DC format)"
    Ward  = "Mother's ward of residence" 
    Mrace  = "Mother's race" 
    latino = "Mother's Hispanic/Latino origin";

  format 
    ward $ward02a.
    latino $yesno.
    mrace racecod.;	

%mend Input_births_98;

/** End Macro Definition **/

