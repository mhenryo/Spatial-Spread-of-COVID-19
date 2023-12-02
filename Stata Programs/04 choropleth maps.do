set more off
clear all

use usaconfirmed_adj_demog_2019, clear

//grmap, activate

spset, modify shpfile(usacounties2019_shp)

grmap confirmed_adj_74,                                           ///
       clnumber(8)                                               ///
       clmethod(custom) fcolor(OrRd)                          ///
       clbreaks(0 20 40 80 160 500 2500 10000 20000)                   ///
       title("Confirmed Cases of COVID-19 in the United States") ///
       subtitle("(cases per 100,000 population as of 3/1/2020)")
gr export cases_nvid_March1.pdf, replace

grmap confirmed_adj_43,                                           ///
       clnumber(8)                                               ///
       clmethod(custom) fcolor(OrRd)                          ///
       clbreaks(0 20 40 80 160 500 2500 10000 20000)                   ///
       title("Confirmed Cases of COVID-19 in the United States") ///
       subtitle("(cases per 100,000 population as of 4/1/2020)")
gr export cases_nvid_April1.pdf, replace

grmap confirmed_adj_14,                                           ///
       clnumber(8)                                               ///
       clmethod(custom) fcolor(OrRd)                          ///
       clbreaks(0 20 40 80 160 500 2500 10000 20000)                   ///
       title("Confirmed Cases of COVID-19 in the United States") ///
       subtitle("(cases per 100,000 population as of 4/30/2020)")
gr export cases_nvid_April30.pdf, replace

grmap confirmed_adj_0,                                           ///
       clnumber(8)                                               ///
       clmethod(custom) fcolor(OrRd)                          ///
       clbreaks(0 20 40 80 160 500 2500 20000)                   ///
       title("Confirmed Cases of COVID-19 in the United States") ///
       subtitle("(cases per 100,000 population as of 5/23/2020)")
gr export cases_nvid_May23.pdf, replace
