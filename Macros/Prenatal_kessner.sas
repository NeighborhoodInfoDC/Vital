/**************************************************************************
 Program:  Prenatal_kessner.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/10/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to calculate Kessner index for prenatal
care.

 Modifications:
**************************************************************************/

/** Macro Prenatal_kessner - Start Definition **/

%macro Prenatal_kessner( 
  gest_age=gest_age,   /** Gestational age of child (weeks) **/
  num_visit=num_visit, /** Number of prenatal visits **/
  pre_care=pre_care,  /** Week of first prenatal care visit **/
  var_pre=prenat      /** Name of output var. **/
);

  ** Calculate kessner index of prenatal care **;
  ** 1 = adequate, 2 = intermediate, 3 = inadequate **;
  
  if not( missing( &gest_age ) or missing( &pre_care ) ) then do;
  
    if &pre_care <= 13 then Births_&var_pre._1st = 1;
    else Births_&var_pre._1st = 0;

    Births_&var_pre._adeq = 0;
    Births_&var_pre._intr = 0;
    Births_&var_pre._inad = 0;
    
    if &pre_care <= 13 and (
         ( &gest_age <= 13 and ( &num_visit >= 1 or missing( &num_visit ) ) ) or
         ( 13 < &gest_age <= 17 and &num_visit >= 2 ) or
         ( 17 < &gest_age <= 21 and &num_visit >= 3 ) or
         ( 21 < &gest_age <= 25 and &num_visit >= 4 ) or
         ( 25 < &gest_age <= 29 and &num_visit >= 5 ) or
         ( 29 < &gest_age <= 31 and &num_visit >= 6 ) or
         ( 31 < &gest_age <= 33 and &num_visit >= 7 ) or
         ( 33 < &gest_age <= 35 and &num_visit >= 8 ) or
         ( 35 < &gest_age and &num_visit >= 9 ) 
       ) then Births_&var_pre._adeq = 1;
    else if ( &pre_care >= 28 ) or
            ( 13 < &gest_age <= 21 and ( &num_visit = 0 or missing( &num_visit ) ) ) or
            ( 21 < &gest_age <= 29 and ( &num_visit <= 1 or missing( &num_visit ) ) ) or
            ( 29 < &gest_age <= 31 and ( &num_visit <= 2 or missing( &num_visit ) ) ) or
            ( 31 < &gest_age <= 33 and ( &num_visit <= 3 or missing( &num_visit ) ) ) or
            ( 33 < &gest_age and ( &num_visit <= 4 or missing( &num_visit ) ) )
          then Births_&var_pre._inad = 1;
    else Births_&var_pre._intr = 1;
    
    Births_w_&var_pre = 1;

  end;
  else do;
    Births_&var_pre._1st = .u;
    Births_&var_pre._adeq = .u;
    Births_&var_pre._intr = .u;
    Births_&var_pre._inad = .u;
    Births_w_&var_pre = 0;
  end;
  
  label 
    Births_&var_pre._1st = "Births with prenatal care visit in 1st trimester"
    Births_&var_pre._adeq = "Births with adequate prenatal care (Kessner index)"
    Births_&var_pre._intr = "Births with intermediate prenatal care (Kessner index)"
    Births_&var_pre._inad = "Births with inadequate prenatal care (Kessner index)"
    Births_w_&var_pre = "Births with prenatal care reported (Kessner index)";
  
%mend Prenatal_kessner;

/** End Macro Definition **/

