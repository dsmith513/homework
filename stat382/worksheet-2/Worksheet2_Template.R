## Worksheet 2
## Name: Dylan Smith



## Question 1 - Download file to your computer. No code required.





## Question 2 - Import Dataset

MLB <- read.csv("MLB2019.csv", header = TRUE)



## Question 3 - Factor Conversion

MLB$Field_Position <- factor(MLB$Field_Position)



## Question 4 - Find standard deviation of RBI by Field_Position.
	# Code

aggregate(MLB$RBI, list(MLB$Field_Position), FUN = sd)

	# Copy and Paste Results

# Group.1        x
# 1       C 17.53797
# 2      DH 30.34720
# 3      IF 25.86694
# 4      OF 24.86617



## Question 5 - Home Runs scored category (HR_cat)
	# HR_cat Creation Code

MLB$HR_cat <- c("Heaps", "Several", "None")

	# Ordered Factor Conversion Code

MLB$HR_cat <- factor(MLB$HR_cat, levels = c("None", "Several", "Heaps"), ordered = TRUE)
MLB$HR_cat[MLB$HR >= 25] <- "Heaps"
MLB$HR_cat[MLB$HR > 0 & MLB$HR < 25] <- "Several"
MLB$HR_cat[MLB$HR == 0] <- "None"

## Question 6 - Function Creation and Application
	# Function Code

expected_value <- function(values, prob) {
  sum((values * prob))
}



	# Applying function using the below vectors.
	Bunts <- 0:3
	probability <- c(0.81, 0.12, 0.04, 0.03)

	expected_value(Bunts, probability)

	# Final Answer for Expected Value: 

	# [1] 0.29

## Question 7 - Loop
	# Code
	
	sample_mean <- NA
	set.seed(2025)
	
	for (i in 1:4) {
	  row_num_selected <- sample(1:630, size = 12, replace = TRUE)
	  num_runs <- sum(MLB$Runs[row_num_selected])
	  sample_mean[i] <- mean(num_runs)
	}
	sample_mean
	
	# Copy and Paste Results
	# [1] 289 226 329 180
	
	
