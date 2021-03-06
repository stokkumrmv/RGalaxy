% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MakeGalaxyTool.R
\name{GetGalaxyTestParams}
\alias{GetGalaxyTestParams}
\title{Get test parameters for function to make into a Galaxy tool}
\usage{
GetGalaxyTestParams(func, functionalTestDirectory = NULL)
}
\arguments{
\item{func}{Function to generate tool of}
}
\value{
List of used functional test parameters.
}
\description{
The functional test needs to know which parameters to pass to the tool.
For this we use the functional tests from the \pkg{RGalaxy} package.
}
\details{
The output can be used to debug the functional test. It will show you
which files are expected to be in the /inst/functionalTests/func folder.
NOTE: DUE TO SOME BUGGY BEHAVIOR IN \pkg{RGalaxy} THE INPUT/OUTPUT FILES DO
NOT HAVE FILE EXTENSIONS!
}
