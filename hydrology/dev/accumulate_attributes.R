#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
library(igraph)

wd = "/home/jc165798/working/NARP_hydro/flow_accumulation/"; setwd(wd) #define and set working directory
network = read.csv('NetworkAttributes.csv',as.is=TRUE) #read in the data
proportion = read.csv('/home/jc148322/NARPfreshwater/Hydrology/proportion.csv',as.is=TRUE); proportion = proportion[,c(1,4,5)] #read in proportion rules
db = merge(network,proportion,all=TRUE)

#load desired runoff file
load(file='/home/jc246980/Hydrology.trials/Reach_runoff_5km.Rdata')  #read in runoff data
runoff=Reach_runoff #rename object
runoff=runoff[which(runoff$SegmentNo %in% network$SegmentNo),] #remove extra SegmentNos

db = merge(db,runoff,all=TRUE)
db$LocalRunoff=db$Annual_runoff*db$SegProp #Calculate local runoff attributed to each HydroID


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

