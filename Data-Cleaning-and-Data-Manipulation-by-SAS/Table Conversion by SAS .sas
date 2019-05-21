*Convert Table A to Table B;

*Question 1: Convert the multiple record per patient table to one record per patient;
data TableA;
   input Emp_Id Jan Feb March April May June;
   card;
   1001 0 1 0 0 1 .
   1001 . 0 0 0 0 0 
   1001 . 0 . 1 0 0
   1001 0 1 0 0 . 0 
   1001 1 1 0 0 0 1
   1002 1 1 1 1 0 0 
   1002 0 0 0 0 0 1 
   1003 1 1 . 1 0 0 
   1003 . 0 0 0 0 0 
   1003 0 0 . . 0 .
   1004 . 1 0 0 0 0 
   1004 1 1 0 0 0 0 
   1004 1 . 0 0 0 0 
   1004 0 1 1 1 0 0 
   ;
Run;


Proc sql;
create table TableB as
select Emp_Id, case when Jan>=1 then 1 else 0 end as Jan,
               case when Feb>=1 then 1 else 0 end as Feb,
               case when March>=1 then 1 else 0 end as March,
               case when April>=1 then 1 else 0 end as April,
               case when May>=1 then 1 else 0 end as May,
               case when June>=1 then 1 else 0 end as June               
from                                
(
select Emp_Id, sum(Jan) as Jan, sum(Feb) as Feb, sum(March) as March, sum(April) as April,
sum(May) as May, sum(June) as June
from tableA
group by Emp_Id) A ;                 /* subquery: sum each variable by Emp_Id  */
Quit;


Proc sort data=TableA out=TableA_s;            /*TableA is sorted by Emp_Id*/ 
   by Emp_Id;
Run;


Data tableB;
   set TableA_s;
   by Emp_Id;
   retain totalJan;
   totalJan+Jan;
   if last.Emp_Id then output;
   if totalJan>0 then totalJan=1;
   else totalJan=0;
run;


Data tableB;
   set TableA_s;
   by Emp_Id;
   retain totalJan;
   totalJan+Jan;
   if last.Emp_Id then output;
   if totalJan>0 then totalJan=1;
   else totalJan=0;
run;

*Question 2: Get the number of employees who got each of the following events;
Data TableA;
   infile datalines missover;
   input Emp_Id Ev1 $6-8 Ev2 $10-12 Ev3 $14-16 Ev4 $18-20 Ev5 $22-24 Ev6 $25-28;
   datalines;
1001 AB  AT  BTR   S XYZ AT
1001 AT  MY  LOV  .  LOV LOV
1001  .  MY  .     S  MY S
1001 AB  BTR LOV BTR AT  AT
1001 AT  LOV KUL  MY  .  S
1002 MY  LOV .    AT  AT BTR 
1002 MY  AT  BTR  .   AT MY
1003 BTR MY  .   XYZ  MY MY
1003  .  MY  MY  MY   MY BTR
1003 BTR AB  MY  .   BTR . 
1004   S  .  MY  MY  .   XYZ
1004 XYZ AT  KUL AB  KUL S 
1004 .    .  BTR LOV MY MY 
1004 MY  KUL AT  KUL XYZ AB
   ;
Run;

Proc sql;                                 /*get all distinct event from each employee*/
Create table TableA1 as
Select Emp_Id,Ev1 from TableA
union 
Select Emp_Id,Ev2 from TableA
union 
Select Emp_Id,Ev3 from TableA
union 
Select Emp_Id,Ev4 from TableA
union 
Select Emp_Id,Ev5 from TableA
union 
Select Emp_Id,Ev6 from TableA
Run;

Proc sql;
select distinct Ev1 as Ev, count(Ev1) as N   /*count the number of employees who attend each event*/
from TableA1
where Ev1 is not null
group by Ev1;
Run;


*Question 3: Collapse drugs with the SAME drug ID into the drug_combo column;
Data tableA;
   input Patient_ID drug_ID drug $15.;
   cards;
   9900001 1 vinorelbine
   9900001 2 carboplatin
   9900001 2 paclitaxel
   9900003 1 fluorouracil
   9900005 1 5-FU
   9900005 1 leucovorin
   9900005 2 fluorouracil
   9900005 3 fluorouracil
   9900005 3 leucovorin
   9900008 1 fluorouracil
   9900008 2 fluorouracil
   9900008 2 leucovorin
   9900008 3 fluorouracil
   9900008 3 irinotecan
   9900008 3 leucovorin
   ;
run;

Proc sort data=tableA out=tableA_s;
   by Patient_ID drug_ID;             /*TableA is sorted by Patient_ID drug_ID*/ 
Run;

Data TableB;
   set TableA_s;
   length drug_combo $50.;
   retain drug_combo;
   by Patient_ID drug_ID;
   if first.drug_ID then drug_combo=drug;
   else 
   drug_combo=catx(" ",drug_combo,drug);              /*concatenate observatin for the same Patient_ID and drug_ID */
   if last.drug_ID;                                  
   drop drug; 
Run;

*Question 4: Convert text data to dates values;
Data tableA;
   input Patient_ID DX_date $20.;
   datalines;
   1001 10, May 2018
   1002 02052011
   1003 2/4/2012
   1004 08/08/2015 9:00 am
   1005 Apr 1, 2000
   1006 2010/09/06
   ;
Run;

Data tableA1;
   set tableA;
   if Patient_ID=1006 then DX_date="2010/06/09";      /*change the format of Da_date for Patient_ID=1006 to yyyy/mm/dd*/
run;

Data tableB;
   set tableA1;
   DX_date_n=input(DX_date, anydtdte20.);    /*read various date values and store them as a SAS date value*/
   drop DX_date;
   format Dx_date_n MMDDYY10.;               /*format output date*/
   rename Dx_date_n=Dx_date;                  /*change the name of variable in output data set */
Run;


..........................................................................

/* SAS sample program for Proc tabulate*/

Data college;                                            /*use INPUT to read raw data*/
   infile datalines dsd;
   input StudentID : $5. Gender :$1. SchoolSize :$1. ScholarShip :$1. GPA :4.2 ClassRank;
   datalines;
00032,F,M,N,4,49
00034,F, M, N, 3.15, 68
00178, M, S, Y, 3.27, 99
00220, F, S, N,   .,   .
00328, F, M, Y, 2.76, 92
00481, M, M, N, 3.05, 61
;
run;

Proc format;                                        /*user-defined format*/
   value $yesno 'Y','1'='Yes'
                 'N','0'='No'
                 ' '    ='Not Given';
  value $size 'S'='Small'
               'M'='Medium'
               'L'='Large'
               ' '='Missing';
  value $gender 'F'='Female'
                 'M'='Male'
                 ' '='Not Given';
Run;

Data college_f;                                    /*create formatted data*/
   set college;
   format Gender $gender.;
   format SchoolSize $size.;
   format ScholarShip $yesno.;
Run;

title "Deomgraphics from College Data Set";           /*using PROC TABULATE to compute frequencies of SchoolSize */
Proc tabulate data=college_f;                          /*  for each combination of Gender and Scholarship*/
   class Gender Scholarship SchoolSize;
   table (Gender all)*(Scholarship all), (schoolSize all);
   keylabel all="Total"
              n=" ";
Run;

title "Percents from College Data Set";                
Proc tabulate data=college_f; 
   class Gender scholarship;
   table (Gender all="Total"), (Scholarship all="Total")* (Colpctn*f=pctfmt7.1); 
   keylabel n=" "
            colpctn="Percent";
Run;


title "Descriptive Statistics from College Data Set";
Proc tabulate data=College_f;
   class SchoolSize;
   var GPA ClassRank;
   table (SchoolSize all), GPA*(median*f=3.1 min*f=3.1 max*f=3.1) ClassRank*(median*f=3. min*f=3. max*f=3.);
   Keylabel all="Total"
            min="Minimum"
            max="Maximum";
   label SchoolSize="School Size"
         ClassRank ="Class Rank";
Run;


/*SAS sample program from blood data set*/

Data blood1;
   infile datalines Missover;
   Input Subject $ Gender $ BloodType $ Age $ WBC RBC Chol;
   datalines;
1    Female AB Young 7710   7.4  258
2    Male   AB Old   6560   4.7  .
3    Male   A  Young 5690   7.53 184
4    Male   B  Old   6680   6.85 .
5    Male   A  Young .      7.72 187
6    Male   A  Old   6140   3.69 142
7    Female A  Young 6550   4.78 290
8    Male   O  Old   5200   4.96 151
;
Run;

Libname project1 '/folders/myfolders';       /*create library and save blood1 SAS data set*/

Data project1.blood1;
   set blood1;
Run;

Ods html body="body.html"                    /*send SAS output of PROC PRINT to an HTML file*/
         contents="contents.html"
         frame="frame.html"
         path="/folders/myfolders";
Title "Listing Data from Blood1"; 
Proc Print data=blood1 label;
   ID Subject;
   Var WBC RBC Chol;
   Label WBC="white blood cell"
         RBC="red blood cell"
         Chol="Cholesterol";
Run;
Ods html close;

ods select extremeobs;                            /*using ODS select statement to restrict proc univariate output*/
Proc univariate data=blood1 ;
   ID Subject;
   Var WBC RBC Chol;
run;  
 
ods trace on/listing;                             /*using ODS trace statement to identify output objects*/
Proc univariate data=blood1;
   ID Subject;
   Var WBC;
run;
ods trace off;  
 
ods output ttests=t_test_data;                    /*using ODS to send procedure output to a SAS data set*/
Proc ttest data=blood1;
  class Gender;
   Var WBC RBC Chol;

ods listing;
proc print data=t_test_data;
Run;

title "T-Test Results-Using Equal Variance Method";    /*using output data set to create a report*/
Proc report data=t_test_data nowd headline;
   where Variances="Equal";
   columns Variances tValue;
   define Variances/width=8;
   define tValue/"T-Value" width=7 format=7.2;
Run;


/* Summarizing Data in Multiple Columns

 produce a grand mean of multiple columns in a table.*/

Data score_data;
   infile datalines dsd;
   input Gender :$1. Score1 Score2 Score3 Score4;
   Datalines;
M, 80, 82, 85, 88
F, 94, 92, 88, 96
M, 96, 88, 89, 92
F, 95, . ,92, 92
;
Run;   
   
proc sql;
   select 	mean(Score1) as s1_mean format 5.2,
   			mean(Score2) as s2_mean format 5.2,
   			mean(Score3) as s3_mean format 5.2,
   			mean(Score4) as s4_mean format 5.2,
          	mean(calculated s1_mean, calculated s2_mean, calculated s3_mean,calculated s4_mean ) 
          	as GrandMean format 4.1
      from score_data;
quit;   

/*An alternative way to obtain the Grand Mean*/

proc sql;
select mean(mean(score1), mean(score2), mean(score3))
   as GrandMean format= 4.1
from score_data;
quit; 












