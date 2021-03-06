% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/API_utils.R
\name{APIgetenv}
\alias{APIgetenv}
\title{Get API env vars}
\usage{
APIgetenv(...)
}
\arguments{
\item{...}{Names of environment variables. If passed as named arguments, the
returned list will retain the same names.}
}
\value{
List of environment variables' values.
}
\description{
Fetches values of environment variables and combines them conveniently in a
list.
}
