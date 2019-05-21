*/The goal of the project is to create the SDTM DM data set based on the SDTM specification file (i.e. dm_only.xlsx), 
Based on the specification file, we have to create 29 variables for the STDM DM data set:
STUDYID
DOMAIN
USUBJID
SUBJID
RFSTDTC
RFENDTC
RFXSTDTC
RFXENDTC
RFPENDTC
DTHDTC
DTHFL
SITEID
BRTHDTC
AGE
AGEU
SEX
RACE
ETHNIC
ARMCD
ARM
ACTARMCD
ACTARM
COUNTRY
DMDTC
CENTRE
PART
RACEOTH
VISITDTC
;
libname CDM "/folders/myfolders/Project_1_SDTM_DM";

Proc import datafile="/folders/myfolders/Project_1_SDTM_DM/DM.xlsx" dbms=xlsx 
		out=CDM.DM;
	getnames=yes;
Run;

Proc import datafile="/folders/myfolders/Project_1_SDTM_DM/DEATH.xlsx" 
		dbms=xlsx out=CDM.DEATH;
	getnames=yes;
Run;

Proc import datafile="/folders/myfolders/Project_1_SDTM_DM/DS.xlsx" dbms=xlsx 
		out=CDM.DS;
	getnames=yes;
Run;

Proc import datafile="/folders/myfolders/Project_1_SDTM_DM/EX.xlsx" dbms=xlsx 
		out=CDM.EX;
	getnames=yes;
Run;

Proc import datafile="/folders/myfolders/Project_1_SDTM_DM/SPCPKB1.xlsx" 
		dbms=xlsx out=CDM.SPCPKB1;
	getnames=yes;
Run;

*/#1-4 12-18 25-29
STUDYID
DOMAIN
USUBJID
SUBJID
SITEID BRTHDTC AGE AGEU SEX RACE ETHNIC CENTRE PART RACEOTH VISITDTC
;


Data SDTM_DM;
    format studyid domain usubjid subjid SITEID BRTHDTC AGE AGEU SEX RACE ETHNIC DMDTC CENTRE PART RACEOTH VISITDTC;     */ordering columns;
    Length ETHNIC $60;
    format ETHNIC $60.;
	set CDM.DM;
	STUDYID=study;
	DOMAIN='DM';
	Length USUBJID $8.;
	USUBJID=catx('/', STUDYID, SUBJECT);
	SUBJID=SUBJECT;
	SITEID=CENTRE;
	BRTHDTC=BRTHDAT;
	if AGEU='C29848' then AGEU='YEARS';
	select (SEX);
	   when ('C20197')  SEX='M';
	   when ('C16576') SEX='F';
	   otherwise SEX='U';
	end;
	IF RACE='C41260' then RACE='ASIAN';
	   else if RACE='C41261' then RACE='WHITE';
	if ETHNIC='C41222' then ETHNIC='NOT HISPANIC OR LATINO';
	DMDTC=VIS_DAT;
	RACEOTH=upcase(RACEOTH);
	VISITDTC=VIS_DAT;
	KEEP studyid domain usubjid subjid SITEID BRTHDTC AGE AGEU SEX RACE ETHNIC DMDTC CENTRE PART RACEOTH VISITDTC;
Run;

*/#5 20 22 RFSTDTC ARMCD ARM ACTARMCD ACTARM;
*/Fill missing values with the previous values;

Data SDTM_SPCPKB1;
	set CDM.SPCPKB1;
	retain _IPFD1DAT;
	if not missing(IPFD1DAT) then
		_IPFD1DAT=IPFD1DAT;
	else
		IPFD1DAT=_IPFD1DAT;
	drop _IPFD1DAT;
	retain _IPFD1TIM;
	if not missing(IPFD1TIM) then
		_IPFD1TIM=IPFD1TIM;
	else
		IPFD1TIM=_IPFD1TIM;
	drop _IPFD1TIM;
	RFSTDTC=cats(IPFD1DAT, IPFD1TIM);
	where PSCHDAY=1 and PART="A";
	keep study subject RFSTDTC;
Run;

*/using macro: fill missing values with the previous values;
Options symbolgen;
Options mprint;

%macro FillMissing (nonm, a);
	retain &a;
	if not missing(&nonm) then &a=&nonm;
	else &nonm=&a;
	drop &a;
%mend;

Data SDTM_SPCPKB1;
	set CDM.SPCPKB1;
	%FillMissing(IPFD1DAT, _IPFD1DAT);
	%FillMissing(IPFD1TIM, _IPFD1TIM);
	RFSTDTC=cats(IPFD1DAT, IPFD1TIM);
	where PSCHDAY=1 and PART="A";
	if not missing(RFSTDTC) then ARMCD="A01-A02-A03";
	else if missing(RFSTDTC) then ARMCD = "SCRNFAIL";
	else ARMCD = "NOTASSGN";
	ARM=ARM;
	ACTARMCD=ARMCD;
	ACTARM=ACTARM;
	keep study centre subject RFSTDTC ARMCD ARM ACTARMCD ACTARM;
Run;

*/#6 RFENDTC;
   */ many-to-many merge;
Proc sql;
	create table SDTM_RFENDTC as 
	select EX.study, EX.centre, EX.subject, coalesce(SDTM_SPCPKB1.RFSTDTC, EX.EXSTDAT, EX.EXENDAT) as RFENDTC 
	from CDM.EX, SDTM_SPCPKB1 
	where EX.study=SDTM_SPCPKB1.study and EX.subject=SDTM_SPCPKB1.subject;
Quit;

*/#7-8 
RFXSTDTC 
RFXENDTC 
;

Data SDTM_DM1;
	merge SDTM_SPCPKB1 SDTM_RFENDTC;
	by study centre subject;
    RFXSTDTC=RFSTDTC;
    RFXENDTC=RFENDTC;
Run;

 */#9-12 RFPENDTC DTHDTC DTHFL SITEID;

Data SDTM_DM2;
   merge CDM.DS CDM.DEATH;
   by study centre subject;
   RFPENDTC=DSSTDAT;
   DTHDTC = DTH_DAT;
   if not missing(DTHDTC) then DTHFL="Y";
   SITEID =centre;
   keep study centre subject RFPENDTC DTHDTC DTHFL SITEID;
Run;

*/ merge SDTM_DM1 and SDTM_DM2;

Data SDTM_DM3;
  merge SDTM_DM1 SDTM_DM2;
    STUDYID=study;
	SUBJID=SUBJECT;
	SITEID=CENTRE;
  by study centre subject;
Run;


Data SDTM_DM_final;
  merge SDTM_DM SDTM_DM3;
  by studyid siteid subjid;
Run;
