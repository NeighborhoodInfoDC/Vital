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
	 
	 If sex = "M" then sex_n = 1;
	 	else if sex = "F" then sex_n = 2;

	if race = "White" then race_n = 1;
		else if race = "Black" then race_n = 2;
		else if race = "Asian" then race_n = 3;
		else if race = "Other" then race_n = 4;
		else race_n = .;

	bday_n = 1* bday;
	bmonth_n = 1* bmonth;
	byear_n = 1* byear;

	dday_n = 1* dday;
	dmonth_n = 1* dmonth;
	dyear_n = 1* dyear;

	Year = 1* dyear;

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


	 drop sex bday bmonth byear dday dmonth dyear age;

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


/* Subset matched records */
data deaths_geo_match;
	set deaths_geo;
	if m_addr ^= " ";
	retain hotdeck_wt 1;
  	city = "1";
run;


** Subset  records that didn't match, use provided tract ID to create geo2010 **;
data deaths_geo_nomatch;
	set deaths_geo (drop=address_std y x ADDRESS_ID Anc2002 Anc2012 Cluster_tr2000 Geo2000 Geo2010 GeoBg2010 GeoBlk2010 
						 Psa2004 Psa2012 SSL VoterPre2012 Ward2002 Ward2012 bridgepk stantoncommons cluster2017 
					     M_CITY M_STATE M_ZIP M_OBS _STATUS_ _NOTES_ _SCORE_);
	if m_addr = " " ;

	/* Fix messed up tract codes */
	if year = 2013 then do;
		if tract = "0038" then tract_fix = "003800";
		if tract = "0097" then tract_fix = "009700";
		if tract = "0104" then tract_fix = "010400";
		if tract = "0109" then tract_fix = "010900";
		if tract_fix ^= " " then fixed = 1;
	end;

	if year = 2012 then do;
		if tract = "0024" then tract_fix = "002400";
		if tract = "0031" then tract_fix = "003100";
		if tract = "0043" then tract_fix = "004300";
		if tract = "0051" then tract_fix = "005100";
		if tract = "0055" then tract_fix = "005500";
		if tract = "0065" then tract_fix = "006500";
		if tract = "0067" then tract_fix = "006700";
		if tract = "0090" then tract_fix = "009000";
		if tract_fix ^= " " then fixed = 1;
	end;

	if year = 2011 then do;
		if tract = "0040" then tract_fix = "004000";
		if tract = "0090" then tract_fix = "009000";
		if tract_fix ^= " " then fixed = 1;

	end;

	if year = 2009 then do;
		tract=compress(tract,,'s');
		if tract = "." then tract_fix = " ";
		if tract = "1" then tract_fix = "000100";
		if tract = "10.01" then tract_fix = "001001";
		if tract = "11" then tract_fix = "001100";
		if tract = "110" then tract_fix = "011000";
		if tract = "36" then tract_fix = "003600";
		if tract = "37" then tract_fix = "003700";
		if tract = "39" then tract_fix = "003900";
		if tract = "46" then tract_fix = "004600";
		if tract = "47" then tract_fix = "004700";
		if tract = "50" then tract_fix = "005000";
		if tract = "51" then tract_fix = "005100";
		if tract = "56" then tract_fix = "005600";
		if tract = "58" then tract_fix = "005800";
		if tract = "64" then tract_fix = "006400";
		if tract = "67" then tract_fix = "006700";
		if tract = "90" then tract_fix = "009000";
		if tract = "110" then tract_fix = "011000";
		if tract = "7.01" then tract_fix = "000701";
		if tract = "10.01" then tract_fix = "001001";
		if tract = "13.02" then tract_fix = "001302";
		if tract = "14.01" then tract_fix = "001401";
		if tract = "18.03" then tract_fix = "001803";
		if tract = "18.04" then tract_fix = "001804";
		if tract = "19.01" then tract_fix = "001901";
		if tract = "19.02" then tract_fix = "001902";
		if tract = "21.01" then tract_fix = "002101";
		if tract = "21.02" then tract_fix = "002102";
		if tract = "23.01" then tract_fix = "002301";
		if tract = "23.02" then tract_fix = "002302";
		if tract = "25.01" then tract_fix = "002501";
		if tract = "27.01" then tract_fix = "002701";
		if tract = "28.02" then tract_fix = "002802";
		if tract = "40.01" then tract_fix = "004001";
		if tract = "48.01" then tract_fix = "004801";
		if tract = "48.02" then tract_fix = "004802";
		if tract = "68.02" then tract_fix = "006802";
		if tract = "73.02" then tract_fix = "007302";
		if tract = "74.04" then tract_fix = "007404";
		if tract = "74.06" then tract_fix = "007406";
		if tract = "75.02" then tract_fix = "007502";
		if tract = "75.03" then tract_fix = "007503";
		if tract = "76.04" then tract_fix = "007604";
		if tract = "76.05" then tract_fix = "007605";
		if tract = "77.03" then tract_fix = "007703";
		if tract = "77.09" then tract_fix = "007709";
		if tract = "78.04" then tract_fix = "007804";
		if tract = "78.08" then tract_fix = "007808";
		if tract = "79.01" then tract_fix = "007901";
		if tract = "89.03" then tract_fix = "008903";
		if tract = "92.03" then tract_fix = "009203";
		if tract = "95.03" then tract_fix = "009503";
		if tract = "95.05" then tract_fix = "009505";
		if tract = "95.07" then tract_fix = "009507";
		if tract = "95.09" then tract_fix = "009509";
		if tract = "96.03" then tract_fix = "009603";
		if tract = "96.04" then tract_fix = "009604";
		if tract = "98.07" then tract_fix = "009807";
		if tract = "98.08" then tract_fix = "009808";
		if tract = "99.02" then tract_fix = "009902";
		if tract = "99.06" then tract_fix = "009906";
		if tract in ("610","731","732","763","901","958") then tract_fix = " ";
		if tract_fix ^= " " then fixed = 1;
	end;

	if tract not in ("0000","9999"," ",".") and fixed ^= 1 then do;
		tract_fix = "00"||tract;
	end; 

	/* Create final geo2010 variable */
	if tract_fix ^= " "  then do;
		geo2010 = "11"||"001"||tract_fix;
	end;

run;

/* Append geos based on geo2010 */
%tr10_to_stdgeos( 
  in_ds=deaths_geo_nomatch, 
  out_ds=deaths_geo_std
);


** Subset ungeocodable records**;
data deaths_ungeocodable deaths_std_match;
	set deaths_geo_std ;
	if city = " " then output deaths_ungeocodable ;
		else output deaths_std_match;
run;


%Hot_deck2( 
  by=year,
  data=deaths_ungeocodable, 
  source=deaths_geo_match, 
  alloc=geo2010, 
  weight=hotdeck_wt, 
  out=deaths_geo_ward_notract_hd,
  print=n
)  


data deaths_geo_ward_notract_hd;
	set deaths_geo_ward_notract_hd;
	drop Anc2002 Anc2012 Cluster_tr2000 city Psa2004 Psa2012 VoterPre2012 Ward2002 Ward2012 bridgepk stantoncommons cluster2017 ;
	city = "1";
run;


/* Append geos based on geo2010 */
%tr10_to_stdgeos( 
  in_ds=deaths_geo_ward_notract_hd, 
  out_ds=deaths_geo_ward_notract_hd_std
);


** Combine matched and non-matched files back together **;
data deaths_geo_all;
	set deaths_geo_match deaths_std_match deaths_geo_ward_notract_hd_std;

	sex = sex_n;
	bday = bday_n;
	bmonth = bmonth_n;
	byear = byear_n;
	dday = dday_n;
	dmonth = dmonth_n;
	dyear = dyear_n;
	age = age_n;

	%read_deaths_new ();

	label age = "Age at death (see Age_unit for unit of time)"
		  age_calc = "Age at death (UI calculated, years)"
		  age_unit = "Unit of time for age at death"
		  Death_dt = "Date of death"
		  Birth_dt = "Date of birth" 
		  Tract = "Census tract (DOH provided)"
		  Latino = "Hispanic origin of deceased (UI recode)"
		  Race = "Race of deceased"
		  Sex = "Sex of deceased"
		  year = "Year of death"
		  bmonth = "Month of birth"
		  bday = "Day of birth"
		  byear = "Year of birth"
		  dmonth = "Month of death"
		  dday = "Day of death"
		  dyear = "Year of death"
	;

	drop sex_n age_n race_n bday_n bmonth_n byear_n dday_n dmonth_n dyear_n
		 address address_std address_id x y ssl latitude longitude 
		 hotdeck_wt tract_fix fixed _label_ geo2010_alloc
		 m_addr m_state m_city m_zip m_obs _matched_ _status_ _notes_ _score_;
      
run;



%macro finalize_by_year;

%do year = 2009 %to 2016;

data deaths_&year.;
	set deaths_geo_all (where=(year = &year.));

	** UI created  record number **;
	RecordNo + 1;
    label RecordNo = "Record number (UI created)";

run;

%Finalize_data_set( 
  data=deaths_&year.,
  out=deaths_&year.,
  outlib=vital,
  label="Individual death records, &year, DC",
  sortby=RecordNo,
  /** Metadata parameters **/
  restrictions=None,
  revisions=%str(&revisions.),
  /** File info parameters **/
  printobs=5,
  freqvars=year race latino_dec Icd10_3d
  );


%end;

%mend finalize_by_year;
%finalize_by_year;


/* End of program */
