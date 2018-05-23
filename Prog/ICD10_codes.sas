/**************************************************************************
 Program:  ICD10_codes.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/23/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create data set & formats with International
 Classification of Diseases, revision 10 (ICD-10) codes used in death
 records.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Vital )

*options obs=20;

filename inf  "&_dcdata_r_path\Vital\Doc\International Classification of Diseases, Revision 10 (1990), 4-digit.txt" 
  lrecl=2000;
  
data Vital.ICD10_codes (label='International Classification of Diseases, revision 10, 3 & 4-digit codes');

  length Icd10_std $ 8 Icd10 $ 4 Code_type 3 Category $ 200 Description $ 200;
  
  retain Category "";

  infile inf stopover pad firstobs=6;

  input @1 Icd10_std $6. @;
  
  if Icd10_std in: ( '[', ' ' ) then stop;
  
  if Icd10_std =: '(' then do;
    input @11 Category $200.;
  end;
  else do;
    
    Icd10 = compress( Icd10_std, '.' );
    
    Code_type = length( Icd10 );
    
    if Code_type = 3 then
      input @7 Description $200.;
    else if Code_type = 4 then
      input @13 Description $200.;
    else do;
      %Warn_put( msg='Invalid ICD-10 code: ' _n_= Icd10_std= Icd10= );
    end;
    output;
    
  end;
  
  label
    Category = 'Disease summary category'
    Code_type = 'Code type (3 or 4-digit)'
    Description = 'Disease description'
    Icd10 = 'ICD-10 code'
    Icd10_std = 'ICD-10 code (WHO standard format)';
    
run;

%File_info( data=Vital.Icd10_codes, freqvars=Code_type, stats=, printobs=40 )

** Label formats **;

%Data_to_format(
  FmtLib=Vital,
  FmtName=$icd104a,
  Desc=%str(ICD10 4-digit, labels),
  Data=Vital.Icd10_codes,
  Value=Icd10,
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
  FmtName=$icd103a,
  Desc=%str(ICD10 3-digit, labels),
  Data=Vital.Icd10_codes (where=(Code_type=3)),
  Value=Icd10,
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
  FmtName=$icd10s,
  Desc=%str(ICD10 3/4-digit, summary categories),
  Data=Vital.Icd10_codes,
  Value=Icd10,
  Label=Category,
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
  FmtName=$icd104v,
  Desc=%str(ICD10 4-digit, verification),
  Data=Vital.Icd10_codes,
  Value=Icd10,
  Label=Icd10,
  OtherLabel='',
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=N
  )

%Data_to_format(
  FmtLib=Vital,
  FmtName=$icd103v,
  Desc=%str(ICD10 3-digit, verification),
  Data=Vital.Icd10_codes (where=(Code_type=3)),
  Value=Icd10,
  Label=Icd10,
  OtherLabel='',
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=N,
  Contents=Y
  )

