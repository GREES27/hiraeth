#' Build a palette from a photograph
#'
#' Reads a JPEG or PNG, clusters its pixels with k-means, and returns the
#' cluster centres as hex colours. Use it on your own photos of a place,
#' tweak the result by eye, then paste it into \code{hiraeth_palettes}.
#'
#' @param path Path to a .jpg/.jpeg or .png file.
#' @param n Number of colours to extract (default 6).
#' @param sample_size Pixels sampled before clustering, for speed.
#' @param sort_by How to order the colours: \code{"lightness"} (dark to light),
#'   \code{"hue"}, or \code{"frequency"} (most common first).
#' @param seed Random seed so results are reproducible.
#' @param show If \code{TRUE}, draws the palette.
#'
#' @return A \code{hiraeth_palette} (character vector of hex colours).
#' @examples
#' \dontrun{
#' pal <- hiraeth_extract("photos/llyn_padarn.jpg", n = 7)
#' dput(as.character(pal))   # copy into hiraeth_palettes
#' }
#' @export
hiraeth_extract <- function(path, n = 6, sample_size = 20000,
                            sort_by = c("lightness", "hue", "frequency"),
                            seed = 27, show = TRUE) {
  sort_by <- match.arg(sort_by)
  if (!file.exists(path)) stop("File not found: ", path, call. = FALSE)
  ext <- tolower(tools::file_ext(path))

  img <- switch(ext,
    jpg = , jpeg = {
      if (!requireNamespace("jpeg", quietly = TRUE))
        stop("Install the 'jpeg' package to read JPEGs.", call. = FALSE)
      jpeg::readJPEG(path)
    },
    png = {
      if (!requireNamespace("png", quietly = TRUE))
        stop("Install the 'png' package to read PNGs.", call. = FALSE)
      png::readPNG(path)
    },
    stop("Only .jpg, .jpeg and .png files are supported.", call. = FALSE)
  )

  # Greyscale images come back as a matrix; give them three channels
  if (length(dim(img)) == 2) img <- array(img, c(dim(img), 3))
  px <- cbind(r = as.vector(img[, , 1]),
              g = as.vector(img[, , 2]),
              b = as.vector(img[, , 3]))
  # Drop fully transparent pixels in PNGs with an alpha channel
  if (dim(img)[3] == 4) px <- px[as.vector(img[, , 4]) > 0.5, , drop = FALSE]

  set.seed(seed)
  if (nrow(px) > sample_size) px <- px[sample(nrow(px), sample_size), ]

  # Cluster in CIE Lab so distances match how we see colour
  lab <- grDevices::convertColor(px, from = "sRGB", to = "Lab")
  km <- stats::kmeans(lab, centers = n, nstart = 5, iter.max = 50)
  centres <- km$centers
  rgb_c <- grDevices::convertColor(centres, from = "Lab", to = "sRGB")
  rgb_c <- pmin(pmax(rgb_c, 0), 1)
  cols <- grDevices::rgb(rgb_c[, 1], rgb_c[, 2], rgb_c[, 3])

  idx <- switch(sort_by,
    lightness = order(centres[, 1]),
    hue       = order(atan2(centres[, 3], centres[, 2])),
    frequency = order(-km$size)
  )
  pal <- structure(cols[idx], class = "hiraeth_palette",
                   name = tools::file_path_sans_ext(basename(path)))
  if (show) print(pal)
  pal
}
