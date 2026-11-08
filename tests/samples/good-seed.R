set.seed(20260101)
x <- rnorm(100)
b <- replicate(500, mean(sample(x, replace = TRUE)))
