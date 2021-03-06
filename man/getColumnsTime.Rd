% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis.R
\name{getColumnsTime}
\alias{getColumnsTime}
\title{Retrieve the time for given columns in a clinical dataset}
\usage{
getColumnsTime(clinical, event, timeStart, timeStop = NULL,
  followup = "days_to_last_followup")
}
\arguments{
\item{clinical}{Data frame: clinical data}

\item{event}{Character: name of column containing time of the event of
interest}

\item{timeStart}{Character: name of column containing starting time of the
interval or follow up time}

\item{timeStop}{Character: name of column containing ending time of the 
interval}

\item{followup}{Character: name of column containing follow up time}
}
\value{
Data frame containing the time for the given columns
}
\description{
Retrieve the time for given columns in a clinical dataset
}
