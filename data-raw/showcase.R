# Build the showcase figures for the README.
#
# Run from the package folder after installing hiraeth:
#   install.packages(c("ggplot2", "patchwork"))
#   source("data-raw/showcase.R")
#
# Writes one panel per palette (man/figures/showcase_<palette>.png) and one
# overview comparing all palettes (man/figures/showcase_all.png).

library(ggplot2)
library(patchwork)
library(hiraeth)

dir.create("man/figures", showWarnings = FALSE, recursive = TRUE)

theme_hiraeth_demo <- function() {
  theme_minimal(base_size = 11, base_family = "serif") +
    theme(
      plot.title = element_text(face = "bold", size = 11),
      panel.grid.minor = element_blank(),
      legend.title = element_blank(),
      legend.key.size = unit(0.4, "cm")
    )
}

# A strip of the palette's colours, labelled with hex codes
swatch_plot <- function(palette) {
  cols <- hiraeth_palettes[[palette]]
  df <- data.frame(x = seq_along(cols), col = cols)
  ggplot(df, aes(x, 1, fill = col)) +
    geom_tile(width = 0.96, height = 1) +
    geom_text(aes(y = 0.35, label = col), size = 2.6, family = "mono",
              colour = ifelse(grDevices::col2rgb(cols)[1, ] * 0.299 +
                              grDevices::col2rgb(cols)[2, ] * 0.587 +
                              grDevices::col2rgb(cols)[3, ] * 0.114 > 140,
                              "grey15", "white")) +
    scale_fill_identity() +
    coord_cartesian(expand = FALSE) +
    labs(title = palette) +
    theme_void(base_family = "serif") +
    theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5,
                                    margin = margin(b = 6)))
}

showcase <- function(palette) {
  # 1. Bar chart: number of cars in each class (7 groups)
  p_bar <- ggplot(mpg, aes(class, fill = class)) +
    geom_bar(width = 0.75, show.legend = FALSE) +
    scale_fill_hiraeth_d(palette) +
    labs(title = "Cars by class", x = NULL, y = "Count") +
    theme_hiraeth_demo() +
    theme(axis.text.x = element_text(angle = 35, hjust = 1))

  # 2. Scatter: engine size vs motorway mileage, coloured by drive type
  p_point <- ggplot(mpg, aes(displ, hwy, colour = drv)) +
    geom_point(size = 2.4, alpha = 0.85) +
    scale_colour_hiraeth_d(palette,
                           labels = c("4" = "4WD", f = "Front", r = "Rear")) +
    labs(title = "Engine size vs mileage",
         x = "Displacement (L)", y = "Highway mpg") +
    theme_hiraeth_demo()

  # 3. Density: diamond price by cut quality (5 groups)
  p_dens <- ggplot(diamonds, aes(price, fill = cut)) +
    geom_density(alpha = 0.8, colour = NA, position = "stack") +
    scale_fill_hiraeth_d(palette) +
    scale_x_continuous(labels = function(x) paste0("$", x / 1000, "k")) +
    labs(title = "Diamond price by cut", x = "Price", y = "Density") +
    theme_hiraeth_demo()

  # 4. Continuous: Old Faithful eruption density
  p_raster <- ggplot(faithfuld, aes(waiting, eruptions, fill = density)) +
    geom_raster(interpolate = TRUE) +
    scale_fill_hiraeth_c(palette) +
    coord_cartesian(expand = FALSE) +
    labs(title = "Old Faithful eruptions",
         x = "Waiting time (min)", y = "Eruption (min)") +
    theme_hiraeth_demo() +
    theme(legend.position = "none")

  swatch_plot(palette) /
    ((p_bar | p_point) / (p_dens | p_raster)) +
    plot_layout(heights = c(0.18, 1))
}

for (pal in names(hiraeth_palettes)) {
  ggsave(file.path("man/figures", paste0("showcase_", pal, ".png")),
         showcase(pal), width = 9, height = 8, dpi = 150, bg = "white")
  message("Saved showcase_", pal, ".png")
}

# Overview: the same scatter plot in every palette, side by side
overview <- lapply(names(hiraeth_palettes), function(pal) {
  ggplot(mpg, aes(displ, hwy, colour = class)) +
    geom_point(size = 1.8, alpha = 0.9, show.legend = FALSE) +
    scale_colour_hiraeth_d(pal) +
    labs(title = pal, x = NULL, y = NULL) +
    theme_hiraeth_demo()
})
ggsave("man/figures/showcase_all.png",
       wrap_plots(overview, nrow = 1),
       width = 14, height = 3.2, dpi = 150, bg = "white")
message("Saved showcase_all.png")
