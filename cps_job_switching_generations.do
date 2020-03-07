#delimit ;
/* Create graphs of job switching by generation and year

By: Gray Kimbrough, @graykimbrough on twitter */

/* Input: IPUMS-CPS extract with all necessary variables for ASEX samples
  1976-2019:

  ASECWT
  YEAR
  AGE
  NUMEMPS
  */
use cps_00151, clear;

/* Approximate birth year this way (since most ASEC responses are from March) */
gen birthyr = year - age - 1;

/* Categorize generations using Pew year definitions
  1: Silent generation
  2: Baby Boomers
  3: Generation X
  4: Millennials
  5: Gen Z
*/
gen generation = 1 if birthyr>=1928 & birthyr<=1945;
replace generation = 2 if birthyr>=1946 & birthyr<=1964;
replace generation = 3 if birthyr>=1965 & birthyr<=1980;
replace generation = 4 if birthyr>=1981 & birthyr<=1996;
replace generation = 5 if birthyr>=1997;

/* Switched jobs if reported multiple sequential employers in the previous
  calendar year, missing if zero employers in that year */
gen switched_jobs = numemps>1 if numemps>0 & ~missing(numemps);
drop if missing(switched_jobs);

keep if age>=21 & age<=54;

collapse (mean) switched_jobs [pweight = asecwt], by(year age generation);

/* Convert to percentage and add labels */
gen pct_switched = switched_jobs * 100;
label define percents 0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%" 25 "25%"
  30 "30%" 35 "35%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_switched percents;

local switched_graphs = `""';

/* Loop through all years */
forval yr = 1976/2019{;

graph twoway `switched_graphs'
  (line pct_switched age if year == `yr' & generation ==1, lcolor(`"24 105 109"'))
  (line pct_switched age if year == `yr' & generation ==2, lcolor(`"219 112 41"'))
  (line pct_switched age if year == `yr' & generation ==3, lcolor(`"73 70 68"'))
  (line pct_switched age if year == `yr' & generation ==4, lcolor(maroon)),
    yscale(r(0 40))
    ylabel(0(5)40, valuelabels)
    plotregion(margin(zero))
    xscale(r(21 54))
    xlabel(25(5)50)
    name(all_generations_`yr', replace)
    text(30 47 `"`yr'"', size(large))
    ytitle("")
    xtitle("")
    subtitle(`"Percentage of workers with multiple sequential employers in previous year"', margin(l+2))
    note(`"Source: 1976-2019 CPS ASEC samples from IPUMS (cps.ipums.org), @graykimbrough"', margin(t+2 b-2));


local switched_graphs = `"`switched_graphs'"' + `"   (line pct_switched age if year == `yr' & generation ==1, lcolor(`"24 105 109%10"'))
  (line pct_switched age if year == `yr' & generation ==2, lcolor(`"219 112 41%10"'))
  (line pct_switched age if year == `yr' & generation ==3, lcolor(`"73 70 68%10"'))
  (line pct_switched age if year == `yr' & generation ==4, lcolor(maroon%10))"';
/* Save and export to .png for compilation into .gif */
graph save `"./graphs/switched_`yr'.gph"', replace;
graph export `"./graphs/switched_`yr'.png"', width(1024) replace;
/* Drop the graphs to avoid "too many sersets" errors */
graph drop _all;
};

/* I manually added labels to several years before generating the .gif
  using ImageMagick 'convert' */
