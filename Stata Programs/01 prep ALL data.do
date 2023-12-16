clear all
set more off

loc qq quietly

******************************************
*** US Census Bureau Demographic Data ****
******************************************

import delimited "cc_est2019-alldata (accessed on Dec 16 2020)_red.csv"

g fips = state*1000 + county

g white = wac_male + wac_female 	
g black = bac_male + bac_female		
g hisp = h_male + h_female			

recode agegrp 0=0 1/4=1 5/8=2 9/12=3 13/16=4 17/18=5, gen(agedec)
lab def ad 0 all 1 1_19 2 20_39 3 40_59 4 60_79 5 ge80 
lab val agedec ad

collapse state county (sum) tot_pop tot_male tot_female ///
white black hisp if agedec>0, by(fips agedec)

reshape wide tot_pop tot_male tot_female white black hisp, i(fips) j(agedec)

egen double pop2019 = rowtotal(tot_pop*)
g pct_1_19 = 100*tot_pop1 / pop2019
g pct_20_39 = 100*tot_pop2 / pop2019
g pct_40_59 = 100*tot_pop3 / pop2019
g pct_60_79 = 100*tot_pop4 / pop2019
g pct_ge80 = 100*tot_pop5 / pop2019

egen double  male = rowtotal(tot_male*)
egen double female = rowtotal(tot_female*)
egen double white = rowtotal(white*)
egen double black = rowtotal(black*)
egen double hisp = rowtotal(hisp*) 

g pct_male = 100*male/pop2019
g pct_female = 100*female/pop2019
g pct_white = 100*white/pop2019
g pct_black = 100*black/pop2019
g pct_hisp = 100*hisp/pop2019

keep fips pct*
save ctypopdemograph_2019, replace

***********************************************************
*** Index zscore data from www.policymap.com **************
***********************************************************
clear all
import delimited "COVID_Risk_Index_Data.csv"
keep geo_boundary_identifier index_zscore
rename (geo_boundary_identifier index_zscore) (fips indzscore)
save policymap_indexzscore, replace

***********************
**** USAFACTS data ****
**** CODE USED on Dec 28, 2020 ***
**********************************
/*
clear all
local date: di %tdCY-N-D  daily("$S_DATE", "DMY")

*** Extracting the CSV file and save a copy of it in the cd directory
!curl https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_confirmed_usafacts.csv > covid_confirmed_usafacts_`date'.csv
*** Importing the extracted CSV file into Stata
import delimited using covid_confirmed_usafacts_`date'.csv, clear
rename ïcountyfips fips

`qq' ds v*
loc en: word count `r(varlist)'
loc lv: word `en' of `r(varlist)'
loc llv0: var l `lv'
di "`lv' `llv0'"
save usaf_cases_`date', replace
*/

/*
!curl https://usafactsstatic.blob.core.windows.net/public/data/covid-19/covid_county_population_usafacts.csv > covid_county_population_usafacts_`date'.csv
import delimited using covid_county_population_usafacts_`date'.csv, clear
rename ïcountyfips fips
drop if fips==0
save usaf_pop_`date', replace
*/

use usaf_cases_2020-12-28, clear
drop if inlist(fips,0, 1, 2270, 6000) 
frame create pop
frame pop: use usaf_pop_2020-12-28

frlink m:1 fips, frame(pop)
frget population, from(pop)
drop if mi(population)

drop v5-v43 pop
`qq' ds v*
loc enn: word count `r(varlist)'
loc lvn: word `enn' of `r(varlist)'

drop v128-`lvn'

`qq' ds v*
loc en: word count `r(varlist)'
loc lv: word `en' of `r(varlist)'
loc llv0: var l `lv'
di "`lv' `llv0'"

clonevar confirmed0 = `lv'

loc npast = `en'-1
dis `npast'

forv i=1/`npast' {
		loc en = `en'-1		
		loc lv`i' : word `en' of `r(varlist)'
		loc llv`i': var l `lv`i''
		di "`lv`i'' `llv`i''"
		clonevar confirmed`i' = `lv`i''
}

forv i=0/`npast' {
	generate confirmed_adj_`i' = 100000*(confirmed`i'/population)  
	label var confirmed_adj_`i' "Cases per 100,000"
	format %16.0fc confirmed_adj_`i'
}
save usaconfirmed_March1-May23, replace

*************************************
**** 2019 Shape Files ***************
*************************************
preserve
clear all
!curl https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_county_500k.zip > cb_2019_us_county_500k.zip
unzipfile cb_2019_us_county_500k.zip, replace
spshape2dta cb_2019_us_county_500k.shp, saving(usacounties2019) replace
use usacounties2019_shp.dta, clear
use usacounties2019, clear
generate fips = real(GEOID)
save usacounties_2019, replace
restore

clear all
use _ID _CX _CY GEOID fips using usacounties_2019, clear
merge 1:1 fips using usaconfirmed_March1-May23, keep(match) nogenerate 
merge 1:1 fips using ctypopdemograph_2019, keep(match) nogenerate
keep _ID-_CY fips-state confirmed_adj_0-pct_hisp confirmed0 confirmed14 confirmed28
merge 1:1 fips using policymap_indexzscore, keep(match) nogenerate
merge 1:1 fips using CHR_2019_allstates, keep(match) nogenerate
drop countyname
order county, after(fips)
rename (indzscore pct_unins pm_25 hhmedinc) (index_zscore unins pm25 medinc)
save usaconfirmed_adj_demog_2019, replace

*** 2019 county pop ***
clear all
import delimited "cc_est2019-alldata (accessed on Dec 16 2020).csv"
keep if year==12
g fips = state*1000 + county
drop if agegrp==0
collapse (sum) tot_pop, by(fips)
save pop_2019, replace

*** 2019 LAND AREA ***
clear all
import delimited "2019_Gaz_counties_national.txt"
keep geoid aland
replace aland = aland * 1e-6
rename geoid fips
merge 1:1 fips using pop_2019, keep(match) nogenerate
g double pop_density = tot_pop / aland
drop aland tot_pop 
merge 1:1 fips using usaconfirmed_adj_demog_2019, keep(match) nogenerate

save usaconfirmed_adj_demog_2019, replace
