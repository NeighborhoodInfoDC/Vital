/**************************************************************************
 Program:  Births_sum_all.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/26/06
 Version:  SAS 9.2
 Environment:  Windows with SAS/Connect
 
 Description:  Create all summary geo files from Births 2000 tract
 summary file. 

 Modifications: Edit year of revisions= statement below.
  09/09/12 PAT Updated for new 2010/2012 geos.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Vital )

rsubmit;

%Create_all_summary_from_tracts( 

  /** Change to N for testing, Y for final batch mode run **/
  register=Y,
  
  /** Update with information on latest file revision **/
  /*revisions=%str(Added 2008 births.),*/
  revisions=%str(Updated for new 2010/2012 geos.),

  lib=Vital,
  data_pre=Births_sum, 
  data_label=%str(Births summary, DC),
  count_vars=births_:, 
  prop_vars=, 
  calc_vars=, 
  calc_vars_labels=,
  creator_process=Births_sum_all.sas,
  restrictions=None
)

run;

endrsubmit;

signoff;

