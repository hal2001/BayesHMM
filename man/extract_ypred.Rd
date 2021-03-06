% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract.R, R/fit.R
\name{extract_ypred}
\alias{extract_ypred}
\title{Extract the sample of the observation variable drawn from the posterior predictive density (ypred).}
\usage{
extract_ypred(fit, ...)

extract_ypred(fit, ...)
}
\arguments{
\item{fit}{An object returned by either \code{\link{sampling}} or \code{\link{optimizing}}.}
}
\value{
A numeric array with four dimensions [N, M, T, R]: number of iterations \emph{N}, number of chains \emph{M}, length of the time series {T}, the dimension of the observation vector \emph{R}. If the argument \emph{chain} was set, the chain dimension is dropped and the function returns a three-dimensional numeric array [N, T, R]. If the argument \emph{reduce} was set to a function returning a vector of size \emph{n}, the returned array has dimension [n, M, T, R]. When \emph{n} is simply one (e.g. \code{\link{median}}), the number-of-iterations dimension is dropped and the function returns a three-dimensional numeric array [M, T, R].

A numeric array with four dimensions [N, M, T, R]: number of iterations \emph{N}, number of chains \emph{M}, length of the time series {T}, the dimension of the observation vector \emph{R}. If the argument \emph{chain} was set, the chain dimension is dropped and the function returns a three-dimensional numeric array [N, T, R]. If the argument \emph{reduce} was set to a function returning a vector of size \emph{n}, the returned array has dimension [n, M, T, R]. When \emph{n} is simply one (e.g. \code{\link{median}}), the number-of-iterations dimension is dropped and the function returns a three-dimensional numeric array [M, T, R].
}
\description{
Extract the sample of the observation variable drawn from the posterior predictive density (ypred).

Extract the sample of the observation variable drawn from the posterior predictive density (ypred).
}
\seealso{
Other extract: \code{\link{extract_K}},
  \code{\link{extract_R}}, \code{\link{extract_T}},
  \code{\link{extract_alpha}}, \code{\link{extract_data}},
  \code{\link{extract_filename}},
  \code{\link{extract_gamma}},
  \code{\link{extract_obs_parameters}},
  \code{\link{extract_parameters}},
  \code{\link{extract_spec}}, \code{\link{extract_ysim}},
  \code{\link{extract_y}}, \code{\link{extract_zpred}},
  \code{\link{extract_zstar}}, \code{\link{extract}}

Other extract: \code{\link{extract_K}},
  \code{\link{extract_R}}, \code{\link{extract_T}},
  \code{\link{extract_alpha}}, \code{\link{extract_data}},
  \code{\link{extract_filename}},
  \code{\link{extract_gamma}},
  \code{\link{extract_obs_parameters}},
  \code{\link{extract_parameters}},
  \code{\link{extract_spec}}, \code{\link{extract_ysim}},
  \code{\link{extract_y}}, \code{\link{extract_zpred}},
  \code{\link{extract_zstar}}, \code{\link{extract}}
}
\concept{extract}
