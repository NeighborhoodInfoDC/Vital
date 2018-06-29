/**************************************************************************
 Program:  Births_2003_2016_chart.sas
 Library:  Requests
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  06/22/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Export births by year for time trend chart. 
 Created for ODCA enrollment study.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Requests )
%DCData_lib( Vital )

%let START_YR = 2003;
%let END_YR = 2016;
%let output_path = &_dcdata_default_path\Requests\Prog\2018;

%macro label_all( varpre );

  %do i = &START_YR %to &END_YR;
    &varpre.&i = "&i"
  %end;
  
%mend label_all;

ods csvall body="&output_path\Births_&START_YR._&END_YR._chart.csv";

proc tabulate data=Vital.Births_sum_wd12 format=comma10.0 noseps missing;
  class ward2012;
  var Births_total_&START_YR.-Births_total_&END_YR.;
  table 
    /** Rows **/
    Ward2012=' ' all='TOTAL',
    /** Columns **/
    sum=' ' * ( Births_total_&START_YR.-Births_total_&END_YR. )
  ;
  label 
    %label_all( Births_total_ )
  ;
  title2 "Total births by ward (2012), District of Columbia, &START_YR - &END_YR";
run;

ods csvall close;

run;
