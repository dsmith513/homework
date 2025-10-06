## Worksheet 3 Template
## Name: 


## Question 1 - Classes
## Make sure to also copy and paste results from your code

	# a) Rank top 4 choices
  factorial(12) / factorial(12 - 4)
  # 11880


	# b) Choose 5 classes from 12
  choose(12, 5)
	# 792	
		
		
		
## Question 2 - Tires (Binomial Distribution)
## Make sure to also copy and paste results from your code
		
	# probability that 11 or more have blowouts
  pbinom(10, 20, 0.3, lower.tail = FALSE)
  # 0.01714482

		
		
## Question 3 - Pencils (Poisson / Exponential)
## Make sure to also copy and paste results from your code

	# P(A < 0.10) - exponential distribution
  ppois(0.10, 2.4, lower.tail = TRUE)
  # 0.09071795
		
		
		
## Question 4 - Broken Screen (Negative Binomial)
  dnbinom(4, 3, 0.18)  
  # 0.03955161



## Question 5 - Find k. P(X > k) = 0.041
## Make sure to also copy and paste results from your code

	# a) X~Standard Normal Distribution
  qnorm(0.041, lower.tail = FALSE)
  # 1.739198
		
	# b) X~t(df = 15)
  qt(0.041, df = 15, lower.tail = FALSE)
	# 1.864092	
		
		
		
## Question 6 - Random Samples identification
	# Import and Explore Dataset (not graded)
  samples <- read.csv("samples.csv")

	
	# a) Histograms (make sure to export the graphs and submit them to Gradescope)
  hist(samples$sample1, right = FALSE)
	hist(samples$sample2, right = FALSE)
	
	# b) Shapiro-Wilk Test of each column  (remember to copy and paste results)
  shapiro.test(samples$sample1)
  # data:  samples$sample1
  # W = 0.95105, p-value = 0.0002583
	
  shapiro.test(samples$sample2)
  # data:  samples$sample2
  # W = 0.99484, p-value = 0.9419
  
	# c) Based on parts a-b, determine whether sample1 came from a normal
	# distribution or not.
  # H0: sample1 is normal
  # H1: sample1 is not normal
  
		# Sample 1 analysis:
			# a) The test statistic is 0.95105, which is far from 1 suggesting the sample may not be normally distributed.
			# b) The p-value is 0.0002583 which is smaller than the significance level of 0.027 suggesting that the sample is not normally distributed.
			# Overall Conclusion) Reject the null hypothesis. There is enough evidence to conclude sample1 is not normally distributed.
	

  # d) Based on parts a-b, determine whether sample2 came from a normal
  # distribution or not.
  # H0: sample2 is normal
  # H1: sample2 is not normal

  # Sample 2 analysis:
    # a) The test statistic is 0.99484 which is close to 1 suggestic the sample is normally dsitributed.
    # b) The p-value is 0.9419 which is very large and larger than the significance level suggesting that the sample is normally distributed.
    # Overall Conclusion) Do not reject the null hypothesis. Normality of sample2 seems plausible.


