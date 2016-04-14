/**************************************************************************
 Program:  Deaths_2001.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/18/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Read in 2001 death records from raw file.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


%Read_deaths( infile=D01URBAN.DAT, year=2001,
  corrections=
    if RecordNo=619 and xByear='01' then xByear='2000';
    if RecordNo=3317 and xByear='01' then xByear='1901';
    if tract=774 and ward=7 then tract=777;
    if tract=156 and Ward=5 then tract=0;
    if tract=691 and Ward=3 then tract=0;
    if tract=153 and Ward=3 then tract=0;
    if tract=379 and Ward=7 then tract=793;
    if tract=599 and Ward=1 then tract=50;
    if tract=889 and Ward=7 then tract=789;
    if tract=313 and Ward=7 then tract=0;
    if tract=930 and Ward=8 then tract=980;
    if tract=549 and Ward=7 then tract=0;
    if tract=152 and Ward=3 then tract=0;
    if tract=382 and Ward=1 then tract=380;
)

run;
