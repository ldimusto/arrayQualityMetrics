## Spatial plot representation
spatialplot = function(expressionset, dataprep, channel, label, scale, imageMat = NULL)
  {
    noaxis = function (...) 
      {     
        tick="no"
      }                        
    
    colourRamp = colorRampPalette(rgb(seq(0,1,l=256),seq(0,1,l=256),seq(1,0,l=256)))
    if(dataprep$classori == "ExpressionSet" || dataprep$classori == "NChannelSet")
      {
        r = featureData(expressionset)$X
        c = featureData(expressionset)$Y
      }
    if(dataprep$classori == "AffyBatch")
      {
        maxc = ncol(expressionset)
        maxr = nrow(expressionset)

        r = rep(seq_len(maxr), maxc)
        c = rep(seq_len(maxc), each = maxr)
      }
    if(dataprep$classori == "BeadLevelList")
      {        
        maxc = ncol(imageMat[[1]])
        maxr = nrow(imageMat[[1]])
        
        r = rep(seq_len(maxr), maxc)
        c = rep(seq_len(maxc), each = maxr)
      }
    
      if(dataprep$classori == "BeadLevelList")
        {
          if(scale == "Rank")
            imageMat = lapply(seq_len(dataprep$numArrays), function(i) rank(imageMat[[i]], na.last = "keep"))         
          df = data.frame("Array" = rep(seq_len(dataprep$numArrays), each=maxr*maxc), "ch" = unlist(imageMat), "row" = r, "column" = c)
        }

      if(dataprep$classori != "BeadLevelList")
        {
          df = switch(scale,
            "Rank" = data.frame("Array" = as.factor(col(dataprep$dat)), "ch" = unlist(lapply(seq_len(dataprep$numArrays), function(i) rank(channel[,i]))), "row" = r,  "column" = c),
            "Log" = data.frame("Array" = as.factor(col(dataprep$dat)),  "ch" = unlist(lapply(seq_len(dataprep$numArrays), function(i) channel[,i])), "row" = r,  "column" = c))
        }
    
    levelplot(ch ~ column*row | Array, data=df, axis = noaxis, asp = "iso", col.regions = colourRamp, as.table=TRUE, strip = function(..., bg) strip.default(..., bg ="#cce6ff"), xlab = label, ylab = "")
  }

## Scores computation
scoresspat = function(expressionset, dataprep, ch)
  {
    if(dataprep$classori == "BeadLevelList")
      stop("Cannot apply scoresspat to BeadLevelList objects. Please use scoresspatbll instead.")
    if(dataprep$classori != "AffyBatch")
      {
        maxr = max(featureData(expressionset)$X)
        maxc = max(featureData(expressionset)$Y)
      }
    if(dataprep$classori == "AffyBatch")
      {
        maxr = nrow(expressionset)
        maxc = ncol(expressionset)
      }
    
    mdat = lapply(seq_len(dataprep$numArrays), function(x) matrix(ch[,x],ncol=maxc,nrow=maxr,byrow=T))
    loc = sapply(mdat, function(x) {
      apg = abs(fft(x)) ## absolute values of the periodogram
      lowFreq = apg[1:4, 1:4]
      lowFreq[1,1] = 0                  # drop the constant component
      highFreq = c(apg[-(1:4), ], apg[1:4, -(1:4)])
      return(sum(lowFreq)/sum(highFreq))
    })
    return(loc)
  }


scoresspatbll = function(expressionset, dataprep, log)
{
  if(dataprep$classori == "BeadLevelList")
  {        
    imageMatg = lapply(seq_len(dataprep$numArrays), function(i) imageplotBLL(expressionset, array = i, whatToPlot="G", log = log))
    if(expressionset@arrayInfo$channels == "two")
      imageMatr = lapply(seq_len(dataprep$numArrays), function(i) imageplotBLL(expressionset, array = i, whatToPlot="Rb", log = log))
    
    locr = sapply(imageMatr, function(x) {
      x[x == "NaN"] = 0
      apg = abs(fft(x)) ## absolute values of the periodogram
      lowFreq = apg[1:4, 1:4]
      lowFreq[1,1] = 0  # drop the constant component
      highFreq = c(apg[-(1:4), ], apg[1:4, -(1:4)])
      return(sum(lowFreq)/sum(highFreq))
    })
     locg = sapply(imageMatg, function(x) {
      x[x == "NaN"] = 0
      apg = abs(fft(x)) ## absolute values of the periodogram
      lowFreq = apg[1:4, 1:4]
      lowFreq[1,1] = 0  # drop the constant component
      highFreq = c(apg[-(1:4), ], apg[1:4, -(1:4)])
      return(sum(lowFreq)/sum(highFreq))
    })
    loc = list("Red" = locr, "Green" = locg)
    return(list(locr, locg))
  }
}

## set Generics  
setGeneric("spatialbg",
           function(expressionset, dataprep, scale)
           standardGeneric("spatialbg"))
setGeneric("spatial",
           function(expressionset, dataprep, scale)
           standardGeneric("spatial"))

## NCS
##Background rank representation
setMethod("spatialbg",signature(expressionset = "NChannelSet"), function(expressionset, dataprep, scale)
          {
            sprb = spatialplot(expressionset, dataprep,dataprep$rcb, paste(scale,"(red background intensity)"), scale)
            spgb = spatialplot(expressionset, dataprep,dataprep$gcb, paste(scale,"(green background intensity)"), scale)
            return(list(sprb, spgb))
          })
            
## NCS
##Foreground rank representation
setMethod("spatial",signature(expressionset = "NChannelSet"), function(expressionset, dataprep, scale)
          {
            spr = spatialplot(expressionset, dataprep,dataprep$rc, paste(scale,"(red intensity)"), scale)
            spg = spatialplot(expressionset, dataprep,dataprep$gc, paste(scale,"(green intensity)"), scale)
            splr = spatialplot(expressionset, dataprep,dataprep$dat, paste(scale,"(ratio)"), scale)
            return(list(spr, spg, splr))
          })
              
## ES-AB
## Foreground rank representation
setMethod("spatial",signature(expressionset = "aqmOneCol"), function(expressionset, dataprep, scale)
          {
            lgl = switch(scale,
              "Rank" = "Rank(intensity)",
              "Log" = "Log(intensity)")
            spi = spatialplot(expressionset, dataprep,dataprep$dat, lgl, scale)
            return(spi)
          })
            
##BeadLeveList plot modified from beadarry package
imageplotBLL = function(BLData, array = 1, nrow = 100, ncol = 100,
                     whatToPlot ="G", log=TRUE, zlim=NULL, method="illumina",
                     n = 3, trim=0.05, ...){

  whatToPlot = match.arg(whatToPlot, choices=c("G", "Gb", "R", "Rb", "wtsG", "wtsR", "residG", "residR", "M", "residM", "A", "beta"))
  if((whatToPlot=="R" | whatToPlot=="residR" | whatToPlot=="M" | whatToPlot=="residM" | whatToPlot=="A" | whatToPlot=="beta") & BLData@arrayInfo$channels!="two")
    stop(paste("Need two-channel data to plot", whatToPlot, "values"))
                                          
  data = getArrayData(BLData, what=whatToPlot, array=array, log=log, method=method, n=n, trim=trim) 
  ind = is.na(data) | is.infinite(data)
  if(sum(ind)>0) {
    cat(paste("Warning:", sum(ind), "NA, NaN or Inf values, which will be ignored.\nCheck your data or try setting log=\"FALSE\"\n"))
    data = data[!ind]
  }

  xs = floor(BLData[[array]]$GrnX[!ind])
  ys = floor(BLData[[array]]$GrnY[!ind])
  rm(ind)

  xgrid = floor(seq(0, max(xs), by = max(xs)/ncol))
  ygrid = floor(seq(0, max(ys), by = max(ys)/nrow))

  imageMatrix = matrix(ncol = ncol, nrow = nrow)
  zr = NULL
  for(i in seq_len(ncol)){
    idx = which((xs > xgrid[i]) & (xs < xgrid[i+1]))
    if(length(idx)>0) {
      fground = data[idx]
      yvalues = ys[idx]

      out = .C("BLImagePlot", length(fground), as.double(fground), as.double(yvalues), as.integer(ygrid),
        result = double(length = nrow), as.integer(nrow), PACKAGE = "beadarray")
      zr[1] = min(zr[1], out$result[!is.na(out$result)], na.rm=TRUE)
      zr[2] = max(zr[2], out$result[!is.na(out$result)], na.rm=TRUE)
      if(!is.null(zlim)) {
        out$result[!is.na(out$result)] = pmax(zlim[1], out$result[!is.na(out$result)], na.rm=TRUE)
        out$result[!is.na(out$result)] = pmin(zlim[2], out$result[!is.na(out$result)], na.rm=TRUE)
      }
      imageMatrix[,i] = rev(out$result)
    }
  }
  return(imageMatrix)
}

## BLL
setMethod("spatialbg",signature(expressionset = "BeadLevelList"), function(expressionset, dataprep, scale)
          {
            imageMatgb = lapply(seq_len(dataprep$numArrays), function(i) imageplotBLL(expressionset, array = i, whatToPlot="Gb", log = dataprep$logtransformed))
            if(expressionset@arrayInfo$channels == "two")
              imageMatrb = lapply(seq_len(dataprep$numArrays), function(i) imageplotBLL(expressionset, array = i, whatToPlot="Rb", log = dataprep$logtransformed))
            
            spgb = spatialplot(expressionset, dataprep,dataprep$gcb, paste(scale, "(green background intensity)"), scale, imageMatgb)
            sprb = NULL
            if(expressionset@arrayInfo$channels == "two")
              sprb = spatialplot(expressionset, dataprep,dataprep$rcb, paste(scale, "(red background intensity)"), scale,  imageMatrb)
            
            return(list(sprb, spgb))
          })
            
setMethod("spatial",signature(expressionset = "BeadLevelList"), function(expressionset, dataprep, scale)
          {
            imageMatg = lapply(seq_len(dataprep$numArrays), function(i) imageplotBLL(expressionset, array = i, whatToPlot="G", log = dataprep$logtransformed))
            if(expressionset@arrayInfo$channels == "two")
              imageMatr = lapply(seq_len(dataprep$numArrays), function(i) imageplotBLL(expressionset, array = i, whatToPlot="R", log = dataprep$logtransformed))
            
            spg = spatialplot(expressionset, dataprep,dataprep$gc, paste(scale, "(green intensity)"), scale, imageMatg)
            spr = NULL
            if(expressionset@arrayInfo$channels == "two")
              spr = spatialplot(expressionset, dataprep,dataprep$rc, paste(scale, "(red intensity)"), scale, imageMatr)
            
            return(list(spr, spg))
          })

## BACKGROUND
aqm.spatialbg = function(expressionset, dataprep, scale)
{
  if(scale != "Log" && scale != "Rank")
    stop("The argument scale must be 'Log' or 'Rank'\n")

  bg = spatialbg(expressionset, dataprep, scale)
  
  title = "Spatial distribution of local background intensities"
  section = "Individual array quality"
  
  legend = sprintf("The figure <!-- FIG --> shows false color representations of the arrays' spatial distributions of feature local background estimates. The color scale is shown in the panel on the right, and it is proportional to the ranks of the probe background intensities.")

  out = list("plot" = bg, "section" = section, "title" = title, "legend" = legend, "shape" = "square")
  class(out) = "aqmobj.spatialbg"
  return(out)
}

## FOREGROUND
aqm.spatial = function(expressionset, dataprep, scale)
{
  if(scale != "Log" && scale != "Rank")
    stop("The argument scale must be 'Log' or 'Rank'\n")

  fore = spatial(expressionset, dataprep, scale)
  
  title = "Spatial distribution of feature intensities"
  section = "Individual array quality"

  legend = sprintf("The figure <!-- FIG --> shows false color representations of the arrays' spatial distributions of feature intensities. The color scale is shown in the panel on the right, and it is proportional to the ranks of the probe intensities. Normally, when the features are distributed randomly on the arrays, one expects to see a uniform distribution; sets of control features with particularily high or low intensities may stand out. Note that the rank scale has the potential to amplify patterns that are small in amplitude but systematic within an array. It is possible to create plots that are not in rank scale but log-transformed scale, calling the aqm.spatial function and modifying the argument 'scale'.")          

  if(!inherits(expressionset, "BeadLevelList"))
    loc = scoresspat(expressionset, dataprep, dataprep$dat)
  
  if(inherits(expressionset, "NChannelSet"))
    {
      locr = scoresspat(expressionset, dataprep, dataprep$rc)
      locg = scoresspat(expressionset, dataprep, dataprep$gc)
      loc = list("LogRatio"=loc, "Red"=locr, "Green"=locg)
    }
 
  if(inherits(expressionset, "BeadLevelList"))
    loc = scoresspatbll(expressionset, dataprep, dataprep$logtransformed)

  if(is(loc,"numeric"))
    {
      locstat = boxplot.stats(loc)
      locout = sapply(seq_len(length(locstat$out)), function(x) which(loc == locstat$out[x]))
    }
 
  if(is(loc,"list"))
    {
      locstat = lapply(seq_len(length(loc)), function(i) boxplot.stats(loc[[i]]))
      locout = lapply(seq_len(length(loc)), function(j) sapply(seq_len(length(locstat[[j]]$out)), function(x) which(loc[[j]] == locstat[[j]]$out[x])))
      names(locout) = if(length(locout) == 3) c("LR","Red","Green") else c("Red","Green")
    }

  out = list("plot" = fore, "section" = section, "title" = title, "legend" = legend, "scores" = loc, "outliers" = locout, "shape" = "square")
  class(out) = "aqmobj.spatial"
  return(out)
}