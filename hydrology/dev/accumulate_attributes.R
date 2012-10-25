#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
library(igraph); library(parallel) #load the necessary libraries

wd = "/home/jc165798/working/NARP_hydro/flow_accumulation/"; setwd(wd) #define and set working directory

###read in necessary data
network = read.csv('NetworkAttributes.csv',as.is=TRUE) #read in the data
proportion = read.csv('proportion.csv',as.is=TRUE)
load(file='Reach_runoff_5km.Rdata')  #read in runoff data

#prepare all data
db = merge(network,proportion[,c(1,4,5)],all=TRUE) #read in proportion rules and merge with network data
runoff=Reach_runoff #rename object
runoff=runoff[which(runoff$SegmentNo %in% network$SegmentNo),] #remove extra SegmentNos
db = merge(db,runoff,all=TRUE) #merge data into db
db$LocalRunoff=db$Annual_runoff*db$SegProp #Calculate local runoff attributed to each HydroID
db = db[,c(11,12,1:10,13:ncol(db))] #reorder the columns
rm(list=c("network","Reach_runoff","runoff")) #cleanup extra files

### create graph object and all possible subgraphs
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs

### do the accumulation
#function to accumulate info in each subgraph in a full graph
gt=gg[[975]]
accum = function(gt) { 
	require(igraph)
	out=NULL #define the output
	while(length(E(gt))>0) { #loop until all edges are dealt with
		vois = which(degree(gt,mode="in")==0) #get index of the headwater vertices
		v.from.to = NULL; for (ii in neighborhood(gt,1,V(gt)[vois],"out")) { #get the index of the from & to nodes for each edge
			if (length(ii)>1) v.from.to = rbind(v.from.to,data.frame(from=ii[1],to=ii[2:length(ii)]))
		}
		eois = get.edge.ids(gt,t(cbind(V(gt)[v.from.to[,1]],V(gt)[v.from.to[,2]]))) #get an index of the output edges from that vertex
		out = rbind(out,data.frame(HydroID=E(gt)$HydroID[eois],runoff=E(gt)$LocalRunoff[eois])) #store the runoff for the current edges
		
		tt = neighborhood(gt,1,V(gt)[v.from.to[,2]],"out") #get the next down verticies from the current edges
		next_edge = NULL; for (ii in 1:length(eois)) { #get an index of the next down vertices and aggregate list to dataframe
			if (length(tt[[ii]])>1) next_edge = rbind(next_edge,data.frame(e.from=eois[ii],from=tt[[ii]][1],to=tt[[ii]][2:length(tt[[ii]])]))
		}
		if (!is.null(next_edge)) { #only do this if there is something down stream
			next_edge$e.next = get.edge.ids(gt,t(cbind(V(gt)[next_edge[,2]],V(gt)[next_edge[,3]]))) #get an index of the next down edges
			E(gt)$LocalRunoff[next_edge$e.next] = E(gt)$LocalRunoff[next_edge$e.next] + (E(gt)$BiProp[next_edge$e.from] * E(gt)$LocalRunoff[next_edge$e.from])#append appropriate runoff to next down edges using proportions
		}
		gt = delete.vertices(gt, V(gt)[vois]) #remove the vois
	}
	return(out)
}

###do the actual accumulation
ncore=5 #this number of cores seems most appropriate
cl <- makeCluster(getOption("cl.cores", ncore))#define the cluster for running the analysis
	print(system.time({ tout = parLapplyLB(cl,gg,accum) }))
stopCluster(cl) #stop the cluster for analysis

out = NULL; for (ii in 1:length(tout)) {cat('.');out = rbind(out,tout[[ii]])} #aggregate the list into a single matrix
db2 = merge(db,out)

