## Worksheet 5 Template
## Name: 


		
###########################################
###########################################
### TASK 1 ################################
###########################################
###########################################
		
		
		
## Task 1 Setup:
		# H0: p = 0.15
		# H1: p < 0.15
		
		
## Question 1 - Vector population_proportions containing values from 0.11 to 0.15 by 0.001.
population_proportions <- seq(0.11, 0.15, 0.001)

		
		
## Question 2 - Critical Value Computations
## Remember to copy and paste your results as a comment
	# Code for CV05
  CV05 <- qnorm(0.05, mean = 0.15, sd = sqrt((0.15 * (1 - 0.15)) / 2500), lower.tail = TRUE)
  # 0.1382534


	# Code for CV01
  CV01 <- qnorm(0.01, mean = 0.15, sd = sqrt((0.15 * (1 - 0.15)) / 2500), lower.tail = TRUE)	
	# 0.1333866	
		
		
		
## Question 3 - Find V(phat) and store values		
  var_phat <- (population_proportions * (1 - population_proportions)) / 2500


		
		
		
		
## Question 4a - for significance level of 0.05, create a vector beta05
  beta05 <- pnorm(CV05, mean = population_proportions, sd = sqrt(var_phat), lower.tail = FALSE)
		
		
		
		
		
## Question 4b - for significance level of 0.01, create a vector beta01
  beta01 <- pnorm(CV01, mean = population_proportions, sd = sqrt(var_phat), lower.tail = FALSE)
		

		
		
		

## Question 5 - Plot OCC significance level 0.05
## You do not need to submit this graph.
  plot(population_proportions, beta05, type = "l", col = "firebrick", 
       ylim = c(0, 1), ylab = "Beta Values")

		
		
		
## Question 6 - Plot OCC significance level 0.01
## Place line on same plot as in Question 5.
## Make sure to export this graph and submit to Gradescope.
	par(new = TRUE)	
	plot(population_proportions, beta01, type = "l", col = "slateblue3",
	     ylim = c(0, 1), ylab = "Beta Values")	
	abline(v = 0.15, lty = "dashed")	


		
## Question 7 - Estimate the power of the test for each significance level if the true population proportion is 0.14.
## Remember to copy and paste your results as a comment
	p_true <- 0.14
	sd_true <- sqrt((p_true * (1 - p_true)) / 2500)
	beta05_at_014 <- pnorm(CV05, mean = p_true, sd = sd_true, lower.tail = FALSE)
	beta01_at_014 <- pnorm(CV01, mean = p_true, sd = sd_true, lower.tail = FALSE)
	
	power05_at_014 <- 1 - beta05_at_014
	power01_at_014 <- 1 - beta01_at_014
	
	power05_at_014
	# 0.4006436
	power01_at_014
  # 0.1702996
		
## Question 8 - Describe the differences between the two graphs and what this means for the power of the test.
  # The red line corresponding to the alpha = 0.05 is lower than the blue line corresponding to alpha = 0.01.
	# This means that the test with significance level 0.01 is stricter with more false negatives and fewer false positives than significance level 0.05.
	# The test with significance level 0.05 has a greater power than the test with significance level 0.01.	

	