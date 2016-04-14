/**************************************************************************
 Program:  Read_births.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/05/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro in Vital library to read raw birth
 record files.
 
 Currently supports years 1998-2004.

 Modifications:
  09/15/06  Revised vars counting race reporting.
  09/26/06  Revised race labels.
  06/04/07  Added preterm births (<37 gestational weeks)
  09/17/09  Updated with new marital status formats.
**************************************************************************/

/** Macro Read_births - Start Definition **/

%macro Read_births07( 
  infile=, 
  year=, 
  path=&_dcdata_path\Vital\Raw );
  
  %let GRAMS_TO_LBS = 0.00220462262;

  %let FIRST_YEAR_LATINO = 2001;
  %let FIRST_YEAR_PRENATAL = 1999;
  %let FIRST_YEAR_PLURAL = 1999;
  %let FIRST_YEAR_MSTAT = 2002;
  %let FIRST_YEAR_ALCOHOL = 2003;
  %let FIRST_YEAR_GEST_AGE = 1999;
  
  data withTracts 
       noTractsnoWard (drop=Tract_Key Tract_full Tract_yr) 
       noTractsWard (drop=Tract_Key Tract_full Tract_yr);  
  
    retain Year &year;
    
    label year = 'Year of birth';
  
    infile "&path\&infile" stopover lrecl=65000;
    
    ** Read data from raw file **;
  
    %** Use appropriate macro for reading in files of different years **;

      %Input_births_07

    
    ** Number observations **;
    
    RecordNo + 1;
    
    label RecordNo = "Record number (UI created)";
    
    ** Recode missing values **;

    ** Numeric vars w/99 = missing **;

    array missv1{*} 
      %if &year >= &FIRST_YEAR_PRENATAL %then %do;
        num_visit pre_care gest_age 
      %end;
      mage;

    do i = 1 to dim( missv1 );
      if missv1{i} in ( ., 99 ) then missv1{i} = .u;
    end;
    
    ** Y/N character vars **;

    array missv2{*} latino
      %if 2007< &year >= &FIRST_YEAR_MSTAT %then %do;
        Mstat
      %end;
      %if &year >= &FIRST_YEAR_ALCOHOL %then %do;
        Mtobaccouse Malcoholuse
      %end;
    ;

    do i = 1 to dim( missv2 );
      missv2{i} = upcase( missv2{i} );
      if missv2{i} not in ( "Y", "N" ) then missv2{i} = "";
    end;
    
    ** Other numeric vars **;
    
    %if &year >= &FIRST_YEAR_PLURAL %then %do;
      if Plural = 9 then Plural = .u;
    %end;
    
    %if &year >= &FIRST_YEAR_PRENATAL %then %do;
      if num_visit = 0 then pre_care = .n;
      if gest_age = 0 then gest_age = .u;
    %end;
    
    if bweight = 9999 then bweight = .u;
    
    if tract = 999 then tract = 0;
    
    ** Other character vars **;
    
    if ward in ( "0", "9" ) then ward = "";
    if Mrace = "9" then Mrace = "";

    drop i;

    ** Birth weight (lbs.) **;
    
    if not( missing( bweight ) ) then 
      Bweight_lbs = bweight * &GRAMS_TO_LBS;
    else 
      Bweight_lbs = .u;
    
    label bweight_lbs = "Child's birth weight (lbs)";
    
    ** Census tract identifiers **;
    
    %Convert_dc_tracts( births, &year )
    
    length Tract_key $ 15;
    
    Tract_key = put( tract_yr, 4. ) || tract_full;
    
    ** Keys for hot deck allocation of tracts **;
    
    if latino in ( " ", "N" ) then do;
    
      select( Mrace );
        when ( '1' ) kMrace = 1;
        when ( '2' ) kMrace = 2;
        when ( '4', '5', '6', '7', '8' ) kMrace = 3;
        when ( '0', '3' ) kMrace = 4;
        otherwise kMrace = 9 /** missing **/;
      end;
      
    end;
    else if latino = "Y" then do;
      kMrace = 5;
    end;
    
    if 0 < mage < 20 then kMage = 1;
    else if 20 <= mage then kMage = 2;
    
    if 0 < bweight_lbs < 5.5 then kbweight = 1;
    else if 5.5 <= bweight_lbs then kbweight = 2;

    Births_total = 1;
    
    label Births_total = "Total births";
        
    if tract_full = "" and ward = "" then output noTractsnoWard;
    else if tract_full = "" and ward ne "" then output noTractsWard;
    else output withTracts;
    
  run;
  
  ** Allocate missing tracts with hot deck method **;
  
  %if &year >= 2002 %then %let match_keys = kMrace kMage kbweight mstat;
  %else %let match_keys = kMrace kMage kbweight;

  %Hot_deck( match_keys=&match_keys, data=noTractsnoWard, source=withTracts, 
    alloc=tract_key, weight=Births_total, num_units=200, out=noTractsnoWard_alloc )  

  %Hot_deck( by=Ward, match_keys=&match_keys, data=noTractsWard, source=withTracts, 
    alloc=tract_key, weight=Births_total, num_units=200, out=noTractsWard_alloc )  

  run;

  ** Recombine records **;
  
  data Vital.Births_&year (label="Individual birth records, &year, DC");
  
    set withTracts noTractsnoWard_alloc noTractsWard_alloc;
    by Recordno;
      
    if tract_key_alloc then do;
      tract_yr = input( tract_key, 4. );
      tract_full = substr( tract_key, 5, 11 );
      *put tract_yr= tract_full= tract_key=;
    end;
    else 
      tract_key_alloc = 0;
    
    label tract_key_alloc = "Tract allocation flag";
    format tract_key_alloc dyesno.;
    
    **** Summary variables ****;
    
    %if &year >= &FIRST_YEAR_LATINO %then %do;
    
    ** By race/ethnicity **;
    
    if not( missing( latino ) ) and not( missing( Mrace ) ) then do;
    
      Births_white = 0;
      Births_black = 0;
      Births_hisp = 0;
      Births_asian = 0;
      Births_oth_rac = 0;

      Births_w_race = 1;
    
      if latino = "N" then do;
      
        select( Mrace );
          when ( '1' ) Births_white = 1;
          when ( '2' ) Births_black = 1;
          when ( '4', '5', '6', '7', '8' ) Births_asian = 1;
          when ( '0', '3' ) Births_oth_rac = 1;
        end;
        
      end;
      else do;
        Births_hisp = 1;
      end;
    
    end;
    else do;
      Births_w_race = 0;
    end;
    
    label
      Births_white = "Births to non-Hisp. white mothers"
      Births_black = "Births to non-Hisp. black mothers"
      Births_hisp = "Births to Hispanic/Latino mothers"
      Births_asian = "Births to non-Hisp. Asian/Pacific Islander mothers"
      Births_oth_rac = "Births to non-Hisp. other race mothers"
      Births_w_race = "Births with mother's race reported";
      
    %end;
    
    ** By age of mother **;
    
    if not( missing( mage ) ) then do;

      Births_w_age = 1;

      if 20 <= mage < 25 then Births_20to24 = 1;
      else Births_20to24 = 0;
    
      if mage < 20 then Births_teen = 1;
      else Births_teen = 0;
    
      if mage < 18 then Births_under18 = 1;
      else Births_under18 = 0;
    
      if mage < 15 then Births_under15 = 1;
      else Births_under15 = 0;
    
    end;
    else do;
      Births_w_age = 0;
    end;
    
    label 
      Births_Teen = "Births to mothers under 20 years old"
      Births_Under18 = "Births to mothers under 18 years old"
      Births_Under15 = "Births to mothers under 15 years old"
      Births_20to24 = "Births to mothers 20-24 years old"
      Births_w_age = "Births with mother's age reported";
    
    %if &year >= &FIRST_YEAR_LATINO %then %do;
      %By_race( Births_teen, under 20 years old, Births )
      %By_race( Births_under18, under 18 years old, Births )
      %By_race( Births_under15, under 15 years old, Births )
      %By_race( Births_20to24, 20-24 years old, Births )
      %By_race( Births_w_age, with age reported, Births )
    %end;
    
    ** By birth weight **;
    
    if not( missing ( bweight_lbs ) ) then do;
    
      Births_w_weight = 1;
    
      if bweight_lbs < 5.5 then Births_low_wt = 1;
      else Births_low_wt = 0;
    
    end;
    else do;
      Births_w_weight = 0;
    end;    
    
    label
      Births_low_wt = "Births with low birth weight (<5.5 lbs)"
      Births_w_weight = "Births with birth weight reported";
    
    %if &year >= &FIRST_YEAR_LATINO %then %do;
      %By_race( Births_low_wt, with low birth weight (<5.5 lbs), Births )
      %By_race( Births_w_weight, with birth weight reported, Births )
    %end;

    ** Single mother births **;
    
    %if 2007=<&year >= 2002 %then %do;
    
      if Mstat in ( 'N', 'Y' ) then do;
        if Mstat = 'N' then Births_single = 1;
        else if Mstat = 'Y' then Births_single = 0;
        Births_w_mstat = 1;
      end;
      else if missing( Mstat ) then do;
        Births_w_mstat = 0;
      end;
      else do;
        %warn_put( msg='Invalid marital status code: ' Recordno= Mstat= )
        Births_w_mstat = 0;
      end;

       %if &year >= 2007 %then %do;
    
      if Mstat in ( '1', '2' ) then do;
        if Mstat = '2' then Births_single = 1;
        else if Mstat = '1' then Births_single = 0;
        Births_w_mstat = 1;
      end;
      else if missing( Mstat ) then do;
        Births_w_mstat = 0;
      end;
      else do;
        %warn_put( msg='Invalid marital status code: ' Recordno= Mstat= )
        Births_w_mstat = 0;
      end;

      label
        Births_Single = "Births to unmarried mothers"
        Births_w_mstat = "Births with mother's marital status reported";

      %if &year >= &FIRST_YEAR_LATINO %then %do;
        %By_race( Births_single, who were unmarried, Births )
        %By_race( Births_w_mstat, with marital status reported, Births )
      %end;
      %end;
    %end;
    
    %if &year >= &FIRST_YEAR_PRENATAL %then %do;

      ** Prenatal care **;
          
      %Prenatal_kessner()
      
      %if &year >= &FIRST_YEAR_LATINO %then %do;
        %By_race( Births_prenat_1st, with prenatal care in 1st trimester, Births )
        %By_race( Births_prenat_adeq, with adequate prenatal care, Births )
        %By_race( Births_prenat_intr, with intermediate prenatal care, Births )
        %By_race( Births_prenat_inad, with inadequate prenatal care, Births )
        %By_race( Births_w_prenat, with prenatal care reported, Births )
      %end;
      
    %end;
    
    %** Preterm births **;
    
    %if &year >= &FIRST_YEAR_GEST_AGE %then %do;

      ** Preterm births **;
      
      if gest_age > 0 then do;
      
        if gest_age < 37 then Births_preterm = 1;
        else Births_preterm = 0;
        
        Births_w_gest_age = 1;
        
      end;
      else do;
      
        Births_preterm = .u;
        Births_w_gest_age = 0;
        
      end;
      
      label 
        Births_preterm = "Preterm births (<37 gestational weeks)"
        Births_w_gest_age = "Births with gestational age reported";

    %end;
    
    drop tract_key kMrace kMage kbweight;
    
    rename tract_key_alloc = Tract_alloc;
    
  run;
  
  %File_info( 
    data=Vital.Births_&year,
    printobs=5,
    freqvars=
      year tract_alloc tract_yr ward Mrace latino 
      %if &year >= &FIRST_YEAR_PRENATAL %then %do;
        num_visit pre_care gest_age 
      %end;
      %if &year >= &FIRST_YEAR_PLURAL %then %do;
        plural 
      %end;
      %if &year >= 2002 %then %do;
        MSTAT 
      %end;
      %if &year >= 2003 %then %do;
        MEDUCATN MTobaccoUse MAlcoholUse 
      %end;
   )
   
  proc univariate data=Vital.Births_&year nextrobs=20;
    var bweight;
 
  %exit:
  
%mend Read_births;

/** End Macro Definition **/

