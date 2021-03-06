\name{arrayQualityMetrics}
\alias{arrayQualityMetrics}

\title{Quality metrics for microarray experiments}

\description{Produce an array quality metrics report. This is the main function
  of the package.
}

\usage{
arrayQualityMetrics(expressionset,
  outdir = reporttitle,
  force = FALSE,
  do.logtransform = FALSE,
  intgroup = character(0),
  grouprep,
  spatial = TRUE,
  reporttitle = paste("arrayQualityMetrics report for", 
                      deparse(substitute(expressionset))),
  ...)
}

\arguments{
\item{expressionset}{a Bioconductor microarray dataset container. This
    can be an object of
    class \code{\link[Biobase:class.ExpressionSet]{ExpressionSet}},
    \code{\link[affy:AffyBatch-class]{AffyBatch}},
    \code{\link[Biobase:class.NChannelSet]{NChannelSet}},
    \code{\link[beadarray:class-ExpressionSetIllumina]{ExpressionSetIllumina}},
    \code{\link[limma:rglist]{RGList}},
    \code{\link[limma:malist]{MAList}}.}

\item{outdir}{the name of the directory in which the report is
  created; a character of length 1.}

\item{force}{if the directory named by \code{outdir} already exists, then, if \code{force} is
  \code{TRUE}, the directory is overwritten, otherwise an
  error is thrown; if the directory does not exist, the value of
  \code{force} is irrelevant; a logical of length 1.}

\item{do.logtransform}{indicates whether the data should be logarithm transformed before
  the analysis; a logical of length 1.}

\item{intgroup}{the name of the sample covariate(s) used to draw
  a colour side bar next to the heatmap. The first element of
  \code{intgroup} is also used define sample groups in
  other plots (boxplots, densities).
  \code{intgroup} should be a character vector, and its elements need to match the columns
  names of \code{phenoData(expressionset)}. If its length is 0,
  then the plots are not decorated with sample covariate information.}

\item{grouprep}{deprecated. Use argument \code{intgroup} instead.}

\item{spatial}{indicates whether spatial plots
  should be made; a logical of length 1. This can be useful for large arrays (like Affymetrix
  hgu133Plus2) when CPU time and RAM resources of the machine would be limiting. }

\item{reporttitle}{title for the report (character of length 1).}

\item{...}{further arguments that will be passed on to the different
  \code{\link[=aqm.pca]{module functions}}.}
}


\details{
  See the arrayQualityMetrics vignette for examples of this function.
}

\value{
  A side effect of the function is the creation of directory named
  by \code{outdir} containing a HTML report \code{QMreport.html} and
  figures. The function also returns a list with R objects containing
  the report elements for subsequent programmatic processing.  }

\author{
  Audrey Kauffmann and Wolfgang Huber.
}

