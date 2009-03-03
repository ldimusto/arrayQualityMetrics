##meanSdplot
aqm.meansd = function(dataprep, ...)
  {
    msdplo = meanSdPlot(dataprep$dat, cex.axis = 0.9, ylab = "Standard deviation of the intensities", xlab="Rank(mean of intensities)", plot = FALSE, ...)

    legsdspe = if(dataprep$classori == "BeadLevelList") "For each bead type obtained by createBeadSummaryData from the package beadarray," else "For each feature,"    
    legend = sprintf("%s the figure <!-- FIG --> shows the standard deviation of the intensities across arrays on the <i>y</i>-axis versus the rank of their mean on the <i>x</i>-axis. The red dots, connected by lines, show the running median of the standard deviation. After normalization and transformation to a logarithm(-like) scale, one typically expects the red line to be approximately horizontal, that is, show no substantial trend. In some cases, a hump on the right hand of the x-axis can be observed and is symptomatic of a saturation of the intensities.", legsdspe)

    title = "Standard deviation versus rank of the mean"
    section = "Variance mean dependence"
    msd = list("plot" = dataprep$dat, "section" = section, "title" = title, "legend" = legend, "shape" = "square")
    class(msd) = "aqmobj.msd"
    return(msd)   
  }