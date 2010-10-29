dens = function(obj)
  {
    dlist = apply(obj, 2, density, na.rm = TRUE)
    names(dlist) = seq_along(dlist)
    ddf = do.call(make.groups, lapply(dlist, function(l) with(l, data.frame(x = x, y = y))))
    return(ddf)
  }

namedEmptyList = function(n) {
  x = vector(mode="list", length = n)
  names(x) = sprintf("aqm_%d", seq(along=x))
  return(x)
}
    
aqm.density = function(x, outliers)
{
  sN = sampleNames(x$expressionset)

  ## For the tooltips
  title = sprintf("Array %d: %s", seq(along=sN), sN)

  if(x$nchannels == 2) {  
    den1 = dens(x$rc)
    den2 = dens(x$gc)
    den3 = dens(x$dat)
    ddf  = rbind(den1, den2, den3)
    panels = factor(rep(1:3, each = c(nrow(den1), nrow(den2), nrow(den3))),
      levels = 1:3,
      labels = c("a. Red Channel", "b. Green Channel", "c. Log2(Ratio)"))
    formula = y ~ x | panels
    lay = c(3,1)

    annotation = namedEmptyList(3*x$numArrays)
    for(i in seq(along=annotation)) {
      s = ((i-1) %% x$numArrays)+1
      annotation[[i]] = list(title = title[s],
                             linkedids = names(annotation)[s+(0:2)*x$numArrays])
    }

  } else {  ## nchannels==1
    ddf = dens(x$dat)
    formula = y ~ x
    lay = c(1,1)

    annotation = namedEmptyList(x$numArrays)
    for(i in seq(along=annotation))
      annotation[[i]] = list(title = title[i],
                             linkedids=names(annotation)[i])
  }

  cl = outlierColours(outliers, n = x$numArrays, withOpacity = TRUE)
  lwd = lty = 1
  
  den = xyplot(formula, ddf, groups = which, layout = lay,
    type = "l", ylab = "Density", xlab="",
    main = if(!is.null(cl$key)) draw.key(key = cl$key),
    strip = function(..., bg) strip.default(..., bg ="#cce6ff"),
    scales = list(relation="free"),
    col = cl$arrayColours, lwd = lwd, lty = lty)
  
  shape = list("h" = 5, "w" = 3+3*lay[1])

  outliertext = if(length(outliers)>0) " Outliers -according to the same criterion as in the boxplots- are highlighted by colour." else ""

  legend = sprintf("The figure <!-- FIG --> shows density estimates (smoothed histograms) of the data. Typically, the distributions of the arrays should have similar shapes and ranges. Arrays whose distributions are very different from the others should be considered for possible problems. Move the mouse over the lines in the plot to see the  corresponding sample names.%s<BR>On raw data, a bimodal distribution can be indicative of an array containing a spatial artefact; a distribution shifted to the right of an array with abnormally high background intensities.", outliertext)
  
  title = "Density plots"
  section = "Array intensity distributions"
  
  new("aqmReportModule",
      "plot"    = den,
      "section" = section,
      "title"   = title,
      "legend"  = legend,
      "shape"   = shape,
      "svg"     = list(annotation=annotation, getfun = aqm.getseries))
}
