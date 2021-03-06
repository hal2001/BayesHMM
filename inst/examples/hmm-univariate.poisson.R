mySpec <- hmm(
  K = 3, R = 1,
  observation = Poisson(
    lambda = Default(bounds = list(0, NULL))
  ),
  initial     = Dirichlet(alpha = c(0.5, 0.5, 0.5)),
  transition  = Dirichlet(alpha = c(0.5, 0.5, 0.5)),
  name = "Univariate Poisson Model"
)

set.seed(9000)
y = as.matrix(
  c(rpois(100, 5), rpois(100, 10), rpois(100, 1))
)

myFit <- fit(mySpec, y = y, chains = 1, iter = 500)

plot_obs(myFit)

print_all(myFit)
