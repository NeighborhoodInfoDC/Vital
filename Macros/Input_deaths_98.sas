/**************************************************************************
 Program:  Input_deaths_98.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/22/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw death data for 1998.

 Modifications:
**************************************************************************/

/** Macro Input_deaths_98 - Start Definition **/

%macro Input_deaths_98;

  input
    Tract      1-3
    xBday     $4-5
    xBmonth   $6-7
    xByear    $8-9
    xDday     $10-11
    xDmonth   $12-13
    xDyear    $14-15
    Age_unit  $16
    xAge      $17-18
    xCombage  $19-21
    Race      $22
    Latino_det 23
    Sex        24
    Ward       25-26
    Icd9_4d   $27-30
  ;
  
  label
    Tract ="Census tract of deceased's residence (DC format)"
    Age_unit  ='Unit of time for age at death'
    race ='Race of deceased'
    Latino_det ='Hispanic origin of deceased (detailed)'
    sex ='Sex of deceased'
    Ward  ="Ward of deceased's residence"
    Icd9_4d = 'Cause of death (ICD-9, 4-digit)';
    
  format sex sexd. race $racecod. latino_det hispd. age_unit $ageunit. Icd9_4d $icd94a.;

%mend Input_deaths_98;

/** End Macro Definition **/

