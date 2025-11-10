# Homework 10
# 1-Way ANOVA Models

# 1. Import the Data. Convert Side to a factor.

nfl2016 <- read.csv("NFL2016_1WayANOVA_v2.csv", header = TRUE)
nfl2016$Side <- as.factor(nfl2016$Side)


# 2. Before running the model, we can try to visually determine if there might be a difference
# in the means. One good way to do this is to create a mean barplot of the average Height
# by Side. Provide your code. Write a short summary answering if there appear to be any
# differences by Side. Provide your plot in your submission.

mean_heights <- tapply(nfl2016$Height, nfl2016$Side, mean)

barplot(mean_heights, main = "Mean Player Height By Side",
        xlab = "Playing Side", ylab = "Average Height (inches)")

# Based on the barplot, there does not appear to be any significant difference in mean height by Side.


# 3. Create and SAVE a linear model for Height with the Side as the predictor.

nfl2016_model <- lm(Height ~ Side, data = nfl2016)


# 4. Create a table to determine how many observations you have per Side. Copy / paste your
# table into your code.

table(nfl2016$Side)
# DEF  OFF   ST 
# 1305 1344  115 


# 5. How many groups do you have? Do you have “large” sample sizes (> 30) for each group?

# There are three groups: Defense, Offense, and Special Teams. Each group has a "large" sample size greater than 30.


# 6. When performing the Normality of Residuals Assumption check, should you perform this
# check by group or only for the overall model?

# You should perform this check by the overall model residuals, not by group.


# 7. Based on your answer to Question 6, determine if the Normality of Residuals Assumption
# is met or not by using the Shapiro-Wilk Test (either by group or for the overall model
# based on your Question 6 answer) using a 3% significance level.
# Be sure to:
# (a) State your hypotheses.
# (b) Copy / paste your test results into your code.
# (c) Specifically state the p-value.
# (d) State your decision(s) (Reject H0 or Do Not Reject H0).
# (e) State your conclusion(s).