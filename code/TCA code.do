*New dataset from EIA
clear all
set more off

* 1. Importing HS861 Excel
import excel "HS861 1990-2009.xlsx", ///
    sheet("Total Electric Industry") firstrow clear

describe
list INDUSTRIAL L M N in 1/10

* 2. Converting INDUSTRIAL columns to numeric
*------------------------------------------------------------
foreach v of varlist INDUSTRIAL L M N {
    replace `v' = subinstr(`v', ",", "", .)
    replace `v' = subinstr(`v', " ", "", .)
    destring `v', replace
}
destring N, gen(ind_price) force
rename INDUSTRIAL  ind_revenue
rename L ind_sales_mwh
rename M ind_customers
label var ind_price "Industrial electricity price (cents/kWh)"

*------------------------------------------------------------
* 3. Creating FIPS state code from 2-letter abbreviations in B
*------------------------------------------------------------
rename B state_abbr
gen str2 st = upper(state_abbr)
gen str2 fipstate = ""

replace fipstate = "01" if st=="AL"
replace fipstate = "02" if st=="AK"
replace fipstate = "04" if st=="AZ"
replace fipstate = "05" if st=="AR"
replace fipstate = "06" if st=="CA"
replace fipstate = "08" if st=="CO"
replace fipstate = "09" if st=="CT"
replace fipstate = "10" if st=="DE"
replace fipstate = "11" if st=="DC"
replace fipstate = "12" if st=="FL"
replace fipstate = "13" if st=="GA"
replace fipstate = "15" if st=="HI"
replace fipstate = "16" if st=="ID"
replace fipstate = "17" if st=="IL"
replace fipstate = "18" if st=="IN"
replace fipstate = "19" if st=="IA"
replace fipstate = "20" if st=="KS"
replace fipstate = "21" if st=="KY"
replace fipstate = "22" if st=="LA"
replace fipstate = "23" if st=="ME"
replace fipstate = "24" if st=="MD"
replace fipstate = "25" if st=="MA"
replace fipstate = "26" if st=="MI"
replace fipstate = "27" if st=="MN"
replace fipstate = "28" if st=="MS"
replace fipstate = "29" if st=="MO"
replace fipstate = "30" if st=="MT"
replace fipstate = "31" if st=="NE"
replace fipstate = "32" if st=="NV"
replace fipstate = "33" if st=="NH"
replace fipstate = "34" if st=="NJ"
replace fipstate = "35" if st=="NM"
replace fipstate = "36" if st=="NY"
replace fipstate = "37" if st=="NC"
replace fipstate = "38" if st=="ND"
replace fipstate = "39" if st=="OH"
replace fipstate = "40" if st=="OK"
replace fipstate = "41" if st=="OR"
replace fipstate = "42" if st=="PA"
replace fipstate = "44" if st=="RI"
replace fipstate = "45" if st=="SC"
replace fipstate = "46" if st=="SD"
replace fipstate = "47" if st=="TN"
replace fipstate = "48" if st=="TX"
replace fipstate = "49" if st=="UT"
replace fipstate = "50" if st=="VT"
replace fipstate = "51" if st=="VA"
replace fipstate = "53" if st=="WA"
replace fipstate = "54" if st=="WV"
replace fipstate = "55" if st=="WI"
replace fipstate = "56" if st=="WY"

drop if fipstate==""

*------------------------------------------------------------
* 4. Extracting year (column A includes year)
*------------------------------------------------------------
gen year = real(substr(A,1,4))
destring year, replace

*------------------------------------------------------------
* 5. Collapsing to state-year
*------------------------------------------------------------
collapse (mean) ind_price, by(fipstate year)

save "HS861_indprice_stateyear.dta", replace


*------------------------------------------------------------
* Structuring the CBP state-industry panel dataset
clear all                
set more off              
use "C:\Users\Salar\Desktop\article public\data\cbp_st_table2.dta"  
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

*------------------------------------------------------------
* Merge industrial electricity price (HS861) at state-year
*------------------------------------------------------------
merge m:1 fipstate year using ///
    "HS861_indprice_stateyear.dta"

drop if _merge == 2   // drop observations that exist only in HS861
drop _merge

label var ind_price "Industrial electricity price (cents/kWh)"

* Quick check
summ ind_price

*------------------------------------------------------------
* Build EI_new = ind_price × enint
*------------------------------------------------------------
gen double EI_new = ind_price * enint
label var EI_new "Electricity price-weighted energy intensity"

gen double postxNBPxEInew = post * NBP * EI_new
label var postxNBPxEInew "Post x NBP x EI_new"

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
// Creating industry-specific trends: trendind1–trendind21
qui tab naics,gen(ind)
foreach var of varlist ind1-ind21 {
    quietly gen trend`var' = `var' * trend
}

// Creating state-specific trends: trendSTdum1–trendSTdum49
foreach x of varlist STdum1-STdum49 {
    quietly gen trend`x' = `x' * trend
}

* Generating East/West industry trend interactions
forvalues i = 1/21 {
    quietly gen eindtrend`i' = trendind`i' * NBP
    quietly gen windtrend`i' = trendind`i' * ((NBP - 1)^2)
}

* Creating combined identifiers and FE dummies
tostring NBP, replace 
gen yearindreg = yearind + "_" + NBP 
quietly tab yearind, gen(yearinddum)
quietly tab STyear, gen(STyeardum)
quietly tab stateind, gen(stateinddum)
global rhs_vars "postxint intxNBP postxNBP"


*=====================================================*
* TCA: Electricity-price-weighted EI (EI_new)

eststo clear

* 1. Baseline with year FE
quietly eststo est1: areg lemp ///
    postxNBPxEInew yeardum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 2. Industry-year FE + state linear trends
quietly eststo est2: areg lemp ///
    postxNBPxEInew yearinddum* trendSTdum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 3. State-year FE
quietly eststo est3: areg lemp ///
    postxNBPxEInew yearinddum* STyeardum* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 4. (optional) with East/West industry trends
quietly eststo est4: areg lemp ///
    postxNBPxEInew yeardum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 5. Full FE: ind-year FE + state trends + E/W trends
quietly eststo est5: areg lemp ///
    postxNBPxEInew yearinddum* trendSTdum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

* 6. Full FE: state-year FE + ind-year FE + E/W trends
quietly eststo est6: areg lemp ///
    postxNBPxEInew yearinddum* STyeardum* windtrend* eindtrend* ///
    [aweight=empweight2], absorb(stateind) rob cluster(NBPind)

outreg2 [est1 est2 est3 est4 est5 est6] using "TCA_EInew.rtf", ///
    title("Table D (TCA): Electricity-price-weighted EI") ///
    keep(postxNBPxEInew) nocons replace
