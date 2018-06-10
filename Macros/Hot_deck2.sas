/**************************************************************************
 Program:  Hot_deck2.sas
 Library:  Macros
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/13/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to perform hot deck allocations.

 Modifications:
**************************************************************************/

/** Macro Hot_deck2 - Start Definition **/

%macro Hot_deck2( 
  match_keys= ,
  by=,
  data= ,
  source=,
  alloc=,
  alloc_len=$15,
  weight=,
  num_units=5,
  min_score=1,
  out=,
  print=Y 
  );

  /***************
  %let quiet = %upcase( &print );

  %** Find last item in match_keys **;
  
  %let i = 1;
  %let rename_keys = ;
  %let calc_score = 0;
  %let v = %scan( &match_keys, &i );
  %do %until ( &v =  );
    %let rename_keys = &rename_keys &v=_hd_&v;
    %let calc_score = &calc_score + ( &v=_hd_&v );
    %let last_match_key = &v;
    %let i = %eval( &i + 1 );
    %let v = %scan( &match_keys, &i );
  %end;
  %let num_keys = %eval( &i - 1 );
  
  %let i = 1;
  %let rename_by = ;
  %let by_match = 1;
  %let v = %scan( &by, &i );
  %do %while ( &v ~=  );
    %let rename_by = &rename_by &v=_hd_&v;
    %let by_match = &by_match and (&v=_hd_&v);
    %let i = %eval( &i + 1 );
    %let v = %scan( &by, &i );
  %end;
  %put by_match=&by_match;
  ********************************/

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
 
  proc sort data=_hot_deck_src_wt out=_hot_deck_src_wt (compress=no);
    by &by descending _wt; 

proc transpose data=_hot_deck_src_wt out=_hot_deck_src_tr_a prefix=_hd_alc_;
  by &by;
  id &alloc;
  var &alloc;
run;

proc transpose data=_hot_deck_src_wt out=_hot_deck_src_tr_b prefix=_hd_wt_;
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
    
	/*********
    length _hd_alloc1-_hd_alloc&num_units &alloc_len;
    retain _hd_alloc1-_hd_alloc&num_units;
    retain _hd_i;
    
    array _hd_a{*} _hd_alloc1-_hd_alloc&num_units;
    
    if first.&last_match_key then do;
      do _hd_i = 1 to dim( _hd_a );
        _hd_a{_hd_i} = "";
      end;
      _hd_i = 1;
    end;
    
    %*put _n_= _hd_i=;
    _hd_a{_hd_i} = &alloc;
    _hd_i + 1;
    
    if last.&last_match_key then do;
      _hd_num_tr = _hd_i - 1;
      output;
    end;
    
    keep &by &match_keys _hd_alloc1-_hd_alloc&num_units _hd_num_tr;

	******/
    
  run;

  ** Randomize order of input data **;

  data _hd_data;

    set &data;

	_hd_random = rand( "Uniform" );

  run;

  proc sort data=_hd_data;
    by &by _hd_random;
  run;

  proc summary data=_hd_data;
    by &by;
	output out=_hd_data_bycount (rename=(_freq_=_hd_bycount) drop=_type_);
  run;

  data &out;

    merge
	  _hd_data
	  _hd_data_bycount
	  _hot_deck_src;
	by &by;

	retain _hd_alloc_obs _hd_alloc_index _hd_alloc_max;

	array _alloc{*} _hd_alc_: ;
	array _wt{*} _hd_wt_: ;

	if first.&by then do;
	  _hd_alloc_index = 1;
	  _hd_alloc_obs = 1;
	  _hd_alloc_max = round( _hd_bycount * ( _wt{_hd_alloc_index} / _hd_wtsum ) );
	  put "START" / &by=; 
	end;

    &alloc = _alloc{_hd_alloc_index};

	put _n_= &alloc= _hd_alloc_index= _hd_alloc_obs= _hd_alloc_max= ;

	output;

	_hd_alloc_obs + 1;

	if _hd_alloc_obs > _hd_alloc_max and _hd_alloc_index < _hd_num then do;
	  _hd_alloc_index + 1;
	  _hd_alloc_obs = 1;
	  _hd_alloc_max = round( _hd_bycount * ( _wt{_hd_alloc_index} / _hd_wtsum ) );
   end;

  run;

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

  
  /*********
  %*proc print data=_hot_deck_src (obs=10);
  
  run;
  
  ** Perform hot deck allocation **;
  
  data &out;
  
    set &data;
    
    array _r{1000} _temporary_;
    
    if _n_ = 1 then do;
      do _hd_i = 1 to dim( _r );
        _r{_hd_i} = 1;
      end;
    end;
  
    _hd_i = 1;
    _hd_match = 0;
    _hd_high_score = 0;
    
    do until( _error_ );
      set _hot_deck_src (rename=(&rename_by &rename_keys)) point=_hd_i;
      if _error_ then goto exit_loop;
      if &by_match then do;
        _hd_score = &calc_score;
        if _hd_score = &num_keys then do;
          _hd_match = _hd_i;
          goto exit_loop;
        end;
        else if _hd_score > _hd_high_score and _hd_score >= &min_score then do;
          _hd_match = _hd_i;
          _hd_high_score = _hd_score;
        end;
      end;
      %*put _all_;
      _hd_i = _hd_i + 1;
    end;
    
    exit_loop:

    array _a{*} _hd_alloc1-_hd_alloc&num_units;
    
    %*put _all_;
    %*put _hd_match=;

    if _hd_match then do;

      %*put "_r{_hd_match}=" _r{_hd_match};
      %*put "_a{_r{_hd_match}}=" _a{_r{_hd_match}};
      
      set _hot_deck_src (rename=(&rename_keys)) point=_hd_match;
      &alloc = _a{_r{_hd_match}};
      if _r{_hd_match} >= _hd_num_tr then _r{_hd_match} = 1;
      else _r{_hd_match} = _r{_hd_match} + 1;
      %*put "_r{_hd_match}=" _r{_hd_match};
      
      &alloc._alloc = 1;
      %*high_score = _hd_high_score;
      
    end;
    else do;
    
      &alloc._alloc = 0;
      
    end;      
    
    output;
    
    drop _hd_: ;
    
  run;
  
  %if &print = Y %then %do;
    proc print data=&out;
      var &by &match_keys &alloc &alloc._alloc;
      title2 "%nrstr(%Hot_deck2()) results: Data=&data, Out=&out, Alloc=&alloc";
    
    run;
    title2;
  %end;

  ********************/

%mend Hot_deck2;

/** End Macro Definition **/


/*************  UNCOMMENT TO TEST MACRO *******************/

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

%Hot_deck2( by=a, data=dat, source=source, out=result, alloc=tr, weight=wt )  



/*******************************************************************************/

