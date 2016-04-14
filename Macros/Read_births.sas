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
 
 Currently supports years 1998-2008.

 Modifications:
  09/15/06  Revised vars counting race reporting.
  09/26/06  Revised race labels.
  06/04/07  Added preterm births (<37 gestational weeks)
  09/17/09  Updated with new marital status formats.
  08/11/11  PAT Corrected errors in macro code.
  08/15/11  RP Updated to include 2008 births.
  08/16/11  RP Added %By_age macro for summary variables.
  02/28/13	BL added 99 option in plural=.u
  04/12/13  PAT Added support for 2010 census tracts for 2010 or later.
**************************************************************************/

/** Macro Read_births - Start Definition **/


%macro Read_births( 
  infile=, 
  year=, 
  path=&_dcdata_path\Vital\Raw );
  
  %let GRAMS_TO_LBS = 0.00220462262;

  %let FIRST_YEAR_LATINO = 2001;
  %let FIRST_YEAR_PRENATAL = 1999;
  %let FIRST_YEAR_PLURAL = 1999;
  %let FIRST_YEAR_MSTAT = 2002;
  %let FIRST_YEAR_ALCOHOL = 2003;
  %let LAST_YEAR_ALCOHOL = 2008;
  %let FIRST_YEAR_TOBACCO = 2003;
  %let FIRST_YEAR_GEST_AGE = 1999;
  
  data withTracts 
       noTractsnoWard (drop=Tract_Key Tract_full Tract_yr) 
       noTractsWard (drop=Tract_Key Tract_full Tract_yr);  
  
    retain Year &year;
    
    label year = 'Year of birth';

  infile "&path\&infile" stopover lrecl=65000;
    
    ** Read data from raw file **;
  
    ** Use appropriate macro for reading in files of different years **;
 %if &year >= 2009 %then %do;
      %Input_births_09
	  %end;
	%else %if &year = 2008 %then %do;
      %Input_births_08
    %end;
    %else %if &year = 2007 %then %do;
      %Input_births_07
    %end;
    %else %if &year >= 2003 and &year <= 2006 %then %do;
      %Input_births_03
    %end;
    %else %if &year = 2002 %then %do;
      %Input_births_02
    %end;
    %else %if &year = 2001 %then %do;
      %Input_births_01
    %end;
    %else %if &year = 1999 or &year = 2000 %then %do;
      %Input_births_00
    %end;
    %else %if &year = 1998 %then %do;
      %Input_births_98
    %end;
    %else %do;
      %err_mput( macro=Read_births, 
                 msg=Macro does not support files for YEAR=&year )
      abort;
      %goto exit;
    %end;
    
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
      %if  &year >= &FIRST_YEAR_MSTAT %then %do;
        Mstat
      %end;
      %if &year >= &FIRST_YEAR_TOBACCO %then %do;
        Mtobaccouse
      %end;
	  %if &LAST_YEAR_ALCOHOL >= &year >= &FIRST_YEAR_ALCOHOL %then %do;
        Malcoholuse
      %end;
    ;

    do i = 1 to dim( missv2 );
      missv2{i} = upcase( missv2{i} );
      if missv2{i} not in ( "Y", "N" ) then missv2{i} = "";
    end;
    
    ** Other numeric vars **;
    
    %if &year >= &FIRST_YEAR_PLURAL %then %do;
      if Plural in ( 9, 99 ) then Plural = .u;
    %end;
    
    %if &year >= &FIRST_YEAR_PRENATAL %then %do;
      if num_visit = 0 then pre_care = .n;
      if gest_age = 0 then gest_age = .u;
    %end;
    
    if bweight = 9999 then bweight = .u;
    
    %if &year <= 2007 %then %do;
      if tract = 999 then tract = 0;
    %end;

    
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
    
    length tract_full $ 11;
    
    %if &year <= 2007 %then %do;
          ** 2007 or earlier data: DC tract identifiers, various tract defs. **;
          %Convert_dc_tracts( births, &year )
    %end;
    %else %if 2010 > &year >= 2008 %then %do;
    
    		  ** 2008-09 data: 2000 tracts **;
    
              %Fedtractno_geo2000
		  tract_full = geo2000;
		  tract_yr=2000;
		  label 
   			 tract_full = "Mother's census tract of residence: ssccctttttt (UI Recode)"
			 tract_yr ="Year of census tract definition (UI recode)";
		  drop geo2000;
    %end;
    %else %if &year = 2010 %then %do;
    
    		  ** 2010 data: Mix of 2010 and 2000 tracts **;

		  tract_full = put( "11001" || put( 100 * input( Fedtractno, 16. ), z6. ), $geo10v. );
		  
		  if tract_full ~= "" then do;
		    tract_yr=2010;
		  end;
		  else do;
                %Fedtractno_geo2000
		    tract_full = geo2000;
		    tract_yr=2000;
		  end;
		  
		  drop geo2000;
		  label 
   			 tract_full = "Mother's census tract of residence: ssccctttttt (UI Recode)"
			 tract_yr ="Year of census tract definition (UI recode)";

    %end;
    %else %if &year > 2010 %then %do;
    
    		  ** 2011 or later data: 2010 tracts **;

		  tract_full = put( "11001" || put( 100 * input( Fedtractno, 16. ), z6. ), $geo10v. );
		  tract_yr=2010;
		  label 
   			 tract_full = "Mother's census tract of residence: ssccctttttt (UI Recode)"
			 tract_yr ="Year of census tract definition (UI recode)";

    %end;
    
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

      if mage < 15 then Births_0to14 = 1;
      else Births_0to14 = 0;

	  if 15 <= mage <= 19 then Births_15to19 = 1;
      else Births_15to19 = 0;

      if 20 <= mage <= 24 then Births_20to24 = 1;
      else Births_20to24 = 0;

	  if 25 <= mage <= 29 then Births_25to29 = 1;
      else Births_25to29 = 0;

	  if 30 <= mage <= 34 then Births_30to34 = 1;
      else Births_30to34 = 0;

	  if 35 <= mage <= 39 then Births_35to39 = 1;
      else Births_35to39 = 0;

	  if 40 <= mage <= 44 then Births_40to44 = 1;
      else Births_40to44 = 0;

	  if mage >= 45 then Births_45plus = 1;
      else Births_45plus = 0;
    
      if mage < 20 then Births_teen = 1;
      else Births_teen = 0;
    
      if mage < 18 then Births_under18 = 1;
      else Births_under18 = 0;
  
    
    end;
    else do;
      Births_w_age = 0;
    end;
    
    label 
      Births_Teen = "Births to mothers under 20 years old"
      Births_under18 = "Births to mothers under 18 years old"
      Births_0to14 = "Births to mothers under 15 years old"
	  Births_15to19 = "Births to mothers 15-19 years old"
      Births_20to24 = "Births to mothers 20-24 years old"
	  Births_25to29 = "Births to mothers 25-29 years old"
	  Births_30to34 = "Births to mothers 30-34 years old"
	  Births_35to39 = "Births to mothers 35-39 years old"
	  Births_40to44 = "Births to mothers 40-44 years old"
	  Births_45plus = "Births to mothers 45 and over years old"
      Births_w_age = "Births with mother's age reported";
    
    %if &year >= &FIRST_YEAR_LATINO %then %do;
      %By_race( Births_teen, under 20 years old, Births )
      %By_race( Births_under18, under 18 years old, Births )
      %By_race( Births_0to14, under 15 years old, Births )
	  %By_race( Births_15to19, 15-19 years old, Births )
      %By_race( Births_20to24, 20-24 years old, Births )
	  %By_race( Births_25to29, 25-29 years old, Births )
	  %By_race( Births_30to34, 30-34 years old, Births )
	  %By_race( Births_35to39, 35-39 years old, Births )
	  %By_race( Births_40to44, 40-44 years old, Births )
	  %By_race( Births_45plus, 45 and over years old, Births )
      %By_race( Births_w_age, with age reported, Births )
    %end;
    
	if Births_w_age = 1 and Births_w_race = 1 then Births_w_agerace = 1;
	else Births_w_agerace = 0;

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

      %By_age( Births_low_wt, with low birth weight (<5.5 lbs), Births )
      %By_age( Births_w_weight, with birth weight reported, Births )

    ** Single mother births **;
    
    %if &year >= 2002 %then %do;
    
      if Mstat in ( 'N', 'Y', '1', '2' ) then do;
        if Mstat in ( 'N', '2' ) then Births_single = 1;
        else Births_single = 0;
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

        %By_age( Births_single, who were unmarried, Births )
        %By_age( Births_w_mstat, with marital status reported, Births )

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
      
        %By_age( Births_prenat_1st, with prenatal care in 1st trimester, Births )
        %By_age( Births_prenat_adeq, with adequate prenatal care, Births )
        %By_age( Births_prenat_intr, with intermediate prenatal care, Births )
        %By_age( Births_prenat_inad, with inadequate prenatal care, Births )
        %By_age( Births_w_prenat, with prenatal care reported, Births )

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
        Births_w_gest_age = "Births with gestational age reported"
		Births_w_agerace= "Births with mother's age and race reported"
		
;

      %if &year >= &FIRST_YEAR_LATINO %then %do;
        %By_race( Births_preterm, that occured preterm, Births )
        %By_race( Births_w_gest_age, with gestational age reported, Births )
	  %end;

        %By_age( Births_preterm, that occured preterm, Births )
        %By_age( Births_w_gest_age, with gestational age reported, Births )

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
        MEDUCATN MTobaccoUse /*MAlcoholUse*/ 
      %end;
   )
   
  proc univariate data=Vital.Births_&year nextrobs=20;
    var bweight;
 
  %exit:
  
%mend Read_births;

/** End Macro Definition **/

