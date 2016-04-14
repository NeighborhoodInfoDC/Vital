/**************************************************************************
 Program:  Births_sum_all.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/26/06
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Create all summary geo files from Births 2000 tract
 summary file. 

 Modifications: Edit year of revisions= statement below.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
/***%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;***/

** Define libraries **;
%DCData_lib( Vital )

/***************** MACRO TESTING ******************/
filename MacTest 'D:\DCData\SAS\Macros\Test';
%MacroSearch( cat=MacTest, action=B )
/**************************************************/

/***rsubmit;***/

%Create_all_summary_from_tracts( 
  lib=Vital,
  data_pre=Births_sum, 
  data_label=%str(Births summary, DC),
  count_vars=births_:, 
  prop_vars=, 
  calc_vars=, 
  calc_vars_labels=,
  register=N,
  creator_process=Births_sum_all.sas,
  restrictions=None,
  revisions=%str(ADDED NEW AGE GROUPING VARIABLES.)
)

run;

libname save "D:\DCData\Libraries\Vital\Data\Save";

proc compare base=Vital.births_sum_wd02 compare=Save.births_sum_wd02 maxprint=(40,32000);
  id ward2002;
run;

/***endrsubmit;***/

/***signoff;***/

