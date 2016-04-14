/**************************************************************************
 Program:  Compare_deaths.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/20/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Compare deaths by cause for old & new methods.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

*options obs=100;

%macro cod (pref,num1,num2,varnm);

if (pre="&pref." and (code>=&num1. and code<=&num2.)) then &varnm.=1;

%mend cod;


%let vars= c_cervix03 c_colore03 
diabetes03 drug03    heart03   hiv03 homicide03 liver03   
MCD03 c_orophy03 c_prosta03 pulmon03  c_skin03  suicide03 acc_tran03
acc_drwn03 acc_fall03 acc_fire03 acc_gun03 acc_mv03  acc_pois03 acc_suff03 accident03 
c_breast03 cancer03  cer_vasc03 viol03  
c_oropha03    
pneum03       
violtn103     
;


data Compare_deaths;

  set Vital.Deaths_2001;
  
array disease{*} &vars.;
do _i_=1 to dim(disease);
disease{_i_}=0;
end;

length pre $1;

pre=substr(icd10_4d,1,1);
code=substr(icd10_4d,2,2)+0;

%cod(C,00,97,cancer03);
%cod(C,43,43,c_skin03);
%cod(C,50,50,c_breast03);
%cod(C,61,61,c_prosta03);
%cod(C,18,21,c_colore03);
%cod(C,53,53,c_cervix03);
%cod(C,00,13,c_oropha03);


%cod(B,20,24,HIV03);

%cod(E,10,14,diabetes03);

%cod(I,00,78,MCD03);

%cod(I,60,69,cer_vasc03);
%cod(J,10,18,pneum03);

%cod(I,00,09,heart03);
%cod(I,11,11,heart03);
%cod(I,13,13,heart03);
%cod(I,20,51,heart03);

%cod(J,40,47,pulmon03);

%cod(K,70,70,liver03);
%cod(K,73,74,liver03);

%cod(X,60,84,suicide03);

%cod(X,85,99,homicide03);
%cod(Y,00,09,homicide03);

%cod(V,01,99,accident03);
/*N.Sawyer did not include 'W' accidents from the IDC10 JMC add to see what may be there*/
%cod(W,00,99,accident03);
%cod(X,00,59,accident03);

%cod(Y,85,86,accident03);

%cod(V,01,99,acc_tran03);
%cod(Y,85,85,acc_tran03);


%cod(W,00,19,acc_fall03);

%cod(W,32,34,acc_gun03);
%cod(Y,22,24,acc_gun03);

%cod(W,65,74,acc_drwn03);

%cod(X,00,09,acc_fire03);

%cod(W,78,84,acc_suff03);

%cod(X,40,49,acc_pois03);

***code motor vehicle accidents (this requires using more specific codes);
%cod(V,02,04,acc_mv03);
%cod(V,12,14,acc_mv03);
%cod(V,20,79,acc_mv03);
%cod(V,83,86,acc_mv03);
if icd10_4d in ('VO90','V091','V092','V190','V191','V192','V194','V195','V196',
'V803','V804','V805','V810','V811','V820','V821','V870','V871','V872','V873',
'V874','V875','V876','V877','V878','V880','V881','V882','V883','V884','V885',
'V886','V887','V888','V890','V892') then acc_mv03=1;

 


%cod(F,10,19,drug03);
/*
%cod(F,55,55,drug03);
%cod(X,40,44,drug03);
%cod(X,60,64,drug03);
%cod(X,85,90,drug03);
*/
%cod(Y,10,14,drug03);

if homicide03=1 or suicide03=1 then viol03=1;
if homicide03=1 or suicide03=1 or accident03=1 then violtn103=1;

drop _i_;

run;

%File_info( data=Compare_deaths, printobs=0 )

/** Macro Print - Start Definition **/

%macro Print( var1, var2 );

  proc print data=Compare_deaths;
    where &var1 ~= &var2 and not( &var1 in ( ., 0 ) and &var2 in ( ., 0 ) );
    id RecordNo;
    var icd10_4d &var1 &var2;
    format icd10_4d $4.;
  run;

%mend Print;

/** End Macro Definition **/


%Print( violtn103, Deaths_violent )
%Print( accident03, Deaths_accident )
%Print( homicide03, Deaths_homicide )
%Print( suicide03, Deaths_suicide )
%Print( diabetes03, Deaths_diabetes )
%Print( heart03, Deaths_heart )
%Print( hiv03, Deaths_hiv )
%Print( liver03, Deaths_liver )
%Print( cancer03, Deaths_cancer )
%Print( cer_vasc03, Deaths_cereb )

