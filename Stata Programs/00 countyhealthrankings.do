clear all
set more off 

*** 2019 Data
loc u1 2019			// tab: "Ranked Measure Data" which has has Uninsured & Air Pollution

loc qq quietly 

****** MATA function that searches for and keep the essential variables and their content infor *****
mata
void look4()
{
	found=J(0,4,"")
	srch=tokens(st_local("srch"))
	for(w=1;w<=cols(srch);w++) {
		lf = srch[w]
		lf
		st_sview(data=.,.,st_local("vl"))
		vn = tokens(st_local("vl"))
		located = strmatch(data,"*"+lf+"*")
		for(i=1;i<=rows(data);i++) {
			for(j=1;j<=cols(data);j++) {
				if (located[i,j]==1) {
					found = found \ (lf,strofreal(i),strofreal(j),vn[j])
				}
			}
		}
	}
	"located in [obs, var, varname] :"
	found
	wantvars = found[.,4]'
	str = "keep "
	for(i=1;i<=cols(wantvars);i++) str = str + " " + wantvars[i] 
	st_local("cmd",str)
}
end
*****************

local all`u1'_datafiles: dir . files "*`u1'.dta"
di `all`u1'_datafiles'
local dir1 .
tempfile building
save `building', emptyok

**** Terms/essential variables ****
loc srch FIPS State County Uninsured Air*
***********************************
foreach f of local all`u1'_datafiles {
use "`f'"
qui ds
loc vl `r(varlist)'
mata: look4()
`cmd'
append using `building'
save `"`building'"', replace
}

drop if C==""
foreach var of varlist * {
local name = strtoname(`var'[1])
capture rename `var' `name'
}
`qq' drop if FIPS=="FIPS"
rename *, lower
rename (__Uninsured bp average_daily_pm2_5) (num_unins pct_unins pm_25)
foreach var of varlist fips num_unins pct_unins pm_25 {
destring `var', force replace    
}
sort fips state county, stable

label data "CHR_`u1'_allstates_1, long format"
save `"`dir1'/CHR_`u1'_allstates_1.dta"', replace

*** check of resulting data
desc
unique state
unique fips
nmissing

clear all
loc u2 2019_a		// tab: "Additional Measure Data" which has Median HH Income
loc qq quietly 
cd "C:\Users\mhenry\Dropbox\Covid19\CountyHealthRankings\usedIWCEE"

****** MATA function that searches for and keep the essential variables and their content infor *****
mata
void look4()
{
	found=J(0,4,"")
	srch=tokens(st_local("srch"))
	for(w=1;w<=cols(srch);w++) {
		lf = srch[w]
		lf
		st_sview(data=.,.,st_local("vl"))
		vn = tokens(st_local("vl"))
		located = strmatch(data,"*"+lf+"*")
		for(i=1;i<=rows(data);i++) {
			for(j=1;j<=cols(data);j++) {
				if (located[i,j]==1) {
					found = found \ (lf,strofreal(i),strofreal(j),vn[j])
				}
			}
		}
	}
	"located in [obs, var, varname] :"
	found
	wantvars = found[.,4]'
	str = "keep "
	for(i=1;i<=cols(wantvars);i++) str = str + " " + wantvars[i] 
	st_local("cmd",str)
}
end
*****************

local all`u2'_datafiles: dir . files "*`u2'.dta"
di `all`u2'_datafiles'
local dir1 .
tempfile building
save `building', emptyok

**** Terms/essential variables ****
loc srch FIPS State County income
***********************************
foreach f of local all`u2'_datafiles {
use "`f'"
qui ds
loc vl `r(varlist)'
mata: look4()
`cmd'
append using `building'
save `"`building'"', replace
}

drop if C==""
keep A-BN
foreach var of varlist * {
local name = strtoname(`var'[1])
capture rename `var' `name'
}
`qq' drop if FIPS=="FIPS"
rename *, lower
rename household_income hhmedinc
foreach var of varlist fips hhmedinc {
destring `var', force replace    
}
sort fips state county, stable

label data "CHR_`u2'_allstates_2, long format"
save `"`dir1'/CHR_`u2'_allstates_2.dta"', replace

*** check of resulting data
desc
unique state
unique fips
nmissing

*** MERGE
clear all
use `"`dir1'/CHR_`u1'_allstates_1.dta"'
merge 1:1 fips using `"`dir1'/CHR_`u2'_allstates_2.dta"', keep(match) nogenerate
save `"`dir1'/CHR_`u1'_allstates.dta"', replace
erase CHR_`u1'_allstates_1.dta 
erase CHR_`u2'_allstates_2.dta
