#' Extract summary results from the optimization procedure.
#'
#' @name extract_grid
#' @keywords internal
#' @param pars An optional vector of characters with the name of the quantities to be extracted. The characters strings may include regular expressions. Further, wildcards are automatically translated into regex: \emph{?} matches a single character, while \emph{*} matches any string including an empty one. For example, \emph{?pred} will match both ypred and zpred, and \emph{z*} will match zstar and zpred. It defaults to all the parameters.
#' @return A named matrix with one row for each time the optimization procedure was run. Columns include the seed, the estimated log posterior evaluated at the maximum, the code returned by the optimization algorithm, the time elapsed (user, system and total) in seconds, and the estimated value of the parameters selected in
#' @export
#' @examples
extract_grid     <- function(x, ...) { UseMethod("extract_grid", x) }

#' Extract summary results from the optimization procedure.
#'
#' @keywords internal
#' @aliases extract_grid
#' @inherit extract_grid
#' @param stanoptim An object returned by \code{\link{optimizing}}.
#' @export
#' @examples
extract_grid.Optimization <- function(stanoptim, pars = NULL) {
  if (is.null(pars)) { pars <- "" }

  unlist(
    c(
      seed         = extract_seed(stanoptim),
      logPosterior = stanoptim$value,
      returnCode   = stanoptim$return_code,
      extract_time(stanoptim)[1:3],
      extract_quantity(stanoptim, pars = pars, combine = c)
    )
  )
}

# plot.Optimization <- function(stanoptim, pars, ...) {
#   dotchart(
#     x = rev(extract_quantity(stanoptim, pars, combine = c)), ...
#   )
# }
#
# print.Optimization <- function(stanoptim, pars = NULL) {
#   print(extract_quantity(stanoptim, pars))
# }

#' Verify that the object was created by \code{\link{optimizing}}.
#'
#' @keywords internal
#' @param x An object.
#' @return TRUE if it is an object created by \code{\link{optimizing}}.
#' @examples
is.stanoptim <- function(x) {
  is.list(x) & all(c("par", "value", "return_code") %in% names(x))
}
