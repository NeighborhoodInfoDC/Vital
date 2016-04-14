/**************************************************************************
 Program:  Births_2007.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   Rob Pitingolo
 Created:  08/16/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read in 2007 birth records from raw data file.

 Modifications: RP added %include statement to load the $vtrcnv. format.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\IncXP\Stdhead.sas";

/*  If the format catelog will not load, run the format_vtrcnv.sas program as a work-around.
	MUST have the tract_list.xls spreadsheet open for this to work  */
%include "D:\DCData\Libraries\Vital\Prog\Format_vtrcnv.sas";

** Define libraries **;
%DCData_lib( Vital )

%Read_births( infile=B07URBAN, year=2007 )

run;

