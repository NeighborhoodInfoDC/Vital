**Fuzzy Merge Birth Records street with MAR street names
**Created by Yipeng Su
**------------------------------------------------------------------------------
version 14              // Set Version number for backward compatibility
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 120        // Line size limit to make output more readable
macro drop _all         // clear all macros
capture log close       // Close existing log files
set trace off			// Disable debugger
ssc install reclink
**------------------------------------------------------------------------------
* Directories & Locals
**------------------------------------------------------------------------------
local dodir "L:\Libraries\Vital\Raw\2018\geocoded"
local project "2018birth_geocode"
local data "L:\Libraries\Vital\Raw\2018\geocoded\streetname_09.dta"
local newdata "L:\Libraries\Vital\Raw\2018\geocoded\fuzzymerge_09.dta"
local output "L:\Libraries\Vital\Raw\2018\geocoded"
local time : di %tcCCYYNNDD!_HHMMSS clock("`c(current_date)'`c(current_time)'","DMYhms")
local date: display %td_CCYYNNDD date(c(current_date), "DMY")
**------------------------------------------------------------------------------
* What to run or not to run
**------------------------------------------------------------------------------
**------------------------------------------------------------------------------
* Create Log File
**------------------------------------------------------------------------------
global logthis "no" 	//change to "no" if no log file is desired
global makecopy "no"   //change to "no" if copies of do files are desired
if "$makecopy"=="yes"{
	copy `project'.do "`project'_`time'.do"
}
if "$logthis"=="yes"{
	log using `project'_`time'.log, replace text
	pwd
	display "$S_DATE $S_TIME"
}
di "-------------------------"
di "`c(username)' `c(current_date)'"
di "`c(current_time)'"
di "-------------------------"

**------------------------------------------------------------------------------
* 0. Load and Prep Data
**------------------------------------------------------------------------------
use `data'

**------------------------------------------------------------------------------
* 1. Use reclink to fuzzy merge street names in birth records with MAR street name 
**------------------------------------------------------------------------------

reclink street_clean using "L:\Libraries\Vital\Raw\2018\geocoded\mar street names.dta", idmaster(AddressID) idusing(Marid) gen(score) _merge(mergedata1)  minscore(0.8)

export excel using "L:\Libraries\Vital\Raw\2018\geocoded\fuzzymerge_09", firstrow(variables) replace 

save
**------------------------------------------------------------------------------
* Close the log, end the file
**------------------------------------------------------------------------------
macro drop _all
capture log close
exit

