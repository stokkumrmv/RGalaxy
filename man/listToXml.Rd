% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/MakeGalaxyTool.R
\name{listToXml}
\alias{listToXml}
\title{Convert List to XML}
\usage{
listToXml(item, tag = "tool")
}
\arguments{
\item{item}{XML in a list (as returned by \code{\link[XML]{xmlToList}})}

\item{tag}{character value giving xml tag}
}
\value{
xmlNode
}
\description{
Convert List to XML
}
\author{
David LeBauer, Carl Davidson, Rob Kooper


Can convert list or other object to an xml object using xmlNode
}
