/**************************************************************************
 Program:  Read_deaths.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/16/06
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to read raw death files.

 Modifications:
  4/8/08 Added invoking of 2005 macro
  10/17/06  Added accidental, homicide, and suicide deaths for
            15-19 and 20-24 years old.
            Added 2004 input macro.
  10/22/06  Added support for 1998 to 2000.
  10/30/06  Corrected handling of obs. with AGE_UNIT = 0.
  11/12/06  Fixed ICD-9 death summary categories for 1998.
  11/14/06  Added deaths by sex.
  11/20/06  Corrected Deaths_accident for ICD-10 codes (added W codes).
**************************************************************************/

/** Macro Read_deaths - Start Definition **/

%macro Read_deaths( 
  infile=, 
  year=, 
  path=&_dcdata_path\Vital\Raw,
  corrections=
);

  %let MAX_CALC_AGE_DIFF = 5;
  %let FIRST_YEAR_LATINO = 2001;
  %let FIRST_YEAR_SEX = 2001;
  %let FIRST_YEAR_ICD10  = 1999;
  
  %if &year >= &FIRST_YEAR_ICD10 %then %let icdv = 10;
  %else %let icdv = 9;

  options yearcutoff=%eval( &year - 99 );
  
  %push_option( compress )
  
  options compress=no;

  data withTracts 
       noTractsnoWard (drop=Tract_Key Tract_full Tract_yr) 
       noTractsWard (drop=Tract_Key Tract_full Tract_yr)
       withAge
       noAge (drop=Age_calc);  
  
    retain Year &year;
    
    label year = 'Year of death';
  
    infile "&path\&infile" stopover lrecl=1000;
    
    ** Read data from raw file **;
    
    length xByear xDyear $ 4;
    
    %** Use appropriate macro for reading in files of different years **;
   

	%if &year = 2007 %then %do;
      %Input_deaths_07
    %end;

    %else %if &year = 2006 %then %do;
      %Input_deaths_06
    %end;

	%else %if &year = 2005 %then %do;
      %Input_deaths_05
    %end;

    %else %if &year = 2004 %then %do;
      %Input_deaths_04
    %end;

    %else %if &year = 2003 %then %do;
      %Input_deaths_03
    %end;
    %else %if &year = 2002 or &year = 2001 %then %do;
      %Input_deaths_02
    %end;
    %else %if &year = 2000 or &year = 1999 %then %do;
      %Input_deaths_00
    %end;
    %else %if &year <= 1998 and &year >= 1998 %then %do;
      %Input_deaths_98
    %end;
    %else %do;
      %err_mput( macro=Read_deaths, 
                 msg=Macro does not support files for YEAR=&year )
      abort;
      %goto exit;
    %end;
    
    ** Number observations **;
    
    RecordNo + 1;
    
    label RecordNo = "Record number (UI created)";
    
    ** Corrections **;
    
    &corrections
    
    ** Recode missing values **;

    if ward in ( "0", "9" ) then ward = "";
    if Race in ( "0", "9" ) then Race = "";

    array missv1{*} xbday xbmonth xdday xdmonth;

    do i = 1 to dim( missv1 );
      if missv1{i} in ( '-', '99' ) then missv1{i} = '';
    end;
    
    array missv2{*} xbyear xdyear;

    do i = 1 to dim( missv2 );
      if missv2{i} in ( '-' ) then missv2{i} = '';
    end;
    
    if age_unit in ( '-' ) then age_unit = '';
    if xCombage in ( '-' ) then xCombage = '';
    if Latino_det in ( 9 ) then Latino_det = .;

    
    drop i;
    
    ** Convert chars to numeric **;
    
    Age = 1 * xAge;
    Combage = 1 * xCombage;
    
    label
      Combage = 'Combined age at death'
      Age = 'Age at death (see Age_unit for unit of time)';
      
    drop xAge xCombage;
    
    ** Recoded Hispanic status **;
    
    if Latino_det = 0 then Latino = 'N';
    else if Latino_det > 0 then Latino = 'Y';
    
    label Latino = 'Hispanic origin of deceased (UI recode)';
    format Latino $yesno.;
    
    ** Create 3-digit death code **;
    
    Icd&icdv._4d = left( compress( upcase( Icd&icdv._4d ), '-' ) );
    
    * Remove trailing X character *;
    
    if substr( reverse( Icd&icdv._4d ), 1, 1 ) = 'X' then
      Icd&icdv._4d = substr( Icd&icdv._4d, 1, length( Icd&icdv._4d ) - 1 );
      
    length Icd&icdv._3d $ 3;
    
    Icd&icdv._3d = Icd&icdv._4d;
    
    label Icd&icdv._3d = "Cause of death (ICD-&icdv, 3-digit)";
    
    format Icd&icdv._3d $Icd&icdv.3a.;
    
    ** Create birth & death date vars **;
    
    array xdtv{*} xbmonth xbday xbyear xdmonth xdday xdyear;
    array dtv{*}   Bmonth  Bday  Byear  Dmonth  Dday  Dyear;
    
    do i = 1 to dim( xdtv );
      dtv{i} = 1 * xdtv{i};
    end;
    
    Birth_dt = mdy( bmonth, bday, byear );
    Death_dt = mdy( dmonth, dday, dyear );
    
    ** Calculate age at death in years **;
    
    Age_calc = ( Death_dt - Birth_dt ) / 365.25;
    
    if ( birth_dt > death_dt ) or ( age_unit = 0 and age_calc < 100 ) then do;
        birth_dt = intnx( 'year', birth_dt, -100, 'sameday' );
        Age_calc = ( Death_dt - Birth_dt ) / 365.25;
    end;
    
    if missing( Age_calc ) then do;
      if age > 0 then do;
        select ( age_unit );
          when ( '0' ) Age_calc = 100;
          when ( '1' ) Age_calc = age;
          when ( '2' ) Age_calc = age / 12;
          when ( '3' ) Age_calc = age / 365.25;
          when ( '4' ) Age_calc = age / ( 365.25 * 24 );
          when ( '5' ) Age_calc = age / ( 365.25 * 24 * 60 );
          otherwise do;
            Age_calc = .u;
            %warn_put( msg='Invalid age unit of time: ' recordno= age_unit= age= Birth_dt= Death_dt= Age_calc= Icd&icdv._3d= )
          end;
        end;
      end;
      else if age_unit = 0 then do;
        Age = .n;
        Age_calc = 100;
      end;
      else do;
        Age = .u;
        Age_calc = .u;
      end;
    end;
    
    format birth_dt death_dt mmddyy10.;

    label
      dmonth ='Death month'
      dday  ='Death day'
      dyear ='Death year'
      bmonth ='Birth month'
      bday  ='Birth day'
      byear  ='Birth year'
      birth_dt = 'Date of birth'
      death_dt = 'Date of death'
      age_calc = 'Age at death (UI calculated, years)';
    
    drop xbmonth xbday xbyear xdmonth xdday xdyear;
    
    ** Check ICD codes **;
    
    %if &year >= &FIRST_YEAR_ICD10 %then %do;
    
      if put( Icd&icdv._3d, $Icd&icdv.3v. ) = "" then do;
        %warn_put( msg="Invalid ICD-&icdv code (3-digit): " RecordNo= Icd&icdv._3d= $8. );
      end;
    
    %end;
    %else %do;
    
      if put( Icd&icdv._3d, $Icd&icdv.3v. ) = "" then do;
        %warn_put( msg="Invalid ICD-&icdv code (3-digit): " RecordNo= Icd&icdv._3d= $8. );
      end;
      
    %end;
    
    ** Check age against dates **;

    if age_unit = '0' then do;
      if age_calc < 99 then do;
        %warn_put( msg='Possible invalid age or dates: ' recordno= birth_dt= death_dt= / age_calc= 5.1 age= age_unit= )
		invalid_age+1;
      end;
    end;      
    else if age_unit = '1' then do;
      if ( abs( age_calc - age ) >= &MAX_CALC_AGE_DIFF ) or 
         ( age_calc < 1 and age >= 1 ) or 
         ( age_calc >= 1 and age < 1 )
      then do;
        %warn_put( msg='Possible invalid age or dates: ' recordno= birth_dt= death_dt= / age_calc= 5.1 age= age_unit= )
		invalid_age+1;
	  end;
    end;
    else if age_unit ~= '' then do;
      if age_calc >= 1 then do;
        %warn_put( msg='Possible invalid age or dates: ' recordno= birth_dt= death_dt= / age_calc= 5.1 age= age_unit= )
		invalid_age+1;
      end;
    end;

	label
      invalid_age ='Count of obs. with possible invalid age or dates';
    ** Census tract identifiers **;
    
    %Convert_dc_tracts( deaths, &year )
    
    length Tract_key $ 15;
    
    Tract_key = put( tract_yr, 4. ) || tract_full;
    
    ** Keys for hot deck allocation of tracts **;
    
    if latino in ( " ", "N" ) then do;
    
      select( Race );
        when ( '1' ) kRace = 1;
        when ( '2' ) kRace = 2;
        when ( '4', '5', '6', '7', '8' ) kRace = 3;
        when ( '0', '3' ) kRace = 4;
        otherwise kRace = 9 /** missing **/;
      end;
      
    end;
    else if latino = "Y" then do;
      kRace = 5;
    end;
    
    if 0 < Age_calc < 1 then kAge_calc = 1;
    else if 1 <= Age_calc < 18 then kAge_calc = 2;
    else if 18 <= Age_calc < 65 then kAge_calc = 3;
    else if 65 <= Age_calc then kAge_calc = 4;
    

    length kIcd&icdv. $ 1;
    kIcd&icdv. = Icd&icdv._3d;
    
    ** Total deaths summary var **;
    
    length Deaths_total 3;
    
    Deaths_total = 1;
    
    label Deaths_total = "Total deaths";
    
    ** Output records **;
        
    if tract_full = "" and ward = "" then output noTractsnoWard;
    else if tract_full = "" and ward ~= "" then output noTractsWard;
    else output withTracts;
    
  run;
  
  ** Allocate missing tracts with hot deck method **;
  
  %if &year ~= 2000 and &year ~= 1999 %then 
    %let match_keys = kRace kAge_calc kIcd&icdv. sex ;
  %else
    %let match_keys = kRace kAge_calc kIcd&icdv. ;

  %Hot_deck( match_keys=&match_keys, data=noTractsnoWard, source=withTracts, 
    alloc=Tract_key, weight=Deaths_total, num_units=700, out=noTractsnoWard_alloc )  

  %Hot_deck( by=Ward, match_keys=&match_keys, data=noTractsWard, source=withTracts, 
    alloc=Tract_key, weight=Deaths_total, num_units=700, out=noTractsWard_alloc )  
    
  ** Recombine records **;
  
  %pop_option( compress )
  
  data Vital.Deaths_&year (label="Individual death records, &year, DC");
  
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
    
    %if &year >= &FIRST_YEAR_SEX %then %do;
    
      ** By sex **;
      
      select ( sex );
        when ( 1 ) do;
          Deaths_male = 1;
          Deaths_female = 0;
          Deaths_w_sex = 1;
        end;
        when ( 2 ) do;
          Deaths_male = 0;
          Deaths_female = 1;
          Deaths_w_sex = 1;
        end;
        otherwise do;
          Deaths_w_sex = 0;
        end;
      end;
      
      label 
        Deaths_male = "Deaths to males"
        Deaths_female = "Deaths to females"
        Deaths_w_sex = "Deaths with sex reported";
    
    %end;
    
    %if &year >= &FIRST_YEAR_LATINO %then %do;
    
      ** By race/ethnicity **;
      
      if not( missing( latino ) ) and not( missing( Race ) ) then do;
      
        Deaths_white = 0;
        Deaths_black = 0;
        Deaths_hisp = 0;
        Deaths_asian = 0;
        Deaths_oth_rac = 0;

        Deaths_w_race = 1;
      
        if latino = "N" then do;
        
          select( Race );
            when ( '1' ) Deaths_white = 1;
            when ( '2' ) Deaths_black = 1;
            when ( '4', '5', '6', '7', '8' ) Deaths_asian = 1;
            when ( '0', '3' ) Deaths_oth_rac = 1;
          end;
          
        end;
        else do;
          Deaths_hisp = 1;
        end;
      
      end;
      else do;
        Deaths_w_race = 0;
      end;
      
      label
        Deaths_white = "Deaths to white persons"
        Deaths_black = "Deaths to black persons"
        Deaths_hisp = "Deaths to Latino persons"
        Deaths_asian = "Deaths to Asian/Pacific Islander persons"
        Deaths_oth_rac = "Deaths to other race persons"
        Deaths_w_race = "Deaths with race reported";
        
    %end;
    
    ** By age **;
    
    if not( missing( age_calc ) ) then do;

      Deaths_w_age = 1;
      
      if age_calc < 1 then Deaths_infant = 1;
      else Deaths_infant = 0;

      if 1 <= age_calc < 15 then Deaths_1to14 = 1;
      else Deaths_1to14 = 0;

      if 15 <= age_calc < 20 then Deaths_15to19 = 1;
      else Deaths_15to19 = 0;

      if 20 <= age_calc < 25 then Deaths_20to24 = 1;
      else Deaths_20to24 = 0;
    
      if age_calc < 18 then Deaths_under18 = 1;
      else Deaths_under18 = 0;
      
      if 18 <= age_calc then Deaths_adult = 1;
      else Deaths_adult = 0;
      
      if 65 <= age_calc then Deaths_senior = 1;
      else Deaths_senior = 0;
    
    end;
    else do;
      Deaths_w_age = 0;
    end;
    
    label 
      Deaths_infant = "Deaths to infants under 1 year old"
      Deaths_under18 = "Deaths to children under 18 years old"
      Deaths_adult = "Deaths to adults 18+ years old"
      Deaths_senior = "Deaths to seniors 65+ years old"
      Deaths_1to14 = "Deaths to children 1-14 years old"
      Deaths_15to19 = "Deaths to persons 15-19 years old"
      Deaths_20to24 = "Deaths to persons 20-24 years old"
      Deaths_w_age = "Deaths with age reported";
    
    %if &year >= &FIRST_YEAR_LATINO %then %do;
      %By_race( Deaths_infant, under 1 year old, Deaths, var2=deaths, pop=infants )
      %By_race( Deaths_under18, under 18 years old, Deaths, var2=deaths, pop=children )
      %By_race( Deaths_adult, 18+ years old, Deaths, var2=deaths, pop=adults )
      %By_race( Deaths_senior, 65+ years old, Deaths, var2=deaths, pop=seniors )
      %By_race( Deaths_1to14, 1-14 years old, Deaths, var2=deaths, pop=children )
      %By_race( Deaths_15to19, 15-19 years old, Deaths, var2=deaths, pop=persons )
      %By_race( Deaths_20to24, 20-24 years old, Deaths, var2=deaths, pop=persons )
      %By_race( Deaths_w_age, with age reported, Deaths, var2=deaths, pop=persons )
    %end;
    
    %if &year >= &FIRST_YEAR_SEX %then %do;
      %By_sex( Deaths_15to19, 15-19 years old )
      %By_sex( Deaths_20to24, 20-24 years old )
      Deaths_15to19_w_sex  = Deaths_15to19 * Deaths_w_sex;
      Deaths_20to24_w_sex  = Deaths_20to24 * Deaths_w_sex;
      label
        Deaths_15to19_w_sex  = "Deaths to persons 15-19 years old with sex reported"
        Deaths_20to24_w_sex  = "Deaths to persons 20-24 years old with sex reported";
    %end;
    
    ** By cause of death **;
    
    if not( missing( put( Icd&icdv._3d, $Icd&icdv.3v. ) ) ) then do;
    
      Deaths_heart = 0;
      Deaths_cancer = 0;
      Deaths_hiv = 0;
      Deaths_diabetes = 0;
      Deaths_hypert = 0;
      Deaths_cereb = 0;
      Deaths_liver = 0;
      Deaths_respitry = 0;
      Deaths_oth_caus = 0;
      Deaths_w_cause = 0;
      
      %if &year >= &FIRST_YEAR_ICD10 %then %do;

        Deaths_homicide = 0;
        Deaths_suicide = 0;
        Deaths_accident = 0;
        Deaths_violent = 0;

        if put( icd10_3d, $icd10s. ) = "Intentional self-harm" then Deaths_suicide = 1;
        else if put( icd10_3d, $icd10s. ) = "Assault" then Deaths_homicide = 1;
        else if icd10_3d in: ( 'V', 'W', 'X' ) then Deaths_accident = 1;
        else if icd10_3d in ( 'I01', 'I11', 'I13' ) or
           put( icd10_3d, $icd10s. ) in: 
             ( "Chronic rheumatic heart diseases",
               "Ischaemic heart diseases",
               "Pulmonary heart disease",
               "Other forms of heart disease" )
          then Deaths_heart = 1;
        else if icd10_3d =: 'C' then Deaths_cancer = 1;
        else if put( icd10_3d, $icd10s. ) = "Human immunodeficiency virus [HIV] disease" then Deaths_hiv = 1;
        else if put( icd10_3d, $icd10s. ) = "Diabetes mellitus" then Deaths_diabetes = 1;
        else if put( icd10_3d, $icd10s. ) = "Hypertensive diseases" then Deaths_hypert = 1;
        else if put( icd10_3d, $icd10s. ) = "Cerebrovascular diseases" then Deaths_cereb = 1;
        else if put( icd10_3d, $icd10s. ) = "Diseases of liver" then Deaths_liver = 1;
        else if icd10_3d =: 'J' then Deaths_respitry = 1;
        else Deaths_oth_caus = 1;
      
        Deaths_violent = sum( Deaths_suicide, Deaths_homicide, Deaths_accident );
        
        label
          Deaths_homicide = 'Deaths from homicide'
          Deaths_suicide = 'Deaths from suicide'
          Deaths_accident = 'Accidental deaths'
          Deaths_violent = 'Violent deaths (homicide/suicide/accidents)';
      
      %end;
      %else %do;
        ***  NB: Violent deaths not available with ICD-9 codes ***;
        if icd9_3d in ( '391', '402', '404' ) or
           put( icd9_3d, $icd9s. ) in: 
             ( "Chronic rheumatic heart disease",
               "Ischemic heart disease",
               "Diseases of pulmonary circulation",
               "Other forms of heart disease" )
          then Deaths_heart = 1;
        else if put( icd9_3d, $icd9s. ) =: "Malignant neoplasm of "
          then Deaths_cancer = 1;
        else if put( icd9_3d, $icd9s. ) = "Human immunodeficiency virus" then Deaths_hiv = 1;
        else if icd9_3d = '250' then Deaths_diabetes = 1;
        else if put( icd9_3d, $icd9s. ) = "Hypertensive disease" then Deaths_hypert = 1;
        else if put( icd9_3d, $icd9s. ) = "Cerebrovascular disease" then Deaths_cereb = 1;
        else if icd9_3d in ( '570', '571', '572', '573' ) then Deaths_liver = 1;
        else if put( icd9_3d, $icd9sm. ) =: "8. Diseases of the respiratory system" 
          then Deaths_respitry = 1;
        else Deaths_oth_caus = 1;
      
      %end;
      
      Deaths_w_cause = 1;
    
    end;
    else do;
    
      Deaths_w_cause = 0;
    
    end;
    
    label
      Deaths_heart = 'Deaths from heart disease'
      Deaths_cancer = 'Deaths from cancer'
      Deaths_hiv = 'Deaths from HIV'
      Deaths_diabetes = 'Deaths from diabetes'
      Deaths_hypert = 'Deaths from hypertensive diseases'
      Deaths_cereb = 'Deaths from cerebrovascular diseases'
      Deaths_liver = 'Deaths from liver diseases'
      Deaths_respitry = 'Deaths from respitory diseases'
      Deaths_oth_caus = 'Deaths from other causes'
      Deaths_w_cause = 'Deaths with cause reported';
      
    %if &year >= &FIRST_YEAR_SEX %then %do;
      %By_sex( Deaths_heart, from heart disease )
      %By_sex( Deaths_cancer, from cancer )
      %By_sex( Deaths_hiv, from HIV )
      %By_sex( Deaths_diabetes, from diabetes )
      %By_sex( Deaths_hypert, from hypertensive diseases )
      %By_sex( Deaths_cereb, from cerebrovascular diseases )
      %By_sex( Deaths_liver, from liver diseases )
      %By_sex( Deaths_respitry, from respitory diseases )
      %By_sex( Deaths_oth_caus, from other causes )
      %By_sex( Deaths_w_cause, with cause reported )
    %end;
    
    %** Violent deaths not available with ICD-9 codes **;

    %if &year >= &FIRST_YEAR_ICD10 %then %do;

      %if &year >= &FIRST_YEAR_LATINO %then %do;
        ** Violent crimes by race **;
        %By_race( Deaths_violent, ,Violent deaths, var2=deaths, pop=persons )
      %end;
      
      %if &year >= &FIRST_YEAR_SEX %then %do;
        ** Violent crimes by sex **;
        %By_sex( Deaths_violent, , type=Violent deaths )
      %end;
      
      ** 15 to 19 years old **;
      
      Deaths_violent_15to19 = Deaths_violent * Deaths_15to19;
      label Deaths_violent_15to19 = "Violent deaths to persons 15-19 years old";
      
      Deaths_homicide_15to19 = Deaths_homicide * Deaths_15to19;
      label Deaths_homicide_15to19 = "Deaths from homicide to persons 15-19 years old";
      
      Deaths_suicide_15to19 = Deaths_suicide * Deaths_15to19;
      label Deaths_suicide_15to19 = "Deaths from suicide to persons 15-19 years old";
      
      Deaths_accident_15to19 = Deaths_accident * Deaths_15to19;
      label Deaths_accident_15to19 = "Accidental deaths to persons 15-19 years old";
      
      Deaths_w_cause_15to19 = Deaths_w_cause * Deaths_15to19;
      label Deaths_w_cause_15to19 = "Deaths to persons 15-19 years old with cause reported";
      
      ** 20 to 24 years old **;
      
      Deaths_violent_20to24 = Deaths_violent * Deaths_20to24;
      label Deaths_violent_20to24 = "Violent deaths to persons 20-24 years old";
          
      Deaths_homicide_20to24 = Deaths_homicide * Deaths_20to24;
      label Deaths_homicide_20to24 = "Deaths from homicide to persons 20-24 years old";
      
      Deaths_suicide_20to24 = Deaths_suicide * Deaths_20to24;
      label Deaths_suicide_20to24 = "Deaths from suicide to persons 20-24 years old";
      
      Deaths_accident_20to24 = Deaths_accident * Deaths_20to24;
      label Deaths_accident_20to24 = "Accidental deaths to persons 20-24 years old";
      
      Deaths_w_cause_20to24 = Deaths_w_cause * Deaths_20to24;
      label Deaths_w_cause_20to24 = "Deaths to persons 20-24 years old with cause reported";
      
    %end;
        
    drop tract_key kRace kAge_calc kIcd&icdv.;
    rename tract_key_alloc = Tract_alloc;
    
  run;
  
  ** Print descriptive information **;
  
  %File_info( 
    data=Vital.Deaths_&year,
    printobs=5,
    freqvars=age age_unit combage race Latino_det Latino sex ward tract_yr )
    
  proc freq data=Vital.Deaths_&year;
    tables birth_dt death_dt / missing;
    format birth_dt year4. death_dt yymms7.;
    label 
      birth_dt = 'Date of birth (year only)'
      death_dt = 'Date of death (year/month)';

  ** Summary tables **;

  proc tabulate data=Vital.Deaths_&year format=comma10.0 noseps missing order=freq;
    class Icd&icdv._3d Icd&icdv._4d;
    var deaths_total;
    table all='TOTAL' Icd&icdv._3d,
      deaths_total * ( sum='Number' colpctsum='Pct.'*f=comma10.1 )
      / indent=3 rts=80 box='Summary categories';
    format Icd&icdv._3d $Icd&icdv.s.;
    title2 "Deaths to All Age Groups, &year";

  run;
  
  proc tabulate data=Vital.Deaths_&year format=comma10.0 noseps missing order=unformatted;
    class Icd&icdv._3d Icd&icdv._4d / preloadfmt order=data;
    var deaths_total;
    table all='TOTAL' Icd&icdv._3d * Icd&icdv._4d,
      deaths_total * ( sum='Number' colpctsum='Pct.'*f=comma10.1 ) 
      / indent=3 rts=90 box='Detailed categories';

  run;
  
  proc tabulate data=Vital.Deaths_&year format=comma10.0 noseps missing order=freq;
    where deaths_infant;
    class Icd&icdv._3d Icd&icdv._4d;
    var deaths_total;
    table all='TOTAL' Icd&icdv._3d,
      deaths_total * ( sum='Number' colpctsum='Pct.'*f=comma10.1 )
      / indent=3 rts=80 box='Summary categories';
    format Icd&icdv._3d $Icd&icdv.s.;
    title2 "Deaths to infants (<1 year), &year";

  proc tabulate data=Vital.Deaths_&year format=comma10.0 noseps missing order=freq;
    where deaths_infant;
    class Icd&icdv._3d Icd&icdv._4d;
    var deaths_total;
    table all='TOTAL' Icd&icdv._3d * Icd&icdv._4d,
      deaths_total * ( sum='Number' colpctsum='Pct.'*f=comma10.1 ) 
      / indent=3 rts=90 box='Detailed categories';
    format Icd&icdv._3d $Icd&icdv.s.;

  run;
  
  proc tabulate data=Vital.Deaths_&year format=comma10.0 noseps missing order=freq;
    where deaths_15to19;
    class Icd&icdv._3d Icd&icdv._4d;
    var deaths_total;
    table all='TOTAL' Icd&icdv._3d,
      deaths_total * ( sum='Number' colpctsum='Pct.'*f=comma10.1 )
      / indent=3 rts=80 box='Summary categories';
    format Icd&icdv._3d $Icd&icdv.s.;
    title2 "Deaths to persons (15-19 years), &year";

  run;
  
  proc tabulate data=Vital.Deaths_&year format=comma10.0 noseps missing order=freq;
    where deaths_20to24;
    class Icd&icdv._3d Icd&icdv._4d;
    var deaths_total;
    table all='TOTAL' Icd&icdv._3d,
      deaths_total * ( sum='Number' colpctsum='Pct.'*f=comma10.1 )
      / indent=3 rts=80 box='Summary categories';
    format Icd&icdv._3d $Icd&icdv.s.;
    title2 "Deaths to persons (20-24 years), &year";

  run;
  
%exit:
  
%mend Read_deaths;

/** End Macro Definition **/

