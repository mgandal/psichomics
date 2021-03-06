% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_firebrowse.R
\name{isFirebrowseUp}
\alias{isFirebrowseUp}
\alias{isFirehoseUp}
\title{Check if the Firebrowse web API is running}
\usage{
isFirebrowseUp()

isFirehoseUp()
}
\value{
Invisible TRUE if the Firebrowse web API is working; otherwise, 
raises a warning
}
\description{
The Firebrowse web API is running if it returns the status condition 200; if
this is not the status code obtained from the API, the function will raise a
warning with the status code and a brief explanation.
}
\examples{
isFirebrowseUp()
}
