#' Specify a model.
#'
#' See below for details on model specification.
#' @param K An integer with the number of hidden states.
#' @param R An integer with the dimension of the observation vector (e.g. one is univariate, two is bivariate)
#' @param observation One density, or more than one density chained with the `+` operator, describing the observation model. See below and future vignette for detailed explanation.
#' @param initial One density, or more than one density chained with the `+` operator, describing the initial distribution model. See below and future vignette for detailed explanation.
#' @param transition One density, or more than one density chained with the `+` operator, describing the transition model. See below and future vignette for detailed explanation.
#' @param name An optional string with a name for a model.
#' @return An specification object that may be used to validate calibration (\code{\link{validate_calibration}}), compiled (\code{\link{compile}}), generate data from \code{\link{sim}}, or fit a model to data to obtain a point estimate (\code{\link{optimizing}}) or run full-bayesian inference via Markov-chain Monte Carlo (\code{\link{fit}}).
#' @export
#' @seealso \code{\link{compile}}, \code{\link{explain}}, \code{\link{fit}}, \code{\link{optimizing}}, \code{\link{sim}}, \code{\link{validate_calibration}}.
#'
#' @section Model specification:
#' A Hidden Markov Model may be seen as three submodels that jointly specify the dinamics of the observed random variable. To specify the observation, initial distribution, and transition models, we designed S3 objects called \code{\link{Density}} that define density form, parameter priors, and fixed values for parameters. These are flexible enough to include bounds in the parameter space as well as truncation in prior densities.
#'
#' Internally, a \code{\link{Specification}} object is a nested list storing either \emph{K} multivariate densities (i.e. one multivariate density for state) or \emph{K x R} univariate densities (i.e. one univariate density for each dimension in the observation variable and each state). (what does this depend on?) However, the user is not expected to known the internal details of the implementation. Instead, user-input will be interpreted based on three things: the dimension of the observation vector \emph{R}, the number of densities given by the user, and the type of density given by the user.
#'
#' \strong{Univariate observation model} (i.e. \emph{R} = 1):
#' \enumerate{
#'   \item Enter one univariate density if you want the observation variable to have the same density and parameter priors in every hidden state. Note that, although the user input is recycled for every hidden state for the purpose of model specification, parameters are not shared across states. All parameters are free.
#'   \item Enter \emph{K} univariate densities if you want the observation variable to have different densities and/or parameter priors in each hidden state.
#' }
#'
#' \preformatted{
#'   # Assume K = 2, R = 1
#'   # 1. Same density and priors in every state
#'   observation = Gaussian(
#'     mu    = Gaussian(0, 10),
#'     sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'   )
#'
#'   # 2. (a) Different priors for each of the K = 2 possible hidden states
#'   observation =
#'     Gaussian(
#'       mu    = Gaussian(0, 10),
#'       sigma = Student(mu = 0, sigma =  1, nu = 1, bounds = list(0, NULL))
#'     ) +
#'     Gaussian(
#'       mu    = Gaussian(0, 10),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     )
#'
#'   # 2. (b) Different densities for each of the K = 2 possible hidden states
#'        (i.e. the observed variable has heavy tails on the second state).
#'   observation =
#'     Gaussian(
#'       mu    = Gaussian(0, 10),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     ) +
#'     Student(
#'       mu    = Gaussian(0, 10),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'       nu    = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     )
#' }
#'
#' \strong{Multivariate observation model} (i.e. \emph{R} > 1):
#' \enumerate{
#'   \item Enter one univariate density if you want every dimension of the observation vector to have the same density and parameter priors in every hidden state. In this case, the user specifies the marginal density of independent random variables.
#'   \item Enter one multivariate density if you want the observation vector to have the same joint density and parameter priors in every hidden state. In this case, the user specifies the joint density of random variables.
#'
#'   \item Enter \emph{K} univariate densities if you want every dimension of the observation vector to have the same density and parameter priors within each hidden state. In this case, the user specifies the marginal density of independent random variables for each state. In other words, given a latent state, each variable in the observation vector will have the same density and parameter priors.
#'   \item Enter \emph{K} multivariate densities if you want the observation vector to have different densities and/or parameter priors in each hidden state. In this case, the user specifies a joint density and parameter priors that varies per state.
#'
#'   \item Enter \emph{R} univariate densities if you want each dimension of the observation vector to have different densities and parameter priors, but these specification should the same in every hidden state. In this case, the user specifies the marginal density of independent elements of a random vector, and this specification is the same in all latent states.
#'   \item Enter \emph{R x K} univariate densities if you want each dimension of the observation vector to have different densities and parameter priors in each hidden state. In this case, the user specifies the marginal density of independent elements of a random vector which also varies for each latent state.
#' }
#'
#' \preformatted{
#'   # Assume K = 2, R = 2
#'   # 1. Same density for every dimension of the random vector and hidden state
#'   observation = Gaussian(
#'     mu    = Gaussian(0, 10),
#'     sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'   )
#'
#'   # 2. Same density for the random vector in every hidden state
#'   observation = MVGaussianCor(
#'     mu    = MVGaussian(mu = c(0, 0), sigma = matrix(c(100, 0, 0, 100), 2, 2)),
#'     L     = LKJCor(eta = 2)
#'   )
#'
#'   # 3. Different density for each dimension of the random vector, but the
#'        specification is the same across hidden states (i.e. we believe the
#'        observed variable has heavy tails on the second state).
#'   observation =
#'     Gaussian(
#'       mu    = Gaussian(0, 10),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     ) +
#'     Student(
#'       mu    = Gaussian(0, 10),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'       nu    = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     )
#'
#'   # 4. Different priors in each hidden state
#'   observation =
#'     MVGaussianCor(
#'       mu    = MVGaussian(mu = c(0, 0), sigma = matrix(c(100, 0, 0, 100), 2, 2)),
#'       L     = LKJCor(eta = 2)
#'     ) +
#'     MVGaussianCor(
#'       mu    = MVGaussian(mu = c(1, -1), sigma = matrix(c(100, 0, 0, 100), 2, 2)),
#'       L     = LKJCor(eta = 2)
#'     )
#'
#'   # 5. Cannot be used in this case since K = R = 2. See paragraph below.
#'
#'   # 6. Different density for for each dimension and hidden state
#'     Gaussian(
#'       mu    = Gaussian(0, 10),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     ) +
#'     Student(
#'       mu    = Gaussian(0, 10),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'       nu    = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     ) +
#'     Gaussian(
#'       mu    = Gaussian(0, 1),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     ) +
#'     Student(
#'       mu    = Gaussian(0, 1),
#'       sigma = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'       nu    = Student(mu = 0, sigma = 10, nu = 1, bounds = list(0, NULL))
#'     )
#' }
#'
#' The last specifications, admittedly intricate and little natural, are provided in case the user has very specific modeling needs. When \emph{K = R}, cases 3 and 5 clash and the software will read it as case 3. Note that, although the user input is recycled for every for the purpose of model specification, parameters are never shared across dimensions or states. All parameters are free.
#'
#' \strong{Initial model}:
#' \enumerate{
#'   \item Enter one univariate density if you want each every initial state probability to have the same parameter priors. In this case, the user specifies the marginal density of independent initial state probabilities. Note that, although these priors may not guarantee per se that the elements of initial vector sum to one, this is not problematic for estimation. The log posterior density will only be affected by the relative strength of these priors even if they are not normalized.
#'   \item Enter \emph{K} univariate densities if you want each initial state probability to have different priors. Additional comments from the previous item apply.
#'   \item Enter one multivariate density if you want to define a joint prior for all the elements of the initial distribution vector.
#' }
#'
#' \preformatted{
#'   # Assume K = 2
#'   # 1. Same prior (uniform) for every initial state probability
#'   initial = Beta(alpha = 1, beta = 1)
#'
#'   # 2. Different priors for each of the K = 2 initial state probabilities
#'   initial = Beta(alpha = 0.7, beta = 1) + Beta(alpha = 1, beta = 0.7)
#'
#'   # 2. One multivariate prior for the initial state vector
#'   initial = Dirichlet(alpha = c(1, 1))
#' }
#'
#' Specification #3 is most suitable for most of the problem, unless the user has very specific modeling needs. Useful densities for this model include \code{\link{Beta}} and \code{\link{Dirichlet}}.
#'
#' \strong{Transition model}:
#' \enumerate{
#'   \item Enter one univariate density if you want all the \emph{K x K} elements of the transition matrix to have the same prior. In this case, the user specifies the marginal prior of transition probabilities. Note that, although these priors may not guarantee per se that the elements of each row sum to one, this is not problematic for estimation. The log posterior density will only be affected by the relative strength of these priors even if they are not normalized.
#'   \item Enter one multivariate density if you want every \emph{K}-sized row of the transition matrix to have the same prior. In this case, the user specifies the joint prior of the transition probability for any given starting state.
#'
#'   \item Enter \emph{K} univariate densities if you want each element of any given row to have different priors. In this case, the user specifies the marginal prior for the \emph{K} transition probabilities for any given starting state. Additional comments from the first item apply.
#'   \item Enter \emph{K} multivariate densities if you want each \emph{K}-sized row of the transition matrix to have the multivariate same prior. In this case, the user specifies the joint prior of the transition probability that varies for each starting state.
#'
#'   \item Enter \emph{KxK} univariate densities if you want each element of the transition matrix to have a different prior. In this case, the user specifies the marginal prior for the \emph{KxK} transition probabilities. Additional comments from the first item apply.
#' }
#'
#' \preformatted{
#'   # Assume K = 2
#'   # 1. Same prior (uniform) for each of the KxK elements of the matrix
#'   transition = Beta(alpha = 1, beta = 1)
#'
#'   # 2. Same prior (uniform) for each of the K rows of the matrix
#'   transition = Dirichlet(alpha = c(1, 1))
#'
#'   # 3. Different priors for each element in a row
#'   transition = Beta(alpha = 0.7, beta = 1) + Beta(alpha = 1, beta = 0.7)
#'
#'   # 4. Different priors for each row
#'   transition = Dirichlet(alpha = c(0.7, 1)) + Dirichlet(alpha = c(1, 0.7))
#'
#'   # 5. Different priors for each element in the matrix
#'   transition =
#'     Beta(alpha = 0.7, beta = 1) + Beta(alpha = 1, beta =   1) +
#'     Beta(alpha =   1, beta = 1) + Beta(alpha = 1, beta = 0.7)
#' }
#'
#' Specifications #2 and #4 are most suitable for most of the problem, unless the user has very specific modeling needs. Useful densities for this model include \code{\link{Beta}} and \code{\link{Dirichlet}}.
#'
#' \strong{Fixed parameters}
#' Note that fixed parameters may be specified following this example:
#'
#' \preformatted{
#'   # Gaussian density with fixed standard deviation
#'   observation = Gaussian(
#'     mu    = Gaussian(0, 10),
#'     sigma = 1
#'   )
#' }
#'
#' @family models
#' @examples
specify <- function(K, R, observation = NULL, initial = NULL,
                 transition = NULL, name = "") {
  check_natural(K, "K")
  check_natural(R, "R")

  K <- as.integer(K)
  R <- as.integer(R)

  l <- list(
    name = name,
    K    = K,
    observation = list(
      R = R,
      covariates = NULL,
      density = parse_observation(observation, K, R)
    ),
    initial   = list(
      density = parse_initial(initial, K, R)
    ),
    transition  = list(
      covariates = NULL,
      density = parse_transition(transition, K, R)
    )
  )

  spec <- structure(l, class = "Specification")

  # check(spec)

  spec
}

#' Verify that the object is a valid specification. TO BE IMPLEMENTED.
#'
#' This function verifies that the structure of the object is valid. Useful to spot inconsistencies in the specification. \strong{TO BE IMPLEMENTED}.
#' @usage check(spec)
#' @param spec An object returned by either \code{\link{specify}} or \code{\link{hmm}}.
#' @return A logical value with TRUE if the object is a valid specification or FALSE otherwise.
#' @export
#' @examples
check             <- function(spec, ...) { UseMethod("check", spec) }

check.Specification <- function(spec) {
  stop("TO BE IMPLEMENTED.")

  # Check if R and the observation tree are consistent
  if (spec$observation$R == 1 & is.multivariate(spec)) {
    stop("Inconsistent specification: although R was set to 1, a multivariate density was given.")
  }

  # if (spec$observation$R != 1 & !is.multivariate(spec)) {
  #   stop(
  #     sprintf(
  #       "Inconsistent specification: although R is set to %s, a univariate density was given.",
  #       spec$observation$R
  #     )
  #   )
  # }

  # Check if univariate and mulvariate densities are mixed
  dens <- densityApply(spec$observation$density, is.multivariate)
  if (length(unique(dens)) != 1) {
    stop("Inconsistent specification: univariate and multivariate densities for the observation model cannot be mixed.")
  }

  # Check if fixed parameters are well specified
  invisible(
    densityApply(spec$observation$density, fixedParameters)
  )
}

#' Create an user-friendly text describing the model.
#'
#' The function creates a user-friendly text describing any of the three elements of the model. It includes the hidden states, variables, densities, bounds, priors, and fixed parameters. It also records environment details for easier reproducibility (package version, R version, time, OS).
#'
#' @usage explain(spec, observation = TRUE, initial = TRUE, transition = TRUE, print = TRUE)
#' @param spec An object returned by either \code{\link{specify}} or \code{\link{hmm}}.
#' @param observation An optional logical indicating whether the observation model should be included in the description. It defaults to TRUE.
#' @param initial An optional logical indicating whether the initial distribution model should be included in the description. It defaults to TRUE.
#' @param transition An optional logical indicating whether the transition model should be included in the description. It defaults to TRUE.
#' @param print An optional logical indicating whether the description should be printing out.
#' @return A character string with the model description.
#' @export
#'
#' @examples
explain           <- function(spec, ...) { UseMethod("explain", spec) }

explain.Specification <- function(spec, observation = TRUE, initial = TRUE,
                                  transition = TRUE, print = TRUE) {
  strHeader      <- make_text_header(spec$name)
  strObservation <- if (observation) { explain_observation(spec) }
  strInitial     <- if (initial)     { explain_initial(spec) }
  strTransition  <- if (transition)  { explain_transition(spec) }
  strFooter      <- sprintf(
    "Note for reproducibility: \n%s.\n",
    get_package_info()
  )

  out <- gsub(
    "\\t",
    get_print_settings()$tab,
    collapse(strHeader, strObservation, strInitial, strTransition, strFooter)
  )

  if (print) { cat(out) }

  invisible(out)
}

#' Create an outline of the observation model.
#'
#' @usage explain_observation(spec)
#' @param spec An object returned by the \code{\link{specify}}) function.
#' @return A character vector with an outline of the observation model.
#' @family explain
#' @export
#' @keywords internal
#' @examples
explain_observation <- function(spec, ...) { UseMethod("explain_observation", spec) }

explain_observation.Specification <- function(spec) {
  R <- spec$observation$R

  block1 <-
    sprintf(
      "%s observations (R = %d): %s.\n",
      if (R > 1) { "Multivariate" } else { "Univariate" },
      R, "Variable names"
    )

  l <- densityApply(spec$observation$density, explain)

  block2 <-
    if (all(sapply(l, identical, l[[1]]))) {
      sprintf(
        "Observation model for all states\n%s\n", l[[1]]
      )
    } else {
      k <- sub("k[[:digit:]].k([[:digit:]])r[[:digit:]]", "\\1", names(l))
      r <- sub("k[[:digit:]].k[[:digit:]]r([[:digit:]])", "\\1", names(l))
      sprintf(
        "\nObservation model for State %s and Variable %s\n%s\n",
        k, r, l
      )
    }

  collapse(c(block1, block2))
}

#' Create an outline of the initial distribution model.
#'
#' @usage explain_initial(spec)
#' @param spec An object returned by the \code{\link{specify}}) function.
#' @return A character vector with an outline of the initial model.
#' @family explain
#' @export
#' @keywords internal
#' @examples
explain_initial     <- function(spec, ...) { UseMethod("explain_initial", spec) }

explain_initial.Specification <- function(spec) {
  l <- densityApply(spec$initial$density, explain)

  block1 <-
    if (all(sapply(l, identical, l[[1]]))) {
      sprintf(
        "Initial distribution model\n%s\n", l[[1]]
      )
    } else {
      k <- sub("i[[:digit:]].i([[:digit:]])j[[:digit:]]", "\\1", names(l))
      sprintf(
        "\nInitial probability for State %s\n%s\n",
        k, l
      )
    }

  collapse(block1)
}

#' Create an outline of the transition model.
#'
#' @usage explain_transition(spec)
#' @param spec An object returned by the \code{\link{specify}}) function.
#' @return A character vector with an outline of the transition model.
#' @family explain
#' @export
#' @keywords internal
#' @examples
explain_transition  <- function(spec, ...) { UseMethod("explain_transition", spec) }

explain_transition.Specification <- function(spec) {
  l <- densityApply(spec$transition$density, explain)

  block1 <-
    if (all(sapply(l, identical, l[[1]]))) {
      sprintf(
        "Transition model\n%s\n", l[[1]]
      )
    } else {
      i <- sub("i[[:digit:]].i([[:digit:]])j[[:digit:]]", "\\1", names(l))
      j <- sub("i[[:digit:]].i[[:digit:]]j([[:digit:]])", "\\1", names(l))
      sprintf(
        "\nTransition probability from State %s to State %s\n%s\n",
        i, j, l
      )
    }

  collapse(block1)
}

#' Compile a specified model.
#'
#' This function turns the model specification into Stan code and compiles the program via rstan.
#'
#' @usage compile(spec, priorPredictive = FALSE, writeDir = tempdir(), ...)
#' @param spec An object returned by either \code{\link{specify}} or \code{\link{hmm}}.
#' @param priorPredictive An optional logical stating whether the log-likelihood should be excluded from the program. If TRUE, the returned object can only be used to draw samples from the prior predictive density. If FALSE, the returned object can only be used to draw samples from the posterior predictive density. It defaults to FALSE.
#' @param writeDir An optional string with the path where the Stan file should be written. Useful to inspect and modify the Stan code manually. It defaults to a temporary directory.
#' @param ... Arguments to be passed to rstan's \code{\link[rstan]{stan_model}}.
#' @return An instance of S4 class stanmodel.
#' @export
#' @examples
compile           <- function(spec, ...) { UseMethod("compile", spec) }

compile.Specification <- function(spec, priorPredictive = FALSE,
                                  writeDir = tempdir(), ...) {

  stanFile <- write_model(spec, noLogLike = priorPredictive, writeDir)

  stanDots <- c(
    list(...),
    list(
      file       = stanFile,
      model_name = spec$name
    )
  )

  stanModel <- do.call(rstan::stan_model, stanDots)
  attr(stanModel, "filename") <- stanFile
  attr(stanModel, "spec") <- spec

  return(stanModel)
}

# Full-Bayesian estimation ------------------------------------------------

#' Draw samples from a specification.
#'
#' @usage function(spec, stanModel = NULL, y, x = NULL, u = NULL, v = NULL, writeDir = tempdir(), ...)
#' @param spec An object returned by either \code{\link{specify}} or \code{\link{hmm}}.
#' @param stanModel An optional instance of S4 class stanmodel returned by \code{\link{compile}}. If not given, the model is automatically compiled but the object is not returned to the user and cannot be reutilized in future sampling.
#' @param y A numeric matrix with the observation sample. It must have as many rows as the time series length \emph{T} and as many columns as the dimension of the observation vector \emph{R}. If not a matrix, the function tries to cast the object to a \eqn{T\times R} matrix.
#' @param x An optional numeric matrix with the covariates for the observation model. It must have as many rows as the time series length \emph{T} and as many columns as the dimension of the covariate vector \emph{M}. If not a matrix, the function tries to cast the object to a \eqn{T\times M} matrix. Useful for Hidden Markov Regression Model (also known as Markov-switching regressions).
#' @param u An optional numeric matrix with the covariates for the transition model. It must have as many rows as the time series length \emph{T} and as many columns as the dimension of the transition covariate vector \emph{P}. If not a matrix, the function tries to cast the object to a \eqn{T\times P} matrix. Useful for Hidden Markov Models with time-varying transition probabilities.
#' @param v An optional numeric matrix with the covariates for the initial distribution model. It must have as many rows as the number of hidden states \emph{K} and as many columns as the dimension of the initial covariate vector \emph{Q}. If not a matrix, the function tries to cast the object to a \eqn{K\times Q} matrix.
#' @param writeDir An optional string with the path where the Stan file should be written. Useful to inspect and modify the Stan code manually. It defaults to a temporary directory.
#' @param ... Arguments to be passed to rstan's \code{\link[rstan]{sampling}}.
#' @return An object of S4 class stanfit with some additional attributes (the dataset \emph{data}, the name of the Stan code file \emph{filename}, and the specification object \emph{spec}). This object is completely compatible with all other functions.
#' @seealso See rstan's \code{\link[rstan]{stan}} and \code{\link[rstan]{sampling}} for further details on tunning the MCMC algorithm.
#' @export
#' @examples
sampling          <- function(spec, ...) { UseMethod("sampling", spec) }

sampling.Specification <- function(spec, stanModel = NULL, y, x = NULL, u = NULL, v = NULL,
                                   writeDir = tempdir(), ...) {

  if (is.null(stanModel)) {
    stanModel <- compile(spec, priorPredictive = FALSE, writeDir)
  }

  stanData <- make_data(spec, y, x, u, v)
  stanDots <- c(list(...), list(object = stanModel, data = stanData))

  stanSampling <- do.call(rstan::sampling, stanDots)
  attr(stanSampling, "data")     <- stanData
  attr(stanSampling, "filename") <- attr(stanModel, "filename")
  attr(stanSampling, "spec")     <- spec

  return(stanSampling)
}

#' Run a Markov-chain Monte Carlo algorithm to sample from the log posterior density.
#'
#' @usage run(spec, data = NULL, writeDir = tempdir(), ...)
#' @inherit sampling
#' @param ... Arguments to be passed to rstan's \code{\link[rstan]{stan}}.
#' @keywords internal
#' @export
run               <- function(spec, ...) { UseMethod("run", spec) }

run.Specification <- function(spec, data = NULL, writeDir = tempdir(), ...) {

  stanData <- data
  stanFile <- write_model(spec, noLogLike = is.null(data$y), writeDir)

  stanDots <- c(
    list(...),
    list(
      file       = stanFile,
      data       = stanData,
      model_name = spec$name
    )
  )

  stanFit <- do.call(rstan::stan, stanDots)
  attr(stanFit, "data")     <- stanData
  attr(stanFit, "filename") <- stanFile
  attr(stanFit, "spec")     <- spec

  return(stanFit)
}

#' Fit a model by MCMC
#'
#' @usage fit(spec, y, x = NULL, u = NULL, v = NULL, ...)
#' @inherit sampling
#' @param ... Arguments to be passed to rstan's \code{\link[rstan]{stan}}.
#' @export
#' @examples
fit               <- function(spec, ...) { UseMethod("fit", spec) }

fit.Specification <- function(spec, y, x = NULL, u = NULL, v = NULL, ...) {
  run(spec, data = make_data(spec, y, x, u, v), ...)
}

# Maximum a posteriori estimation -----------------------------------------

#' Fit a model by MAP
#'
#' This function computes a maximum a posteriori estimate by running one or more instances of a numerical optimization procedure to maximize the joint posterior density. If no seed is given, one is automatically generated and stored as an attribute in the returned object. An error is printed if no convergence was achieved after all the runs.
#'
#' @usage optimizing(spec, stanModel = NULL, y, x = NULL, u = NULL, v = NULL, nRuns = 1, keep = "best", nCores = 1, writeDir = tempdir(), ...)
#' @inheritParams sampling
#' @param nRuns An optional integer with the number of initializations.
#' @param keep An optional string specifying whether the function should return the converging instance with the maximum posterior log density (\emph{best}) or all the instances (\emph{all}). The latter may be useful for debugging. It defaults to \emph{best}.
#' @param nCores An optional integer with the number of cores to be used. If equal to one, the instances are run sequentially. Otherwise, doParallel's backend is used for parallel computing. It defaults to one.
#' @param ... Arguments to be passed to rstan's \code{\link[rstan]{optimizing}}.
#' @return An \emph{Optimization} object if \emph{keep} is set to \emph{best}), or an \emph{OptimizationList} otherwise. In the latter case, the best instance can be obtained with \code{\link{extract_best}}.
#' @export
#' @seealso See \code{\link[rstan]{optimizing}} for further details on tunning the optimization procedure.
#' @examples
optimizing        <- function(spec, ...) { UseMethod("optimizing", spec) }

optimizing.Specification <- function(spec, stanModel = NULL, y, x = NULL, u = NULL, v = NULL,
                                     nRuns = 1, keep = "best", nCores = 1,
                                     writeDir = tempdir(), ...) {

  if (!(keep %in% c("best", "all")))
    stop("keep must be either \"best\" or \"all\". See ?optimizing.")

  if (is.null(stanModel))
    stanModel <- compile(spec, priorPredictive = FALSE, writeDir, ...)

  fun <- sprintf("optimizing_%s", keep)
  stanData <- make_data(spec, y, x, u, v)
  stanDots <- c(list(object = stanModel, data = stanData), list(...))
  stanOptimizing <- do.call(fun, list(stanDots = stanDots, nRuns = nRuns, nCores = nCores))
  attr(stanOptimizing, "data")     <- stanData
  attr(stanOptimizing, "filename") <- attr(stanModel, "filename")
  attr(stanOptimizing, "spec")     <- spec

  return(stanOptimizing)
}

#' Run one instance of the
#'
#' @param stanDots The arguments to the passed to rstan's \code{\link[rstan]{optimizing}}.
#' @param n An integer with the number of the instance (i.e. the n-th time the algorithm is run on this model).
#' @return An \emph{Optimization} object.
#' @export
#' @keywords internal
optimizing_run  <- function(stanDots, n) {
  # sink(tempfile())

  stanDots[["seed"]] <-
    if ("seed" %in% names(stanDots)) {
      as.integer(stanDots[["seed"]] + n)
    } else {
      sample.int(.Machine$integer.max, 1)
    }

  sysTime <- system.time({
    stanoptim <- do.call(rstan::optimizing, stanDots)
  })
  attr(stanoptim, "systemTime") <- sysTime
  attr(stanoptim, "seed")       <- stanDots[["seed"]]
  structure(stanoptim, class = c("Optimization", "list"))

  # sink()
}

#' Run several instances of the optimization algorithm.
#'
#' Note that this function returns the results of all the instances while \code{\link{optimizing_best}} only returns the converging instance with highest log posterior density.
#' @param stanDots The arguments to the passed to rstan's \code{\link[rstan]{optimizing}}.
#' @param nRuns An optional integer with the number of initializations.
#' @param nCores An optional integer with the number of cores to be used. If equal to one, the instances are run sequentially. Otherwise, doParallel's backend is used for parallel computing. It defaults to one.
#' @return An \emph{OptimizationList} object.
#' @export
#' @keywords internal
optimizing_all  <- function(stanDots, nRuns, nCores) {
  l <- if (nCores == 1) {
    lapply(seq_len(nRuns), function(n) optimizing_run(stanDots, n))
  } else {
    cl <- parallel::makeCluster(nCores, outfile = "")
    doParallel::registerDoParallel(cl)
    on.exit({parallel::stopCluster(cl)})
    `%dopar%` <- foreach:::`%dopar%`
    foreach::foreach(n = seq_len(nRuns), .combine = c, .packages = c("rstan")) %dopar% {
      optimizing_run(stanDots, n)
    }
  }
  l <- lapply(seq_len(nRuns), function(n) optimizing_run(stanDots, n))
  structure(l, class = c("OptimizationList", "list"))
}

#' Run several instances of the optimization algorithm.
#'
#' Note that this function returns the results of the converging instance with highest log posterior density while \code{\link{optimizing_all}} returns all.
#' @inherit optimizing_all
#' @return An \emph{Optimization} object.
#' @export
#' @keywords internal
optimizing_best <- function(stanDots, nRuns, nCores) {
  best <- optimizing_run(stanDots, n = 1)

  for (n in seq_len(nRuns)[-1]) {
    current <- optimizing_run(stanDots, n)
    if (current$return_code == 0 && current$value > best$value)
      best <- current
  }

  if (best$return_code) # from ?optimizing: Anything != 0 is problematic.
    stop(
      sprintf(
        "After %d runs, none returned a code == 0. First iteration returned %d",
        nRuns, best$return_code
      )
    )

  best
}

# Other methods -----------------------------------------------------------
#' Simulate data from the prior predictive density.
#'
#' @usage sim(spec, T = 1000, x = NULL, u = NULL, v = NULL, nSimulations = 500, ...)
#' @inheritParams sampling
#' @param nSimulations An optional integer with the number of simulations. It defaults to 500 time series.
#' @return
#' @export
#' @examples
sim               <- function(spec, ...) { UseMethod("sim", spec) }

sim.Specification <- function(spec, T = 1000, x = NULL, u = NULL, v = NULL, nSimulations = 500, ...) {
  dots <- list(...)
  dots[["spec"]] <- spec
  dots[["data"]] <- make_data(spec, y = NULL, x, u, v, T)
  dots[["iter"]] <- nSimulations
  do.call(run, dots)
}

# Generic defined and documented in fitIntegration.R
browse_model.Specification <- function(spec) {
  browseURL(write_model(spec, noLogLike = FALSE, writeDir = tempdir()))
}
