# 1. You have been given two .csv files containing car information about cars manufactured
# domestically, and those manufactured by a foreign company.

# (b) In RStudio, write code to identify your current working directory and report what it
# is.

getwd()
#[1] "C:/source/homework/stat382/homework-2"

# (c) Change your working directory to the directory where the file is located. If your file
# is in the current working directory, still write code to practice changing your working
# directory.

setwd("C:/source/homework/stat382/homework-2")

# (d) Write code to import cars_domestic.csv and cars_foreign.csv into RStudio,
# naming the data frames whatever you like. Both CSV files have a header.

domestic <- read.csv("cars_domestic.csv", header = TRUE)
foreign <- read.csv("cars_foreign.csv", header = TRUE)

# (e) Do each of the following to verify that the import seems successful.
# i. Look at the Environment window (top right hand corner). What information
# does this contain?

# domestic is a data frame with 57 rows and 16 variables
# foreign is a data frame with 165 rows and 16 variables

# ii. Print the first 10 rows of each data set. (Only code required.)

head(domestic, n = 10)
head(foreign, n = 10)
 
# iii. Use the str() function to view the structure of the data set. (Only code re-
#                                                                       quired.)

str(domestic)
str(foreign)

# (f) Determine how many rows and columns each data frame has. Include your code.
# Include your values as a comment.

str(domestic)
str(foreign)

# domestic has 57 rows and 16 columns
# foreign has 165 rows and 16 columns

# (g) Verify that both data frames have the same columns. Include your values as a com-
#   ment.

identical(colnames(domestic), colnames(foreign))
# TRUE

# (h) Combine the two data frames into one data frame called cars with the same columns
# as the original data frames.

cars <- rbind(domestic, foreign)

# 2. Manufacturer_Type and Car_Type should be factors.
#  State whether Manufacturer_Type and / or Car_Type should be ordered or not.
# Explain your decision.
#  Convert Manufacturer_Type and Car_Type to either a factor or an ordered factor
# within the data frame, based on your previous answer.

# Both Manufacturer_Type and Car_Type should not be ordered because the order that 
# a car's manufacturer or type appears is not relevant. For example, it does not matter the order that
# Sedan vs SUV appears or Foreign vs Domestic.

cars$Manufacturer_Type = factor(cars$Manufacturer_Type)
cars$Car_Type = factor(cars$Car_Type)

# 3. Use the summary() function to get an overview of each variable. Note which variables
# contain NAs.

summary(cars)
# Car_Type, Engine_liter, and Overall_MPG contain NAs

# 4. Engine_liter has NA values. These are the electric and hybrid cars. It is probably
# reasonable to assume these values are 0. Make of copy of cars called cars fix and in the
# new data frame, replace the NA values in the Engine_liter column with 0s.

cars_fix <- cars
cars_fix$Engine_liter[is.na(cars_fix$Engine_liter)] <- 0

# 5. Explain why the other NA values should probably not be set to 0. Make of copy of
# cars_fix called cars_clean that has the observations with NA values removed.

# The NA values in Car_Type should not be set to 0 because it doesn't make sense to have 0
# as a value for a car's type. Additionally, the NA values in Overall_MPG should not be set to 0
# because it doesn't make sense for a car's mpg to be 0.

cars_clean <- na.omit(cars_fix)

# 6. Create a new variable in the data frame called spread that is the difference between
# Length_in and Wheelbase_in. It should be a new column on the data frame, not a stand
# alone vector. Calculate it as Length − W heelbase.

cars_clean$spread <- cars_clean$Length_in - cars_clean$Wheelbase_in

# 7. Create a new (ordered) factor variable called Weight_category, which assigns a value
# of “Light” if Weight_lbs is less than 3500 pounds; “Moderate” if Weight_lbs is greater
# than or equal to 3500 pounds and less than 4500 pounds; “Heavy” if Weight_lbs is greater
# than or equal to 4500 pounds and less than 6000 pounds; and “Massive” if Weight_lbs is
# greater than or equal to 6000 pounds.

cars_clean$Weight_category <- cut(cars_clean$Weight_lbs, breaks = c(-Inf, 3500, 4500, 6000, Inf),
                                  labels = c("Light", "Moderate", "Heavy", "Massive"),
                                  right = FALSE, ordered_result = TRUE)

# 8. If we wanted to do some further investigations on “luxury cars”, or cars that cost a lot, we
# want to separate out these cars from the others. Create a data frame from cars_clean
# called luxury that contains Manufacturer_Type, Name, Engine_liter, Overall_MPG and
# Lowest_MSRP for cars that have a Lowest_MSRP of 60000 or greater.

luxury <- cars_clean[, c("Manufacturer_Type", "Name", "Engine_liter", "Overall_MPG", "Lowest_MSRP")]
luxury <- luxury[luxury$Lowest_MSRP >= 60000, ]

# 9. For cars_clean, compute the 25th percentile for Lowest_MSRP and HP (Horsepower). The
# R computation of Q1 is acceptable. Include your values as a comment.

quantile(cars_clean$Lowest_MSRP)
quantile(cars_clean$HP)

# The 25th percentile for Lowest_MSRP is 24975.
# The 25th percentile for HP is 183.50.

# 10. Create a data frame from cars_clean called small that contains all variables for cars
# whose Lowest_MSRP and HP both are less than the 25th percentiles.

small <- cars_clean
small <- small[small$Lowest_MSRP < 24975, ]
small <- small[small$HP < 183.50, ]

# 11. Sort small in descending order by Lowest_MSRP. Save this view as small_sorted.

small_sorted <- small[order(small$Lowest_MSRP, decreasing = TRUE), ]

# 12. Export small_sorted as a new file called small_sorted.csv to your computer.

write.csv(small_sorted, file = "small_sorted.csv", row.names = FALSE)

# 13. Use sapply() to compute the standard deviation for each numerical variable in cars_clean
# (columns 4 though 14) in one command. Include the values you obtained as a comment.

sapply(cars_clean[, 4:14], sd)
# Seating      Engine_liter                HP         Length_in 
# 1.235066          1.109133         80.134626         13.801247 
# Width_in         Height_in      Wheelbase_in        Weight_lbs 
# 3.773151          6.282058          7.352846        832.159186 
# Cargo_Volume_cuft       Overall_MPG       Lowest_MSRP 
# 13.793236         18.287782      17809.039027 

# 14. Use tapply() or aggregate() to compute the mean Overall_MPG by Car_Type. Include
# the values you obtained as a comment.

tapply(cars_clean$Overall_MPG, cars_clean$Car_Type, mean)

# Convertible       Coupe   Hatchback     Minivan       Sedan         SUV 
# 30.00000    24.63636    47.00000    21.75000    29.88971    23.75728 
# Wagon 
# 43.42857 
