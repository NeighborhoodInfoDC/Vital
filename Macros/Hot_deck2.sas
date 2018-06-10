/**************************************************************************
 Program:  Hot_deck2.sas
 Library:  Macros
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  6/10/2018
 Version:  SAS 9.4
 Environment:  Windows
 
 Description:  Autocall macro to perform simplified hot deck allocations.

 Modifications:
**************************************************************************/

/** Macro Hot_deck2 - Start Definition **/

%macro Hot_deck2( 
  by=,   /** By group variable for allocation **/
  data= ,  /** Data with obs to which allocated var will be added **/
  source=,  /** Source data upon which allocation will be based **/
  alloc=,  /** Var to be allocated **/
  weight=,  /** Weight var for allocation source observations **/
  out=,   /** Output data set for results **/
  print=Y  /** Controls whether to print summaray tables (Y/N) **/
  );

  %if %mparam_is_yes( &print ) %then %do;

    title2 '**** Summary of Source data set ****';

    proc tabulate data=&source format=comma12.0 noseps missing;
      class &by &alloc;
      var &weight;
      table 
        /** Pages **/
        &by,
        /** Rows **/
      all='Total'
        &alloc,
        /** Columns **/
        ( sum='N (weighted)' colpctsum='Percent' * f=comma12.1 ) * &weight=' '
        / condense;
    run;

    title2;

  %end;


  ** Summarize source data **;
  
  proc summary data=&source nway;
    class &by &alloc;
    var &weight;
    output out=_hot_deck_src_wt (compress=no) sum=_wt;
  run;

  proc summary data=&source nway;
    class &by;
    var &weight;
    output out=_hot_deck_src_wtsum (compress=no) sum=_hd_wtsum;
  run;

  ** Randomize order of source summary obs if same weight **;

  data _hot_deck_src_wt_rnd;

    set _hot_deck_src_wt;

    _hd_random = rand( "Uniform" );

  run;

  proc sort data=_hot_deck_src_wt_rnd out=_hot_deck_src_wt_rnd (compress=no);
    by &by descending _wt _hd_random; 

  ** Transpose summary allocated var values and sum of weights according to BY var **;

  proc transpose data=_hot_deck_src_wt_rnd out=_hot_deck_src_tr_a prefix=_hd_alc_;
    by &by;
    id &alloc;
    var &alloc;
  run;

  proc transpose data=_hot_deck_src_wt_rnd out=_hot_deck_src_tr_b prefix=_hd_wt_;
    by &by;
    id &alloc;
    var _wt;
  run;

  data _hot_deck_src (compress=no);
  
    merge 
      _hot_deck_src_tr_a (drop=_name_) 
      _hot_deck_src_tr_b (drop=_name_) 
    _hot_deck_src_wtsum (drop=_type_ rename=(_freq_=_hd_num));
    by &by;
    
  run;

  ** Randomize order of input data **;

  data _hd_data;

    set &data;

    _hd_random = rand( "Uniform" );

  run;

  proc sort data=_hd_data;
    by &by _hd_random;
  run;
  
  ** Count number of obs in input data set by BY var **;

  proc summary data=_hd_data;
    by &by;
    output out=_hd_data_bycount (rename=(_freq_=_hd_bycount) drop=_type_);
  run;
  
  ** Perform allocation **;

  data &out;

    merge
      _hd_data
      _hd_data_bycount
      _hot_deck_src;
    by &by;

    retain _hd_alloc_obs _hd_alloc_index _hd_alloc_max;

    array _alloc{*} _hd_alc_: ;
    array _wt{*} _hd_wt_: ;

    %Sort_array_ref( _wt, order=descending )

    if first.&by then do;
      _hd_alloc_index = 1;
      _hd_alloc_obs = 1;
      _hd_alloc_max = round( _hd_bycount * ( _wt{_wt_srtd{_hd_alloc_index}} / _hd_wtsum ) );
    end;

    &alloc = _alloc{_wt_srtd{_hd_alloc_index}};

    output;

    _hd_alloc_obs + 1;

    if _hd_alloc_obs > _hd_alloc_max and _hd_alloc_index < _hd_num then do;
      _hd_alloc_index + 1;
      _hd_alloc_obs = 1;
      _hd_alloc_max = round( _hd_bycount * ( _wt{_wt_srtd{_hd_alloc_index}} / _hd_wtsum ) );
    end;
     
    drop _hd_: ;

  run;

  %if %mparam_is_yes( &print ) %then %do;

    title2 '**** Summary of Result data set ****';

    proc tabulate data=&out format=comma12.0 noseps missing;
    class &by &alloc;
    table 
      /** Pages **/
      &by,
      /** Rows **/
    all='Total'
      &alloc,
      /** Columns **/
      n='N' colpctn='Percent' * f=comma12.1
      / condense;
  run;

  title2;

%end;

%mend Hot_deck2;

/** End Macro Definition **/


/*************  UNCOMMENT TO TEST MACRO *******************

** Locations of SAS autocall macro libraries **;

filename uiautos "L:\Uiautos";
options sasautos=(uiautos sasautos);

data Source;

input a tr :$4. wt;

datalines;
1 0001 2
1 0002 4
1 0003 1
1 0004 0
1 0005 3
2 0001 0
2 0002 0
2 0003 1
2 0004 10
2 0005 2
;

run;

data dat;

input id a ;

datalines;
1 1
2 1
3 1
4 1
5 1
6 1
7 1
8 1
9 1
10 1
11 2
12 2
13 2
14 2
15 2
16 2
17 2
18 2
19 2
20 2
21 2
22 2
23 2
24 2
25 2
;


options mprint nosymbolgen nomlogic;

%Hot_deck2( by=a, data=dat, source=source, out=result, alloc=tr, weight=wt, print=y )  

%File_info( data=Result, printobs=50, stats= )

/*******************************************************************************/

