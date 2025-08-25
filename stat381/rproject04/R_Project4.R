##### R Project 4: Normal Distribution
##### Name: Dylan Smith
##### Version Number: 1


#############################
###### PART 1 ###############
###### GRAPH  ###############
#############################

## DENSITY FUNCTION
	## C1: Create x-values - code
  part1_x <- seq(from = -3.25, to = 3.25, by = 0.0025)


	## C2: Create y-values - code
  part1_y <- dnorm(part1_x, mean = 0, sd = 1)


	## C3: Create Plot - code
	## Remember to save your plot and also submit it to Gradescope.
  plot(x = part1_x, y = part1_y, type = "l", lty = 1, col = "aquamarine2", main = "PDF: Standard Normal Distribution", xlab = "Variable", ylab = "Density")




#############################
###### PART 1 ###############
###### QUESTIONS  ###########
#############################

## Question 4: Largest approximate y value
	# Answer: The largest y value is approximately 0.4.
  # The exact value given by max(part1_y) is 0.3989423.





## Question 5: Why stop at the x-values from C1 instead of something like -1 and +1?
	# Answer: We want to stop at larger numbers like -3.25 and +3.25 because a large percentage
  # of the distribution falls outside the bounds of -1 and +1.





## Question 6: When calculating a probability, how would this be represented on the graph?
	# Answer: The probability that a random variable X lies in a certain range between
  # a and b on the graph is equal the the integral from a to b of the function. The area
  # under the curve shown by the graph is the probability.





## Question 7: Standard Normal Questions
	## a) What is the mean and variance of the standard normal distribution?
			## Mean = 0
			## Variance = 1
	

	## b) What random variable abbreviation do we usually use to represent the standard normal distribution?
			## Answer: Z

	
	## c) Based on graph in Part 1, what do the values on the horizontal axis represent?
			## Answer: They represent the Z-score.






#############################
###### PART 2 ###############
###### GRAPH  ###############
#############################

## CUMULATIVE DISTRIBUTION FUNCTION
## X ~ N(mean = 290; variance = 576) (see PDF for mean and variance values)


	## C8: Create x-values - code
  part2_x <- seq(from = 200, to = 380, by = 4)


	## C9: Create y-values - code
  part2_y <- pnorm(part2_x, mean = 290, sd = 24, lower.tail = TRUE)


	## C10: Create Plot - code
  plot(x = part2_x, y = part2_y, type = "l", lty = 1, col = "goldenrod1", main = "CDF: Normal Distribution", xlab = "x-values", ylab = "Cumulative Probability P(X <= x)")


	## C11: Cumulative Probabilities - code
  cumulative_prob <- c(0.05, 0.14, 0.50, 0.86, 0.95)


	## C12: Find x-values associated with cumulative probabilities - code
  quantiles <- qnorm(cumulative_prob, mean = 290, sd = 24, lower.tail = TRUE)


	## C13: Overlay points on plot - code
  points(x = quantiles, y = cumulative_prob, pch = 24, bg = "rosybrown3", )


	## C14: Add text at each point - code
	## Remember to save your plot and also submit it to Gradescope.  <- this is the only plot from Part 2 you need to submit.
  text(x = quantiles, y = cumulative_prob, labels = paste("(", round(quantiles,2), ", ", cumulative_prob,")", sep = ""), pos = 4)





#############################
###### PART 2 ###############
###### QUESTIONS  ###########
#############################

## Question 15: What do the y-values approach as x goes to +/- infinity?
	# As x goes towards -infinity: 0


	# As x goes towards +infinity: 1





## Question 16: Pick one of the points on your graph from Part 2.  Write a probability statement involving the $x$- and $y$- coordinate values that describes how they relate to each other. Do not use the value corresponding to y = 0.5.

	# Point you will use: (250.52, 0.05)


	# Probability Statement: When generating a CDF for the normal distribution with mean = 290 and variance = 576,
  # there is a 5% chance that an x-value chosen at random will be less than or equal to 250.52.





## Question 17: Create and solve your own probability problem.
## Start with the Normal Distribution you were provided with in Part 2.
## Must be of the form where you solve for a particular value, given the probability.
## Do not use any of the points from Q16.
## Do not use the mean value (meaning the point corresponding to the mean; still use the mu provided when doing your calculation).
## Include your code and your final answer.
## Do NOT use a table or your calculator.

	# Question: What is the value of k such that P(X <= k) = 0.25?


	# Code: qnorm(0.25, mean = 290, sd = 24, lower.tail = TRUE)


	# Answer: 273.8122



