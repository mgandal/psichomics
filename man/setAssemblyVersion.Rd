% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/globalAccess.R
\name{setAssemblyVersion}
\alias{setAssemblyVersion}
\title{Set the assembly version of a data category}
\usage{
setAssemblyVersion(value, category = getCategory())
}
\arguments{
\item{value}{Character: assembly version}

\item{category}{Character: data category (e.g. "Carcinoma 2016"); by default,
it uses the selected data category}
}
\value{
NULL (this function is used to modify the Shiny session's state)
}
\description{
Set the assembly version of a data category
}
\note{
Needs to be called inside a reactive function
}
