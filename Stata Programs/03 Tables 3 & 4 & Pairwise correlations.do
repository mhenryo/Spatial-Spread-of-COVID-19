set more off
clear all

// NOTE: impact3.ado is an ado file that must be stored in the appropriate directory for ado files. 
// Run the command -adopath- if you do not know what the directory is.

loc yr 2019

use usaconfirmed_adj_demog_`yr', clear

replace medinc = medinc/1e3
g lnpop_density = ln(pop_density)

***** Pairwise correlations *****
pwcorr pct_male pct_black pct_hisp pct_1_19-pct_ge80 lnpop_density pm25 medinc unins index_zscore, sig
mat corr = r(C)
outtable using correlm_2019, mat(corr) replace nobox center caption("Paiwise Correlations of Socioeconomic-Demographic Variables") ///
format(%6.3f) 

**** CONSTRUCTION OF W matrix ******
spset, modify shpfile(usacounties`yr'_shp)
**** Creating CDIST contiguity ROOK spatial weight matrix with default normalization
**** The matrix will be normalized so that its largest eigenvalue is 1.
spmatrix create contiguity CDIST`yr', rook normalize(minmax) replace
spmatrix save CDIST`yr' using CDIST`yr', replace
capt drop *hat	
clonevar Ct = confirmed_adj_0
clonevar Ct14 = confirmed_adj_14
clonevar Ct28 = confirmed_adj_28

****************************************************
********** SAR models using previous W matrix ******
****************************************************

*** DEFAULT PREDICTIONS below used to compute Pseudo R2 ***

*** Table 3, Column 1
eststo clear
spregress Ct Ct14 Ct28, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

*** Table 3, Column 2
spregress Ct Ct14 Ct28 pct_male, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

*** Table 3, Column 3
spregress Ct Ct14 Ct28 pct_black pct_hisp, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
test pct_black pct_hisp
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

*** Table 3, Column 4
spregress Ct Ct14 Ct28 pct_male pct_black pct_hisp, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
test pct_male pct_black pct_hisp
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

*** Table 3, Column 5
spregress Ct Ct14 Ct28 pct_20_39, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust) 
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

*** Table 3, Column 6
spregress Ct Ct14 Ct28 lnpop_density, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

*** Table 3, Column 7
spregress Ct Ct14 Ct28 lnpop_density pct_20_39 pct_male, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
test lnpop_density pct_20_39 pct_male
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

esttab, star(* 0.1 ** 0.05 *** 0.01) nomti ti("Spatial models of COVID-19 Cases: I") scalars("ll LogLikelihood" "r2_p PseudoR2" "p model pv" "p_c spatial pv") gap sfmt(%12.3f) varw(18)
esttab using table3_`yr'.tex, star(* 0.1 ** 0.05 *** 0.01) nomti ti("Average Total Impact of Spatial Models of COVID-19 Cases: I")  scalars("ll LogLikelihood" "r2_p PseudoR2" "p model pv" "p_c spatial pv") ///
gap sfmt(%12.3f) varw(18) rename(CDIST`yr':Ct $\hat{\rho}$ CDIST`yr':e.Ct $\hat{\lambda}$) replace posthead("{\small\label{resultsA}") prefoot("}") 

*** Table 4, Column 1
eststo clear
spregress Ct Ct14 Ct28 pm25, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

// Table 4, Column 2
spregress Ct Ct14 Ct28 unins, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

// Table 4, Column 3
spregress Ct Ct14 Ct28 index_zscore, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

// Table 4, Column 4
spregress Ct Ct14 Ct28 pm25 unins pct_male, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
test pm25 unins pct_male
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

// Table 4, Column 5
spregress Ct Ct14 Ct28 medinc, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

// Table 4, Column 6
spregress Ct Ct14 Ct28 pm25 unins pct_male medinc, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
test pm25 unins pct_male medinc
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

// Table 4, Column 7
spregress Ct Ct14 Ct28 pct_male pct_black pct_hisp lnpop_density medinc, dvarlag(CDIST`yr') errorlag(CDIST`yr') ml nolog vce(robust)
test pct_male pct_black pct_hisp lnpop_density medinc
estat impact
mat b_ = r(b_total)
mat v_ = r(V_total)
local depvar = e(depvar)
sca en_ = e(N)
sca ll_ = e(ll)
sca r2_p_ = e(r2_p)
sca p_ = e(p)
sca p_c_ = e(p_c)
// locate coefficients for spatial terms
mata: bs = st_matrix("e(b)"); vs = st_matrix("e(V)"); bsw = bs[1,(cols(bs)-2::cols(bs)-1)];st_matrix("b__",bsw) 
mat b_ = b_,b__
mata: v22 = vs[(cols(bs)-2),(cols(bs)-2)], 0 \ 0, vs[(cols(bs)-1),(cols(bs)-1)];  v11=st_matrix("v_")
mata: v0=J(cols(v11),2,0); v33=v11,v0 \ v0',v22;  st_matrix("v_",v33)
mata: cs=st_matrixcolstripe("b_"); cs[rows(cs)-1,1]="W"; cs[rows(cs)-1,2]="Ct"; cs[rows(cs),1]="W"; cs[rows(cs),2]="e.Ct"; st_matrixcolstripe("b_",cs);st_matrixrowstripe("v_",cs);st_matrixcolstripe("v_",cs)
eststo: qui eimpact3 b_ v_ `depvar' en_ ll_ r2_p_ p_ p_c_

esttab, star(* 0.1 ** 0.05 *** 0.01) nomti ti("Average Total Impact of Spatial models of COVID-19 Cases: II") scalars("ll LogLikelihood" "r2_p PseudoR2" "p model pv" "p_c spatial pv")  ///
gap sfmt(%12.3f) varw(18) replace posthead("{\scriptsize") prefoot("}")
esttab using table4_`yr'.tex, star(* 0.1 ** 0.05 *** 0.01) nomti ti("Spatial models of COVID-19 Cases: II") scalars("ll LogLikelihood" "r2_p PseudoR2" "p model pv" "p_c spatial pv")  ///
gap sfmt(%12.3f) varw(18) rename(CDIST`yr':Ct $\hat{\rho}$ CDIST`yr':e.Ct $\hat{\lambda}$) replace posthead("{\small\label{resultsB}") prefoot("}")
