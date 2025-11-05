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

# 