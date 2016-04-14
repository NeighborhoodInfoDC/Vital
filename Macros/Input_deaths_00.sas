/**************************************************************************
 Program:  Input_deaths_00.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/22/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw death data for 2000.

 Modifications:
**************************************************************************/

/** Macro Input_deaths_00 - Start Definition **/

%macro Input_deaths_00;

  input
    Tract      24-26
    xBday     $9-10
    xBmonth   $7-8
    xByear    $11-12
    xDday     $3-4
    xDmonth   $1-2
    xDyear    $5-6
    Age_unit  $16
    xAge      $17-18
    xCombage  $14-15
    Race      $23
    /*
    Latino_det 23
    Sex        30
    */
    Ward       27-28
    Icd10_4d   $19-22
  ;
  
  sex = .u;
  Latino_det = .u;
  
  label
    Tract ="Census tract of deceased's residence (DC format)"
    Age_unit  ='Unit of time for age at death'
    race ='Race of deceased'
    Latino_det ='Hispanic origin of deceased (detailed)'
    sex ='Sex of deceased'
    Ward  ="Ward of deceased's residence"
    Icd10_4d = 'Cause of death (ICD-10, 4-digit)';
    
  format sex sexd. race $racecod. latino_det hispd. age_unit $ageunit. Icd10_4d $icd104a.;

%mend Input_deaths_00;

/** End Macro Definition **/

