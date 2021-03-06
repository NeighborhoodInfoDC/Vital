/**************************************************************************
 Program:  Births_2003_2008_New.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  6/4/18
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
data births_in;
	set vitalraw.B0308final;

	** Temporary ID  number **;
	XID + 1;

	** Convert some character variables to numeric **;
	mage_n = 1 * mage;
	bweight_n = 1 * bweight;
	gest_age_n = 1 * gest_age;
	num_visit_n = 1 * num_visit;
	pre_care_n = 1 * pre_care;
	plural_n = 1* plural;
	Year = 1 * birthyr ;

	drop mage bweight gest_age num_visit;

	** Code missings **;
	if mage_n = 99 then mage_n = .u;
	if bweight_n = 9999 then bweight_n = .u;
	if gest_age_n = 99 then gest_age_n = .u;
	if num_visit_n = 99 then num_visit_n = .u;
	if pre_care_n = 99 then pre_care_n = .u;
	if plural_n in (9,99) then plural_n = .u;


	 ** Check birth dates **;
  
	if not missing( date ) and year( date ) ~= 1 * birthyr then do;
		%warn_put( msg="Birth date in wrong year: " _n_= date= birthyr= birthmo= birthdy= )
	end;

	** Record race and ethnicity **;
	if mrace = "White" then mrace_num = 1;
		else if mrace = "Black" then mrace_num = 2;
		else if mrace = "Asian/Other" then mrace_num=4;
		else mrace_num = 0;

	if latino_new = "Non-Hispanic" then latino = "N";
		else if latino_new = "Unknown" then latino ="N";
		else if latino_new = "Hispanic" then latino = "Y";

	** Recode marital status **;
	if mstatnew = "Married" then mstat = "Y";
		else if mstatnew = "Unmarried" then mstat = "N";

	  if 0 < mage_n < 20 then kMage = 1;
  		else if 20 <= mage_n then kMage = 0;
  
  	if 0 < bweight_n < 2500 then kbweight = 1;
  		else if 2500 <= bweight_n then kbweight = 0;

	** Convert weight to lbs **;
	if not( missing( bweight_n ) ) then 
      Bweight_lbs = bweight_n * 0.00220462262;
    else 
      Bweight_lbs = .u;


	** Remove WASHINGTON from address strings **;
	address=tranwrd(address, "NWWASHINGTON", "NW");
	address=tranwrd(address, "NEWASHINGTON", "NE");
	address=tranwrd(address, "SWWASHINGTON", "SW");
	address=tranwrd(address, "SEWASHINGTON", "SE");
	address=tranwrd(address, "WASHINGTON DC", " ");
	address=tranwrd(address, "WASH DC", " ");

	length fedtractno_ $ 3;
	fedtractno_ = fedtractno;
	
	if ward not in ( "1", "2", "3", "4", "5", "6", "7", "8" ) then ward = "";
    
  
  	format date mmddyy10. fedtractno_ $3.;

	drop mage bweight gest_age num_visit pre_care plural;

	%macro makevars ();
	%do j=1 %to 99;
	%let idvar = %scan(&idlist. , &j., ' ');
	%let cleanvar = %scan(&cleanlist. , &j., ' ');

	if xid = &idvar. then address = "&cleanvar.";

	%end;
	%mend makevars;


run;

/* Import cleaned addresses list */
proc import 
	datafile="&_dcdata_r_path\Vital\Raw\2018\addressfix2003-2008.csv" dbms=dlm out=addressfix;
    delimiter=',';
    getnames=yes;
run;

/* Merge on cleaned addresses */
proc sql;
	CREATE TABLE births_m AS
	SELECT *
	FROM births_in FULL JOIN addressfix
	on births_in.XID=addressfix.XID;
quit;

/* Correct bad addresses */
data births;
	set births_m;
	if CleanAddress ^= " " then do;
		address = CleanAddress;
	end;
run;


proc format;
  value $blank
    ' ' = 'Blank'
    other = 'Not blank';
run;

title2 '**** Missing geo data in source files ****';

proc tabulate data=births format=comma12.0 noseps missing;
  class birthyr address ward;
  table 
    /** Rows **/
    birthyr='Year',
    /** Columns **/
    n='Total records' * all=' '
    ( n='Addresses' rowpctn='%' * f=comma12.1 ) * address=' '
  ;
  table 
    /** Rows **/
    birthyr='Year',
    /** Columns **/
    n='Total records' * all=' '
    ( n='Wards (source data)' rowpctn='%' * f=comma12.1 ) * ward=' '
  ;
  format address ward $blank.;
run;

title2;

** Geocode the records **;
%DC_mar_geocode(
  debug=n,
  listunmatched=N,
  streetalt_file = &_dcdata_default_path\Vital\Prog\StreetAlt_041918_new.txt,
  data = births,
  staddr = address,
  out = births_geo,
  stnamenotfound_export = &_dcdata_default_path\Vital\Prog\Births_2003_2008_new_stnamenotfound.csv
);


** Subset  records that didn't match, use provided tract ID to create geo2010 **;
data births_geo_nomatch;
	set births_geo (drop=address_std y x ADDRESS_ID Anc2002 Anc2012 Cluster_tr2000 Geo2000 Geo2010 GeoBg2010 GeoBlk2010 
						 Psa2004 Psa2012 SSL VoterPre2012 Ward2002 Ward2012 bridgepk stantoncommons cluster2017 
						 M_CITY M_STATE M_ZIP M_OBS
						 _STATUS_ _NOTES_ _SCORE_);
	if M_ADDR = " " ;

	** Create Geo2010 from fedtractno **;
	*if fedtractno in ("000","999"," ") then delete;
	*geo2010 = "11"||"001"||"00"||fedtractno_||"0"; 

	tract = fedtractno;
	%Convert_dc_tracts( births, 2008 );
	
	length Geo2010 $ 11;
	
	if tract_yr = 2010 then Geo2010 = tract_full;

run;

data births_geo_2008_ward_notract births_geo_other;

  set births_geo_nomatch;
  ward_ = ward +0;
  
  if missing( geo2010 ) and not( missing( ward ) ) and birthyr = '2008' 
    then output births_geo_2008_ward_notract;
  else output births_geo_other;
  
run;


** Subset records that matched **;
data births_geo_match;
	set births_geo;
	if M_ADDR ^= " " ;
    retain hotdeck_wt 1;
    city = "1";

  	zip = put(m_zip,z5.);
	format zip $zipa.;
	label zip = "ZIP code (5-digit)";
run;


%Hot_deck2( 
  by=Ward,
  data=births_geo_2008_ward_notract, 
  source=births_geo_match (where=(birthyr='2008')), 
  alloc=geo2010, 
  weight=hotdeck_wt, 
  out=births_geo_2008_ward_notract_hd,
  print=n
)  


data births_geo_nomatch_hotdeck;

  set 
    births_geo_other
    births_geo_2008_ward_notract_hd;
  
  label geo2010_alloc = 'Census tract (GEO2010) was allocated';
  
  format geo2010_alloc dyesno.;
      
run;


%tr10_to_stdgeos( 
  in_ds=births_geo_nomatch_hotdeck, 
  out_ds=births_geo_std
);


** Combine matched and non-matched files back together **;
data births_geo_all;
	set births_geo_match (drop=hotdeck_wt) births_geo_std (where=(geo2010^=""));
	
	if missing( geo2010_alloc ) then geo2010_alloc = 0;

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
;

	drop mage_n bweight_n gest_age_n num_visit_n pre_care_n
		 birthmo birthdy kbweight kmage plural_n
		 address address_std address_id x y ssl latitude longitude 
		 m_addr m_state m_city m_zip m_obs _matched_ _status_ _notes_ _score_
		 tract Dctract Tract_full Tract_yr ward_ _label_ XID;


run;

title2 '**** Check HOTDECK allocation results ****';

proc tabulate data=births_geo_all format=comma12.0 noseps missing;
  where birthyr = '2008' and not( missing( ward2012 ) );
  class birthyr ward2012 geo2010 geo2010_alloc;
  table 
    /** Pages **/
    birthyr=' ' * ward2012=' ',
    /** Rows **/
    all='Total records' * n=' '
    Geo2010='% by tract' * colpctn=' ' * f=comma12.1,
    /** Columns **/
    Geo2010_alloc='Allocated?'
    / condense;
run;

title2; 


title2 '**** Records with ward filled in after geocoding and allocations ****';

proc tabulate data=births_geo_all format=comma12.0 noseps missing;
  class birthyr ward2012;
  table 
    /** Rows **/
    birthyr='Year',
    /** Columns **/
    n='Total' * all=' '
    ( n='Wards (2012)' rowpctn='%' * f=comma12.1 ) * ward2012=' '
  ;
  format ward2012 $blank.;
run;

title2;


%macro finalize_by_year;

%do year = 2003 %to 2008;

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
  printobs=0,
  freqvars=birthyr ward2012 mrace mstatnew meducatn
  );


%end;

%mend finalize_by_year;

%finalize_by_year;
