/* creat a customized graph by PROC SGPPLOT */

/*data source:   https://archive.ics.uci.edu/ml/datasets/student+performance  */

/* import a csv file delimited by semicolon */
Proc import datafile="/folders/myfolders/student-por.csv" out=student_por 
		dbms=csv replace;
	delimiter=';';
Run;

/* Bar chart */
ods graphics / reset;

title "Freq distribution of failures by group of studytime";
title2 "Cluster bars (side-by-side)";
proc sgplot data=STUDENT_POR;
	hbar failures / group=studytime groupdisplay=cluster;
	xaxis grid;
run;


/* Scatter plot: show correlation of two continuious viables */

Data scatter_data;
   input d1 d2 d3;
   datalines;
   9 3 11
   1 2 2
   3 6 3
   2 1 4
   1 3 3
   2 3 5
   1 2 1
   8 6 9
   10 2 12
   5 3 7
   6 3 7.5
   ;
Run;

proc sgplot data=scatter_data;
	scatter x=d1 y=d3;
run;

/* Add regression line, to see if there is linear relationship of two variables */

proc sgplot data=scatter_data;
	reg x=d1 y=d3;
run;

/* Add a prediction ellipse to a scatter plot  */

proc sgplot data=scatter_data;
	scatter x=d1 y=d3;
	ellipse x=d1 y=d3;
run;



/* creat a visualize data by PROC UNIVARIATE:measures of central tendency and dispersion */

/* data source: https://archive.ics.uci.edu/ml/datasets/Immunotherapy+Dataset#  */
/* import excel file */

Proc import datafile="/folders/myfolders/immunotherapy.xlsx" out=immunotherapy1 
		dbms=xlsx replace;
Run;


/* age distribution */
Proc univariate data=immunotherapy1 plot normal;
	var age;
	histogram/normal;
Run;

/* categorical data: type count */
Proc sgplot data=immunotherapy1;
   Hbar type;
   xaxis grid;
Run;
