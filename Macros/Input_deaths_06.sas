/**************************************************************************
 Program:  Input_deaths_06.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  4/8/08
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw death data for 2004.

 Modifications: Changes Latino_detail to take into account new character values (VA).
**************************************************************************/

/** Macro Input_deaths_06 - Start Definition **/

%macro Input_deaths_06;

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
    Latino_det $23
    Sex        24
    Ward       25-26
    Icd10_4d   $27-30
  ;
if Latino_det = 'C' then Latino_det = .C;
if Latino_det = 'N' then Latino_det= .N;
if Latino_det = 'O' then Latino_det= .O;
if Latino_det = 'U' then Latino_det= .U;
newlatino_det = input(Latino_det,hisp.); 
drop latino_det; 
rename newlatino_det=latino_det;
  label
    Tract ="Census tract of deceased's residence (DC format)"
    Age_unit  ='Unit of time for age at death'
    race ='Race of deceased'
    Latino_det ='Hispanic origin of deceased (detailed)'
    sex ='Sex of deceased'
    Ward  ="Ward of deceased's residence"
    Icd10_4d = 'Cause of death (ICD-10, 4-digit)';
    
  format sex sexd. race $racecod. latino_det hispd. age_unit $ageunit. Icd10_4d $icd104a.;

%mend Input_deaths_06;

/** End Macro Definition **/

