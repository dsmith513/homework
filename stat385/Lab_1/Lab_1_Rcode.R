## Set working directory, please set the working directory as the folder where you saved
## the ZipCode images data sets

setwd("...STAT 385/datasets/ZipCodes")

## Q1: (a) 
X<-rnorm(100, 0, 2) ## Generating a N(0,4) distributed random vector of length 100
meanX<-mean(X) ## Compute sample mean
varX<-var(X)  ## Compute sample variance
hist(X,freq=FALSE) ## Creat a histogram for X using probaility density
dnorm2<-function(x) ## Define the density function of N(0,4)
{return(dnorm(x,0,2))}
curve(dnorm2,add=TRUE,col=2) ## Add the density to the histogram
prob1<-mean(X>1) ## Compute the empirical probability, namely the percentage of elements in X that is 
                 ## greater than 1.

## Q1: (c) Create a new vector that contains all positive numbers from the vector X 
positiveX<-X[X>0]
 
## Q2: (a) Approximate the expectation of NB(r,p)
# r: the number of successes you want to obtain
# p: success probability

rvec<-c(10,20,30)
pvec<-c(0.2,0.5)

N<-1000
expX<-matrix(0,3,2) ## A matrix contains all approximations of expectations with different combinations of r and p
for (i in 1:3)
 for (j in 1:2)
  for (k in rvec[i]:N)
  {
   pk<-choose(k-1,rvec[i]-1)*(pvec[j]^(rvec[i]))*((1-pvec[j])^(k-rvec[i]))	
   expX[i,j]<-expX[i,j]+k*pk
  } 
expX

## Q3:Visualize all the probability mass functions in Q3

rvec<-c(10, 20, 30)
pvec<-c(0.2, 0.5)
N<-200
xvec<-c(rvec[1]:N)
pkvec<-choose(xvec-1,rvec[1]-1)*(pvec[1]^rvec[1])*((1-pvec[1])^(xvec-rvec[1]))
plot(xvec,pkvec,type="n",xlab="x",ylab="probability mass of NB(r,p)",ylim=c(0,0.1))
legendtext<-NULL
colvec<-NULL
ltyvec<-NULL
for (i in 1:3)
 for (j in 1:2)
 {
  xvec<-c(rvec[i]:N)
  pkvec<-choose(xvec-1,rvec[i]-1)*(pvec[j]^rvec[i])*((1-pvec[j])^(xvec-rvec[i]))
  lines(xvec,pkvec,lty=j, col=i)
  legendtext<-c(legendtext,paste("r=",rvec[i],",p=",pvec[j],sep=""))
  colvec<-c(colvec,i)
  ltyvec<-c(ltyvec,j)
 }
legend("topright",legendtext,col=colvec,lty=ltyvec)

## Q4: Rotate the matrix A colockwisely 90 degree: Reverse the matrix column by column and do a transpose
## When image function plot A, it will rotate A counter-clockwisely 90 degree.
## In gray function: 0 means black and 1 means white

A<-matrix(c(1,1,-1,-1,-1,1,1,1,-1),3,3)
image(A,col=gray((0:32)/32)) ## Wrong usage
imA<-t(apply(A,2,rev)) ## Turn the matrix clockwisely 90 degree
image(-imA,col=gray((0:32)/32)) ## The minus sign is to match the definition of colors in gray function

## Q5: Hand-written digit recognition data
## (a): Read data sets
zipTrain=read.csv("zip.train.gz", header = F, sep=" ")
dim(zipTrain)
head(zipTrain)
zipTrain=zipTrain[,1:257]
zipTest=read.csv("zip.test.gz", header = F, sep=" ")
dim(zipTest)

## (b): Creat a frequency table

table(zipTrain[,1])

## (c): Classify training data sets according to the numbers

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

## (d): Visualize the image of a handwritten number

par(mfrow=c(1,2))
im=matrix(as.numeric(zipTrain[4,2:257]), nrow = 16, ncol = 16)
image(t(apply(-im,1,rev)),col=gray((0:32)/32)) # plot column by column using values row by row
newim=matrix(as.numeric(zipTrain[4,2:257]), nrow = 16, ncol = 16, byrow=TRUE)
image(t(apply(-newim,2,rev)),col=gray((0:32)/32)) # This gives the same image as above

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


## Q6: Optimization of a likelihood function

set.seed(2025)
x<- rnorm(100)
beta <- 2
pi <- exp(x*beta)/(1+exp(x*beta))
y <- rbinom(100, size=1, prob=pi)

#### log-likelihood function ####

Loglbeta<-function(beta,y,x)
{
    lbeta <- rep(0,length(beta))
    for (i in 1:length(beta)){
       lbeta[i]<-sum(y*x*beta[i]-log(1+exp(x*beta[i])))
    }
    return(lbeta)
}

## Plot of the objective function
betavec<-seq(1,5,length=1000)
lbetavec<-Loglbeta(betavec,y,x)
plot(betavec,lbetavec,type="l")

lbetaprime<-function(beta,y,x)
{
  lbetaprime <- rep(0,length(beta))
  for (i in 1:length(beta)){
   pi <- exp(x*beta[i])/(1+exp(x*beta[i]))
   lbetaprime[i] <-sum(x*(y-pi))
  }
  return(lbetaprime)
}

## Plot of the first order derivative
lbetaprimevec<-lbetaprime(betavec,y,x)
plot(betavec,lbetaprimevec,type="l")
abline(h=0)


#### Newton-Raphson's method for optimizing a univariate function ####

lbetaprime2<-function(beta,y,x)
{
  lbetaprime2 <- rep(0,length(beta))
  for (i in 1:length(beta)){
   pi <- exp(x*beta[i])/(1+exp(x*beta[i]))
   lbetaprime2[i] <- -sum((x^2)*pi*(1-pi))
  }
  return(lbetaprime2)
}

## Plot of the first and second order derivatives
lbetaprime2vec<-lbetaprime2(betavec,y,x)
par(mfrow=c(1,2))
plot(betavec,lbetaprimevec,type="l")
plot(betavec,lbetaprime2vec,type="l")

newtonraphson<-function(beta0,y,x,epsilon=0.0001)
{
  counts<-0
  repeat{
    lbeta1<-lbetaprime(beta0,y,x)
    lbeta2<-lbetaprime2(beta0,y,x)
    beta1<-beta0-lbeta1/lbeta2
    if (abs(beta1-beta0)<epsilon)
    {break;}
    beta0<-beta1
    counts<-counts+1
  }
  return(list(betastar=beta1,counts=counts))
}

newtonresults<-newtonraphson(1,y,x,0.00001)
newtonresults<-newtonraphson(3,y,x,0.00001)

## Steepest ascent method (step halving backtracking)

steepascent<-function(beta0, y, x, epsilon=0.0001){
    counts <- 0
    repeat{
        lbetaprimes <- lbetaprime(beta0,y,x)
        ratio <- 1
        beta1 <- beta0 + ratio*lbetaprimes
        iters <- 0
        while(Loglbeta(beta1,y,x)<Loglbeta(beta0,y,x)){
          ratio <- ratio/2
          iters <- iters+1
          beta1 <- beta0 + ratio*lbetaprimes
          cat(iters,beta1,"\n")}
        if(abs(beta1 - beta0) < epsilon || counts >1000){
            break;}
        beta0 <- beta1
        counts <- counts + 1
    }
    return(list(betastar=beta1, iterations=counts))
}

beta0 <- c(2.5)
steepascentresults <- steepascent(beta0, y, x, 0.00001)
steepascentresults

## Gradient ascent algorithm

gradientascent<-function(beta0, y, x, alpha, epsilon=0.0001){
    counts <- 0
    repeat{
        lbetaprimes <- lbetaprime(beta0,y,x)
        beta1 <- beta0 + alpha*lbetaprimes
        if(abs(lbetaprime(beta1,y,x)) < epsilon || counts >1000){
            break;
        }
        beta0 <- beta1
        counts <- counts + 1
    }
    return(list(betastar=beta1, iterations=counts))
}

beta0 <- c(3.5)
gradientascentresults <- gradientascent(beta0, y, x, 0.01, 0.00001)
gradientascentresults

gradientascentresults <- gradientascent(beta0, y, x, 0.05, 0.00001)
gradientascentresults



