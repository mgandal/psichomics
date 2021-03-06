% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/groups.R
\name{selectGroupsUI}
\alias{selectGroupsUI}
\title{Group selection interface}
\usage{
selectGroupsUI(id, label,
  placeholder = "Click on 'Groups' to create or edit groups",
  noGroupsLabel = NULL, groupsLabel = NULL)
}
\arguments{
\item{id}{Character: identifier of the group selection}

\item{label}{Character: selectize label}

\item{placeholder}{Character: selectize placeholder}

\item{noGroupsLabel}{Character: label to show when no groups may be selected
(if NULL, the option to show no groups will not be shown)}

\item{groupsLabel}{Character: label to show to the option of using groups
when no groups may be selected}
}
\value{
Interface for group selection
}
\description{
Group selection interface
}
\note{
To allow the user to (explicitly) select no groups, pass the 
\code{noGroupsLabel} and \code{groupsLabel} arguments.
}
\seealso{
selectGroupsServer getSelectedGroups
}
