*******************************************************
* This SAS code is an example from the text			  *
* SAS ESSENTIALS 2nd Ed, Wiley                        *
* (C) 2016 Elliott, Alan C. and Woodward, Wayne A.    *
*******************************************************;

* This example illustrates PROC MEANS (basic, HT, CI - Task);

DATA CHILDREN;
INPUT WEIGHT HEIGHT AGE;
DATALINES;
64 57 8
71 59 10
53 49 6
67 62 11
55 51 8
58 50 8
77 55 10
57 48 9
56 42 10
51 42 6
76 61 12
68 57 9
;


PROC MEANS DATA = CHILDREN;
TITLE 'PROC MEANS, simplest use';
RUN;

PROC MEANS DATA = CHILDREN MAXDEC=2; *only 2 decimals;
VAR WEIGHT HEIGHT; *omit age;
TITLE 'PROC MEANS, limit decimals, specify variables';
RUN;

PROC MEANS DATA = CHILDREN MAXDEC=2 N MEAN STDERR MEDIAN;
VAR WEIGHT HEIGHT;
TITLE 'PROC MEANS, specify statistics to report';
RUN;

/* In-class exercise */

/* 1) Add 95% confidence intervals for weight and height and find the standard error  */
PROC MEANS DATA = CHILDREN MAXDEC=2 N MEAN STDERR MEDIAN CLM; *CLM = confidence interval;
VAR WEIGHT HEIGHT;
TITLE 'PROC MEANS, specify statistics to report +95% CI';
RUN;





/* 2) HOMEWORK: Add 92% confidence intervals for weight and height and find the standard error. */









/* Part of original code provided to you */

PROC MEANS DATA = CHILDREN MAXDEC = 2 N MIN Q1 MEDIAN Q3 MAX QRANGE QNTLDEF=5; *qrange = IQR;
VAR WEIGHT HEIGHT;
TITLE 'PROC MEANS, 5 number summary, IQR';
RUN;
/* Matches TI-calculator for both even and odd sample sizes */


PROC MEANS DATA = CHILDREN MAXDEC = 2 SKEW KURTOSIS;
VAR WEIGHT HEIGHT;
TITLE 'PROC MEANS, Skewness and Kurtosis';
RUN;
/* To generate these same values in R, use the e1071 library.
	skewness(weight, type = 2)
	kurtosis(weight, type = 2)
*/

PROC MEANS DATA = CHILDREN MAXDEC = 2 N MEAN STD T PROBT CLM; *t = test stat, probt =pvalue;
VAR WEIGHT;
TITLE 'PROC MEANS Hypothesis Test';
TITLE2 'H0: mu_weight = 0; H1: mu_weight != 0';
RUN;
*t = test statistic value, probt = p-value;

TITLE; TITLE2;
