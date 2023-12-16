# spatial-spread-of-COVID-19

Replication materials (code and data) for our published findings in ["Socio-economic and demographic factors influencing the spatial spread of COVID-19 in the USA"](https://www.inderscienceonline.com/doi/abs/10.1504/IJCEE.2022.126313), published in the International Journal of Computational Economics and Econometrics journal. 

In this study, we analyse population-adjusted confirmed case rates based on daily US county-level variations in COVID-19 confirmed case counts during the first several months of the pandemic to evaluate the spatial dependence between neighbouring counties and quantify the overall spatial effect of socio-economic demographic factors on the prevalence of COVID-19.

The Stata Program folder contains all the needed programs to reproduce Tables 1-4, and the county-level choropleth maps in the Appendix showing the evolution of population-adjusted COVID-19 case rates for March 1, April 1, April 30, and the last date referenced in the analysis, May 23, 2020. Make sure the eimpact3.ado file is placed in the ado directory. The adopath command specifies the expected location of this directory.

The 2019 Cartographic Boundary Shapefiles (cb_2019_us_county_500k.zip) used in the do-file 01 prep ALL data.do are available at the [US Census Bureau](https://www2.census.gov/geo/tiger/GENZ2019/shp/).

# Authors
Christopher F. Baum, Boston College, Chestnut Hill, MA 02467-3806 USA; E-mail: kit.baum [at] bc [dot] edu

Miguel Henry; E-mail: mhenryo [at] yahoo [dot] com
