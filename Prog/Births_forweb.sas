/**************************************************************************
 Program:  Births_forweb
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  11/16/2017
 Version:  SAS 9.4
 Environment:  Windows
 Modifications: 

**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas"; 

** Define libraries **;
%DCData_lib( Vital )
%DCData_lib( Web )


/***** Update the let statements for the data you want to create CSV files for *****/

%let library = vital; /* Library of the summary data to be transposed */
%let outfolder = births; /* Name of folder where output CSV will be saved */
%let sumdata = births_sum; /* Summary dataset name (without geo suffix) */
%let start = 2003; /* Start year */
%let end = 2016; /* End year */
%let keepvars = Births_w_weight Births_low_wt Births_w_age Births_teen; /* Summary variables to keep and transpose */


/***** Update the web_varcreate marcro if you need to create final indicators for the website after transposing *****/

%macro web_varcreate;

Pct_births_low_wt = Births_low_wt / Births_w_weight *100;
Pct_births_teen = Births_teen / Births_w_age *100;

label Pct_births_low_wt = "% low weight births (under 5.5 lbs)";
label Pct_births_teen = "% births to teen mothers";

drop &keepvars.;

%mend web_varcreate;



/**************** DO NOT UPDATE BELOW THIS LINE ****************/

%macro csv_create(geo);
			 
%web_transpose(&library., &outfolder., &sumdata., &geo., &start., &end., &keepvars. );

/* Load transposed data, create indicators for profiles */
data &sumdata._&geo._long_allyr;
	set &sumdata._&geo._long;
	%web_varcreate;
	label start_date = "Start Date"
		  end_date = "End Date"
		  timeframe = "Year of Data";
run;

/* Create metadata for the dataset */
proc contents data = &sumdata._&geo._long_allyr out = &sumdata._&geo._metadata noprint;
run;


%mend csv_create;
%csv_create (tr10);
%csv_create (tr00);
%csv_create (anc12);
%csv_create (wd02);
%csv_create (wd12);
%csv_create (city);
%csv_create (psa12);
%csv_create (zip);
%csv_create (cl17);

