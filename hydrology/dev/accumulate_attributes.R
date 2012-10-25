#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
library(igraph); library(parallel)

wd = "/home/jc165798/working/NARP_hydro/flow_accumulation/"; setwd(wd) #define and set working directory
network = read.csv('NetworkAttributes.csv',as.is=TRUE) #read in the data
runoff = read.csv('local_runoff.csv',as.is=TRUE); runoff = runoff[,c(1,6,7)] #read in runoff info
db = merge(network,runoff,all=TRUE)

db = db[,c(11,12,1:10,13:32)] #reorder the columns
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs

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
