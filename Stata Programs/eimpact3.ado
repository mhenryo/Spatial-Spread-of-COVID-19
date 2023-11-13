prog drop _all
prog eimpact3, eclass
args b v dv s ll r2_p p p_c 
eret post `b' `v'
estadd local depvar `dv' 
estadd scalar N = `s'
estadd scalar ll = `ll'
estadd scalar r2_p = `r2_p'
estadd scalar p = `p'
estadd scalar p_c = `p_c'
end
