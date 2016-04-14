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

/** Macro Input_births_09 - Start Definition **/

%macro Input_births_09;

  input

BIRTHYR  1-4
BIRTHMO  5-6 
BIRTHDY  7-8
BWEIGHT 9-12		
FEDTRACTNO 13-17
WARD $ 23
MAGE   24-25 		 
MSTATNEW $ 26
MRACE $ 27	    
LATINO_NEW $ 28
NUM_VISIT 29-30  	     
GEST_AGE 31-32 	
PLURAL 33-34 		
MEDUCATN 35-36 		
MTOBACCOUSE_NEW $ 37
DOFP_DT_MM 38-39
DOFP_DT_DD 41-42
DOFP_DT_YYYY 44-47
DOLP_DT_MM 48-49
DOLP_DT_DD 51-52
DOLP_DT_YYYY 54-57
;



if BIRTHYR=8888 or BIRTHYR=9999 or BIRTHMO=88 or BIRTHMO=99 or BIRTHDY=88 or BIRTHDY=99 then Date=.U;
else Date = mdy(BirthMo,BirthDy,BirthYr); 
 
   format Date mmddyy10.
; 

if DOFP_DT_DD in (99,88) and DOFP_DT_MM in (01,02,03,04,05,06,07,08,09,10,11,12) then DOFP_DT_DD=15;
if DOLP_DT_DD in (99,88) and DOLP_DT_MM in (01,02,03,04,05,06,07,08,09,10,11,12) then DOLP_DT_DD=15;

	DOFP_Date = mdy(DOFP_DT_MM,DOFP_DT_DD,DOFP_DT_YYYY); 
	DOLP_Date = mdy(DOLP_DT_MM,DOLP_DT_DD,DOLP_DT_YYYY); 
   format DOFP_Date mmddyy10.;
   format DOLP_Date mmddyy10.;

	if num_visit=0 then do;
                  DOFP_Date=.N;
                  DOLP_Date=.N;
                  
                end;
                else if num_visit>0 then do;
                  if DOFP_DT_MM=99 then DOFP_Date=.U;
                  if DOLP_DT_MM=99 then DOLP_Date=.U;
                  if DOFP_DT_YYYY=9999 then DOFP_Date=.U;
                  if DOLP_DT_YYYY=9999 then DOLP_Date=.U;
                end;

    
   



  ** Pre_care **;
  
if 1 <= gest_age < 99 then Conception_date = intnx( 'week',Date, -1 * gest_age );
  else Conception_date = intnx( 'week',Date, -1 * 39 );

  format Conception_date mmddyy10.;


Pre_care = intck( 'week', Conception_date, DOFP_DaTe);
  


  label
  	BIRTHYR = "Year of Birth"
	BIRTHMO= "Month of Birth"
	BIRTHDY = "Day of Birth"
    Mage = "Mother's age at birth (years)"
    Bweight = "Child's birth weight (grams)"
    fedtractno = "Mother's census tract of residence (numeric)"
    Ward  = "Mother's ward of residence (DOH reported)" 
    Mrace  = "Mother's race" 
    latino_new= "Mother's Hispanic/Latino origin (new code)"
    plural ='Count of single/plural births' 
    pre_care ='Week of first prenatal care visit' 
    num_visit ='Number of prenatal visits' 
    gest_age = 'Gestational age of child (weeks)' 
    MEDUCATN = "Mother's education level (years)"
    MSTATNEW = "Mother's marital status"
	MTobaccoUse = "Mother uses tobacco"
    MTobaccoUse_new = "Mother uses tobacco (new code)"
	dofp_date = 'Date of First Prenatal Visit'
	dolp_date = 'Date of Last Prenatal Visit'
	Date= 'Date of Birth'
	conception_date='Date Conceived (UI estimated)'
	pre_care='Weeks in to Pregnancy of first Prenatal Visit'
	MSTAT ="Mother's marital status"
	latino ="Mother's Hispanic/Latino origin"
    ;
drop 
DOFP_DT_MM 
DOFP_DT_DD 
DOFP_DT_YYYY 
DOLP_DT_MM
DOLP_DT_DD
DOLP_DT_YYYY
BIRTHDY
BIRTHMO
BIRTHYR;

  format
   MSTAT $MMar.;
 
	
  if mstatnew='1' then Mstat='Y';
  else if mstatnew='2' then Mstat='N';
  drop mstatnew;

  if latino_new='1' then latino='Y';
  if latino_new='2' then latino='N';
  else if latino_new='9' then latino=" ";

  if MTOBACCOUSE_NEW='1' then MTOBACCOUSE='Y';
  if MTOBACCOUSE_NEW='2' then MTOBACCOUSE='N';
  else if MTOBACCOUSE_NEW='9' then MTOBACCOUSE=" ";

  format 
    ward $ward02a.
    latino_new MTobaccoUse_new $yn12f. 
    Mrace $race09f.
    latino MTobaccoUse $yesno.;
	** Fix bad tracts **;
/*
	if fedtractno = 38.01 then fedtractno = 38 ;
	if fedtractno = 70.01 then fedtractno = 70 ;
	if fedtractno = 76.07 then fedtractno = 76.05 ;
	if fedtractno = 96 then fedtractno = 96.01 ;
*/
	** Fix weird data values **;
/*
	if ward = '9' then ward = ' ';
	if fedtractno = 0 then fedtractno = . ;

  tract = fedtractno; */

%mend Input_births_09;



/** End Macro Definition **/

