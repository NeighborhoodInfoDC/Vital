/**************************************************************************
 Program:  Read_deaths_new.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  6/4/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Macro to create indicators for deaths_yyyy

 Modifications:
**************************************************************************/

%macro Read_deaths_new (
calc_sex=Y,
calc_race=Y,
calc_age=Y,
calc_cause=Y
);

%let calc_sex = %upcase(&calc_sex.);
%let calc_race = %upcase(&calc_race.);
%let calc_age = %upcase(&calc_age.);
%let calc_cause = %upcase(&calc_cause.);

	** Total deaths **;

	length Deaths_total 3;
    
    Deaths_total = 1;
    
    label Deaths_total = "Total deaths";
    
	%if &calc_sex. = Y %then %do;

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

	%if &calc_race. = Y %then %do;
    
      ** By race/ethnicity **;
      
      if not( missing( latino ) ) and not( missing( Race_n ) ) then do;
      
        Deaths_white = 0;
        Deaths_black = 0;
        Deaths_hisp = 0;
        Deaths_asian = 0;
        Deaths_oth_rac = 0;

        Deaths_w_race = 1;
      
        if latino = "N" then do;
        
          select( Race_n );
            when ( 1 ) Deaths_white = 1;
            when ( 2 ) Deaths_black = 1;
            when ( 3) Deaths_asian = 1;
            when ( 4 ) Deaths_oth_rac = 1;
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

	%if &calc_age. = Y %then %do;
    
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
    
	  %if &calc_race. = Y %then %do;
      %By_race( Deaths_infant, under 1 year old, Deaths, var2=deaths, pop=infants )
      %By_race( Deaths_under18, under 18 years old, Deaths, var2=deaths, pop=children )
      %By_race( Deaths_adult, 18+ years old, Deaths, var2=deaths, pop=adults )
      %By_race( Deaths_senior, 65+ years old, Deaths, var2=deaths, pop=seniors )
      %By_race( Deaths_1to14, 1-14 years old, Deaths, var2=deaths, pop=children )
      %By_race( Deaths_15to19, 15-19 years old, Deaths, var2=deaths, pop=persons )
      %By_race( Deaths_20to24, 20-24 years old, Deaths, var2=deaths, pop=persons )
      %By_race( Deaths_w_age, with age reported, Deaths, var2=deaths, pop=persons )
      %end;

	  %if &calc_sex. = Y %then %do;
      %By_sex( Deaths_15to19, 15-19 years old )
      %By_sex( Deaths_20to24, 20-24 years old )
      Deaths_15to19_w_sex  = Deaths_15to19 * Deaths_w_sex;
      Deaths_20to24_w_sex  = Deaths_20to24 * Deaths_w_sex;
      label
        Deaths_15to19_w_sex  = "Deaths to persons 15-19 years old with sex reported"
        Deaths_20to24_w_sex  = "Deaths to persons 20-24 years old with sex reported";
	  %end;
	%end;

	%if &calc_cause. = Y %then %do;
    
    ** By cause of death **;
    
    if not( missing( put( Icd10_3d, $icd10s. ) ) ) then do;
    
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
      
	  %if &calc_sex. = Y %then %do;
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

	   ** Violent crimes by sex **;
       %By_sex( Deaths_violent, , type=Violent deaths )
      %end;

	 %if &calc_race. = Y %then %do;
     ** Violent crimes by race **;
        %By_race( Deaths_violent, ,Violent deaths, var2=deaths, pop=persons )
      %end;

	  %if &calc_age. = Y %then %do;

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

	  %end;

%mend Read_deaths_new;


/* End of macro definition */
