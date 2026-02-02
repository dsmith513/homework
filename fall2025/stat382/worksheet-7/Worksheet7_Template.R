## Worksheet 7 Template



########################################
## 2-Way ANOVA                ##########
########################################

## Question 1: Import Data
seatbelts <- read.csv("Seat_Belts.csv")


## Question 1: Convert Belt_Type and Temperature to Factors
seatbelts$Belt_Type <- factor(seatbelts$Belt_Type)
seatbelts$Temperature <- factor(seatbelts$Temperature)


## Question 2: Run Model Including Interactions and SAVE it
seatbelt_model <- lm(Total_Crash_Deaths ~ Belt_Type * Temperature, data = seatbelts)



## Question 3: Check Normality of Residuals Assumption using QQ Plot
## Make sure to submit your plot
	# Code:
qqnorm(seatbelt_model$residuals, main = "Normal Q-Q")
qqline(seatbelt_model$residuals)
	# Is the Normality Assumption met or not?
  # No
	# Why or why not?
  # The theoretical quantiles < -1 and > 1 deviate to much from the Q-Q line for the Normality Assumption to be met.


## Question 4: Check Equal Variance of Residuals Assumption
## Make sure to submit your plot
	# Code:
plot(x = seatbelt_model$fitted.values, y = seatbelt_model$residuals,
     xlab = "Fitted Values", ylab = "Residuals", main = "Residuals versus Fitted Values")
abline(h = 0)
	# Is the Equal Variance Assumption met or not?
  # Yes.
	# Why or why not?
  # The Equal Variance Assumption is met. The residuals appear randomly distributed around zero.


## Question 5: Provide the ANOVA table.
	# Code:
anova(seatbelt_model)

	# Copy / Paste Table:
# Analysis of Variance Table
# 
# Response: Total_Crash_Deaths
# Df Sum Sq Mean Sq F value Pr(>F)    
# Belt_Type               3  29931  9977.1 69.2553 <2e-16 ***
#   Temperature             2    291   145.7  1.0112 0.3647    
# Belt_Type:Temperature   6   1328   221.4  1.5369 0.1646    
# Residuals             408  58778   144.1                   
# ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1


## Question 6: Interactions Check
	# H0: (αβ)ij = 0, ∀(i, j)
	# H1: At least one (αβ)ij̸ = 0

	# Test Statistic: 1.5369
	# P-Value: 0.1646
	# Decision at alpha = 0.028: Do not reject H0. p = 0.1646 > 0.028 = alpha
	# Conclusion: There is enough evidence that the interaction effect is not present. 
  # It seems plausible that there are no interactions.



## Question 7: Are required to test for main effects or not, and why?
# We are required to test for main effects because we found that evidence of interaction between Belt_Type and Temperature was not present.


## Question 8: Main Effects: Belt Type
	# H0: αi = 0, ∀i
	# H1: at least one αi̸ = 0
	
	# Test Statistic: 69.2553
	# P-Value: < 2e-16
	# Decision at alpha = 0.028: Reject H0. p < 2e-16 < 0.028 = alpha
	# Conclusion: There is enough evidence to conclude that there is a difference among Belt_Type.



## Question 9: Main Effects: Temperature
	# H0: βj = 0, ∀j
	# H1: at least one βj̸ = 0
	
	# Test Statistic: 1.0112
	# P-Value: 0.3647
	# Decision at alpha = 0.028: Do not reject H0. p = 0.3647 > 0.028 = alpha
	# Conclusion: There is not enough evidence that there is a difference among temperature.



## Question 10: Tukey SCI at alpha = 0.028
	# Code:
TukeyHSD(aov(Total_Crash_Deaths ~ Belt_Type * Temperature, data = seatbelts), conf.level = 1 - 0.028)

	# Copy / Paste the set of results that you need to look at,
	# based on your previous analysis
	# no points if you copy / paste the whole thing.

# $Belt_Type
# diff       lwr       upr     p adj
# Not Rekt-M8-Mum-Rah Everliving  10.333333  5.773369 14.893298 0.0000000
# Safety Dance-Mum-Rah Everliving 21.153846 16.550245 25.757448 0.0000000
# U-No-Die-Mum-Rah Everliving     19.400000 14.749731 24.050269 0.0000000
# Safety Dance-Not Rekt-M8        10.820513  6.216911 15.424114 0.0000000
# U-No-Die-Not Rekt-M8             9.066667  4.416397 13.716936 0.0000005
# U-No-Die-Safety Dance           -1.753846 -6.446913  2.939221 0.7240430





## Question 11: Bonferroni
	# Code:
pairwise.t.test(x = seatbelts$Total_Crash_Deaths, g = seatbelts$Belt_Type, 
                p.adjust.method = "bonferroni")

	# Copy / Paste Results:

# Pairwise comparisons using t tests with pooled SD 
# 
# data:  seatbelts$Total_Crash_Deaths and seatbelts$Belt_Type 
# 
# Mum-Rah Everliving Not Rekt-M8 Safety Dance
# Not Rekt-M8  4.5e-09            -           -           
#   Safety Dance < 2e-16            1.1e-09     -           
#   U-No-Die     < 2e-16            6.0e-07     1           
# 
# P value adjustment method: bonferroni 
