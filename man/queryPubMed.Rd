% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/analysis_information.R
\name{queryPubMed}
\alias{queryPubMed}
\title{Query the PubMed REST API}
\usage{
queryPubMed(primary, ..., top = 3, field = "abstract", sort = "relevance")
}
\arguments{
\item{primary}{Character: primary search term}

\item{...}{Character: other relevant search terms}

\item{top}{Numeric: number of articles to retrieve (3 by default)}

\item{field}{Character: field of interest where to look for terms ("abstract"
by default)}

\item{sort}{Character: sort by a given parameter ("relevance" by default)}
}
\value{
Parsed response
}
\description{
Query the PubMed REST API
}
\examples{
psichomics:::queryPubMed("BRCA1", "cancer", "adrenocortical carcinoma")
}
