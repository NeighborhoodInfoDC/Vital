/**************************************************************************
 Program:  Deaths_2009_2016_New.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  6/19/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Read-in raw dath data and create deaths_yyyy

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital )
%DCData_lib( MAR )

libname vitalraw "&_dcdata_r_path\Vital\Raw\2018";

%let revisions = New File;


** Read raw data and clean some of the variables **;
data deaths;
	set vitalraw.D0916final;

	** Convert some character variables to numeric **;
	 Age_n = 1 * Age;

	** Code missings **;
	if age_n = 99 then age_n = .u;

	** Recoded Hispanic status **;
    if latino_dec = "Hispanic" then Latino = "Y";
    else if latino_dec = "Non-Hispanic" then Latino = "N";
	else Latino = " ";
	
    ** Create 3-digit death code **;
    Icd10_4d = left( compress( upcase( Icd10_4d ), '-' ) );
    
    * Remove trailing X character **;
    if substr( reverse( Icd10_4d ), 1, 1 ) = 'X' then
      Icd10_4d = substr( Icd10_4d, 1, length( Icd10_4d ) - 1 );
      
    length Icd10_3d $ 3;
    
    Icd10_3d = Icd10_4d;
    
    label Icd10_3d = "Cause of death (ICD-10, 3-digit)";
    
    format Icd10_3d $Icd103a.;

	 ** Format date of death **;
	xdmonth = put(input(dmonth,best2.),z2.);
	xdday = put(input(dday,best2.),z2.);
	xdyear = put(input(dyear,best4.),z4.);

	xDeath_dt = xdmonth || "-" || xdday || "-" || xdyear;
	Death_dt = input(xDeath_dt,mmddyy10.);

	format Death_dt mmddyy10.;
	drop xdmonth xdday xdyear xDeath_dt;

	 ** Format date of birth **;
	xbmonth = put(input(bmonth,best2.),z2.);
	xbday = put(input(bday,best2.),z2.);
	xbyear = put(input(byear,best4.),z4.);

	xBirth_dt = xbmonth || "-" || xbday || "-" || xbyear;
	Birth_dt = input(xBirth_dt,mmddyy10.);

	format Birth_dt mmddyy10.;
	drop xbmonth xbday xbyear xBirth_dt;

	** Calculate age at death **;
	age_calc = ( Death_dt - Birth_dt ) / 365.25;

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
            %warn_put( msg='Invalid age unit of time: ' age_unit= age= Birth_dt= Death_dt= Age_calc= Icd10_3d= )
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


	 

run;


** Geocode the records **;
%DC_mar_geocode(
  debug=n,
  listunmatched=N,
  streetalt_file = &_dcdata_default_path\Vital\Prog\StreetAlt_041918_new.txt,
  data = deaths,
  staddr = address,
  out = deaths_geo
);


** Subset  records that didn't match, use provided tract ID to create geo2010 **;
data deaths_geo_nomatch;
	set deaths_geo (drop=address_std y x ADDRESS_ID Anc2002 Anc2012 Cluster_tr2000 Geo2000 Geo2010 GeoBg2010 GeoBlk2010 
						 Psa2004 Psa2012 SSL VoterPre2012 Ward2002 Ward2012 M_CITY M_STATE M_ZIP M_OBS
						 _STATUS_ _NOTES_ _SCORE_);
	if M_ADDR = " " ;

	tract2 = compress(tract,,'p');
	tract3 = put(input(tract2,best4.),z4.);
	geo2010 = "11"||"001"||"00"||tract3;

	/** Create Geo2010 from fedtractno **;
	if fedtractno in ("000000","999999"," ") then delete;
	geo2010 = "11"||"001"||fedtractno;
	format geo2010 $11.;*/

run;

%tr10_to_stdgeos( 
  in_ds=births_geo_nomatch, 
  out_ds=births_geo_std
);


** Subset ungeocodable records**;
data births_ungeocodable;
	set births_geo (keep = address fedtractno m_addr);
	if fedtractno in ("000000","999999"," ") and m_addr = " " ;
run;


** Subset records that matched **;
data births_geo_match;
	set births_geo;
	if M_ADDR ^= " " ;

	city = "1";
run;


** Combine matched and non-matched files back together **;
data births_geo_all;
	set births_geo_match births_geo_std;

	mage = mage_n;
	bweight = bweight_n;
	gest_age = gest_age_n ;
	num_visit = num_visit_n;
	pre_care = pre_care_n;
	plural = plural_n;

	%Read_births_new ();

	label mrace = "Mother's race"
	      mage = "Mother's age at birth (years)"
		  Bweight_lbs = "Child's birth weight (lbs)"
		  bweight = "Child's birth weight (grams)"
		  latino = "Mother's Hispanic/Latino origin"
		  mstat = "Mother's marital status"
		  num_visit = "Number of prenatal visits"
		  year = "Year of birth"
		  gest_age = "Gestational age of child (weeks)"
		  mrace_num = "Mother's race UI re-code"
		  ward = "Mother's ward of residence"
		  concept_dt = "Date Conceived (UI estimated)"
		  pre_care = "Weeks in to Pregnancy of first Prenatal Visit"
		  plural = "Count of single/plural births"
;

	drop mage_n bweight_n gest_age_n num_visit_n pre_care_n
		 birthmo birthdy kbweight kmage plural_n
		 address address_std address_id x y ssl latitude longitude 
		 m_addr m_state m_city m_zip m_obs _matched_ _status_ _notes_ _score_;

run;


%macro finalize_by_year;

%do year = 2010 %to 2016;

data births_&year.;
	set Births_geo_all (where=(year = &year.));

	** UI created  record number **;
	RecordNo + 1;
    label RecordNo = "Record number (UI created)";

run;

%Finalize_data_set( 
  data=births_&year.,
  out=births_&year.,
  outlib=vital,
  label="Individual birth records, &year, DC",
  sortby=RecordNo,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions.),
  /** File info parameters **/
  printobs=5,
  freqvars=birthyr ward2012 mrace mstatnew meducatn
  );


%end;

%mend finalize_by_year;
%finalize_by_year;
