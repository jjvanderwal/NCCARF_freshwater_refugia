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
gt = gg[[827]]
degree(gt,mode="out")

accum = function(gt) { cat('.')
	require(igraph)
	out=NULL #define the output
	if (any(degree(gt,mode="out")>1)) { #bifucation exists... deal with it
		while(length(E(gt))>0) { #loop until all edges are dealt with
			vois = which(degree(gt,mode="in")==0) #get index of the headwater vertices
			for (voi in vois) { #cycle through the vertices
				eois = incident(gt,V(gt)[voi],"out") #get an index of the output edges from that vertex
				for (eoi in eois) {
					e_tmp = E(gt)[eoi] #this is the edge being worked with
					runoff=e_tmp$LocalRunoff #get the runoff
					out = rbind(out,data.frame(HydroID=e_tmp$HydroID,runoff=runoff)) #append the current data
					v2 = get.edge(gt,e_tmp)[2] #get the index of the "to_vertex"
					next_edges = incident(gt,V(gt)[v2],"out") #get an index of the output edges from that vertex
					for (next_edge in next_edges) { #cycle through the next edges and add the upstream flow
						E(gt)$LocalRunoff[next_edge] = E(gt)$LocalRunoff[next_edge] + (E(gt)$BiProp[next_edge] * runoff) #add the appropriate proportion of upstream runoff
					}
				}
			}
			gt = delete.vertices(gt, V(gt)[vois])#remove the vois
		}
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

ncore=10
cl <- makeCluster(getOption("cl.cores", ncore))#define the cluster for running the analysis
	print(system.time({
		tout = parLapplyLB(cl,gg,accum)
	}))
stopCluster(cl) #stop the cluster for analysis

out = NULL; for (ii in 1:length(tout)) {cat('.');out = rbind(out,tout[[ii]])}
db2 = merge(db,out)
