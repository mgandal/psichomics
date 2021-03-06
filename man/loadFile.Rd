% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/formats.R
\name{loadFile}
\alias{loadFile}
\title{Loads a file according to its format}
\usage{
loadFile(format, file)
}
\arguments{
\item{format}{Environment: format of the file}

\item{file}{Character: file to load}
}
\value{
Data frame with the loaded file
}
\description{
Loads a file according to its format
}
\details{
The resulting data frame includes the attribute "tablename" with the
name of the data frame
}
