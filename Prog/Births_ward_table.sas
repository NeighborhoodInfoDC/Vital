/**************************************************************************
 Program:  Births_ward_table.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/02/13
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create table showing numbers of births by ward 1998-2008. 

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Vital )

proc tabulate data=Vital.Births_sum_wd12 format=comma8.0 noseps missing;
  class Ward2012;
  var births_total_1998-births_total_2008;
  table 
    /** Rows **/
    all='Total' ward2012=' ',
    /** Columns **/
    sum='Total Births' * ( 
      births_total_1998="1998"
      births_total_1999="1999"
      births_total_2000="2000"
      births_total_2001="2001"
      births_total_2002="2002"
      births_total_2003="2003"
      births_total_2004="2004"
      births_total_2005="2005"
      births_total_2006="2006"
      births_total_2007="2007"
      births_total_2008="2008" 
    )
    / rts=20
  ;

run;

proc tabulate data=Vital.Births_sum_wd12 format=comma8.0 noseps missing;
  class Ward2012;
  var births_white_2001-births_white_2008;
  table 
    /** Rows **/
    all='Total' ward2012=' ',
    /** Columns **/
    sum='White Births' * ( 
      births_white_2001="2001"
      births_white_2002="2002"
      births_white_2003="2003"
      births_white_2004="2004"
      births_white_2005="2005"
      births_white_2006="2006"
      births_white_2007="2007"
      births_white_2008="2008" 
    )
    / rts=20
  ;

run;

proc tabulate data=Vital.Births_sum_wd12 format=comma8.0 noseps missing;
  class Ward2012;
  var births_black_2001-births_black_2008;
  table 
    /** Rows **/
    all='Total' ward2012=' ',
    /** Columns **/
    sum='Black Births' * ( 
      births_black_2001="2001"
      births_black_2002="2002"
      births_black_2003="2003"
      births_black_2004="2004"
      births_black_2005="2005"
      births_black_2006="2006"
      births_black_2007="2007"
      births_black_2008="2008" 
    )
    / rts=20
  ;

run;

proc tabulate data=Vital.Births_sum_wd12 format=comma8.0 noseps missing;
  class Ward2012;
  var births_hisp_2001-births_hisp_2008;
  table 
    /** Rows **/
    all='Total' ward2012=' ',
    /** Columns **/
    sum='Latino Births' * ( 
      births_hisp_2001="2001"
      births_hisp_2002="2002"
      births_hisp_2003="2003"
      births_hisp_2004="2004"
      births_hisp_2005="2005"
      births_hisp_2006="2006"
      births_hisp_2007="2007"
      births_hisp_2008="2008" 
    )
    / rts=20
  ;

run;
