% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_caseCounts.R
\name{create_caseCounts}
\alias{create_caseCounts}
\title{Create a Case Counts Data Frame}
\usage{
create_caseCounts(date_vec, location_vec, cases_vec)
}
\arguments{
\item{date_vec}{A vector of dates corresponding to case reports; must be of type Date.}

\item{location_vec}{A character vector representing the location of the case reports;
all entries must refer to the same location.}

\item{cases_vec}{A numeric vector representing the number of cases reported on each date;
values must be non-negative integers.}
}
\value{
A data frame named \code{caseCounts} with columns \code{date}, \code{cases}, and \code{location}.
Each row corresponds to a unique report of cases on a given date at a specified location.
The data frame is assigned a class attribute of \code{caseCounts}.
}
\description{
This function constructs a data frame from vectors representing dates, locations,
and case numbers, ensuring that all input vectors meet specific data integrity
requirements. It checks for the correct data types, non-negative case numbers,
and uniformity in vector lengths. The function also ensures no missing values are
present and that all data pertain to a single location.
}
\details{
The function performs several checks to ensure the integrity of the input:
- It verifies that all vectors have the same length.
- It confirms that there are no negative numbers in \code{cases_vec}.
- It checks for and disallows any missing values in the data frame.
It throws errors if any of these conditions are not met, indicating that
the input vectors are not appropriately formatted or contain invalid data.
}
\examples{
data("sample_dates")
data("sample_location")
data("sample_cases")
case_Counts = create_caseCounts(sample_dates, sample_location, sample_cases)
}
