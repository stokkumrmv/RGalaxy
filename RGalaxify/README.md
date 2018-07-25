Creating Galaxy tools from R scripts
================
Lodewic van Twillert
13 June 2018

RGalaxify
=========

This repository contains an R package called `RGalaxify` that is used to generate Galaxy tools from R functions directly. Most of the credit should go to the creators of the [RGalaxy](https://bioconductor.org/packages/release/bioc/html/RGalaxy.html) package, since we built on their work and edited it fit our needs.

Installation
------------

Pull the repository locally and install from there. (You'll need to have your Git setup configured correctly first to connect in the first place.)

### Pull repository

You could `git clone` your repository, although this has not worked for me with GitLab. I run into authentication errors and rather do it by initializing a new local repository and pulling data from GitLab.

Assuming you're using Git bash on Windows, open Git bash and create a RGalaxify folder wherever you want to initialize the git repository.

I recommend making a folder `C:\Users\yourusername\...\RGalaxify` for this package.

``` r
cd existing_folder
git init
git remote add origin https://:@gitlab-dv.tno.nl:443/DataScience-MSB/GalaxyProjects/RGalaxify.git
git pull
```

Now you can look at `docs/index.html` locally to find function documentation and an example vignette going over the use of this package.

What does it do?
================

What it achieves
----------------

Let's assume you have a script, containing a function definition that you want to make available as a Galaxy tool. To create a Galaxy tool you need,

-   A valid R script that you can run from the command line to run your function
-   A Galaxy tool definition in XML format

The R script should be able to parse command line options, which many of us don't routinely do.

Once you have a valid R script that you can call from a command line, you'll need a Galaxy tool definition file. This is an .xml file that defines all the inputs outputs, tool descriptions, options, etc.

What this package achieves is that we can

**Create a valid R script and .xml tool definition from a single R function.**

What it requires of you
-----------------------

You will have to stick to some formatting requirements of your function.

Let's say you have a simple function, `addTwoNumbers`.

``` r
addTwoNumbers <- function(number1, number2) {
  number1 + number2
  }
```

We need two steps to rewrite this function into a valid function to galaxify.

-   Use [Galaxy Parameter Classes](https://rdrr.io/bioc/RGalaxy/man/GalaxyClasses.html) to define input/output parameter options
-   Change function to output a file instead of a variable
-   Add documentation to the function

### Galaxy Parameter Classes

[Galaxy Parameter Classes](https://rdrr.io/bioc/RGalaxy/man/GalaxyClasses.html) can be one of the following,

-   `GalaxyIntegerParam(...)`
-   `GalaxyNumericParam(...)`
-   `GalaxyCharacterParam(...)`
-   `GalaxyLogicalParam(...)`
-   `GalaxySelectParam(...)`

Or for **output**, the `GalaxyOutput(basename, format)` function.

Replace ALL parameters to your function with these and take a careful look at the possible options.

Let's change the function definition to use Galaxy Parameters, and write the output to a file rather than returning a variable.

``` r
addTwoNumbers <- 
  function(
    number1=GalaxyNumericParam(required=TRUE),
    number2=GalaxyNumericParam(required=TRUE),
    sum=GalaxyOutput("sum", "txt"))
  {
    cat(number1 + number2, file=sum)
  }
```

Great! And remember, if you've read the `RGalaxy` vignette, you can still call this function as you normally would.

``` r
outfile <- tempfile()
addTwoNumbers(5, 5, outfile)
readLines(outfile)
```

    ## [1] "10"

### Add some documentation

This function lacks a function description. We use the power of `roxygen2` to create documentation, normally used for package documentation. [Learn more about roxygen2 and package documentation here](http://kbroman.org/pkg_primer/pages/docs.html).

``` r
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
    number1=GalaxyNumericParam(required=TRUE),
    number2=GalaxyNumericParam(required=TRUE),
    sum=GalaxyOutput("sum", "txt"))
  {
    cat(number1 + number2, file=sum)
  }
```

And now, you're finished! This function can be transformed into a valid Galaxy tool.

(Single function to generate a tool under contstruction...:)

Examples
--------

For more examples to get started, look at the `docs/index.html` file or find the vignette in `vignettes/`.

RGalaxy difference
------------------

RGalaxy also creates Galaxy tools from R scripts, but the output tools are not immediately fit to publish and host on any Galaxy instance. For one,

-   RGalaxy expects functions to be part of a publically available package
-   RGalaxy uses a local Galaxy instance

This works well because all you'd have to do is load the function from an existing package and write a wrapper function that loads the library and then calls the relevant function. However, we often want to write our own tools and functions that we can publish as a Galaxy tool.

In our case,

-   RGalaxify uses any custom function to generate a valid Galaxy tool
-   You can `lint` and `test` the output with [Planemo](http://planemo.readthedocs.io/en/latest/writing.html)

This means we will have to deal with dependencies differently. Also, we do not need a lot of the functionality that RGalaxy offers, such as using `RServe` to serve computationally heavy tasks to a separate R instance.
