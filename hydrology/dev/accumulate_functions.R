#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################

#function to accumulate runoff
accum.runoff = function(gt,cois) { 
	require(igraph)
	out=NULL #define the output
	while(length(E(gt))>0) { #loop until all edges are dealt with
		vois = which(degree(gt,mode="in")==0) #get index of the headwater vertices
		suppressWarnings({ 
			tt = do.call("rbind", neighborhood(gt,1,V(gt)[vois],"out")) #get the index of the from & to nodes for each edge in a list
		})
		v.from.to = NULL; for (ii in 2:ncol(tt)) v.from.to = rbind(v.from.to,tt[,c(1,ii)]) #flatten the list to a matrix and setup for next cleaning
		v.from.to = rbind(v.from.to,v.from.to) #allow for duplicate from-to nodes with separate SegmentNo
		if (is.null(dim(v.from.to))) v.from.to = matrix(v.from.to,ncol=2) #ensure v.from.to is a matrix
		eois = get.edge.ids(gt,t(cbind(V(gt)[v.from.to[,1]],V(gt)[v.from.to[,2]])),multi=TRUE) #get an index of the output edges from that vertex
		eois = unique(eois); if (0 %in% eois) eois = eois[-which(eois==0)] #only keep unique eois
		tout=E(gt)$HydroID[eois] #prepare empty df to store attributes		
		for (coi in cois){ tt=get.edge.attribute(gt,coi,eois); tout=cbind(tout,tt)} #store the attribute for the selected edges for each of the columns to be accumulated
		colnames(tout)=c('HydroID',cois) #name the columns	
		out = rbind(out,tout) #store the attribute for the current edges
		
		suppressWarnings({ 
			tt = cbind(eois, do.call("rbind", neighborhood(gt,1,V(gt)[v.from.to[,2]],"out"))) #get the next down verticies from the current edges
		})
		if ((length(dim(tt))<1 & length(tt)>2) | (length(dim(tt))>0 & ncol(tt)>2)) { #only do this if there is something down stream	
			next_edge = NULL; for (ii in 3:ncol(tt)) next_edge = rbind(next_edge,tt[,c(1,2,ii)]) #flatten the list to a matrix and setup for next cleaning
			if (is.null(dim(next_edge))) next_edge = matrix(next_edge,ncol=3) #ensure v.from.to is a matrix
			if(nrow(unique(next_edge[,2:3]))==nrow(unique(next_edge))) {
				next_edge = cbind(next_edge,get.edge.ids(gt,t(cbind(V(gt)[next_edge[,2]],V(gt)[next_edge[,3]])),multi=TRUE)) #get an index of the next down edges
				}else{
				next_edge = cbind(next_edge,get.edge.ids(gt,t(cbind(V(gt)[next_edge[,2]],V(gt)[next_edge[,3]]))))} #get an index of the next down edges
			next_edge=unique(next_edge);
			next_edge=next_edge[which(next_edge[,4]>0),];next_edge=matrix(next_edge,ncol=4);
			colnames(next_edge) = c("e.from","from","to","e.next")
			for (coi in cois) {
				v=cbind(next_edge[,'e.next'],get.edge.attribute(gt, coi, next_edge[,'e.next']) + E(gt)$BiProp[next_edge[,"e.next"]] * get.edge.attribute(gt, coi, next_edge[,'e.from'])) #creates a 2 colmn matrix of next edge id and the accumulated value -- needed to deal with 2 or more flows going into a single node
				colnames(v)=c('e.next','acc')
				if (nrow(v)!=length(unique(v[,1]))) { #do this if there is any duplicate net down edges
					tfun = function(x) {return(c(sum(x),length(x)))} #define a aggregate function to get sums for e.next and a count
					tt = aggregate(v[,2],by=list(e.next=v[,1]), tfun ) #aggregate e.next sums
					tt=as.matrix(tt) #convert to matrix for indexing purposes
					tt[,3] = tt[,3] -1 #we need to remove duplications of e.next flow so first remove 1 from counts so that where there is only a single flow nothing will be removed
					tt[,2] = tt[,2] - tt[,3] * get.edge.attribute(gt, coi, tt[,'e.next']) #remove the number of e.next flows that it has been duplicated
					v = tt #set v = tt[,1:2] as it has been corrected for flows

				}
				gt=set.edge.attribute(gt, coi, v[,'e.next'],v[,2])
			}
		}
		gt = delete.vertices(gt, V(gt)[vois]) #remove the vois
	}
	return(out)
}
