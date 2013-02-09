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
		tt = which(eois==0) #identify edges that have no identity (e.g., 0 values)
		if (length(tt)>0) { eois = eois[-tt]; v.from.to = v.from.to[-tt,] } #only keep eois and asociated v.from.to rows that have adges associated with them
		if (is.null(dim(v.from.to))) v.from.to = matrix(v.from.to,ncol=2) #ensure v.from.to is a matrix
		tout=E(gt)$HydroID[eois] #prepare empty df to store attributes		
		for (coi in cois){ tt=get.edge.attribute(gt,coi,eois); tout=cbind(tout,tt)} #store the attribute for the selected edges for each of the columns to be accumulated
		colnames(tout)=c('HydroID',cois) #name the columns	
		out = rbind(out,tout) #store the attribute for the current edges
		
		
		suppressWarnings({ 
			tt = cbind(eois, do.call("rbind", neighborhood(gt,1,V(gt)[v.from.to[,2]],"out"))) #get the next down verticies from the current edges
		})
		if ((length(dim(tt))<1 & length(tt)>2) | (length(dim(tt))>0 & ncol(tt)>2)) { #only do this if there is something down stream	
			next_edge = NULL; for (ii in 3:ncol(tt)) next_edge = rbind(next_edge,tt[,c(1,2,ii)]) #flatten the list to a matrix and setup for next cleaning
			next_edge = rbind(next_edge,next_edge) #allow for bifurcations
			colnames(next_edge) = c("e.from","from","to") #add the column names
			tt = cbind(next_edge[,c(2:3)],get.edge.ids(gt,t(cbind(V(gt)[next_edge[,2]],V(gt)[next_edge[,3]])),multi=TRUE)) #get an index of the next down edges
			colnames(tt)[3] = "e.next" #assign the 3rd column name
			if (length(which(tt[,3]==0))) tt = tt[-which(tt[,3]==0),] #remove the no next_down edge
			if(is.null(dim(tt))) { tt=matrix(tt,ncol=3); colnames(tt) = c("from","to","e.next") } #ensure this is a matrix
			next_edge = unique(next_edge) #keep the unique values
			next_edge = merge(next_edge,tt) #merge the next edges with original edges
			#print(next_edge)
			for (coi in cois) { #cycle through each of the columns of interest
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
				gt=set.edge.attribute(gt, coi, v[,'e.next'],v[,2]) #append the new aggregated flows to the next down edges
			}
		}
		gt = delete.vertices(gt, V(gt)[vois]) #remove the vois
	}
	return(out)
}

#function to accumulate area
accum.area = function(gt,cois) { 
	require(igraph)
	sum.area = function(x,graph,cois) { #define a function to sum area above a vertex
		tgraph = induced.subgraph(graph, vids=subcomponent(graph, V(graph)[x], mode = "in")) #create a subgraph from upstream vertices
		tout = c(from=x) #define the from node
		for (coi in cois) tout = c(tout,sum(get.edge.attribute(tgraph,coi),na.rm=TRUE)) #sum the variables for each column of interest
		return(tout) 
	} 
	out=NULL #define the output
	while(length(E(gt))>0) { #loop until all edges are dealt with
		vois = which(degree(gt,mode="out")==0) #get index of the lowest reaches
		suppressWarnings({ 
			tt = do.call("rbind", neighborhood(gt,1,V(gt)[vois],"in")) #get the index of the from & to nodes for each edge in a list
		})
		v.from.to = NULL; for (ii in 2:ncol(tt)) v.from.to = rbind(v.from.to,tt[,c(1,ii)]) #flatten the list to a matrix and setup for next cleaning
		v.from.to = rbind(v.from.to,v.from.to) #allow for duplicate from-to nodes with separate SegmentNo
		if (is.null(dim(v.from.to))) v.from.to = matrix(v.from.to,ncol=2) #ensure v.from.to is a matrix
		eois = get.edge.ids(gt,t(cbind(V(gt)[v.from.to[,2]],V(gt)[v.from.to[,1]])),multi=TRUE) #get an index of the output edges from that vertex
		tt = which(eois==0) #identify edges that have no identity (e.g., 0 values)
		if (length(tt)>0) { eois = eois[-tt]; v.from.to = v.from.to[-tt,] } #only keep eois and asociated v.from.to rows that have adges associated with them
		if (is.null(dim(v.from.to))) v.from.to = matrix(v.from.to,ncol=2) #ensure v.from.to is a matrix
		v.from.to = cbind(v.from.to[,2],eois); colnames(v.from.to) = c('from','eois') #correct the from.to matrix for order and add the edge to v.from.to
		area.above = do.call("rbind",lapply(unique(v.from.to[,1]), sum.area , graph=gt, cois = cois)) #get the area above the edges of interest
		colnames(area.above) = c('from',cois) #define the column names
		v.from.to = merge(v.from.to,area.above) #merge the areas onto here
		for (coi in cois) v.from.to[,coi] = v.from.to[,coi] + get.edge.attribute(gt,coi,v.from.to[,'eois'])
		tout = data.frame(HydroID=E(gt)$HydroID[v.from.to[,'eois']],v.from.to[,cois]); colnames(tout) = c('HydroID',cois) #create a tmp output file
		out = rbind(out,tout) #append the data
		gt = delete.vertices(gt, V(gt)[vois]) #remove the vois
	}
	return(out)
}
