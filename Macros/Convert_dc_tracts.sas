/**************************************************************************
 Program:  Convert_dc_tracts.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/14/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to convert 3-digit DC tract codes for
 vital statistics data to standard 11-digit Census codes.

 Modifications:
  09/23/06  Added parameters TYPE & YEAR
**************************************************************************/

/** Macro Convert_dc_tracts - Start Definition **/

%macro Convert_dc_tracts( type, year );

  %let type = %upcase( &type );

  ** DC tract code (3-digit, zero-padded) **;
  
  length Dctract $3.;
  dctract = put(tract, z3.0);
  
  ** Correct tract nos. **;
  
  if dctract = '972' then dctract = '792';
  else if dctract = '781' and ward = '8' then dctract = '731';
  else if dctract = '200' and ward = '2' then dctract = '201';
  else if dctract = '917' and ward = '1' then dctract = '';
  else if dctract = '998' and ward = ' ' then dctract = '';
  else if Dctract = '529' and Ward = '5' then dctract = '';
  else if Dctract = '799' and Ward = '8' then dctract = '';
  else if Dctract = '990' and Ward = '8' then dctract = '';
  
  label 
     DCtract = "Mother's census tract of residence (DC format, zero-padded)";
  
  ** Full tract code (11-digit) **;
  
  length Tract_full $ 11;
  
  tract_full = put( dctract, $vtrcnv. );

  %if &year >= 2005 %then %do;
   %*%if &type = BIRTHS %then %do;
  
    %** Birth records: Assume tracts are 2010 first **;
  
    if tract_full ~= "" then do;
	if put( tract_full, $geo10v. ) ~= "" then
        Tract_yr = 2010;
	else if put( tract_full, $geo00v. ) ~= "" then
        Tract_yr = 2000;
      else if put( tract_full, $geo90v. ) ~= "" then
        Tract_yr = 1990;
      else if put( tract_full, $geo80v. ) ~= "" then
        Tract_yr = 1980;
      else if put( tract_full, $geo70v. ) ~= "" then
        Tract_yr = 1970;
      else do;
        %warn_put( msg="Invalid tract ID: " _n_= dctract= tract_full= ward= )
        tract_full = "";
      end;
    end;
    else if dctract not in ( "", "000" ) then do;
        %warn_put( msg="Invalid tract ID: " _n_= dctract= ward= )
    end;
    
  %*%end;
  %end;
  %else %do;
  %if &type = BIRTHS %then %do;
  
    %** Birth records: Assume tracts are 1980 first **;
  
    if tract_full ~= "" then do;
      if put( tract_full, $geo80v. ) ~= "" then
        Tract_yr = 1980;
      else if put( tract_full, $geo90v. ) ~= "" then
        Tract_yr = 1990;
      else if put( tract_full, $geo70v. ) ~= "" then
        Tract_yr = 1970;
      else do;
        %warn_put( msg="Invalid tract ID: " _n_= dctract= tract_full= ward= )
        tract_full = "";
      end;
    end;
    else if dctract not in ( "", "000" ) then do;
        %warn_put( msg="Invalid tract ID: " _n_= dctract= ward= )
    end;
    
  %end;
  %else %if &type = DEATHS %then %do;
  
    %** Death records: Assume tracts are 1990 first **;
  
    if tract_full ~= "" then do;
      if put( tract_full, $geo90v. ) ~= "" then
        Tract_yr = 1990;
      else if put( tract_full, $geo80v. ) ~= "" then
        Tract_yr = 1980;
      else if put( tract_full, $geo70v. ) ~= "" then
        Tract_yr = 1970;
      else do;
        %warn_put( msg="Invalid tract ID: " _n_= dctract= tract_full= ward= )
        tract_full = "";
      end;
    end;
    else if dctract not in ( "", "000" ) then do;
        %warn_put( msg="Invalid tract ID: " _n_= dctract= ward= )
    end;
    
   %end;
   %else %do;
     %err_mput( macro=Convert_dc_tracts, msg=1st macro parameter must be BIRTHS or DEATHS. )
   %end;
   %end;
  label 
    tract_full = "Mother's census tract of residence: ssccctttttt (UI recode)"
    tract_yr = "Year of census tract definition (UI recode)";

%mend Convert_dc_tracts;

/** End Macro Definition **/

