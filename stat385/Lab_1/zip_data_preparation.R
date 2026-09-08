## Set working directory
setwd("/Users/pszhong/Library/CloudStorage/Box-Box/UIC Teaching/STAT 385-2025-Summer/Presentation Material/Week-1/email spam")

## Read data sets
zipTrain=read.csv("zip.train.gz", header = F, sep=" ")
#zipTrain=read.table(gzfile("zip.train.gz"), header=F, sep=" ")

head(zipTrain)

zipTrain=zipTrain[,1:257]

zipTest=read.csv("zip.test.gz", header = F, sep=" ")

## Visualize the images of handwritten numbers

im=matrix(as.numeric(zipTrain[4,2:257]), nrow = 16, ncol = 16)

image(t(apply(-im,1,rev)),col=gray((0:32)/32)) # plot column by column using values row by row

## Classify training data sets according to the numbers
table(zipTrain[,1])

number0=zipTrain[zipTrain[,1]==0,]
number1=zipTrain[zipTrain[,1]==1,]
number2=zipTrain[zipTrain[,1]==2,]
number3=zipTrain[zipTrain[,1]==3,]
number4=zipTrain[zipTrain[,1]==4,]
number5=zipTrain[zipTrain[,1]==5,]
number6=zipTrain[zipTrain[,1]==6,]
number7=zipTrain[zipTrain[,1]==7,]
number8=zipTrain[zipTrain[,1]==8,]
number9=zipTrain[zipTrain[,1]==9,]

## Visualize some handwritten numbers

par(mfrow=c(5,10))
par(mar=rep(1,4))
for (i in 1:5)
{
 for (j in 0:9)
 {
 numberj=zipTrain[zipTrain[,1]==j,]
 im=matrix(as.numeric(numberj[i,2:257]), nrow = 16, ncol = 16)
 image(t(apply(-im,1,rev)),col=gray((0:32)/32),axes = FALSE)
 }
}





