# 1a) Import and inspect the data.
schools <- read.csv("College.csv")
dim(schools)
names(schools)
str(schools)

# 1b) Set the university names as row names. 
rownames(schools) <- schools[, 1]
schools <- schools[, -1]
View(schools)

# 1c) Numerical and graphical exploration.
# i.
summary(schools)

# ii.
pairs(schools[, c("Apps", "Enroll", "Outstate", "Top10perc", "PhD")],
      main = "Pairwise Relationships Among College Variables",
      pch = 19, cex = 0.4)

# iii.
boxplot(Enroll ~ Private, data = schools,
        main = "Enrollment by University Type",
        xlab = "Private University (No / Yes)",
        ylab = "Number of New Students Enrolled")

# iv.
schools$Faculty <- cut(schools$PhD,
                       breaks = c(-Inf, 75, 85, Inf),
                       labels = c("Moderate", "Good", "Great"),
                       right = FALSE, ordered_result = TRUE)

boxplot(Top10perc ~ Faculty, data = schools,
        main = "Top 10% Students by Faculty Category",
        xlab = "Faculty Category (Based on PhD Percentage)",
        ylab = "New Students from Top 10% of High School Class (%)")

# v.
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

# 2a) Derivatives and Newton-Raphson for the oil-spill model.
oil <- read.table(file = "oilspills.dat", header = TRUE)
X <- as.matrix(oil[, c("importexport", "domestic")])
N <- oil$spills

# i. Score vector.
score <- function(alpha, X, N) {
  lambda <- exp(drop(X %*% alpha))
  drop(t(X) %*% (N - lambda))
}

# ii. Hessian matrix.
hessian <- function(alpha, X) {
  lambda <- exp(drop(X %*% alpha))
  W <- diag(lambda, nrow = nrow(X))
  -t(X) %*% W %*% X
}

# iii. Newton-Raphson update.
newton_step <- function(alpha, X, N) {
  alpha - drop(solve(hessian(alpha, X), score(alpha, X, N)))
}

alpha <- c(alpha1 = 0, alpha2 = 0)
score(alpha, X, N)
hessian(alpha, X)
alpha_next <- newton_step(alpha, X, N)
alpha_next

# iv. Curvature of the log-likelihood.
# For any vector v = (v1, v2)^T,
# t(v) %*% H(alpha) %*% v = -sum_i lambda_i * (b_i1 * v1 + b_i2 * v2)^2 <= 0.
# Since every lambda_i > 0, H is always negative semidefinite and ell
# is concave. If X has full column rank (the predictors are linearly
# independent), the expression is strictly negative for every nonzero v,
# so H is negative definite and ell is strictly concave.
# Thus any stationary point is a global maximum; with full column rank,
# a finite maximizer, if it exists, is unique.

# 2b) Implement Newton-Raphson and report the estimates.
log_likelihood <- function(alpha, X, N) {
  eta <- drop(X %*% alpha)
  sum(N * eta - exp(eta) - lgamma(N + 1))
}

iteration_row <- function(t, alpha, X, N) {
  data.frame(t = t,
             alpha1 = unname(alpha[1]),
             alpha2 = unname(alpha[2]),
             log_likelihood = log_likelihood(alpha, X, N),
             gradient_norm = sqrt(sum(score(alpha, X, N)^2)))
}

alpha <- c(alpha1 = 0, alpha2 = 0)
tolerance <- 1e-6
max_iterations <- 100
converged <- FALSE
iteration_history <- iteration_row(0, alpha, X, N)

for (t in seq_len(max_iterations)) {
  alpha_next <- newton_step(alpha, X, N)
  step_norm <- sqrt(sum((alpha_next - alpha)^2))
  alpha <- alpha_next
  iteration_history <- rbind(iteration_history,
                             iteration_row(t, alpha, X, N))

  if (step_norm < tolerance) {
    converged <- TRUE
    break
  }
}

alpha_hat <- alpha
iterations_required <- t
final_log_likelihood <- log_likelihood(alpha_hat, X, N)
final_gradient <- score(alpha_hat, X, N)
final_gradient_norm <- sqrt(sum(final_gradient^2))

cat("Converged:", converged, "\n")
cat("Final MLEs:\n")
print(alpha_hat, digits = 10)
cat("Iterations required:", iterations_required, "\n")
cat("Final log-likelihood:", format(final_log_likelihood, digits = 12), "\n")

# Display the first three and last three iterations, without duplicate rows.
rows_to_show <- sort(unique(c(head(seq_len(nrow(iteration_history)), 3),
                              tail(seq_len(nrow(iteration_history)), 3))))
print(iteration_history[rows_to_show, ], row.names = FALSE, digits = 10)

cat("Gradient at the final estimate:\n")
print(final_gradient, digits = 10)
cat("Final gradient norm:", format(final_gradient_norm, digits = 10), "\n")
cat("Gradient is close to zero:", final_gradient_norm < 1e-6, "\n")

# 2c) Steepest ascent with step-halving.
ascent_alpha <- c(alpha1 = 0, alpha2 = 0)
ascent_tolerance <- 1e-6
ascent_max_iterations <- 100
max_halvings <- 50
total_halvings <- 0
ascent_status <- "Maximum of 100 iterations reached"
ascent_history <- iteration_row(0, ascent_alpha, X, N)
ascent_history$step_size <- NA_real_
ascent_history$step_norm <- NA_real_
ascent_history$halvings <- 0L

for (t in seq_len(ascent_max_iterations)) {
  gradient <- score(ascent_alpha, X, N)
  current_ll <- log_likelihood(ascent_alpha, X, N)
  step_size <- 1
  halvings <- 0L

  repeat {
    candidate <- ascent_alpha + step_size * gradient
    candidate_ll <- log_likelihood(candidate, X, N)
    accepted <- is.finite(candidate_ll) && candidate_ll > current_ll
    if (accepted || halvings == max_halvings) break
    step_size <- step_size / 2
    halvings <- halvings + 1L
  }

  total_halvings <- total_halvings + halvings
  if (!accepted) {
    ascent_status <- paste("No increasing step after 50 halvings at iteration", t)
    break
  }

  ascent_step_norm <- sqrt(sum((candidate - ascent_alpha)^2))
  ascent_alpha <- candidate
  ascent_row <- iteration_row(t, ascent_alpha, X, N)
  ascent_row$step_size <- step_size
  ascent_row$step_norm <- ascent_step_norm
  ascent_row$halvings <- halvings
  ascent_history <- rbind(ascent_history, ascent_row)

  if (ascent_step_norm < ascent_tolerance) {
    ascent_status <- "Converged: step norm below 1e-6"
    break
  }
}

ascent_alpha_hat <- ascent_alpha
ascent_iterations <- nrow(ascent_history) - 1L
ascent_final_ll <- log_likelihood(ascent_alpha_hat, X, N)
ascent_final_gradient <- score(ascent_alpha_hat, X, N)

cat("\nSteepest ascent status:", ascent_status, "\n")
cat("Final estimate:\n")
print(ascent_alpha_hat, digits = 10)
cat("Accepted iterations:", ascent_iterations, "\n")
cat("Final log-likelihood:", format(ascent_final_ll, digits = 12), "\n")
cat("Total step-halving operations:", total_halvings, "\n")

ascent_rows <- sort(unique(c(head(seq_len(nrow(ascent_history)), 3),
                            tail(seq_len(nrow(ascent_history)), 3))))
print(ascent_history[ascent_rows, ], row.names = FALSE, digits = 10)

cat("Log-likelihood increases at every accepted step:",
    all(diff(ascent_history$log_likelihood) > 0), "\n")
cat("Final gradient:\n")
print(ascent_final_gradient, digits = 10)
cat("Final gradient norm:", sqrt(sum(ascent_final_gradient^2)), "\n")
cat("Distance from Newton-Raphson estimate:",
    sqrt(sum((ascent_alpha_hat - alpha_hat)^2)), "\n")
cat("Log-likelihood gap from Newton-Raphson:",
    final_log_likelihood - ascent_final_ll, "\n")

# 2d) Gradient ascent with a fixed step size.
# I tried gamma = 0.1, 0.05, 0.02, and 0.01 from (0, 0).
# The first two did not converge within 1000 iterations and had decreases
# in log-likelihood. Both 0.02 and 0.01 increased the log-likelihood at
# every step and converged, taking 102 and 195 iterations, respectively.
# I selected gamma = 0.02 because it was stable and faster than 0.01.
gamma <- 0.02
fixed_alpha <- c(alpha1 = 0, alpha2 = 0)
fixed_tolerance <- 1e-6
fixed_max_iterations <- 1000
fixed_converged <- FALSE
fixed_status <- "Did not converge within 1000 iterations"
fixed_history <- iteration_row(0, fixed_alpha, X, N)
fixed_history$step_norm <- NA_real_

for (t in seq_len(fixed_max_iterations)) {
  fixed_next <- fixed_alpha + gamma * score(fixed_alpha, X, N)
  if (any(!is.finite(fixed_next)) ||
      !is.finite(log_likelihood(fixed_next, X, N))) {
    fixed_status <- paste("Failed: nonfinite value at iteration", t)
    break
  }

  fixed_step_norm <- sqrt(sum((fixed_next - fixed_alpha)^2))
  fixed_alpha <- fixed_next
  fixed_row <- iteration_row(t, fixed_alpha, X, N)
  fixed_row$step_norm <- fixed_step_norm
  fixed_history <- rbind(fixed_history, fixed_row)

  if (fixed_step_norm < fixed_tolerance) {
    fixed_converged <- TRUE
    fixed_status <- "Converged: step norm below 1e-6"
    break
  }
}

fixed_alpha_hat <- fixed_alpha
fixed_iterations <- nrow(fixed_history) - 1L
fixed_final_ll <- log_likelihood(fixed_alpha_hat, X, N)
fixed_final_gradient <- score(fixed_alpha_hat, X, N)

cat("\nFixed-step gradient ascent status:", fixed_status, "\n")
cat("Step size gamma:", gamma, "\n")
cat("Final estimate:\n")
print(fixed_alpha_hat, digits = 10)
cat("Iterations:", fixed_iterations, "\n")
cat("Final log-likelihood:", format(fixed_final_ll, digits = 12), "\n")

fixed_rows <- sort(unique(c(head(seq_len(nrow(fixed_history)), 3),
                           tail(seq_len(nrow(fixed_history)), 3))))
print(fixed_history[fixed_rows, ], row.names = FALSE, digits = 10)
cat("Log-likelihood increases at every step:",
    all(diff(fixed_history$log_likelihood) > 0), "\n")
cat("Final gradient:\n")
print(fixed_final_gradient, digits = 10)
cat("Final gradient norm:", sqrt(sum(fixed_final_gradient^2)), "\n")
cat("Distance from Newton-Raphson estimate:",
    sqrt(sum((fixed_alpha_hat - alpha_hat)^2)), "\n")

