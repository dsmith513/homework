# Homework 8

# 1. Import the dataset. Are there any missing values? Note: Do NOT convert any variables
# to factors. Include your code in your answer.

running_data <- read.csv("running_speed.csv", header = TRUE)
sum(is.na(running_data))
# 0
# There are no missing values in running_speed.


# 2. Run and save the multiple linear regression model without interactions. Use Age and
# Gender to predict Running_Speed.

running_model <- lm(Running_Speed ~ Age + Gender, data = running_data)


# 3. (Assumptions) Check the linearity assumption by investigating plots of the residuals versus
# each of the x-variables. Do you think it is met or not? Explain why or why not for each
# variable. In your submission, make sure to include your graphs.

plot(running_data$Age, running_model$residuals, xlab = "Age", ylab = "Residuals", main = "Residuals versus Age")
abline(h = 0, lty = 2)

plot(running_data$Gender, running_model$residuals, xlab = "Gender", ylab = "Residuals", main = "Residuals versus Gender")
abline(h = 0, lty = 2)

# The linearity assumption is met for both x-variables. For Age, there is no clear pattern present in the plot, 
# which means that the linearity assumption is met. For Gender, both genders appear evenly distributed around 0,
# which means that the linearity assumption is met.


# 4. (Assumptions) Explain why we don’t need to check the independence assumption.

# We don't need to check the independence assumption because each person's running speed is only measured once.
# Each observation in the running_data dataset represents an individual person. We can reasonably assume that each person's running speed is independent.


# 5. (Assumptions) Check the normality assumption. Do you think it is met or not? Explain
# why or why not for each of the items below.
# Items you should investigate:
#    A Q-Q Plot of residuals, complete with Q-Q Line. In your submission, make sure to
# include this graph.
#  The Shapiro-Wilk test on the residuals using α = 0.043. Be sure to include your
# hypotheses, copy / paste your test results into your code, specifically indicate what
# the p-value for this test is, state your decision, and state your conclusion.

qqnorm(running_model$residuals, main = "Q-Q Plot of Residuals")
qqline(running_model$residuals, lty = 2)

shapiro.test(running_model$residuals)

# Shapiro-Wilk normality test
# 
# data:  running_model$residuals
# W = 0.98012, p-value = 0.6941

# H0: The residuals are normally distributed.
# H1: The residuals are not normally distributed.

# Decision: Do not reject H0. Because the p-value = 0.6941 > 0.043 = alpha, we do not reject the null hypothesis.
# Conclusion: There is not enough evidence to conclude that the residuals are not normally distributed. Therefore, the normality assumption is met.


# 6. (Assumptions) Check the equal variance assumption by investigating a plot of the residuals
# versus the fitted values. Do you think it is met or not? Explain why or why not. In your
# submission, make sure to include your graph.

plot(running_model$fitted.values, running_model$residuals, xlab = "Fitted Values", ylab = "Residuals", main = "Residuals versus Fitted Values")
abline(h = 0, lty = 2)

# The residuals appear to be scattered randomly around the value zero. This means that the equal variance assumption is met.


# 7. Use the summary() function to investigate the model results, even if the model assumptions
# are not met. Copy and paste your test results into your code.

summary(running_model)

# Call:
#   lm(formula = Running_Speed ~ Age + Gender, data = running_data)
# 
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -6.2808 -2.1043  0.4156  1.8561  5.6427 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) 11.00018    2.81292   3.911 0.000379 ***
#   Age         -0.07823    0.11587  -0.675 0.503784    
# Gender       2.92347    0.89786   3.256 0.002420 ** 
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 2.837 on 37 degrees of freedom
# Multiple R-squared:  0.2276,	Adjusted R-squared:  0.1859 
# F-statistic: 5.452 on 2 and 37 DF,  p-value: 0.008412


# 8. (Overall Model Test) Do the x-variables explain some of the variability in running speed?
#   Test at a 4.3% significance level.
# (a) State your hypotheses using symbols.
# (b) State the value of the test statistic. Indicate whether you are using F or t.
# (c) State your p-value.
# (d) State your decision (Reject H0 or Do Not Reject H0).
# (e) Write your conclusion.

# (a) H0: Beta_Age = Beta_Gender = 0
#     H1: At least one of Beta_Age and Beta_Gender != 0

# (b) The F-statistic = 5.452 on 2 and 37 DF.

# (c) p-value = 0.008412

# (d) Decision: Reject H0. Because the p-value = 0.008412 < 0.043 = alpha, we reject the null hypothesis.

# (e) Conclusion: There is significant evidence to conclude that at least one of Age and Gender significantly explain some of the variability in running speed.


# 9. (Partial t-Tests) If the x-variables explain some of the variability in running speed, which
# one(s) are significant? Perform a test for each variable separately. Test at at 4.3% signifi-
#   cance level. For each test you perform,
# (a) State the hypotheses to be tested.
# (b) State the value of the test statistic. Indicate whether you are using F or t.
# (c) State the p-value.
# (d) State your decision (Reject H0 or Do Not Reject H0).
# (e) Write your conclusion.
# Even if you had previously decided that the x-variables do NOT explain some of the
# variability in running speed in Question 8, we still want you to answer Question 9 for
# practice.

# Test 1: Age

# (a) H0: Beta_Age = 0
#     H1: Beta_Age != 0

# (b) The t-statistic = -0.675

# (c) p-value = 0.503784

# (d) Decision: Do not reject H0. Because the p-value = 0.503784 > 0.043 = alpha, we do not reject the null hypothesis.

# (e) Conclusion: There is not enough evidence to conclude that Age significantly explains some of the variability in running speed.

# Test 2: Gender

# (a) H0: Beta_Gender = 0
#     H1: Beta_Gender != 0

# (b) The t-statistic = 3.256

# (c) p-value = 0.002420

# (d) Decision: Reject H0. Because the p-value = 0.002420 > 0.043 - alpha, we reject the null hypothesis.

# (e) Conclusion: There is enough evidence to conclude that Gender does significantly explain some of the variability in running speed.


# 10. Give the value of the coefficient of determination. Explain what it tells you about the
# model.

# R^2 = 0.2276
# This means that approximately 22.76% of the variation in running speed is explained by Age and Gender.