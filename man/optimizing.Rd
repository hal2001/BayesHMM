% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/specification.R
\name{optimizing}
\alias{optimizing}
\title{Fit a model by MAP}
\usage{
optimizing(spec, stanModel = NULL, y, x = NULL, u = NULL, v = NULL, nRuns = 1, keep = "best", nCores = 1, writeDir = tempdir(), ...)
}
\arguments{
\item{spec}{An object returned by either \code{\link{specify}} or \code{\link{hmm}}.}

\item{...}{Arguments to be passed to rstan's \code{\link[rstan]{optimizing}}.}

\item{nRuns}{An optional integer with the number of initializations.}

\item{keep}{An optional string specifying whether the function should return the converging instance with the maximum posterior log density (\emph{best}) or all the instances (\emph{all}). The latter may be useful for debugging. It defaults to \emph{best}.}

\item{nCores}{An optional integer with the number of cores to be used. If equal to one, the instances are run sequentially. Otherwise, doParallel's backend is used for parallel computing. It defaults to one.}
}
\value{
An \emph{Optimization} object if \emph{keep} is set to \emph{best}), or an \emph{OptimizationList} otherwise. In the latter case, the best instance can be obtained with \code{\link{extract_best}}.
}
\description{
This function computes a maximum a posteriori estimate by running one or more instances of a numerical optimization procedure to maximize the joint posterior density. If no seed is given, one is automatically generated and stored as an attribute in the returned object. An error is printed if no convergence was achieved after all the runs.
}
\seealso{
See \code{\link[rstan]{optimizing}} for further details on tunning the optimization procedure.
}
