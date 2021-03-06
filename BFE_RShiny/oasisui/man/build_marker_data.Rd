% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map.R
\name{build_marker_data}
\alias{build_marker_data}
\title{build_marker_data}
\usage{
build_marker_data(data, session, paramID, step = NULL)
}
\arguments{
\item{data}{dataframe containing location id and coordinates.}

\item{session}{Current session.}

\item{paramID}{Chosen parameter ID.}

\item{step}{Only important if user is in Validation Map. NULL by default.}
}
\value{
dataframe with popup information under "popup".
}
\description{
Builds markers data to be used in a map rendered with leaflet.
}
