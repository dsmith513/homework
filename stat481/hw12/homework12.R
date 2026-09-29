
## Question 2:

relief <- read.csv("relief.csv")

interaction.plot(
  x.factor = relief$FactorB,
  trace.factor = relief$FactorA,
  response = relief$Hours,
  type = "b",
  pch = 19,
  xlab = "Factor B (Ingredient 2)",
  ylab = "Mean Hours of Relief",
  trace.label = "Factor A (Ingredient 1)",
  main = "Interaction Plot for Hours of Relief"
)
