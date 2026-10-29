#' ggplot2 scales for hiraeth palettes
#'
#' Discrete (\code{_d}) scales use the palette's own colours; continuous
#' (\code{_c}) scales interpolate a smooth gradient through them.
#'
#' @param palette Name of a palette in \code{hiraeth_palettes}.
#' @param direction \code{1} or \code{-1} to reverse.
#' @param ... Passed on to \code{ggplot2::discrete_scale()} or
#'   \code{ggplot2::scale_colour_gradientn()} / \code{scale_fill_gradientn()}.
#'
#' @examples
#' library(ggplot2)
#' ggplot(mpg, aes(displ, hwy, colour = class)) +
#'   geom_point(size = 3) +
#'   scale_colour_hiraeth_d("eryri")
#'
#' ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
#'   geom_raster() +
#'   scale_fill_hiraeth_c("rhossili")
#' @name hiraeth_scales
NULL

hiraeth_pal_fun <- function(palette, direction) {
  function(n) {
    pal <- hiraeth_palettes[[palette]]
    if (is.null(pal)) stop("Palette '", palette, "' not found.", call. = FALSE)
    if (n > length(pal)) {
      warning("Palette '", palette, "' has ", length(pal), " colours but ",
              n, " are needed; interpolating.", call. = FALSE)
      return(as.character(hiraeth(palette, n, "continuous", direction)))
    }
    as.character(hiraeth(palette, n, "discrete", direction))
  }
}

#' @rdname hiraeth_scales
#' @export
scale_colour_hiraeth_d <- function(palette = "eryri", direction = 1, ...) {
  ggplot2::discrete_scale(aesthetics = "colour",
                          palette = hiraeth_pal_fun(palette, direction), ...)
}

#' @rdname hiraeth_scales
#' @export
scale_fill_hiraeth_d <- function(palette = "eryri", direction = 1, ...) {
  ggplot2::discrete_scale(aesthetics = "fill",
                          palette = hiraeth_pal_fun(palette, direction), ...)
}

#' @rdname hiraeth_scales
#' @export
scale_colour_hiraeth_c <- function(palette = "rhossili", direction = 1, ...) {
  ggplot2::scale_colour_gradientn(
    colours = hiraeth(palette, 256, "continuous", direction), ...)
}

#' @rdname hiraeth_scales
#' @export
scale_fill_hiraeth_c <- function(palette = "rhossili", direction = 1, ...) {
  ggplot2::scale_fill_gradientn(
    colours = hiraeth(palette, 256, "continuous", direction), ...)
}

#' @rdname hiraeth_scales
#' @export
scale_color_hiraeth_d <- scale_colour_hiraeth_d

#' @rdname hiraeth_scales
#' @export
scale_color_hiraeth_c <- scale_colour_hiraeth_c
