/**************************************************************************
 Program:  ICD9_codes.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/22/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create data set & formats with International
 Classification of Diseases, revision 9 (ICD-9) codes used in death
 records.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital )

*options obs = 50;

filename inf  "&_dcdata_r_path\Vital\Doc\ICD-9 codes.txt" 
  lrecl=2000;
  
data Vital.Icd9_codes (label='International Classification of Diseases, revision 9, 3 & 4-digit codes');

  length buff $ 2000 Icd9_std $ 8 Icd9 $ 4 Code_type 3 Category1 Category2 $ 200 Description $ 200;
  
  retain Category1 Category2 "";

  infile inf stopover pad firstobs=1;
  
  input @1 buff $2000.;
  
  buff = left( buff );

  pos1 = indexc( buff, '(' );
  
  if pos1 = 0 then delete;
  else if pos1 = 1 then do;
  
    pos2 = indexc( buff, ')' );
    
    if pos2 - pos1 - 1 in ( 3, 5 ) then do;

      Icd9_std = substr( buff, 2, pos2 - pos1 - 1 );
      Icd9 = compress( Icd9_std, '.' );
      
      Code_type = length( Icd9 );
      
      Description = left( substr( buff, pos2 + 1 ) );
      
      output;
      
    end;
    
  end;
  
  else if pos1 > 1 then do;
  
    if indexc( substr( buff, 1, 1 ), '123456789' ) then do;
      Category1 = left( substr( buff, 1, pos1 - 1 ) );
      Category2 = "";
    end;
    else do;
      Category2 = left( substr( buff, 1, pos1 - 1 ) );
      Category2 = upcase( substr( Category2, 1, 1 ) ) || substr( Category2, 2 );
    end;
  
  end;

  label
    Category1 = 'Disease summary main category'
    Category2 = 'Disease summary sub-category'
    Code_type = 'Code type (3 or 4-digit)'
    Description = 'Disease description'
    Icd9 = 'ICD-9 code'
    Icd9_std = 'ICD-9 code (WHO standard format)';
    
  drop buff pos1 pos2;

run;

%File_info( data=Vital.Icd9_codes, freqvars=Code_type, stats= )

proc freq data=Vital.Icd9_codes;
  tables Category1 Category2 / nocum nopercent;

%Dup_check(
  data=Vital.Icd9_codes,
  by=icd9,
  id=description,
  out=_dup_check,
  listdups=Y,
  count=,
  quiet=N,
  debug=N
)



** Label formats **;

/*
proc catalog catalog=Vital.formats;
  delete icd9ss / entrytype=formatc;
quit;
*/

%Data_to_format(
  FmtLib=Vital,
  FmtName=$icd94a,
  Desc=%str(ICD9 4-digit, labels),
  Data=Vital.Icd9_codes,
  Value=Icd9,
  Label=Description,
  OtherLabel='Unrecognized code',
  NotSorted=Y,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

%Data_to_format(
  FmtLib=Vital,
  FmtName=$icd93a,
  Desc=%str(ICD9 3-digit, labels),
  Data=Vital.Icd9_codes (where=(Code_type=3)),
  Value=Icd9,
  Label=Description,
  OtherLabel='Unrecognized code',
  NotSorted=Y,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

** Summary formats **;

%Data_to_format(
  FmtLib=Vital,
  FmtName=$icd9sm,
  Desc=%str(ICD9 3/4-digit, summary categories 1),
  Data=Vital.icd9_codes,
  Value=icd9,
  Label=Category1,
  OtherLabel='Unrecognized code',
  NotSorted=Y,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

%Data_to_format(
  FmtLib=Vital,
  FmtName=$icd9s,
  Desc=%str(ICD9 3/4-digit, summary categories 2),
  Data=Vital.icd9_codes,
  Value=icd9,
  Label=Category2,
  OtherLabel='Unrecognized code',
  NotSorted=Y,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

** Verification formats **;

%Data_to_format(
  FmtLib=Vital,
  FmtName=$icd94v,
  Desc=%str(ICD9 4-digit, verification),
  Data=Vital.icd9_codes,
  Value=icd9,
  Label=icd9,
  OtherLabel='',
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

%Data_to_format(
  FmtLib=Vital,
  FmtName=$icd93v,
  Desc=%str(ICD9 3-digit, verification),
  Data=Vital.icd9_codes (where=(Code_type=3)),
  Value=icd9,
  Label=icd9,
  OtherLabel='',
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=Y
  )

