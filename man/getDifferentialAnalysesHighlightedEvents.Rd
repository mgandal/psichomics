% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/globalAccess.R
\name{getDifferentialAnalysesHighlightedEvents}
\alias{getDifferentialAnalysesHighlightedEvents}
\title{Get highlighted events from differential analyses of a data category}
\usage{
getDifferentialAnalysesHighlightedEvents(category = getCategory())
}
\arguments{
\item{category}{Character: data category (e.g. "Carcinoma 2016"); by default,
it uses the selected data category}
}
\value{
Integer of indexes relative to a table of differential analyses
}
\description{
Get highlighted events from differential analyses of a data category
}
\note{
Needs to be called inside a reactive function
}
