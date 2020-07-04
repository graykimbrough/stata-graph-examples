/* EPOP rates by age and gender for prime age individuals,
	by 5-year birth cohorts

	Final version:
	https://twitter.com/graykimbrough/status/1117960689166028801

	Gray Kimbrough
*/

/* Use IPUMS extract of CPS ASEC samples from 1968-2017 with relevant variables:
year
hflag
asecwt
age
sex
marst
popstat
empstat
*/
clear all
use cps_00120

/* This is as close as we can get to birth year using CPS data (which lack
	explicit birth year, as found in Census/ACS). ASEC is mostly fielded
	in March, so this is correct for most people. */
gen birthyr = year - age - 1
gen finalweight = asecwt
// Deal with the mystery negative weights in some early CPS samples
replace finalweight = 0 if finalweight <0
// Normalize weights for 2014 ASEC
replace finalweight = finalweight * 3/8 if hflag ==1
replace finalweight = finalweight * 5/8 if hflag ==0

// Limit the sample to birth years and ages of interest
keep if birthyr>=1945
keep if age>=25 & age<=54
gen birthyr5 = ceil((birthyr - 1944) / 5)

// Limit to civilians
keep if popstat==1

// Generate employed indicator variable
gen employed = empstat==10 | empstat==12

// Calculate mean employment rates by age/sex/cohort
collapse (mean) employed [pweight=finalweight], by(birthyr5 age sex)

// Convert to percents for better graph display
gen pct_employed = employed * 100
label define percents 0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%" ///
	60 "60%" 70 "70%" 80 "80%" 90 "90%" 100 "100%"
label values pct_employed percents

// colors for men (1) and women (2)
local col1 24 105 109
local col2 219 112 41

// Manually label cohorts for now
local text1 "1945-1949"
local text2 "1950-1954"
local text3 "1955-1959"
local text4 "1960-1964"
local text5 "1965-1969"
local text6 "1970-1974"
local text7 "1975-1979"
local text8 "1980-1984"
local text9 "1985-1989"
local text10 "1990-1994"

// Label men and women in the first graph
local lbl1 text(88 33 "Men", size(large) color("`col1'")) text(58.8 34 "Women", size(large) color("`col2'"))

// Loop over cohorts
forval val = 1/10 {

	local g1 line pct_employed age if birthyr5 ==`val' & sex==1
	local g2 line pct_employed age if birthyr5 ==`val' & sex==2

	graph twoway `graphs' (`g1', lcolor("`col1'")) (`g2', lcolor("`col2'")), ///
			ytitle("") yscale(r(50 91)) ylabel(50(10)90, valuelabels) ///
			xtitle("") xscale(r(25 54)) xlabel(25(5)50) ///
			plotregion(margin(zero)) ///
			text(60 45 "Born `text`val''", size(large)) ///
			name(birthyr5_employed_`val', replace) ///
			subtitle("Percentage employed", justification(left) margin(b+1 t-1) bexpand) ///
			note("Source: Civilians in CPS households from 1968-2018 IPUMS CPS ASEC samples (cps.ipums.org), @graykimbrough", ///
				margin(l-12 t+2 b-2));

	// Add previous cohort lines, at 20% opacity
	local graphs `graphs' (`g1', lcolor("`col1'%20")) (`g2', lcolor("`col2'%20"))

	// Export graphs as .png images
	graph export `"./graphs/birthyr5_employed_`val'.png"', width(1024) replace
}

/* Use ImageMagick 'convert' command to combine all of these .png graphs
	into a .gif. This command works on OS X with 'convert' installed, but
	the specific command may vary, or the files can be combined using another
	method. */
!/usr/local/bin/convert -delay 400 ./graphs/birthyr5_employed_1.png ///
	-delay 250 ./graphs/birthyr5_employed_{2..9}.png ///
	-delay 450 ./graphs/birthyr5_employed_10.png ///
	./graphs/employed_5year_cohorts.gif
