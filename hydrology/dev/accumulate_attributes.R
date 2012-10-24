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

###cycle through all subgraphs and do analysis
out = NULL #setup the output
for (ii in 1:length(gg)) { cat(ii,'\n') #cycle through each subgraph
	if (any(degree(gg[[ii]],mode="out")>1)) { #bifucation exists... deal with it
	
	} else { #no bifucation so deal simplistically with it
		ii = 1192
		gt = gg[[ii]]
		for (ee in 1:length(E(gt))) {
			etmp = E(gt)[ee] #define the edge we are working with
			SegmentNo = etmp$SegmentNo #segment number that we are aggregating to
			vtmp = V(gt)[get.edge(gt,etmp)[1]] #get the "from" vertex for this edge
			tt = induced.subgraph(gt,V(gt)[subcomponent(gt, vtmp, mode = 'in')]) #create a subgraph for everything upstream of this edge
			out = rbind(out,data.frame(SegmentNo=SegmentNo,runoff=sum(c(etmp$LocalRunoff,E(tt)$LocalRunoff),na.rm=TRUE)))
		}
	}

}

###some checks
E(gg[[850]])
E(gg[[850]])$HydroID
db[which(db$HydroID%in%E(gg[[850]])$HydroID),c("From_Node","To_Node","SegmentNo","HydroID","NextDownID")]

g.clust = clusters(g,"weak") #create the clusters

?subcomponent
E(gg[[850]])$SegmentNo[incident(gg[[850]],"1130388",mode="out")]