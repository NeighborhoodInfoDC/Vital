/**************************************************************************
 Program:  Deaths_1998.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/22/06
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 1998 death records from raw file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_deaths( infile=dth98.dat, year=1998,
  corrections=
    if RecordNo=113 and xBmonth='11' and xBday='31' then xBday='30';
    if RecordNo=5055 and xBday='27' then xBday='25';
    if tract=165 and ward=6 then tract=0;
)

run;


/** Macro table - Start Definition **/

%macro table( var );

  proc tabulate data=Vital.Deaths_1998 format=comma10.0 noseps missing order=freq;
    where &var;
    class Icd9_3d;
    var deaths_total;
    table all='TOTAL' Icd9_3d,
      deaths_total * ( sum='Number' colpctsum='Pct.'*f=comma10.1 )
      / indent=3 rts=80 box='Summary categories';
    format Icd9_3d $Icd93a.;
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
