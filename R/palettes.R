#' The hiraeth palettes
#'
#' A named list of colour palettes sampled from photographs of places in
#' Wales. Each palette is a character vector of eight hex colours.
#'
#' \describe{
#'   \item{eryri}{Eryri (Snowdonia): slate roof, valley olive, frosted
#'     slopes, bracken in low sun, snow at alpenglow, winter sky and still
#'     llyn. Sampled from a photograph of the Snowdon massif across a lake.}
#'   \item{barafundle}{Barafundle Bay, Pembrokeshire: shaded cliffs, the
#'     ruined stone wall and arch, clifftop grass, dune grass, turquoise
#'     water, bright sky, the sandy path and the beach. Sampled from a
#'     photograph of the bay.}
#'   \item{tenby}{Dinbych-y-pysgod (Tenby): harbour-wall stone, cobalt and
#'     pastel townhouses, Castle Hill green, harbour teal and North Beach sand.
#'     Sampled from a photograph of the harbour.}
#'   \item{rhossili}{Rhossili, Gower, at sunset: heather from shadow to
#'     bloom, the sunlit slope, gorse, the Atlantic, the orange sky and the
#'     gold at the horizon. Sampled from a photograph by Drew Buckley
#'     looking out to Worms Head.}
#'   \item{portmeirion}{Portmeirion: copper beech, the slate dome, the
#'     Piazza lawn, turquoise cupola, terracotta roofs, the orange bell tower,
#'     ochre and pink villas. Sampled from a photograph of the village.}
#' }
#'
#' @export
hiraeth_palettes <- list(
  eryri       = c("#202A2B", "#3F4918", "#6C6546", "#A46721", "#D58C25", "#D2AE93", "#B7BCBA", "#D8D1C1"),
  barafundle  = c("#052B31", "#3B3932", "#8F9748", "#978349", "#2DB8AB", "#17BFD6", "#DFAA73", "#EFCCB1"),
  tenby       = c("#4C353F", "#1C45B5", "#4669AE", "#75A8A2", "#7C9122", "#C36975", "#E0A062", "#F6D0B0"),
  rhossili    = c("#522640", "#7D4965", "#AA708E", "#634D31", "#B78B47", "#8E9DBE", "#F7805B", "#FEE8AC"),
  portmeirion = c("#3B1F1F", "#5A5C54", "#777E1D", "#48BEC4", "#D55229", "#FD9C00", "#E3B57A", "#F1BFA4")
)

#' Get a hiraeth palette
#'
#' @param name Name of the palette. See \code{names(hiraeth_palettes)}.
#' @param n Number of colours wanted. Defaults to all colours in the palette.
#' @param type \code{"discrete"} returns the palette's own colours (and errors
#'   if you ask for more than it has); \code{"continuous"} interpolates
#'   between them to give any number of colours.
#' @param direction \code{1} for the stored order, \code{-1} to reverse.
#'
#' @return A character vector of hex colours with class \code{hiraeth_palette}.
#' @examples
#' hiraeth("eryri")
#' hiraeth("tenby", n = 4)
#' hiraeth("rhossili", n = 50, type = "continuous")
#' @export
hiraeth <- function(name, n, type = c("discrete", "continuous"), direction = 1) {
  type <- match.arg(type)
  pal <- hiraeth_palettes[[name]]
  if (is.null(pal)) {
    stop("Palette '", name, "' not found. Available palettes: ",
         paste(names(hiraeth_palettes), collapse = ", "), call. = FALSE)
  }
  if (!direction %in% c(1, -1)) stop("`direction` must be 1 or -1.", call. = FALSE)
  if (direction == -1) pal <- rev(pal)
  if (missing(n)) n <- length(pal)

  if (type == "discrete" && n > length(pal)) {
    stop("Palette '", name, "' has only ", length(pal), " colours. ",
         "Use type = \"continuous\" to interpolate more.", call. = FALSE)
  }

  out <- switch(type,
    discrete   = pal[seq_len(n)],
    continuous = grDevices::colorRampPalette(pal)(n)
  )
  structure(out, class = "hiraeth_palette", name = name)
}

#' @export
print.hiraeth_palette <- function(x, ...) {
  n <- length(x)
  old <- graphics::par(mar = c(0.5, 0.5, 0.5, 0.5))
  on.exit(graphics::par(old))
  graphics::image(seq_len(n), 1, as.matrix(seq_len(n)), col = x,
                  ylab = "", xaxt = "n", yaxt = "n", bty = "n")
  graphics::rect(0, 0.92, n + 1, 1.08, col = grDevices::rgb(1, 1, 1, 0.8),
                 border = NA)
  graphics::text((n + 1) / 2, 1, labels = attr(x, "name"), cex = 1.5,
                 family = "serif")
  invisible(x)
}

#' Show every hiraeth palette
#'
#' Draws all palettes as labelled swatch strips in the plotting window.
#' @return Invisibly, the list of palettes.
#' @examples
#' display_all()
#' @export
display_all <- function() {
  pals <- hiraeth_palettes
  np <- length(pals)
  old <- graphics::par(mar = c(0.2, 7, 0.2, 0.5))
  on.exit(graphics::par(old))
  graphics::plot(NULL, xlim = c(0, 1), ylim = c(0, np), axes = FALSE,
                 xlab = "", ylab = "")
  for (i in seq_len(np)) {
    cols <- pals[[i]]
    k <- length(cols)
    y <- np - i
    graphics::rect((seq_len(k) - 1) / k, y + 0.1, seq_len(k) / k, y + 0.9,
                   col = cols, border = NA)
  }
  graphics::axis(2, at = rev(seq_len(np)) - 0.5, labels = names(pals),
                 las = 1, tick = FALSE, line = -0.8)
  invisible(pals)
}
