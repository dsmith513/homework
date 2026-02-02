/*  STAT 382 SAS HOMEWORK 1 */



/* Task 1: Data Frame Creation */
TITLE1 "Task 1";
TITLE2 "Q1 Part a) Import Datasets";
PROC IMPORT datafile="/home/u64394289/SAS_cars_domestic.csv"
	OUT=domestic
	DBMS=CSV 
	replace;
run;

PROC IMPORT datafile="/home/u64394289/SAS_cars_foreign.csv"
	OUT=foreign
	DBMS=CSV 
	replace;
run;

TITLE2 "Q1 Part b) Modify column formats";
DATA domestic; *change the name to whatever you named your DOMESTIC dataset;
  LENGTH Manufacturer_Type $30 Parent_Company_HQ $30 Car_Type $14;
  FORMAT Manufacturer_Type $30. Parent_Company_HQ $30. Car_Type $14.;
  SET domestic; *change the name to whatever you named your DOMESTIC dataset;
RUN;

DATA foreign; *change the name to whatever you named your FOREIGN dataset;
  LENGTH Manufacturer_Type $30 Parent_Company_HQ $30 Car_Type $14;
  FORMAT Manufacturer_Type $30. Parent_Company_HQ $30. Car_Type $14.;
  SET foreign;  *change the name to whatever you named your FOREIGN dataset;
RUN;



TITLE2 "Q1 Part c) Combine DOMESTIC and FOREIGN Datasets"; * list DOMESTIC first;
data all_cars;
	set domestic foreign;
run;


TITLE2 "Q1 Part d) Sort all_cars by ascending Drive_Wheels_Available";
proc sort data = all_cars;
	by Drive_Wheels_Available;
run;


TITLE2 "Q1 Part e) Create the dataset DriveWheels";
data DriveWheels;
	length Drive_Wheels_Available $12 Drive_Wheels_Max $10;
	input Drive_Wheels_Available $1-12 Drive_Wheels_Max $14-23;
datalines;
Rear         Rear
Rear, 4WD    Four
Rear, AWD    All
Rear, AWD, 4 All
AWD          All
Front        Front
Front, AWD   All
Front, AWD,  All
4WD          Four
;
run;

proc print data = DriveWheels;
run;

proc contents data = DriveWheels;
run;

TITLE2 "Q1 Part f) Sort DriveWheels by ascending Drive_Wheels_Available";
proc sort data = DriveWheels;
	by Drive_Wheels_Available;
run;



TITLE2 "Q1 Part g) Merge the all_cars dataset and the DriveWheels dataset to create all_cars2";
data all_cars2;
	merge all_cars DriveWheels;
	by Drive_Wheels_Available;
run;








/* Task 2: Cleaning and Formatting */
TITLE1 "Task 2";
TITLE2 "Q2) Replace missing values for Engine_liter with 0s in new dataset cars_fix";
data cars_fix;
	set all_cars2;
	if Engine_liter = . then Engine_liter = 0;
run;



TITLE2 "Q3) Remove rows for Car_Type and Overall_MPG that are missing. Do this in a new dataset called cars_clean";
data cars_clean;
	set cars_fix;
	if Car_Type = "" then delete;
	if Overall_MPG = . then delete;
run;






