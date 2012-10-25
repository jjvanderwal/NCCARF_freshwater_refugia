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
accum = function(gt) { cat('.')
	require(igraph)
	out=NULL #define the output
	if (any(degree(gt,mode="out")>1)) { #bifucation exists... deal with it
	
	} else { #no bifucation so deal simplistically with it
		for (ee in 1:length(E(gt))) {
			etmp = E(gt)[ee] #define the edge we are working with
			HydroID = etmp$HydroID #segment number that we are aggregating to
			vtmp = V(gt)[get.edge(gt,etmp)[1]] #get the "from" vertex for this edge
			tt = induced.subgraph(gt,V(gt)[subcomponent(gt, vtmp, mode = 'in')]) #create a subgraph for everything upstream of this edge
			out = rbind(out,data.frame(HydroID=HydroID,runoff=sum(c(etmp$LocalRunoff,E(tt)$LocalRunoff),na.rm=TRUE)))
		}
	}
	return(out)
}

ncore=4
cl <- makeCluster(getOption("cl.cores", ncore))#define the cluster for running the analysis
	print(system.time({
		tout = parLapplyLB(cl,gg,accum)
	}))
stopCluster(cl) #stop the cluster for analysis

out = NULL; for (ii in 1:length(tout)) {cat('.');out = rbind(out,tout[[ii]])}
db2 = merge(db,out)
