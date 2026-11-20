* Structuring the state-industry panel dataset
clear all                
set more off              
use "cbp_st_table2.dta"  
encode STind, gen(stateind)   
tsset stateind year          
drop if enint==0   
drop if fipstate=="11" //Dropping DC because it has almost no manufacturing employment and is not part of NBP 

* Balance panel and fill identifiers
tsfill, full   
bysort stateind: carryforward naics fipstate NBP enint, replace 
gsort stateind -year
bysort stateind: carryforward naics fipstate NBP enint, replace 

* Rebuilding composite keys
drop STyear yearind post NBP postxNBP postxint intxNBP postxNBPxint 
tostring year, replace 
gen STyear = fipstate + year 
gen yearind = year + naics 
destring year, replace 
 
* Defining treatment (NBP) and post-policy periods
destring fipstate, gen(fipsnum)
gen post = 1 if inlist(year,2005,2006,2007,2008,2009) 
gen NBP = 1 if inlist(fipsnum,1,9,10,11,17,18,19,21,23,24,25,26,27,33,34,36,37,38,39,42,44,45,47,50,51,54,55) // Identify NBP-region states by numeric FIPS code
replace NBP = 0 if NBP==. 
replace post = 0 if post==. 
replace post = 1 if year==2004 & inlist(fipsnum,9,10,11,23,24,25,33,34,36,42,44,50) // Mark 2004 as “treated” for the traeted states

* Creating interaction terms for the triple-difference model
gen postxNBP = post * NBP 
gen postxint = post * enint 
gen intxNBP = enint * NBP 
gen postxNBPxint = post * NBP * enint //the main treatment effect

* Merging state-level fuel price data
gen flag = 1 if fipsnum < 10 
replace fipstate = "0" + fipstate if flag == 1 
drop fipsnum 
rename fipstate state 
sort state year 
drop _merge 
merge m:1 state year using "C:\Users\Salar\Desktop\article public\data\stfueldata09_figureO4.dta" 
drop _merge 

* Approximate employment counts from size-class bins
rename state fipstate   
local bins  1_4 5_9 10_19 20_49 50_99 100_249 250_499 500_999 1000
local sufs  14  59  1019   2049  5099  100249  250499  500999  1000
local mids  2.5 7   14.5   34.5  74.5  174.5   374.5   749.5   1000
local k : word count `bins'
forvalues i = 1/`k' {
    local b : word `i' of `bins'
    local s : word `i' of `sufs'
    local m : word `i' of `mids'
    gen double empcellcount`s' = n`b' * `m'
}

* Constructing total employment and bounds from size-class data
replace emp=empcellcount14+empcellcount59+empcellcount1019+empcellcount2049+empcellcount5099+empcellcount100249+empcellcount250499+empcellcount500999+empcellcount1000 if empflag~=""
// Replace missing total employment with sum of all estimated cell counts
replace emp = 3750  if empflag == "H"
replace emp = 7500  if empflag == "I"
replace emp = 17500 if empflag == "J"
replace emp = 37500 if empflag == "K" // Replacing coded flags (H–K) with midpoint employment values for those ranges
gen newobs = 1 if emp == .
replace newobs = 0 if newobs == . 
gen lower_KM=n1_4*1+n5_9*5+n10_19*10+n20_49*20+n50_99*50+n100_249*100+n250_499*250+n500_999*500+n1000*1000 if empflag~="" 
gen upper_KM=n1_4*4+n5_9*9+n10_19*19+n20_49*49+n50_99*99+n100_249*249+n250_499*499+n500_999*999+n1000*5000 if empflag~="" 
gen emp_KM = emp if empflag ~= "" 

*| Code | Approx. range | Assigned value |
*| ---- | ------------- | -------------- |
*| H    | 2,500–4,999   | 3,750          |
*| I    | 5,000–9,999   | 7,500          |
*| J    | 10,000–24,999 | 17,500         |
*| K    | 25,000–49,999 | 37,500         |


* Assigning midpoint employment values for CBP letter codes and compute log employment
gen emp_MS = . 
local flags A B C E F G H I J K L M
local mids  10 59 174 374 749 1749 3749 7499 17499 37499 74999 149000 // Defining each CBP employment flag (A–M) and its corresponding midpoint value
local n : word count `flags'
forvalues i = 1/`n' {
    local f : word `i' of `flags'
    local m : word `i' of `mids'
    replace emp_MS = `m' if empflag=="`f'"
} 
replace emp = 1 if missing(emp) 
sort stateind year 
replace lemp = ln(emp) // main dependent variable for regressions

gen empweight2 = emp if year == 1998 // Create employment weight based on 1998 employment
bysort stateind: carryforward empweight2, replace // Carry 1998 employment weights forward for all years within each state-industry panel
sort stateind year // Sort correctly before continuing

*==========================================================================
*==========================================================================
* MEA2: High and Low Energy-Intensity industries (based on quartiles of enint)
xtile qEI = enint, nq(4)
gen highEI = (qEI == 4)
gen lowEI  = (qEI == 1)

label var highEI "High energy-intensity industry (top quartile)"
label var lowEI  "Low energy-intensity industry (bottom quartile)"
gen postxNBPxhighEI = post * NBP * highEI
gen postxNBPxlowEI  = post * NBP * lowEI
label var postxNBPxhighEI "Post x NBP x High-EI industry"
label var postxNBPxlowEI  "Post x NBP x Low-EI industry"

* Creating NBP/West region identifiers and year dummies
gen NBPstr = cond(NBP==1, "NBP", "west") // Define region string: “NBP” for treated states, “west” for others
gen NBPind = NBPstr + naics 
capture drop yeardum*
tab year, gen(yeardum)

* increasing matsize for saturated FE specifications
set matsize 1500

* Generating linear trend and interactions for fixed effects
gen trend = year - 1997 
quietly tab fipstate, gen(STdum) 

qui tab naics,gen(ind)
foreach var of varlist ind1-ind21 {
    quietly gen trend`var' = `var' * trend
}

foreach x of varlist STdum1-STdum49 {
    quietly gen trend`x' = `x' * trend
}

forvalues i = 1/21 {
    quietly gen eindtrend`i' = trendind`i' * NBP
    quietly gen windtrend`i' = trendind`i' * ((NBP - 1)^2)
}

tostring NBP, replace 
gen yearindreg = yearind + "_" + NBP 
quietly tab yearind, gen(yearinddum)
quietly tab STyear, gen(STyeardum)
quietly tab stateind, gen(stateinddum)
global rhs_vars "postxint intxNBP postxNBP"


* MEA2 regressions: High Energy-Intensity industries
*=====================================================*

eststo clear

* 1. Baseline with year FE
quietly eststo est1: areg lemp ///
    postxNBPxhighEI postxNBP yeardum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 2. Industry-year FE + state linear trends
quietly eststo est2: areg lemp ///
    postxNBPxhighEI postxNBP ///
    yearinddum* trendSTdum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 3. State-year FE
quietly eststo est3: areg lemp ///
    postxNBPxhighEI ///
    yearinddum* STyeardum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 4. With East/West industry trends
quietly eststo est4: areg lemp ///
    postxNBPxhighEI postxNBP ///
    yeardum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 5. Full spec: ind-year FE + state trends + E/W trends
quietly eststo est5: areg lemp ///
    postxNBPxhighEI postxNBP ///
    yearinddum* trendSTdum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 6. Full spec: state-year FE + ind-year FE + E/W trends
quietly eststo est6: areg lemp ///
    postxNBPxhighEI ///
    yearinddum* STyeardum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

outreg2 [est1 est2 est3 est4 est5 est6] using "table B_MEA2_highEI.rtf", ///
    title("Table B (MEA2): : High Energy-Intensity Industries") ///
    keep(postxNBPxhighEI) nocons replace


* MEA2(Appendix) regressions: Low Energy-Intensity industries
*=====================================================*
eststo clear

* 1. Baseline with year FE
quietly eststo est1: areg lemp ///
    postxNBPxlowEI postxNBP yeardum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 2. Industry-year FE + state linear trends
quietly eststo est2: areg lemp ///
    postxNBPxlowEI postxNBP ///
    yearinddum* trendSTdum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 3. State-year FE
quietly eststo est3: areg lemp ///
    postxNBPxlowEI ///
    yearinddum* STyeardum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 4. With East/West industry trends
quietly eststo est4: areg lemp ///
    postxNBPxlowEI postxNBP ///
    yeardum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 5. Full spec: ind-year FE + state trends + E/W trends
quietly eststo est5: areg lemp ///
    postxNBPxlowEI postxNBP ///
    yearinddum* trendSTdum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 6. Full spec: state-year FE + ind-year FE + E/W trends
quietly eststo est6: areg lemp ///
    postxNBPxlowEI ///
    yearinddum* STyeardum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

outreg2 [est1 est2 est3 est4 est5 est6] using "table C_MEA2_highEI.rtf", ///
    title("Table C (MEA2): : Low Energy-Intensity Industries") ///
    keep(postxNBPxlowEI) nocons replace
