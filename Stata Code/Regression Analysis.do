**********Data Analysis with the cleaned data**********

use "/Users/Wdy/Desktop/Honors/cleaned1.dta"

**********Chapter 2**********
describe

**renames a few varibales for easier reading
rename tfprYKLM TFP
rename legal_status1 shareholdingpublic
rename legal_status2 shareholdingprivate
rename main_market2 national_market
rename main_market3 international_market
rename tax_obstacle4 major_tax_obstacle
rename tax_obstacle5 severe_tax_obstacle
rename political_obstacle4 major_political_obstacle
rename political_obstacle5 severe_political_obstacle
rename size_num number_employees
rename d2_gdp09 total_sale09
*save "/Users/Wdy/Desktop/Honors/cleaned1.dta", replace

*********gdp data cleaning
import excel "/Users/Wdy/Desktop/GDP.xls", sheet("Data") firstrow clear
rename (C-Q) (Y2006 Y2007 Y2008 Y2009 Y2010 Y2011 Y2012 Y2013 Y2014 Y2015 Y2016 Y2017 Y2018 Y2019 Y2020)
drop CountryName
reshape long Y, i(ISO) j(year)
save "/Users/Wdy/Desktop/Honors/GDP.dta"
*merge
merge m:1 ISO year using GDP.dta
drop if _merge == 2
drop _merge
gen gdp09 = Y*(90.724/107.494)
*save "/Users/Wdy/Desktop/Honors/cleaned1.dta", replace
**************


*TFP follows normal distribution
histogram TFP, normal
swilk TFP

*export/import and productivity
graph bar TFP, over(Export, relabel (1 "Does Not Export" 2 "Export")) over(Import, relabel (1 "Does Not Import" 2 "Import")) title("TFP and Export/Import Participation")
*graph export "/Users/Wdy/Desktop/Honors/Export:Import - TFP.png", as(png) name("Graph")
*if participate in import, bad; export, always positive.

*this trend follows if we change sectors; import a little varied but overall bad.
tostring isic, gen(Isic)
graph bar TFP, over(Export, relabel(1 "Does Not Export" 2 "Export")) over(Isic, lab(angle(45)) sort(1)) title("TFP and Export Participation across Industries") ascategory asyvars bar(1, fcolor(maroon)) bar(2, fcolor(navy))
graph export "/Users/Wdy/Desktop/Honors/TFP and Export Participation across Industries.png", as(png) name("Graph")
graph bar TFP, over(Import, relabel(1 "Does Not Import" 2 "Import")) over(Isic, lab(angle(45)) sort(1)) title("TFP and Import Participation across Industries") ascategory asyvars bar(1, fcolor(maroon)) bar(2, fcolor(navy))
graph export "/Users/Wdy/Desktop/Honors/TFP and Import Participation across IndustriesTFP and Import Participation across Industries.png", as(png) name("Graph")
*********************************

*year TFP
tabstat export, by (year)
tabstat import, by (year)

*percentage of exporting and importing firms
count if Export == 1
display 16207/49983
*0.32425025
count if Import ==1
display 28731/49983
*0.57481544

*firm size dist
tab size
*39.88, 37.39, 22.73

*RD
tab RD
*Out of 37,697 firms, 24.09% invest in R&D

*foreign technology
tab foreign_tech
*Out of 49,554 firms, 14.64% use foreign technology

*years in export
sum year_of_export,d
*47,198 obs, 4.623226 mean. 190 max

**over year, no significant pattern
graph bar TFP export import, over(year)
tabstat import, by (year)
tabstat export, by (year)

***********EXPLORE PATTERNS***********
graph bar Export Import, over(size) title("Export/Import by Firm Size") ytitle("Percentage")
graph export "/Users/Wdy/Desktop/Honors/export:import by firm size.png", as(png) name("Graph")
*large size import and export more

graph bar Export Import, over(b1, lab(alt) relabel(1 "shareholding" 2 "non-traded shareholding")) title("Export/Import by Legal Status") ytitle("Percentage")
graph export "/Users/Wdy/Desktop/Honors/Export:Import by Legal Status.png", as(png) name("Graph")
*share holding companies are more likely to participate in international trade

graph bar Export Import, over(RD, relabel(1 "Without R & D" 2 "With R & D")) title("Export/Import by RD Investments") ytitle("Percentage")
graph export "/Users/Wdy/Desktop/Honors/Export:Import by RD Investments.png", as(png) name("Graph")
*import&export more for RD companies

graph bar Export Import, over(high_income, relabel(1 "Low Income" 2 "High Income")) title("Export/Import by Country Income") ytitle("Percentage")
*firms in high income country export/import more
graph export "/Users/Wdy/Desktop/Honors/Export:Import by Country Income.png", as(png) name("Graph")

**********Chapter 3**********
*reg TFP export import year_of_export medium_size large_size legal_status1 legal_status2 foreign_tech RD loss_theft high_income main_market2 main_market3 tax_obstacle4 tax_obstacle5 political_obstacle4 political_obstacle5  i.Year i.Country i.ISIC, robust

gen  large_size_Export = large_size*Export
gen  medium_size_Export = medium_size*Export
* however, not significant for medium firms, negative coeff but significant for large firms
*save "/Users/Wdy/Desktop/Honors/cleaned1.dta", replace

*MAIN
eststo clear
quietly reg TFP export import i.Year i.Country, robust
eststo model1
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "N", replace

quietly reg TFP export import i.Year i.Country i.ISIC, robust
eststo model2
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

quietly reg TFP export import year_of_export i.Year i.Country i.ISIC, robust
eststo model3
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

quietly reg TFP export import year_of_export medium_size large_size i.Year i.Country i.ISIC, robust
eststo model4
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

quietly reg TFP export import year_of_export medium_size large_size shareholdingpublic shareholdingprivate i.Year i.Country i.ISIC, robust
eststo model5
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

quietly reg TFP export import year_of_export medium_size large_size shareholdingpublic shareholdingprivate foreign_tech RD loss_theft lgdp i.Year i.Country i.ISIC, robust
eststo model6
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

quietly reg TFP export import year_of_export medium_size large_size shareholdingpublic shareholdingprivate foreign_tech RD loss_theft lgdp major_tax_obstacle severe_tax_obstacle major_political_obstacle severe_political_obstacle i.Year i.Country i.ISIC, robust
eststo model7
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

quietly reg TFP export import year_of_export medium_size large_size shareholdingpublic shareholdingprivate foreign_tech RD loss_theft lgdp major_tax_obstacle severe_tax_obstacle major_political_obstacle severe_political_obstacle i.Year i.Country i.ISIC if year<2008| year>2009, robust
eststo model8
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

***need manual labor for the code above: add FE in tables for model1-6

esttab using "/Users/Wdy/Desktop/Honors/mainregresult.txt",  drop(*.Year *.Country *.ISIC) s(fixedy fixedr fixedry N r2, label("Year FE" "Country FE" "Industry FE" "Obs" "R-Squared"))

*Several others on export
gen lgdp = log(gdp09)
gen lemployee = log(number_employees)
gen lsale = log(total_sale09)

reg TFP Export, robust
reg lgdp Export, robust
reg lemployee Export, robust
reg lsale Export, robust

reg TFP Export i.Year i.Country, robust
reg lgdp Export i.Year i.Country, robust
reg lemployee Export i.Year i.Country, robust
reg lsale Export i.Year i.Country, robust

reg TFP Export i.Year i.Country i.ISIC, robust
reg lgdp Export i.Year i.Country i.ISIC, robust
reg lemployee Export i.Year i.Country i.ISIC, robust
reg lsale Export i.Year i.Country i.ISIC, robust

*****************************previously useful

esttab using "/Users/Wdy/Desktop/Honors/table1.txt", replace keep(export import)

*generate fixed effects in tables
quietly estadd local fixedy "Y", replace

quietly estadd local fixedr "Y", replace

quietly estadd local fixedry "Y", replace

esttab using "/Users/Wdy/Desktop/Honors/table1.xls", replace keep(export) s(fixedy fixedr fixedry N r2, label("Year FE" "Region FE" "Country FE" "Obs" "R-Squared"))

*******************************start answering Q2

rename obstacle5 severe_obstacle
rename obstacle4 major_obstacle
*then replace data

****import
eststo clear
 reg import foreign_tech i.Year i.Country, robust
eststo model1
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "N", replace

 reg import foreign_tech  i.Year i.Country i.ISIC, robust
eststo model2
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg import foreign_tech export medium_size large_size i.Year i.Country i.ISIC, robust
eststo model3
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  import foreign_tech export medium_size large_size  shareholdingpublic shareholdingprivate i.Year i.Country i.ISIC, robust
eststo model4
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  import export medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD  i.Year i.Country i.ISIC, robust
eststo model5
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  import export medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD import_custom i.Year i.Country i.ISIC, robust
eststo model6
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  import export medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD  import_custom i.Year i.Country i.ISIC if import>0, robust
eststo model7
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

esttab using "/Users/Wdy/Desktop/Honors/importregresult.txt",  drop(*.Year *.Country *.ISIC) s(fixedy fixedr fixedry N r2, label("Year FE" "Country FE" "Industry FE" "Obs" "R-Squared"))

****export
eststo clear

 reg export year_of_export i.Year i.Country, robust
eststo model1
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "N", replace

 reg export year_of_export  i.Year i.Country i.ISIC, robust
eststo model2
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg export year_of_export import medium_size large_size i.Year i.Country i.ISIC, robust
eststo model3
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  export year_of_export import medium_size large_size  shareholdingpublic shareholdingprivate i.Year i.Country i.ISIC, robust
eststo model4
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  export year_of_export import medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD  i.Year i.Country i.ISIC, robust
eststo model5
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  export year_of_export import medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD export_custom severe_obstacle major_obstacle i.Year i.Country i.ISIC, robust
eststo model6
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  export year_of_export import medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD export_custom severe_obstacle major_obstacle  i.Year i.Country i.ISIC if export>0, robust
eststo model7
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

esttab using "/Users/Wdy/Desktop/Honors/exportregresult.txt",  drop(*.Year *.Country *.ISIC) s(fixedy fixedr fixedry N r2, label("Year FE" "Country FE" "Industry FE" "Obs" "R-Squared"))

***Export

eststo clear

 reg Export year_of_export i.Year i.Country, robust
eststo model1
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "N", replace

 reg Export year_of_export  i.Year i.Country i.ISIC, robust
eststo model2
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg Export year_of_export import medium_size large_size i.Year i.Country i.ISIC, robust
eststo model3
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  Export year_of_export import medium_size large_size  shareholdingpublic shareholdingprivate i.Year i.Country i.ISIC, robust
eststo model4
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  Export year_of_export import medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD  i.Year i.Country i.ISIC, robust
eststo model5
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  Export year_of_export import medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD export_custom severe_obstacle major_obstacle i.Year i.Country i.ISIC, robust
eststo model6
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

 reg  Export year_of_export import medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD export_custom severe_obstacle major_obstacle  i.Year i.Country i.ISIC if export>0, robust
eststo model7
quietly estadd local fixedy "Y", replace
quietly estadd local fixedr "Y", replace
quietly estadd local fixedry "Y", replace

esttab using "/Users/Wdy/Desktop/Honors/Exportregresult1.txt",  drop(*.Year *.Country *.ISIC) s(fixedy fixedr fixedry N r2, label("Year FE" "Country FE" "Industry FE" "Obs" "R-Squared"))


*reg  export import medium_size large_size  shareholdingpublic shareholdingprivate foreign_tech RD loss_theft lgdp severe_obstacle major_obstacle export_custom i.Year i.Country i.ISIC if import>0, robust

**********Chapter 4**********

****************attempts: try iv!
*Within country

egen country_year_customs = total(export_custom), by(country_name Year)
gen customs_pos_firm = export_custom > 0
egen country_pos_firms = total(customs_pos_firm), by(country_name Year)
gen customs_average = (country_year_customs - export_custom) / (country_pos_firms - 1)
*save "/Users/Wdy/Desktop/Honors/cleaned1.dta", replace

*across country
use "/Users/Wdy/Desktop/Honors/bilateral_trade_flows.dta"
rename tradeflow volume
rename origin origin
rename destination dest
rename origin origin_full
rename dest dest_full
rename iso3_o origin
rename iso3_d dest
*save "/Users/Wdy/Desktop/Honors/bilateral_trade_flows.dta",replace

egen total_exports = total(volume), by(origin year)
gen export_share = volume/total_exports
egen total_imports = total(volume), by(dest year)
gen import_ROW = total_imports - volume
gen weighted_exports = export_share*import_ROW
collapse (sum) weighted_exports, by(origin year)
rename origin ISO
save "/Users/Wdy/Desktop/Honors/tradeflow.dta"
merge m:1 ISO year using tradeflow.dta
drop if _merge == 2
drop _merge
*tab year if _merge==1, not all obs have values.
*multiply
gen lweighted_exports = log(weighted_exports)
gen instrument = customs_average * lweighted_exports
ivregress 2sls TFP (export = instrument) i.Year i.Country i.ISIC
estat firststage

*********************attempts/prep above, formal below

*reg TFP import year_of_export medium_size large_size shareholdingpublic shareholdingprivate foreign_tech RD loss_theft lgdp major_tax_obstacle severe_tax_obstacle major_political_obstacle severe_political_obstacle i.Year i.Country i.ISIC (export = lweighted_exports)

gen lweighted_exports = log(weighted_exports)
gen instrument = log(customs_average * weighted_exports)
ivregress 2sls TFP (export = instrument) i.Year i.Country i.ISIC
estat firststage

ivregress 2sls TFP import year_of_export medium_size large_size shareholdingpublic shareholdingprivate foreign_tech RD loss_theft lgdp major_tax_obstacle severe_tax_obstacle major_political_obstacle severe_political_obstacle i.Year i.Country i.ISIC (export = instrument)
estat firststage
**********Chapter 5**********

***patterns over number of observations per countries
bysort country_name: egen Countrycounter=count(country_name)
*might also work? egen Countrycount = count(Country), by (country_name) 
tab Countrycount
collapse Countrycounter, by(country_name)
sum Countrycounter,d
clear
*average of 367.5221 obs per country, but 25% is 87, 75% is 425. median 204.5






