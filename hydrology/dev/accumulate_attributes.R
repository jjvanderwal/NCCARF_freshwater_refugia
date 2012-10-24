#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
library(igraph)

wd = "/home/jc165798/working/NARP_hydro/flow_accumulation/"; setwd(wd) #define and set working directory
network = read.csv('NetworkAttributes.csv',as.is=TRUE) #read in the data
runoff = read.csv('local_runoff.csv',as.is=TRUE); runoff = runoff[,c(2,6)] #read in runoff info
db = merge(network,runoff,all=TRUE)

db = db[,c(11,12,1:10,13:31)] #reorder the columns
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs

#function to accumulate info in each subgraph in a full graph
accum = function(gt) { cat('.')
	out=NULL #define the output
	if (any(degree(gt,mode="out")>1)) { #bifucation exists... deal with it
	
	} else { #no bifucation so deal simplistically with it
		for (ee in 1:length(E(gt))) {
			etmp = E(gt)[ee] #define the edge we are working with
			SegmentNo = etmp$SegmentNo #segment number that we are aggregating to
			vtmp = V(gt)[get.edge(gt,etmp)[1]] #get the "from" vertex for this edge
			tt = induced.subgraph(gt,V(gt)[subcomponent(gt, vtmp, mode = 'in')]) #create a subgraph for everything upstream of this edge
			out = rbind(out,data.frame(SegmentNo=SegmentNo,runoff=sum(c(etmp$LocalRunoff,E(tt)$LocalRunoff),na.rm=TRUE)))
		}
	}
	return(as.matrix(out))
}
tout = sapply(gg[1:10],accum,simplify=TRUE,USE.NAMES=FALSE) #apply the function to all the subgraphs...
out = NULL; for (ii in 1:length(tout)) out = rbind(out,tout[[ii]])
db2 = merge(db,out)

