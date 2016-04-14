/**************************************************************************
 Program:  Deaths_1999.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/22/06
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 1999 death records from raw file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_deaths( infile=D99DCKID.DAT, year=1999,
  corrections=
    if RecordNo=226 and xBmonth='01' and xBday='28' and xByear='99' then xBday='22';
    if RecordNo=348 and xBmonth='06' and xBday='26' and xByear='99' then xBday='24';
    if RecordNo=1678 and xBmonth='02' and xBday='17' and xByear='99' then xByear='81';
    if RecordNo=3383 and xDday='97' then xDday='07';
    
)

run;

/** Macro table - Start Definition **/

%macro table( var );

  proc tabulate data=Vital.Deaths_1999 format=comma10.0 noseps missing order=freq;
    where &var;
    class icd10_3d;
    var deaths_total;
    table all='TOTAL' icd10_3d,
      deaths_total * ( sum='Number' colpctsum='Pct.'*f=comma10.1 )
      / indent=3 rts=80 box='Summary categories';
    format icd10_3d $icd103a.;
    title2 "&var = 1";

  run;

%mend table;

/** End Macro Definition **/

%table( Deaths_heart )
%table( Deaths_cancer )
%table( Deaths_hiv      )
%table( Deaths_diabetes )
%table( Deaths_hypert   )
%table( Deaths_cereb    )
%table( Deaths_liver    )
%table( Deaths_respitry )
