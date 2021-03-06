% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/optimization.R
\name{extract_grid.Optimization}
\alias{extract_grid.Optimization}
\alias{extract_grid}
\title{Extract summary results from the optimization procedure.}
\usage{
\method{extract_grid}{Optimization}(stanoptim, pars = NULL)
}
\arguments{
\item{stanoptim}{An object returned by \code{\link{optimizing}}.}

\item{pars}{An optional vector of characters with the name of the quantities to be extracted. The characters strings may include regular expressions. Further, wildcards are automatically translated into regex: \emph{?} matches a single character, while \emph{*} matches any string including an empty one. For example, \emph{?pred} will match both ypred and zpred, and \emph{z*} will match zstar and zpred. It defaults to all the parameters.}
}
\value{
A named matrix with one row for each time the optimization procedure was run. Columns include the seed, the estimated log posterior evaluated at the maximum, the code returned by the optimization algorithm, the time elapsed (user, system and total) in seconds, and the estimated value of the parameters selected in
}
\description{
Extract summary results from the optimization procedure.
}
\keyword{internal}
