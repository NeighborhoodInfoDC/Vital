/**************************************************************************
 Program:  Input_births_08.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/05/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to read raw birth data for 2008.

 Modifications:
**************************************************************************/

/** Macro Input_births_08 - Start Definition **/

%macro Input_births_08;

  input

	Bweight               1-4 
    Fedtractno              5-9
    Ward_full              $10-15
    Mage                  16-17
    Mstatnew              $18
    Mrace                 $19
    Latino                $20
    Num_visit             21-22
    xPre_care             $23-24
    Gest_age              25-26
    Plural                27-28
    Meducatn              29-30
    Mtobaccouse           $31
    Malcoholuse           $32
      ;

	ward_ch = Substr(ward_full,5,6);
	ward_num = ward_ch + 0;
	ward = put(ward_num,$1.);

	drop ward_full ward_ch ward_num;

  ** Pre_care **;
  
  if xPre_care ~= '-' then Pre_care = input( xPre_care, 2. );
  
  drop xPre_care;
  
  label
    Mage = "Mother's age at birth (years)"
    Bweight = "Child's birth weight (grams)"
    tract = "Mother's census tract of residence (numeric)"
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
  
  if mstatnew='1' then Mstat='Y';
  else if mstatnew='2' then Mstat='N';
  drop mstatnew;

	** Fix bad tracts **;

	if fedtractno = 38.01 then fedtractno = 38 ;
	if fedtractno = 70.01 then fedtractno = 70 ;
	if fedtractno = 76.07 then fedtractno = 76.05 ;
	if fedtractno = 96 then fedtractno = 96.01 ;

	** Fix weird data values **;

	if ward = '9' then ward = ' ';
	if fedtractno = 0 then fedtractno = . ;

  tract = fedtractno;

%mend Input_births_08;



/** End Macro Definition **/

