
clear all
set more off

cd "/Users/miguelhenry/Library/Mobile Documents/com~apple~CloudDocs/RESEARCH/COVID-19/Stata Data/"
use usaconfirmed_adj_demog_2019, clear

*** Table 1
foreach j of varlist confirmed_adj_0 confirmed_adj_14 confirmed_adj_28 {
gen int_`j'=int(`j')	
}
tabstat int_confirmed_adj_0 int_confirmed_adj_14 int_confirmed_adj_28, stat(min p25 median p75 p99 max) long col(stat)

*** Table 2
summ pct_male pct_black pct_hisp
summ pct_20_39
replace medinc = medinc/1e3
summ pm25 medinc unins index*
g lnpop_density = ln(pop_density)
summ lnpop_density
