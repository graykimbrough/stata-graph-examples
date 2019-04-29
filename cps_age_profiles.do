#delimit ;
/* Create profiles by age and gender for 10 characteristics over 51 years of
  CPS ASEC data from IPUMS. 
  
  Final figure: https://twitter.com/graykimbrough/status/1122535539477868545
  
  Author: Gray Kimbrough, @graykimbrough 
*/

/* Load data: IPUMS dataset containing, at a minimum (for all of these figures)
	for all CPS ASEC samples from 1968-2018:
	YEAR
	HFLAG
	ASECWT
	AGE
	SEX
	MARST
	POPSTAT
	VETSTAT
	MOMLOC
	POPLOC
	NCHILD
	NCHLT5
	EMPSTAT
	EDUC
*/
use cps_00125.dta, clear;

/* My usual code to adjust CPS weights. */
gen finalweight = asecwt ;
replace finalweight = 0 if finalweight <0;
replace finalweight = finalweight * 3/8 if hflag ==1;
replace finalweight = finalweight * 5/8 if hflag ==0;

/* Keep ages 18-64 */
keep if age>=18 & age<=64;

/* Drop if not civilian adults */
keep if popstat==1;

/* Save the full set of individuals before collapsing */
save cps_individuals, replace;

/************* 1) Percentage married ********************/
use cps_individuals, clear;
/* Generate marriage indicator variable */
gen married = (marst==1 | marst==2) if ~missing(marst);

/* Collapse to generate proportion by age and gender */
collapse (mean) married [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_married = married * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_married percents;

/* Initialize locals to store all of the graphs, by gender */
local graphs_men = "";
local graphs_women = "";

/* Get all values of sample years */
levelsof year, local(years);

/* Loop through all years */
foreach yr of local years{;

/* Graph men and women separately, making sure that y axis range is the same
	for all graphs. I specify these ranges manually here, as well as the
	placement of the year. */
graph twoway `graphs_men'
	(line pct_married age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 92))
		ylabel(0(10)90, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(married_men_`yr', replace)
		subtitle(`"Percentage of men married, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_married age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 92))
		ylabel(0(10)90, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(married_women_`yr', replace)
		subtitle(`"Percentage of women married, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_married age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_married age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine married_men_`yr' married_women_`yr',
	rows(1)
	note(`"Source: Civilians in CPS households from 1968-2018 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_married_`yr', replace);
graph export `"./graphs/married_`yr'.png"', width(1024) replace;
graph drop _all;
};

/* Call ImageMagick 'convert' to create the .gif from all of the .png images */
/* Additional delay at years ending in 8 */
!/usr/local/bin/convert 
	-delay 300 ./graphs/married_1968.png
	-delay 100 ./graphs/married_19{69..77}.png
	-delay 250 ./graphs/married_1978.png
	-delay 100 ./graphs/married_19{79..87}.png
	-delay 250 ./graphs/married_1988.png
	-delay 100 ./graphs/married_19{89..97}.png
	-delay 250 ./graphs/married_1998.png
	-delay 100 ./graphs/married_1999.png
	-delay 100 ./graphs/married_200{0..7}.png
	-delay 250 ./graphs/married_2008.png
	-delay 100 ./graphs/married_2009.png
	-delay 100 ./graphs/married_20{10..17}.png
	-delay 500 ./graphs/married_2018.png
	./graphs/married.gif;
	
