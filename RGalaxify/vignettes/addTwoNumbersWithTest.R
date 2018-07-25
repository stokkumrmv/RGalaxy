#' Add two numbers
#' 
#' A test function to use as an example to create a galaxy tool.
#' It takes two numeric values and returns the sum to a .txt file.
#'
#' @param number1 First numeric value to sum
#' @param number2 Second numeric value to sum
#' @param sum Output file
#' 
#' @details
#' Both arguments are required and contain test values to
#' automatically generate tool tests with.
#' These tests are included in the output .xml tool definition, and
#' can be tested using Planemo's test command.
#'
#' @return The sum of two values
#' @export
#'
#' @examples
#' outfile <- tempfile(pattern = "sum")
#' addTwoNumbersWithTest(5, 5, sum = outfile)
#' readLines(outfile)
addTwoNumbersWithTest <- 
  function(
    number1=GalaxyNumericParam(required=TRUE, testValues = 5),
    number2=GalaxyNumericParam(required=TRUE, testValues = 5),
    sum=GalaxyOutput("sum", "txt"))
  {
    cat(number1 + number2, file=sum)
  }

