/**************************************************************************
 Program:  Births_2010_2016_New.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  5/31/18
 Version:  SAS 9.4
 Environment:  Windows with SAS/Connect
 
 Description:  Read-in raw birth data and create births_yyyy

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital )
%DCData_lib( MAR )

libname vitalraw "&_dcdata_r_path\Vital\Raw\2018";

%let revisions = New File;


** Read raw data and clean some of the variables **;
data births;
	set vitalraw.B1016final;

	** Convert some character variables to numeric **;
	mage_n = 1 * mage;
	bweight_n = 1 * bweight;
	gest_age_n = 1 * gest_age;
	num_visit_n = 1 * num_visit;
	Year = 1 * birthyr ;
	plural_n = 1* plural;

	drop mage bweight gest_age num_visit;

	** Code missings **;
	if mage_n = 99 then mage_n = .u;
	if bweight_n = 9999 then bweight_n = .u;
	if gest_age_n = 99 then gest_age_n = .u;
	if num_visit_n = 99 then num_visit_n = .u;
	if plural_n in (9,99) then plural_n = .u;

	 ** Check birth dates **;
  
	if not missing( date ) and year( date ) ~= 1 * birthyr then do;
		%warn_put( msg="Birth date in wrong year: " _n_= date= birthyr= birthmo= birthdy= )
	end;

	** Record race and ethnicity **;
	if mrace = "White" then mrace_num = 1;
		else if mrace = "Black" then mrace_num = 2;
		else if mrace = "Asian & Specific Isl" then mrace_num=4;
		else mrace_num = 0;

	if latino_new = "Non-Hispanic" then latino = "N";
		else if latino_new = "Missing" then latino ="N";
		else if latino_new = "Hispanic" then latino = "Y";

	** Recode marital status **;
	if mstatnew = "Married" then mstat = "Y";
		else if mstatnew = "Unmarried" then mstat = "N";

	** Fill in missing vars for 2010 - 2016 data **;
  
	concept_dt = intnx( 'week', date, -1 * gest_age_n, 'same' );
  
    pre_care_n = intck( 'week', concept_dt, dofp_date ) + 1;

	  if 0 < mage_n < 20 then kMage = 1;
  		else if 20 <= mage_n then kMage = 0;
  
  	if 0 < bweight_n < 2500 then kbweight = 1;
  		else if 2500 <= bweight_n then kbweight = 0;

	** Convert weight to lbs **;
	if not( missing( bweight_n ) ) then 
      Bweight_lbs = bweight_n * 0.00220462262;
    else 
      Bweight_lbs = .u;
    
  
  	format date concept_dt mmddyy10.;

	drop mage bweight gest_age num_visit pre_care plural;

run;


** Geocode the records **;
%DC_mar_geocode(
  debug=n,
  listunmatched=N,
  streetalt_file = &_dcdata_default_path\Vital\Prog\StreetAlt_041918_new.txt,
  data = births,
  staddr = address,
  out = births_geo
);

** Subset records that matched **;
data births_geo_match;
	set births_geo;
	if M_ADDR ^= " " ;
	city = "1";
	retain hotdeck_wt 1;

	zip = put(m_zip,z5.);
	format zip $zipa.;
	label zip = "ZIP code (5-digit)";
run;


** Subset  records that didn't match, use provided tract ID to create geo2010 **;
data births_geo_nomatch;
	set births_geo (drop=address_std y x ADDRESS_ID Anc2002 Anc2012 Cluster_tr2000 Geo2000 Geo2010 GeoBg2010 GeoBlk2010 
						 Psa2004 Psa2012 SSL VoterPre2012 Ward2002 Ward2012 M_CITY M_STATE M_ZIP M_OBS
						 _STATUS_ _NOTES_ _SCORE_);
	if M_ADDR = " " ;

	** Create Geo2010 from fedtractno **;
	if fedtractno in ("000000","999999"," ") then delete;
	geo2010 = "11"||"001"||fedtractno;
	format geo2010 $11.;

run;

%tr10_to_stdgeos( 
  in_ds=births_geo_nomatch, 
  out_ds=births_geo_std
);


** Subset ungeocodable records**;
data births_ungeocodable;
	set births_geo ;
	if fedtractno in ("000000","999999"," ") and m_addr = " " ;
run;

%Hot_deck2( 
  by=birthyr,
  data=births_ungeocodable, 
  source=births_geo_match, 
  alloc=geo2010, 
  weight=hotdeck_wt, 
  out=births_hd,
  print=n
)  





** Combine matched and non-matched files back together **;
data births_geo_all;
	set births_geo_match births_geo_std births_hd;

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
		 m_addr m_state m_city m_zip m_obs _matched_ _status_ _notes_ _score_ 
		 hotdeck_wt _label_;

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
