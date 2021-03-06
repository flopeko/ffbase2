#' Join ffdf tbls.
#'
#' See \code{\link[dplyr]{join}} for a description of the general purpose of the
#' functions.
#'
#' @inheritParams dplyr::join
#' @param x,y tbls to join
#' @param ... Included for compatibility with generic; otherwise ignored.
#' @examples
#' if (require(Lahman)){
#' data("Batting", package = "Lahman")
#' data("Master", package = "Lahman")
#'
#' batting_ffdf <- tbl_ffdf(Batting)
#' person_ffdf <- tbl_ffdf(Master)
#'
#' # Inner join: match batting and person data
#' inner_join(batting_ffdf, person_ffdf)
#'
#' # Left join: keep batting data even if person missing
#' left_join(batting_ffdf, person_ffdf)
#'
#' # Semi-join: find batting data for top 4 teams, 2010:2012
#' grid <- expand.grid(
#'   teamID = c("WAS", "ATL", "PHI", "NYA"),
#'   yearID = 2010:2012)
#' top4 <- semi_join(batting_ffdf, grid, copy = TRUE)
#'
#' # Anti-join: find batting data with out player data
#' anti_join(batting_ffdf, person_ffdf)
#' }
#' @name join.tbl_ffdf
NULL

#' @export
#' @rdname join.tbl_ffdf
inner_join.ffdf <- function(x , y, by=NULL, copy = FALSE, ...){
  by <- by %||% common_by(x, y)
  if (!length(by)) 
    stop("no common variables")
  
  if (!is.ffdf(y)){
    y <- tbl_ffdf(y)
  }
  res <- NULL
  for (i in chunk(x)){
    x_chunk <- x[i,]
    for (j in chunk(y)){
      res <- append_to(res, inner_join(x_chunk, y[j,], by=by))
    }
  }
  res
}

#' @export
#' @rdname join.tbl_ffdf
left_join.ffdf  <- function(x, y, by=NULL, copy=FALSE, ...){  
  by <- by %||% common_by(x, y)
  if (!length(by)) 
    stop("no common variables")
  
  if (!is.ffdf(y)){
    y <- tbl_ffdf(y)
  }
  res <- NULL
  for (i in chunk(x)){
    x_chunk <- x[i,]
    for (j in chunk(y)){
      res <- append_to(res, left_join(x_chunk, y[j,], by=by))
    }
  }
  res
}

#' @export
#' @rdname join.tbl_ffdf
semi_join.ffdf  <- function(x, y, by=NULL, ...){
  by <- by %||% common_by(x, y)
  if (!length(by))
    stop("no common variables")
  
  if (!is.ffdf(y)){
    y <- tbl_ffdf(y)
  }
  
  res <- NULL
  for (i in chunk(x)){
    x_chunk <- x[i,]
    for (j in chunk(y)){
      res <- append_to(res, semi_join(x_chunk, y[j,], by=by))
    }
  }
  res 
}

#' @export
#' @rdname join.tbl_ffdf
#' @importFrom ff is.ffdf
#' @importFrom bit chunk
anti_join.ffdf <- function(x, y, by=NULL, ...){
  by <- by %||% common_by(x, y)
  if (!length(by))
    stop("no common variables")
  
  if (!is.ffdf(y)){
    y <- tbl_ffdf(y)
  }
  
  res <- NULL
  for (i in chunk(x)){
    x_chunk <- x[i,]
    for (j in chunk(y)){
      x_chunk <- dplyr::anti_join(x_chunk, y[j,], by=by)
      if (nrow(x_chunk) == 0){
        break
      }
    }
    res <- append_to(res, x_chunk, check_structure = FALSE)
  }
  res
}


## testing
# iris_ffdf <- tbl_ffdf(iris)
# left_join(iris_ffdf, iris)
