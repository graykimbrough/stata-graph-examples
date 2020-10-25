#delimit ;
/* Create profiles by age and gender for 10 characteristics over 53 years of
  CPS ASEC data from IPUMS.

  Final figure: https://twitter.com/graykimbrough/status/1122535539477868545

  Author: Gray Kimbrough, @graykimbrough
*/

/* Load data: IPUMS dataset containing, at a minimum (for all of these figures)
	for all CPS ASEC samples from 1968-2020:
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
use cps_00172.dta, clear;

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
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_married_`yr', replace);
graph export `"./graphs/married_`yr'.png"', width(1024) replace;
graph drop _all;
};

/************* 2) Percentage employed ********************/
use cps_individuals, clear;
/* Generate employment indicator variable */
gen employed = (empstat==10 | empstat==12) if ~missing(empstat);

/* Collapse to generate proportion by age and gender */
collapse (mean) employed [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_employed = employed * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_employed percents;

/* Initialize locals to store all of the graphs, by gender */
local graphs_men = "";
local graphs_women = "";

/* Get all values of sample years */
levelsof year, local(years);

/* Loop through all years */
foreach yr of local years{;

/* Graph men and women separately, making sure that y axis range is the same
	for all graphs. I specify these ranges manually here, as well as the
	placement of the year.
	These are copied from the married code, except that I expanded Y value
	ranges to 100.
*/
graph twoway `graphs_men'
	(line pct_employed age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(employed_men_`yr', replace)
		subtitle(`"Percentage of men employed, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_employed age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(employed_women_`yr', replace)
		subtitle(`"Percentage of women employed, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_employed age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_employed age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine employed_men_`yr' employed_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_employed_`yr', replace);
graph export `"./graphs/employed_`yr'.png"', width(1024) replace;
graph drop _all;
};

/************* 3) Percentage ever married ********************/
use cps_individuals, clear;
/* Generate ever-married indicator variable */
gen ever_married = marst~=6 if ~missing(marst);

/* Collapse to generate proportion by age and gender */
collapse (mean) ever_married [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_ever_married = ever_married * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_ever_married percents;

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
	(line pct_ever_married age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(ever_married_men_`yr', replace)
		subtitle(`"Percentage of men ever married, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_ever_married age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(ever_married_women_`yr', replace)
		subtitle(`"Percentage of women ever married, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_ever_married age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_ever_married age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine ever_married_men_`yr' ever_married_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_ever_married_`yr', replace);
graph export `"./graphs/ever_married_`yr'.png"', width(1024) replace;
graph drop _all;
};

/************* 4) Percentage living with own children ********************/
use cps_individuals, clear;
/* Generate marriage indicator variable */
gen lives_with_children = nchild>0 if ~missing(nchild);

/* Collapse to generate proportion by age and gender */
collapse (mean) lives_with_children [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_lives_with_children = lives_with_children * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_lives_with_children percents;

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
	(line pct_lives_with_children age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(lives_with_children_men_`yr', replace)
		subtitle(`"Percentage of men living with own children"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_lives_with_children age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(lives_with_children_women_`yr', replace)
		subtitle(`"Percentage of women living with own children"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_lives_with_children age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_lives_with_children age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine lives_with_children_men_`yr' lives_with_children_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(lives_with_children_`yr', replace);
graph export `"./graphs/lives_with_children_`yr'.png"', width(1024) replace;
graph drop _all;
};

/********** 5) Percentage living with own children younger than 5 *************/
use cps_individuals, clear;
/* Generate marriage indicator variable */
gen with_young_children = nchlt5>0 if ~missing(nchild);

/* Collapse to generate proportion by age and gender */
collapse (mean) with_young_children [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_with_young_children = with_young_children * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_with_young_children percents;

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
	(line pct_with_young_children age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 65))
		ylabel(0(10)60, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(with_young_children_men_`yr', replace)
		subtitle(`"Percentage of men living with own children under 5"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_with_young_children age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 65))
		ylabel(0(10)60, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(with_young_children_women_`yr', replace)
		subtitle(`"Percentage of women living with own children<5"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_with_young_children age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_with_young_children age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine with_young_children_men_`yr' with_young_children_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(with_young_children_`yr', replace);
graph export `"./graphs/with_young_children_`yr'.png"', width(1024) replace;
graph drop _all;
};

/************* 6) Percentage high school graduates ********************/
use cps_individuals, clear;
/* Generate high school graduate indicator variable */
gen hsgrad = educ>=72 if (~missing(educ) & educ~=999);

/* Collapse to generate proportion by age and gender */
collapse (mean) hsgrad [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_hsgrad = hsgrad * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_hsgrad percents;

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
	(line pct_hsgrad age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(hsgrad_men_`yr', replace)
		subtitle(`"Percentage of men with HS diploma, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_hsgrad age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(hsgrad_women_`yr', replace)
		subtitle(`"Percentage of women with HS diploma, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_hsgrad age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_hsgrad age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine hsgrad_men_`yr' hsgrad_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"'
		`"Includes those who completed 12 years of education with unclear diploma status."')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_hsgrad_`yr', replace);
graph export `"./graphs/hsgrad_`yr'.png"', width(1024) replace;
graph drop _all;
};

/************* 7) Percentage college graduates ********************/
use cps_individuals, clear;
/* Generate college graduate indicator variable */
gen collgrad = educ>=110 if (~missing(educ) & educ~=999);

/* Collapse to generate proportion by age and gender */
collapse (mean) collgrad [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_collgrad = collgrad * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_collgrad percents;

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
	(line pct_collgrad age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 52))
		ylabel(0(10)50, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(5 55 `"`yr'"', size(large))
		name(collgrad_men_`yr', replace)
		subtitle(`"Percentage of men with bachelor's degrees, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_collgrad age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 52))
		ylabel(0(10)50, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(5 55 `"`yr'"', size(large))
		name(collgrad_women_`yr', replace)
		subtitle(`"Percentage of women with bachelor's degrees, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_collgrad age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_collgrad age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine collgrad_men_`yr' collgrad_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_collgrad_`yr', replace);
graph export `"./graphs/collgrad_`yr'.png"', width(1024) replace;
graph drop _all;
};

/************* 8) Percentage living in owned housing ********************/
use cps_individuals, clear;

/* Limit to 1976 and later, because ownership is not available in
	prior years. */
keep if year>=1976;

/* Generate ownership indicator variable */
gen owns = ownershp==10 if (~missing(ownershp) & ownershp~=0);

/* Collapse to generate proportion by age and gender */
collapse (mean) owns [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_owns = owns * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_owns percents;

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
	(line pct_owns age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 90))
		ylabel(0(10)90, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(owns_men_`yr', replace)
		subtitle(`"Percentage of men living in owned home, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_owns age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 90))
		ylabel(0(10)90, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(owns_women_`yr', replace)
		subtitle(`"Percentage of women living in owned home, by age"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_owns age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_owns age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine owns_men_`yr' owns_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1976-2018 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_owns_`yr', replace);
graph export `"./graphs/owns_`yr'.png"', width(1024) replace;
graph drop _all;
};

/************* 9) Percentage living with parents ********************/
use cps_individuals, clear;
/* Generate marriage indicator variable */
gen mom = momloc >0 if ~missing(momloc );
gen pop = poploc >0 if ~missing(poploc );
gen lives_with_parents = mom | pop;

/* Collapse to generate proportion by age and gender */
collapse (mean) lives_with_parents [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_lives_with_parents = lives_with_parents * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_lives_with_parents percents;

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
	(line pct_lives_with_parents age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(lives_with_parents_men_`yr', replace)
		subtitle(`"Percentage of men living with parents"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_lives_with_parents age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 100))
		ylabel(0(10)100, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(15 55 `"`yr'"', size(large))
		name(lives_with_parents_women_`yr', replace)
		subtitle(`"Percentage of women living with parents"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_lives_with_parents age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_lives_with_parents age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine lives_with_parents_men_`yr' lives_with_parents_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_lives_with_parents_`yr', replace);
graph export `"./graphs/lives_with_parents_`yr'.png"', width(1024) replace;
graph drop _all;
};

/************* 10) Percentage veterans ********************/
use cps_individuals, clear;
/* Generate marriage indicator variable */
gen vet = vetstat==2 if (vetstat~=0 & vetstat~=9 & ~missing(vetstat));

/* Collapse to generate proportion by age and gender */
collapse (mean) vet [pweight=finalweight], by(year age sex);

/* Convert to a percent and label */
gen pct_vet = vet * 100;
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%"
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%";
label values pct_vet percents;

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
	(line pct_vet age if year==`yr' & sex==1, lcolor(`"24 105 109"')),
		yscale(r(0 81))
		ylabel(0(10)80, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(8 55 `"`yr'"', size(large))
		name(vet_men_`yr', replace)
		subtitle(`"Percentage of men who are military veterans"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

graph twoway `graphs_women'
	(line pct_vet age if year==`yr' & sex==2, lcolor(`"219 112 41"')),
		yscale(r(0 81))
		ylabel(0(10)80, valuelabels)
		xtitle("")
		xscale(r(18 64))
		ytitle("")
		xlabel(20(5)60)
		plotregion(margin(zero))
		text(8 55 `"`yr'"', size(large))
		name(vet_women_`yr', replace)
		subtitle(`"Percentage of women who are military veterans"', justification(left) margin(b+1 t-1) bexpand)
		nodraw;

/* Add all previous lines to each graph, at 10% opacity. */
local graphs_men = `"`graphs_men'"' + `" (line pct_vet age if year==`yr' & sex==1, lcolor(`"24 105 109%10"'))"';
local graphs_women = `"`graphs_women'"' + `" (line pct_vet age if year==`yr' & sex==2, lcolor(`"219 112 41%10"'))"';

/* Combine graphs and export at a resolution that twitter will accept
	once converted to a .gif (without having to mess with resizing). */
graph combine vet_men_`yr' vet_women_`yr',
	rows(1)
	note(`"Source: Civilian, non-institutional American population from 1968-2020 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough"')
	xsize(10) ysize(5) iscale(*1.3)
	name(combined_vet_`yr', replace);
graph export `"./graphs/vet_`yr'.png"', width(1024) replace;
graph drop _all;
};

/* Make all of the .gifs at once */

foreach graphname in married employed ever_married lives_with_children
	with_young_children hsgrad collgrad lives_with_parents vet{;

	/* Call ImageMagick 'convert' to create the .gif from all of the .png images */
	/* Additional delay at years ending in 8 */
	!/usr/local/bin/convert
		-delay 300 ./graphs/`graphname'_1968.png
		-delay 100 ./graphs/`graphname'_1969.png
		-delay 250 ./graphs/`graphname'_1970.png
		-delay 100 ./graphs/`graphname'_197{1..9}.png
		-delay 250 ./graphs/`graphname'_1980.png
		-delay 100 ./graphs/`graphname'_198{1..9}.png
		-delay 250 ./graphs/`graphname'_1990.png
		-delay 100 ./graphs/`graphname'_199{1..9}.png
		-delay 250 ./graphs/`graphname'_2000.png
		-delay 100 ./graphs/`graphname'_200{1..9}.png
		-delay 250 ./graphs/`graphname'_2010.png
		-delay 100 ./graphs/`graphname'_201{1..9}.png
		-delay 500 ./graphs/`graphname'_2020.png
		./graphs/`graphname'.gif;
};

/* Exception: "owns" doesn't go back that far */

foreach graphname in owns{;
	/* Call ImageMagick 'convert' to create the .gif from all of the .png images */
	/* Additional delay at years ending in 8 */
	!/usr/local/bin/convert
		-delay 300 ./graphs/`graphname'_1976.png
		-delay 100 ./graphs/`graphname'_197{7..9}.png
		-delay 250 ./graphs/`graphname'_1980.png
		-delay 100 ./graphs/`graphname'_198{1..9}.png
		-delay 250 ./graphs/`graphname'_1990.png
		-delay 100 ./graphs/`graphname'_199{1..9}.png
		-delay 250 ./graphs/`graphname'_2000.png
		-delay 100 ./graphs/`graphname'_200{1..9}.png
		-delay 250 ./graphs/`graphname'_2010.png
		-delay 100 ./graphs/`graphname'_201{1..9}.png
		-delay 500 ./graphs/`graphname'_2020.png
		./graphs/`graphname'.gif;
};
