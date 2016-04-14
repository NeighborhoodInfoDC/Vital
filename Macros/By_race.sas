/**************************************************************************
 Program:  By_race.sas
 Library:  Vital
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/10/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to generate summary variables by race.

 Modifications:
  10/23/08 PAT Added VAR2= parameter to allow different 2nd var from TYPE.
  08/10/11 PAT Fixed error in %if &var2 line.
**************************************************************************/

/** Macro By_race - Start Definition **/

%macro By_race( var, cat, type, var2=, pop=mothers );

  %if &var2 = %then %let var2 = &type;

  &var._wht = &var. * &var2._white;
  &var._blk = &var. * &var2._black;
  &var._hsp = &var. * &var2._hisp;
  &var._asn = &var. * &var2._asian;
  &var._oth = &var. * &var2._oth_rac;
  
  label 
    &var._wht = "&type to non-Hisp. white &pop &cat"
    &var._blk = "&type to non-Hisp. black &pop &cat"
    &var._hsp = "&type to Hispanic/Latino &pop &cat"
    &var._asn = "&type to non-Hisp. Asian/PI &pop &cat"
    &var._oth = "&type to non-Hisp. other race &pop &cat"
  ;
    
%mend By_race;

/** End Macro Definition **/

