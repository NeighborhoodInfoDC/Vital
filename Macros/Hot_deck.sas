/**************************************************************************
 Program:  Hot_deck.sas
 Library:  Macros
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  09/13/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to perform hot deck allocations.

 Modifications:
**************************************************************************/

/** Macro Hot_deck - Start Definition **/

%macro Hot_deck( 
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
  /**%let last_match_key = %scan( &match_keys, %eval( &i - 1 ) );**/
  
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

  ** Summarize source data **;
  
  proc summary data=&source nway;
    class &by &match_keys &alloc;
    var &weight;
    output out=_hot_deck_src1 (compress=no) sum=;
  
  proc sort data=_hot_deck_src1 out=_hot_deck_src1 (compress=no);
    by &by &match_keys descending &weight; 
    
  data _hot_deck_src (compress=no);
  
    set _hot_deck_src1;
    by &by &match_keys;
    
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
    
  run;
  
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
      title2 "%nrstr(%Hot_deck()) results: Data=&data, Out=&out, Alloc=&alloc";
    
    run;
    title2;
  %end;

%mend Hot_deck;

/** End Macro Definition **/


/*************  UNCOMMENT TO TEST MACRO *******************

data Source;

input a b c tr :$4. wt;

datalines;
1 1 1 0001 1
1 1 1 0002 2
1 1 1 0003 3
1 1 2 0004 4
1 1 2 0005 5
1 2 1 0006 6
1 2 3 0007 7
;

run;

data dat;

input id a b c ;

datalines;
1 1 1 1
2 1 1 2
3 1 2 3
4 1 1 1
5 1 1 3
6 1 1 2
7 1 1 1
8 0 0 0
;


options mprint symbolgen mlogic;

%Hot_deck( match_keys=a b c, data=dat, source=source, alloc=tr, weight=wt )  

/*******************************************************************************/

