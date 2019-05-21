/* data source   https://archive.ics.uci.edu/ml/datasets/student+performance  */
/* import a csv file delimited by semicolon */
Proc import datafile="/folders/myfolders/student-por.csv" out=student_por 
		dbms=csv replace;
	delimiter=';';
Run;


/* compute frequencies and percentages of studytime by failures for  each combination of sex and school */
Proc freq data=student_por;
	table sex*school*studytime*failures/nocol norow;
Run;

/* statistic analysis of studytime and failures for each combination of sex and school */
title "analysis of studytime and failures";

Proc tabulate data=student_por;
	class sex school;
	var studytime failures;
	table (sex all)*(school all), (studytime failures)*(mean min max)*f=5.2;
	keylabel all="total" n=" " pctn="Percent";
run;

/*compute percentages of Failures for each combination of Sex and School */
Ods html body="body.html"                    /*send SAS output of PROC TABULATE to an HTML file*/
contents="contents.html" frame="frame.html" path="/folders/myfolders";
title "counts and percentages";

Proc tabulate data=student_por;
	class sex school failures;
	table (sex all)*(school all), (failures all)*(n pctn*f=pctn7.1);
	keylabel all="total" pctn="Percent";
run;

Ods html close;



/*using ODS trace statement to identify output objects*/
ods trace on/listing;

Proc univariate data=student_por;
	ID school;
	var failures;
Run;

ods trace off;



/*using ODS to send procedure output to a SAS data set*/
ods output ttests=t_test_data;

Proc ttest data=student_por;
	class school;
	Var studytime failures;
	ods listing;

proc print data=t_test_data;
Run;

/* run a scatter plot to determine if there is correlation between two variables: age and studytime */
Proc plot data=student_por;
	plot age*studytime;
	Run;
