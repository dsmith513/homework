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

# (a) H0: The residuals are normally distributed.
#     H1: The residuals are not normally distributed.

# (b) 
shapiro.test(nfl2016_model$residuals)
# Shapiro-Wilk normality test
# 
# data:  nfl2016_model$residuals
# W = 0.98015, p-value < 2.2e-16

# (c) p < 2.2e-16

# (d) Reject H0. p < 2.2e-16 < 0.03 = alpha

# (e) There is significant evidence to conclude that the residuals are not normally distributed.
#     The normality of residuals assumption is not met.


# 8. Check the Homogeneity of Variance Assumption by running the most appropriate of
# Bartlett’s Test or Levene’s Test using a significance level of 3%.
# Be sure to:
# (a) State your hypotheses using symbols.
# (b) Copy / paste your test results into your code.
# (c) Specifically state the p-value.
# (d) State your decision (Reject H0 or Do Not Reject H0).
# (e) State your conclusion.

# (a) H0: sigma_def^2 = sigma_off^2 = sigma_st^2
#     H1: At least one sigma^2 differs

# (b)
library(car)
leveneTest(Height ~ Side, data = nfl2016)
# Levene's Test for Homogeneity of Variance (center = median)
#         Df F value    Pr(>F)    
# group    2  36.815 < 2.2e-16 ***
#       2761                      
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# (c) p < 2.2e-16

# (d) Reject H0. p < 2.2e-16 < 0.03 = alpha

# (e) There is significant evidence to conclude that the player height variances are not equal.


# 9. Provide the ANOVA table for the overall model. Copy / paste your table into your code.

anova(nfl2016_model)
# Analysis of Variance Table
# 
# Response: Height
# Df  Sum Sq Mean Sq F value    Pr(>F)    
# Side         2   704.1  352.06  51.731 < 2.2e-16 ***
#   Residuals 2761 18790.4    6.81                      
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


# 10. From the ANOVA table generated in Question 9, does it appear that there is a difference
# between sides using α = 0.03?
#   Be sure to:
# (a) State the hypotheses using symbols. Use the treatment effects model.
# (b) State the value of the test statistic. Indicate whether you are using F or t.
# (c) State the p-value.
# (d) What decision (Reject H0 or Do Not Reject H0) do you make?
# (e) What conclusion can you make?

# (a) H0: μ_def = μ_off = μ_st
#     H1: At least one μ differs

# (b) F = 51.731

# (c) p < 2.2e-16

# (d) Reject H0. p < 2.2e-16 < 0.03 = alpha

# (e) There is significant evidence that the mean player heights are not equal.


# 11. Perform the Bonferroni Test for Multiple Pairwise Comparisons using α = 0.03.
#  Provide your code. Copy / paste your results into your code.
#  For each group, state whether the difference was significant or not.

pairwise.t.test(x = nfl2016$Height, g = nfl2016$Side, p.adj = "bonferroni")
# Pairwise comparisons using t tests with pooled SD 
# 
# data:  nfl2016$Height and nfl2016$Side 
# 
# DEF     OFF    
# OFF < 2e-16 -      
#   ST  0.98    3.6e-06
# 
# P value adjustment method: bonferroni

# For DEF and OFF, the average heights differ significantly.
# For DEF and ST, the average heights do not differ significantly.
# For OFF and ST, the average heights differ significantly.


# 12. Find the Tukey Simultaneous Confidence Intervals for all pairwise differences using α =
#   0.03.
#  Provide your code. Copy / paste your results into your code.
#  For each group, state whether the difference was significant or not.

TukeyHSD(aov(nfl2016_model), conf.level = 0.97)
# Tukey multiple comparisons of means
# 97% family-wise confidence level
# 
# Fit: aov(formula = nfl2016_model)
# 
# $Side
# diff        lwr        upr     p adj
# OFF-DEF  0.9849343  0.7274753  1.2423934 0.0000000
# ST-DEF  -0.2491754 -0.8935851  0.3952343 0.5883628
# ST-OFF  -1.2341097 -1.8777618 -0.5904577 0.0000035

# For DEF and OFF, the average heights differ significantly.
# For DEF and ST, the average heights do not differ significantly.
# For OFF and ST, the average heights differ significantly.