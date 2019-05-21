/* 1) Overlaying Missing Data Values
1. two tables contains same students' list with score1 and gender information
2. each table contains missing values for different students:
missings in one table, may have values in another table
3. combine the two tables to fill out the missings as much as possible
*/

proc import datafile = "/folders/myfolders/study_1"
dbms = xlsx out = study_1 replace;
run;

proc import datafile = "/folders/myfolders/study_2"
dbms = xlsx out = study_2 replace;
run;

proc sql;
   select s1.name,
   		  s1.score1 'score1_s1' , s2.score1 'score1_s2', 
   		  s1.gender 'gender_s1', s2.gender 'gender_s2',
          coalesce(s1.score1,s2.score1)as score1_final ,
           coalesce(s1.gender,s2.gender)as gender_final
      from study_1 as s1 full join study_2 as s2
           on s1.name =s2.name
      order by name;
quit;


/* 2) Updating a Table with Values from Another Table

update score data with updated score1 values*/

proc import datafile = "/folders/myfolders/score_data" 
DBMS = xlsx out = score_data replace ;
run;
proc import datafile = "/folders/myfolders/score1_update" 
DBMS = xlsx out = score1_data replace ;
run;


proc sql;
create table score_data_updated as
   select * from score_data;
update score_data_updated as u
   set score1=(select score1 from score1_data as s1
            where u.name=s1.name)                                 
        where u.name in (select Name from score1_data);           
        
/*The WHERE clause of outer query ensures that only the rows 
in score_data_updated that have a corresponding row in score1_data 
are updated by checking each value of Name against the list of 
Names that is returned from the in-line view. */
       
       
 /* 3) create formatted data */       
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

Data college_f;                                   
   set college;
   format Gender $gender.;
   format SchoolSize $size.;
   format ScholarShip $yesno.;
Run;
       
       
/* 4) Summarizing Data in Multiple Columns

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
      

/* 5) Using Macro Programs */

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

Options Symbolgen;
Options MPRINT;
Options MLOGIC;

%macro STATS (Dsn, Class, Vars);
   
   title "Statistics from data set &Dsn";
   
   Proc means data=&Dsn n mean min max maxdec=1;
      class &Class;
      var &Vars;
   Run;
   
%mend;

%STATS (score_data, Gender, Score1 Score2 Score3)
       
       
       