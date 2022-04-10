*first I merged the data with the idstd

clear

use "/Users/Wdy/Desktop/Honors/Firm Level TFP Estimates and Factor Ratios_February_16_2021.dta"

merge 1:1 idstd using "/Users/Wdy/Desktop/Honors/New_Comprehensive_February_16_2021.dta"

*(label N2E already defined)
*(label D2 already defined)
*(label L1 already defined)
*(label N7A already defined)
*(label N2A already defined)
*(label N2I already defined)
*(label a0 already defined)\

drop if _merge != 3
*(10,557 observations deleted)

save /Users/Wdy/Desktop/Honors/merged.dta

*2.17.2021
*use "/Users/Wdy/Desktop/Honors/merged copy.dta"

*2.24.2021
use "/Users/Wdy/Desktop/Honors/merged copy.dta"

keep country idstd stra_sector sector_MS income size isic a3 b1 b2a b2b b7a d2 d3b d3c d4 d5a d8 d12b d14 d15a d30b e1 e6 h8 j10 j11 j12 i3 j30a j30e k3a k5a l1 m1a size_num strata year d2_gdp09 n2a_gdp09 n2e_gdp09 tfprYKLM tfprVAKL

*summarize

drop if missing(tfprYKLM)
drop if missing(tfprVAKL)

*save /Users/Wdy/Desktop/Honors/cleaned.dta

use /Users/Wdy/Desktop/Honors/cleaned.dta
*now let's clean more

*describe

*Step 0
*Check key variables' distribution using histograms
*tfprYKLM tfprVAKL: same for cleaned data and the original merged data
*country year isic: country,year has some disparitie but overall is spread out.

*Solved!!the isic code should be cut off by leaving 2 remaining digits because the format of numbers
*is not correct. Or drop this variable if needed.

*Solved!!Cannot check country size income because inspect/summarize both return missing values
*and no string operation works as I tried

*l1 d2 b1     ok
*b2a b2b    ok
*d3b d3c --- checked histograms ok.
*d4 d14 d5a d8    ok
*e1 h8 i3 k3a m1a    ok
*n2a n2e	 ok.(do not use the deflated value for checking.)

*Step 1
*find outliers, get rid of 
*negative values (-7:does not apply, -4: ????????too many to count, -8:refusal, -9:don't know), and change all the missing data into dots.

*example
summarize d2,d
*tabulate d2
*too many values
sum country idstd stra_sector sector_MS income size isic a3 b1 b2a b2b b7a d2 d3b d3c d4 d5a d8 d12b d14 d15a d30b e1 e6 h8 j10 j11 j12 i3 j30a j30e k3a k5a l1 m1a size_num strata year d2_gdp09 n2a_gdp09 n2e_gdp09 tfprYKLM tfprVAKL,d
*note that outliers exist for a3, b2a, b2b, b7a, d3b, d3c, d4, d5a, etc.


*Suggested codes: 
*hist
*summarize, tabulate-display r(r), codebook
*replace female = . if female == -999

*generate Country = country
*generate country1 = substr(Country, -4, 100)
*generate country2 = substr(Country,1, strlen(Country)-4)
generate country_name = substr(country,1, strlen(country)-4)
egen Year = group(year)

*Variables that remain undone: stra_sector, isic, strata (also not sure what it means)
*TOO many distinct values---***Solved*** with tabulate generate.
tabulate stra_sector, generate(stra)

generate Income = income
generate high_income = 1 if Income == "High Income"
replace high_income = 0 if Income == "Low Income"
drop Income

decode size, generate(SIZE)
generate small_size = 1 if SIZE == "Small(<20)"
replace small_size = 0 if SIZE != "Small(<20)"
generate medium_size = 1 if SIZE == "Medium(20-99)"
replace medium_size = 0 if SIZE != "Medium(20-99)"
generate large_size = 1 if SIZE == "Large(100 And Over)"
replace large_size = 0 if SIZE != "Large(100 And Over)"
*Checked using generate sum = small_size + medium_size + large_size
*summarize sum
*drop sum

tabulate isic, generate(isic)

summarize a3,d
*!!!!!!!!!!!!problem: 1,6 unclear what it means

replace b1=. if b1<0|b1>8
tabulate b1, gen(legal_status)

replace b2a = . if b2a<0
replace b2b = . if b2b<0

decode b7a, generate(B7a)
gen female = 1 if B7a == "Yes"
replace female = 0 if B7a == "No"
drop B7a

replace d3b = . if d3b<0
replace d3c = . if d3c<0
gen export = d3b + d3c


*decode d4, generate(D4)
generate dd4 = d4
*replace dd4 = 1 if d4 == "One day or less"
rename dd4 export_custom
replace export_custom = 0 if missing(export_custom)
replace export_custom = . if export_custom <0

decode d5a, generate(D5a)
generate gift_export = 1 if D5a == "Yes"
replace gift_export = 0 if D5a == "No"
drop D5a

replace d8 = year if missing(d8)
replace d8 = . if d8<0
gen year_of_export=year-d8

replace d12b = . if d12b<0

generate dd14 = d14
rename dd14 import_custom
replace import_custom = 0 if missing(import_custom)
replace import_custom = . if import_custom<0

decode d15a, generate(D15a)
gen gift_import = 1 if D15a == "Yes"
replace gift_import = 0 if D15a == "No"
drop D15a

****************NEXT*****************
*get country by splitting string of the variable country
*start with d30b and work on cleaning
*As for the string variables, wait and talk w Prof Lopresti and see what is the best
*approach for treating missing values& handle categorial/dummy variables.

replace d30b = . if d30b<0
tabulate d30b, generate(obstacle)

replace e1 = . if e1<0 | e1>3
tabulate e1, generate(main_market)

replace e6 = . if e6<0 | e6>3
decode e6, generate(E6)
gen foreign_tech = 1 if E6 == "Yes"
replace foreign_tech = 0 if E6 == "No"
drop E6

replace h8 = . if h8<0
decode h8, generate(H8)
gen RD = 1 if H8 == "Yes"
replace RD = 0 if H8 == "No"
drop H8

replace i3 = . if i3<0
decode i3, generate(I3)
gen  loss_theft = 1 if I3 == "Yes"
replace loss_theft = 0 if I3 == "No"
drop I3

replace j10 = . if j10<0
decode j10, generate(J10)
gen app_import = 1 if J10 == "Yes"
replace app_import = 0 if J10 == "No"
drop J10

gen J11 = j11
replace J11 = 0 if missing(J11)
replace J11 = . if J11<0

replace j12 = . if j12<0
gen J12 = j12

replace j30a = . if j30a <0
tabulate j30a, gen(tax_obstacle)

replace j30e = . if j30e<0
tabulate j30e, gen(political_obstacle)

replace k3a = . if k3a<0
replace k5a = . if k5a<0

tabulate m1a, gen(biggest_obstacle)

*check at last
sum country idstd stra_sector sector_MS income size isic a3 b1 b2a b2b b7a d2 d3b d3c d4 d5a d8 d12b d14 d15a d30b e1 e6 h8 j10 j11 j12 i3 j30a j30e k3a k5a l1 m1a size_num strata year d2_gdp09 n2a_gdp09 n2e_gdp09 tfprYKLM tfprVAKL,d
*Also try 'ssc install unique' to check unique values 

save /Users/Wdy/Desktop/Honors/cleaned1.dta

*Step 2
*Convert yes-no to indicator variables of 1-0, do the split for certain variables
*including main market etc. 
*pass

*Step 3
*Create necessary variables, including total exports, etc.
*Note that the sum should be in the range [0,100]    ok

*use /Users/Wdy/Desktop/Honors/cleaned1.dta

*drop idstd country sector_MS Income size b1 b7a
*Seems unnecessary though, just ignore the variables if encountered.
*replace a3 = . if a3<1.5|a3>5.5
drop a3
save /Users/Wdy/Desktop/Honors/cleaned1.dta, replace

drop idstd sector_MS income d2 strata SIZE 

save /Users/Wdy/Desktop/Honors/cleaned1.dta, replace

