## Reading 01: Structures R Code


## *******************************************
## Example 1
patientID <- c(1,2,3,4)
age  <- c(25, 34, 28, 52)
diabetes <- c("Type1","Type2","Type1","Type1")
status <- c("Poor","Improved","Excellent","Poor")

patientdata <- data.frame(patientID, age, diabetes, status)

patientdata



## *******************************************
## Example 2

# Part 1
str(patientdata)

# Part 2
colnames(patientdata)



## *******************************************
## Example 3
mtcars$mpg

summary(mtcars$mpg)
plot(mtcars$mpg, mtcars$wt)

attach(mtcars)
summary(mpg)
plot(mpg, wt)
detach(mtcars)


mpg <- c(25, 36, 47)
attach(mtcars)
plot(mpg, wt)
mpg
detach(mtcars)



## *******************************************
## Example 4
## Part 1
patientdata$diabetes
patientdata[ , 3]
patientdata[3]

## Part 2
patientdata[ , 1:2]
patientdata[ , c(1,2)]

## Part 3
patientdata[1:2, ]
patientdata[c(1,2), ]

# Part 4
patientdata[ , c("diabetes", "status")]
patientdata[ , c(3,4)]
patientdata[ , -c(1,2)]

patientdata[ , -c("patientID", "age")]

# Part 5
patientdata$age
patientage <- patientdata$age
patientage

patientage[c(2,4)]
patientage[-c(1,3)]

# Part 6
patientdata[ patientdata$age > 30 , ]

# Part 7
patientdata[ patientdata$age > 30, c(2,4)]

# Part 8
patientdata[patientdata$age > 30, 4]
patientdata$status[patientdata$age > 30]

# Part 9
patientdata$patientID[3] <- 10



## *******************************************
## Example 6

# Part 1
patientdata$diabetes <- factor(patientdata$diabetes)

patientdata$diabetes

levels(patientdata$diabetes)

as.numeric(patientdata$diabetes)

summary(patientdata$diabetes)

table(patientdata$diabetes)

# Part 2
patientdata$status <- factor(patientdata$status, ordered = TRUE, levels = c("Poor","Improved","Excellent"))

patientdata$status <- ordered(patientdata$status, levels = c("Poor","Improved","Excellent"))

patientdata$status

# Part 3
star(patientdata)

# Part 4
summary(patientdata)

# Part 5
summary(patientdata$age)



## *******************************************
## Example 7

# Part 1
g <- "My First List"
h <- c(25, 26, 18, 39)
j <- matrix(1:10, nrow = 5)
k <- c("one","two","three")

# Part 2
mylist <- list(title = g, ages = h, j, k)
mylist

# Part 3
mylist$title

mylist$ages

# Part 4
mylist["ages"]

mylist[2]

mylist[["ages"]]

mylist[[2]]



## *******************************************
## Example 8

# Part 1
with(mtcars, {
	print(summary(mpg))
	plot(mpg, wt)
	})

# Part 2
with(mtcars, {
	nokeepstats <- summary(mpg)
	keepstats <<- summary(mpg)
	})

nokeepstats
keepstats



## *******************************************
## Example 9

# Part 1
library(ISwR)
energy

# Part 2
exp.lean <- energy$expend[energy$stature == "lean"]
exp.lean

# Part 3
exp.obese <- energy[energy$stature == "obese" , 1]
exp.obese