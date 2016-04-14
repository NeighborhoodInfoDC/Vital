/**************************************************************************
 Program:  Compare_kessner.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/17/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Compare results of Kessner Index calculations.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )


data Compare_kessner;

  set Vital.Births_2003;
  
*if Gest_age = 99 then Gest_age=.;
if Gest_age<37 then preterm2003=1; else preterm2003=0;

*if Pre_care =99 then Pre_care=.;
if  28=< Pre_care < 99 then latecare2003=1; else latecare2003=0;


*if Num_visit=99 then Num_visit=.;
if Num_visit=0 then nopncare2003=1; else nopncare2003=0;
  
  ***calculate the kessner index*****;

k_unk2003=0;

if Gest_age=99 or missing(Gest_age) then nogest2003=1;
if Num_visit=99 or missing(Num_visit) then novisit2003=1;
if Pre_care=99 or missing(Pre_care) then noprecare2003=1;
if nogest2003=1 or novisit2003=1 or noprecare2003=1 then k_unk2003=1;


if 0 < Pre_care < 14 then precare1_132003=1;
if Pre_care <=13 then precare0_132003=1; 



if k_unk2003=0 then do;

if Pre_care <=13  then do;
if Gest_age in (14,15,16,17) and Num_visit >=2 and Num_visit NE 99 then k_ad2003=1;
if Gest_age in (18,19,20,21) and Num_visit >=3 and Num_visit NE 99 then k_ad2003=1;
if Gest_age in (22,23,24,25) and Num_visit >=4 and Num_visit NE 99 then k_ad2003=1;
if Gest_age in (26,27,28,29) and Num_visit >=5 and Num_visit NE 99 then k_ad2003=1;
if Gest_age in (30,31) and Num_visit >=6 and Num_visit NE 99 then k_ad2003=1;
if Gest_age in (32,33) and Num_visit >=7 and Num_visit NE 99 then k_ad2003=1;
if Gest_age in (34,35) and Num_visit >=8 and Num_visit NE 99 then k_ad2003=1;
if Gest_age>=36 and Gest_age<=47 and Num_visit >=9 and Num_visit NE 99 then k_ad2003=1;
end;


if latecare2003=1 or
(Gest_age in (14,15,16,17,18,19,20,21) and Num_visit=0) or
(Gest_age in (22,23,24,25,26,27,28,29)   and Num_visit<=1)or
(Gest_age in(30,31) and Num_visit<=2) or
(Gest_age in (32,33)  and Num_visit<=3) or
(Gest_age>=34 and Gest_age<=47  and Num_visit<=4) then k_inad2003=1;


if k_ad2003 ne 1 and k_inad2003 ne 1 then k_int2003=1;
end;



 

if k_ad2003=1 or k_inad2003=1 or  k_int2003=1 then k_knowcare2003=1;




run;

proc freq data=Compare_kessner;
  tables Births_prenat_adeq * k_ad2003 
   Births_prenat_intr * k_int2003 
   Births_prenat_inad * k_inad2003 
  / missing list;

proc print data=Compare_kessner noobs;
  where ( Births_prenat_adeq = 1 and k_ad2003 ~= 1 );
  var Pre_care Num_visit Gest_age Births_prenat_adeq Births_prenat_intr Births_prenat_inad k_ad2003 k_int2003 k_inad2003;
  
run;

proc print data=Compare_kessner noobs;
  where ( Births_prenat_intr = 1 and k_int2003 ~= 1 );
  var Pre_care Num_visit Gest_age Births_prenat_adeq Births_prenat_intr Births_prenat_inad k_ad2003 k_int2003 k_inad2003;
  
run;

proc print data=Compare_kessner noobs;
  where ( Births_prenat_inad = 1 and k_inad2003 ~= 1 );
  var Pre_care Num_visit Gest_age Births_prenat_adeq Births_prenat_intr Births_prenat_inad k_ad2003 k_int2003 k_inad2003;
  
run;
