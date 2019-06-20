/* data source   https://archive.ics.uci.edu/ml/datasets/student+performance  

Is is possible to predict student performance? 
What are the factors that affect student achievement?
Modeling student performance

*/

/* import a csv file delimited by semicolon */

Proc import datafile="/folders/myfolders/student-por.csv" out=student_por 
		dbms=csv replace;
	delimiter=';';
Run;

*create format G3_binary to group G3 into 2 categories (Binary classification);

Proc format;
   value G3_binary 10-20="pass"
                   0-9="fail";
Run;

*create format G3_grade to group G3 into 5 categories (5-level classification);

Proc format;
   value G3_5level 16-20="A"
                  14-15="B"
                  12-13='C'
                  10-11='D'
                    0-9='E';
Run;


Data G3_binary_student_por;
   Set student_por;
   format G3 G3_binary.;
Run; 

Data G3_5level_student_por;
   Set student_por;
   format G3 G3_5level.;
Run;

* descriptive statistics on G3 based on school;

Proc freq data=G3_binary_student_por order=formatted;
    tables school*G3/norow nocol;
Run;

Proc freq data=G3_5level_student_por order=formatted;
    tables school*G3/norow nocol;
Run;


ods graphics on;

title "Clustered bar-chart for G3 by school (Binary classification)";

Proc Sgplot  data=G3_binary_student_por;
    vbar G3/group=school groupdisplay=cluster;
Run;

Proc sort data=G3_5level_student_por out=sorted_G3;
   by descending G3;
Run;

title "Clustered bar-chart for G3 by school (5-level classification)";
Proc Sgplot  data=sorted_G3;
   vbar G3/group=school groupdisplay=cluster;
   xaxis discreteorder=data;
Run;

ods graphics off;


title "Histogram and probability plot for G3 by school";
Proc univariate data=student_por;
    class school;
    var G3;
    Histogram G3;
    Freq G3;
    inset skewness kurtosis;
    Probplot G3;
Run;
