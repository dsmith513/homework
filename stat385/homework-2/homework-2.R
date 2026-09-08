# Import the data as a data frame.
schools <- read.csv("College.csv")

# Report dimensions, variable names, and variable data types.
dim(schools)
names(schools)
str(schools)

# Use university names as row names and remove the first column.
rownames(schools) <- schools[, 1]
schools <- schools[, -1]
View(schools)

# Summarize the variables.
summary(schools)

# Compare a readable subset of quantitative variables.
pairs(schools[, c("Apps", "Enroll", "Outstate", "Top10perc", "PhD")],
      main = "Pairwise Relationships Among College Variables",
      pch = 19, cex = 0.4)

# Compare enrollment at public and private universities.
boxplot(Enroll ~ Private, data = schools,
        main = "Enrollment by University Type",
        xlab = "Private University (No / Yes)",
        ylab = "Number of New Students Enrolled")

# Classify faculty by the percentage holding a PhD.
schools$Faculty <- cut(schools$PhD,
                       breaks = c(-Inf, 75, 85, Inf),
                       labels = c("Moderate", "Good", "Great"),
                       right = FALSE, ordered_result = TRUE)

boxplot(Top10perc ~ Faculty, data = schools,
        main = "Top 10% Students by Faculty Category",
        xlab = "Faculty Category (Based on PhD Percentage)",
        ylab = "New Students from Top 10% of High School Class (%)")

# Display four histograms together, then restore the graphics settings.
old_par <- par(mfrow = c(2, 2))

hist(schools$Enroll, breaks = 20,
     main = "Distribution of Enrollment",
     xlab = "Number of New Students Enrolled")
hist(schools$Outstate, breaks = 20,
     main = "Distribution of Out-of-State Tuition",
     xlab = "Out-of-State Tuition ($)")
hist(schools$Top10perc, breaks = seq(0, 100, by = 10),
     main = "Distribution of Top 10% Students",
     xlab = "New Students from Top 10% of High School Class (%)")
hist(schools$PhD, breaks = 20,
     main = "Distribution of Faculty PhD Percentages",
     xlab = "Faculty with PhDs (%)")

par(old_par)

# Compare enrollment using a different number of breaks.
hist(schools$Enroll, breaks = 50,
     main = "Distribution of Enrollment (Finer Bins)",
     xlab = "Number of New Students Enrolled")
