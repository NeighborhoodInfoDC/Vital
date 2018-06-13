/**************************************************************************
 Program:  Read_births_new.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  6/4/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Macro to create indicators for births_yyyy

 Modifications:
**************************************************************************/

%macro Read_births_new (
calc_birthwt=Y,
calc_single=Y,
calc_prenat=Y,
calc_preterm=Y
);

%let calc_birthwt = %upcase(&calc_birthwt.);
%let calc_single = %upcase(&calc_single.);
%let calc_prenat = %upcase(&calc_prenat.);
%let calc_preterm = %upcase(&calc_preterm.);

	** Total births **;
	Births_total = 1;
    label Births_total = "Total births";

	** Births by race / ethnicity **;

	if not( missing( latino ) ) and not( missing( mrace_num ) ) then do;
    
      Births_white = 0;
      Births_black = 0;
      Births_hisp = 0;
      Births_asian = 0;
      Births_oth_rac = 0;

      Births_w_race = 1;
    
      if latino = "N" then do;
      
        select( mrace_num );
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


	** Births by age of mother **;
    
    if not( missing( mage_n ) ) then do;

      Births_w_age = 1;

      if mage_n < 15 then Births_0to14 = 1;
      else Births_0to14 = 0;

	  if 15 <= mage_n <= 19 then Births_15to19 = 1;
      else Births_15to19 = 0;

      if 20 <= mage_n <= 24 then Births_20to24 = 1;
      else Births_20to24 = 0;

	  if 25 <= mage_n <= 29 then Births_25to29 = 1;
      else Births_25to29 = 0;

	  if 30 <= mage_n <= 34 then Births_30to34 = 1;
      else Births_30to34 = 0;

	  if 35 <= mage_n <= 39 then Births_35to39 = 1;
      else Births_35to39 = 0;

	  if 40 <= mage_n <= 44 then Births_40to44 = 1;
      else Births_40to44 = 0;

	  if mage_n >= 45 then Births_45plus = 1;
      else Births_45plus = 0;
    
      if mage_n < 20 then Births_teen = 1;
      else Births_teen = 0;
    
      if mage_n < 18 then Births_under18 = 1;
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

	** Births by age AND race **;
	  %By_race( Births_teen, under 20 years old, Births );
      %By_race( Births_under18, under 18 years old, Births );
      %By_race( Births_0to14, under 15 years old, Births );
	  %By_race( Births_15to19, 15-19 years old, Births );
      %By_race( Births_20to24, 20-24 years old, Births );
	  %By_race( Births_25to29, 25-29 years old, Births );
	  %By_race( Births_30to34, 30-34 years old, Births );
	  %By_race( Births_35to39, 35-39 years old, Births );
	  %By_race( Births_40to44, 40-44 years old, Births );
	  %By_race( Births_45plus, 45 and over years old, Births );
      %By_race( Births_w_age, with age reported, Births );

	if Births_w_age = 1 and Births_w_race = 1 then Births_w_agerace = 1;
		else Births_w_agerace = 0;

	label Births_w_agerace = "Births with age and race reported";

	%if &calc_birthwt. = Y %then %do;

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

	** By birth weight AND race **;
	%By_race( Births_low_wt, with low birth weight (<5.5 lbs), Births );
    %By_race( Births_w_weight, with birth weight reported, Births );

	** By birth weight AND age **;
	%By_age( Births_low_wt, with low birth weight (<5.5 lbs), Births );
    %By_age( Births_w_weight, with birth weight reported, Births );

	%end; 

	%if &calc_single. = Y %then %do;
	  ** Single mother births **;
    
      if Mstat in ( 1, 2 ) then do;
        if Mstat in ( 2 ) then Births_single = 1;
        else Births_single = 0;
        Births_w_mstat = 1;
      end;
      else if missing( Mstat ) then do;
        Births_w_mstat = 0;
      end;

      label
        Births_Single = "Births to unmarried mothers"
        Births_w_mstat = "Births with mother's marital status reported";

	** Single mother births by race **;
        %By_race( Births_single, who were unmarried, Births );
        %By_race( Births_w_mstat, with marital status reported, Births );

	** Single mother births by age **;
        %By_age( Births_single, who were unmarried, Births );
        %By_age( Births_w_mstat, with marital status reported, Births );

	%end;

	%if &calc_prenat. = Y %then %do;

	** Prenatal care **;

	pre_care = pre_care_n;
          
      %Prenatal_kessner()
      
        %By_race( Births_prenat_1st, with prenatal care in 1st trimester, Births );
        %By_race( Births_prenat_adeq, with adequate prenatal care, Births );
        %By_race( Births_prenat_intr, with intermediate prenatal care, Births );
        %By_race( Births_prenat_inad, with inadequate prenatal care, Births );
        %By_race( Births_w_prenat, with prenatal care reported, Births );
      
        %By_age( Births_prenat_1st, with prenatal care in 1st trimester, Births );
        %By_age( Births_prenat_adeq, with adequate prenatal care, Births );
        %By_age( Births_prenat_intr, with intermediate prenatal care, Births );
        %By_age( Births_prenat_inad, with inadequate prenatal care, Births );
        %By_age( Births_w_prenat, with prenatal care reported, Births );

	%end;

	%if &calc_preterm. = Y %then %do;

   ** Preterm births **;

	gest_age = gest_age_n;
      
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

        %By_race( Births_preterm, that occured preterm, Births );
        %By_race( Births_w_gest_age, with gestational age reported, Births );

        %By_age( Births_preterm, that occured preterm, Births );
        %By_age( Births_w_gest_age, with gestational age reported, Births );

	%end;

run;

%mend Read_births_new;

/* End of macro definition */
