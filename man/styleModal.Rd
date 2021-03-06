% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{styleModal}
\alias{styleModal}
\alias{errorModal}
\alias{warningModal}
\alias{infoModal}
\title{Style and show a modal}
\usage{
styleModal(session, title, ..., style = NULL,
  iconName = "exclamation-circle", footer = NULL, echo = FALSE,
  size = "medium", dismissButton = TRUE)

errorModal(session, title, ..., size = "small", footer = NULL)

warningModal(session, title, ..., size = "small", footer = NULL)

infoModal(session, title, ..., size = "small", footer = NULL)
}
\arguments{
\item{session}{Current Shiny session}

\item{title}{Character: modal title}

\item{...}{Extra arguments to pass to \code{shiny::modalDialog}}

\item{style}{Character: style of the modal (NULL, "warning", "error" or 
"info"; NULL by default)}

\item{iconName}{Character: FontAwesome icon name to appear with the title}

\item{footer}{HTML elements to use in footer}

\item{echo}{Boolean: print to console? FALSE by default}

\item{size}{Character: size of the modal - "medium" (default), "small" or 
"large"}

\item{dismissButton}{Boolean: show dismiss button in footer? TRUE by default}
}
\value{
NULL (this function is used to modify the Shiny session's state)
}
\description{
You can also use \code{errorModal} and \code{warningModal} to use template 
modals already stylised to show errors and warnings, respectively.
}
\seealso{
showAlert
}
