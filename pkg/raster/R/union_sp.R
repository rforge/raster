# Author: Robert J. Hijmans
# Date : November 2011
# Version 1.0
# Licence GPL v3

if (!isGeneric("union")) {
	setGeneric("union", function(x, y)
		standardGeneric("union"))
}	


setMethod('union', signature(x='SpatialPolygons', y='SpatialPolygons'), 
function(x, y) {

	x <- spChFIDs(x, as.character(1:length(row.names(x))))
	y <- spChFIDs(y, as.character(1:length(row.names(y))))

	if (! identical(proj4string(x), proj4string(y)) ) {
		warning('non identical CRS')
		y@proj4string <- x@proj4string
	}
	
	subs <- gIntersects(x, y, byid=TRUE)
	
	if (!any(subs)) {
	
		x <- combine(x, y)
		
	} else {
	
		xdata <- .hasSlot(x, 'data')
		ydata <- .hasSlot(y, 'data')
		if (xdata & ydata) {
			nms <- .goodNames(c(colnames(x@data), colnames(y@data)))
			colnames(x@data) <- nms[1:ncol(x@data)]
			colnames(y@data) <- nms[(ncol(x@data)+1):length(nms)]
		} 
		
		dif1 <- erase(x, y)
		dif2 <- erase(y, x)
		x <- intersect(x, y)
		if (!is.null(dif1) | !is.null(dif2)) {
			x <- combine(dif1, x, dif2) 
		} 
		
		# remove slivers
		area <- sapply(x@polygons, function(i) slot(i, 'area'))
		x <- x[area > 0, ]
	}
	x
}
)
