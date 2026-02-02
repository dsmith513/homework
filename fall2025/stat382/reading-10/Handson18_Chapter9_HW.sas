*******************************************************
* This SAS code is an example from the text			  *
* SAS ESSENTIALS 2nd Ed, Wiley                        *
* (C) 2016 Elliott, Alan C. and Woodward, Wayne A.    *
*******************************************************;

* This example illustrates PROC MEANS BY and CLASS;

DATA FERTILIZER;
INPUT FEEDTYPE WEIGHTGAIN;
DATALINES;
1 46.20
1 55.60
1 53.30
1 44.80
1 55.40
1 56.00
1 48.90
2 51.30
2 52.40
2 54.60
2 52.20
2 64.30
2 55.00
;

* SORT DATASET;
PROC SORT DATA=FERTILIZER OUT = FERTILIZER2;
BY FEEDTYPE;
RUN;



* ANALYSIS;

PROC MEANS DATA = FERTILIZER2;
VAR WEIGHTGAIN;
BY FEEDTYPE;
TITLE 'Summary statistics by group USING BY';
RUN;

PROC MEANS DATA = FERTILIZER;
VAR WEIGHTGAIN;
CLASS FEEDTYPE;
TITLE 'Summary statistics by group USING CLASS';
RUN;
*Note: If there are missing values, the N column will be less than the N Obs column;


/* What is the difference between BY and CLASS in the above lines of code? */














/* Only generate N, MEAN, MEDIAN, MIN, MAX.
	Output results to "results"
	Save mean as mymean */
PROC MEANS DATA = FERTILIZER N MEAN MEDIAN MIN MAX MAXDEC=2;
VAR WEIGHTGAIN;
CLASS FEEDTYPE;
OUTPUT OUT = RESULTS MEAN = mymean;
TITLE 'Specific Summary statistics by group USING CLASS and Output Results';
RUN;

PROC PRINT DATA = RESULTS;
RUN;


/* Describe how the results look in your results dataset. */








proc means data = fertilizer;
var weightgain; *summary statistics for the entire dataset;
run;
TITLE;


