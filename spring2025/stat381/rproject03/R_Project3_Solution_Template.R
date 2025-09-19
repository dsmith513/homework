##### R Project 3: Binomial Distribution
##### Name: Dylan Smith
##### Version Number: 1



### Part 1
## (C1): Store the size of your distribution

num_of_trials <- 17


## (C2) Store your probability of successes

prob_of_success <- 0.23


## (C3) Create a vector from 0 through the number of Bernoulli Trials of your distribution.

num_of_successes <- c(0:17)


## (C4) Find Binomial Probabilities.

prob_at_a_point <- dbinom(num_of_successes, num_of_trials, prob_of_success)


## (C5) Create a barplot.

barplot(height = prob_at_a_point, xlab = "Number", ylab = "PMF P(X = x)", ylim = c(0, 0.28), names.arg = num_of_successes)


### Part 1 Questions
## (Q6) Describe the barplot.
	# X-value for the highest bar: 4
	# Is the highest bar in the center or somewhat off to the side of the graph?
  # The highest bar is toward the left side of the graph.    

	# Do all of the bars go to the same height, or are they all different?
  # Each of the bars has a different height.

	# Code for calculating P(X <= 5)
  # pbinom(5, num_of_trials, prob_of_success, lower.tail = TRUE)

	# Answer from above code: 0.8230213

	# If you had to shade your barplot from Part 1 corresponding to the calculation you just made, what part(s) of the barplot would be shaded? (You don't actually have to shade your graph, just describe it in words.)
  # The portions of the barplot corresponding to this calculation are bars 0, 1, 2, 3, 4, and 5.





## (Q7) Expected Value of Distribution?
	# Code: sum(num_if_successes * prob_at_a_point)


	# Result from Code: 3.91



## (Q8) Standard Deviation of Distribution?
	# Code: sd(prob_at_a_point)


	# Result from Code: 0.07928726






### Part 2
## (C9) Random Sampling

set.seed(66)
values_from_sample <- rbinom(115, num_of_trials, prob_of_success)

### Part 2 Questions
## (Q10) Mean of random sample?
	# Code: mean(values_from_sample)


	# Result from Code: 3.843478



## (Q11) Standard Deviation of random sample?
	# Code: sd(values_from_sample)


	# Result from Code: 1.699284





### Additional Questions
## (Q12) 
## Compare the expected value from Q7 and the sample mean from Q10.  Are they close in value?
	# Answer: Yes

## Compare the standard deviations from Q8 and Q11.  Are they close in value?
	# Answer: No

## Why do you think the values aren't exactly the same?
	# Answer: They are not exactly the same because we are only randomly selecting 115 different values and if the sample size increased the expected value and standard deviation would get closer together.







## (Q13) Share an example of a real life scenario that uses the Binomial Distribution.
	# Example: Flipping a coin 10 times


	# Explain how your example meets the criteria for a Binomial Distribution
	# Criteria 1: n Bernoulli Trials
	# Criteria 2: each trial is independent
	# Criteria 3: the probability of success is constant
  # There are exactly 10 coin flips.
  # Each coin flip's result is not dependent on any other coin flip's result.
  # The probability of heads or tails on a fair coin is always 0.5.


