require(RGalaxy)
require(optparse)

require(RGalaxy)
require(ggplot2)


#' Title 
#' 
#' Test plaatje met random getallen
#'
#' @param points 
#' @param file 
#'
#' @details 
#'
#' @return
#' @export
#'
#' @examples
#' 
plaatje <- function(points = GalaxyNumericParam(testValues= 100, required=TRUE, label = "Number of Points"),
                     file = GalaxyOutput(format = "png",
                                          basename = "Figure_test")) {
                      
  library(ggplot2)
  dat <- data.frame(x = rnorm(points,10,10),
             y = rnorm(points,10,10))
  
  fig <- ggplot(dat, aes(x = x, y = y, color = x*y)) + geom_point()
  ggsave(file, plot = fig, device = "png")
  
}

# plaatje(points = 100, file = "test.png"

fun_name="plaatje"
source(file.path(Sys.getenv("TOOL_INSTALL_DIR"), "generate_runnable.R"))
