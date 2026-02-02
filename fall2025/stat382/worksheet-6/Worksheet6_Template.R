## Worksheet 6
## Name: 





########################################
## Task 1: Simple Linear Regression  ###
########################################

# Import Data
penguindives <- read.csv("penguindives.csv")



# Question 1 - Compute Person's correlation coefficient, r.
		# Code:
cor(penguindives$Heart_Rate, penguindives$Duration, method = "pearson")


		# Value:
    # -0.8441596

		
		

# Question 2 - Based on your value for r, describe the linear association between the two variables.
		
	# Strength: Strong 
	# Direction: Negative
	# Type: Linear
		
		
		
		
		
# Question 3 - Create the linear regression model for Duration with Heart_Rate as the predictor.  Make sure to save your model as something.
linearmodel <- lm(Duration ~ Heart_Rate, data = penguindives)		
plot(x = penguindives$Heart_Rate, y = penguindives$Duration,
     xlab = "Heart Rate", ylab = "Duration")
abline(linearmodel)


		
		
		
# Question 4a - Test Linearity
# Make sure to export any graphs and submit them to Gradescope

	# Code
plot(x = penguindives$Heart_Rate, y = linearmodel$residuals,
     xlab = "Heart Rate", ylab = "Residuals")
abline(h = 0, lty = 2)


	# Is the linearity condition met?
		
# The linear condition is met. There is no clear pattern present.

		
		
		
		
# Question 4b - Test Normality
	# Hypotheses
  # H0: The residuals are normally distributed.
  # H1: The residuals are not normally distributed.

	# Code
shapiro.test(linearmodel$residuals)


	# Copy / paste results from the code
# Shapiro-Wilk normality test
# 
# data:  linearmodel$residuals
# W = 0.97681, p-value = 0.67



	# P-Value:
# p-value = 0.67


	# Decision using alpha = 0.03:
# Do not reject H0.


	# Conclusion: Is the normality assumption met?
# There is enough evidence to conclude that the normality assumption is met.		
		
		

		
		
# Question 4c - Test Equal Variance
# Make sure to export any graphs and submit them to Gradescope

	# Code
plot(x = linearmodel$fitted.values, y = linearmodel$residuals,
     xlab = "Predicted values: (yhat)", ylab = "Residuals")
abline(h = 0, lty = 2)


	# Is the equal variance assumption met?
  # The equal variance assumption is met. There is no clear pattern present.

	
	
	
	
	
# Question 5 - Test whether Heart_Rate is important in explaining variation in Duration at a 3% significance level.
	
	# a) State hypotheses with symbols (or words for symbols)
		# H0: Beta = 0
		# H1: Beta != 0
	

	
	# b) Conduct the Test and report the results as a comment.
		# Code
library(lmtest)
dwtest(linearmodel, alternative = "two.sided")


		# Copy and paste results here
# Durbin-Watson test
# 
# data:  linearmodel
# DW = 1.7073, p-value = 0.3756
# alternative hypothesis: true autocorrelation is not 0



	# c) Test Statistic Value = 1.7073

		# P-Value = 0.3756



	# d) State your decision.
  # Do not reject H0.
			
			
	# e) State your conclusion.
  # There is enough evidence to conclude that Heart Rate is not important in explaining Duration.
			
			

			
# Question 6 - Give the value for the coefficient of determination and explain what it tells you about the model.

		# Value = 0.7126

		# Interpretation: 71% of variability in Duration is explained by Heart Rate.
			
			
			
			
			
			
			
			
			
			


