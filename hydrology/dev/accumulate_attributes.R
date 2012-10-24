#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################

library(igraph)

wd = "/home/jc165798/working/NARP_hydro/flow_accumulation/"; setwd(wd) #define and set working directory
db = read.dbf('/home/jc246980/Janet_Stein_data/NetworkAttributes.dbf')

network = read.csv('network.csv',as.is=TRUE) #read in the data
network = network[,c(3,6,1,2,4,5,7)] #reorder the columns
g = graph.data.frame(network,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs

###some checks
E(gg[[2]])
E(gg[[2]])$HydroID
network[which(network$HydroID%in%E(gg[[2]])$HydroID),]

g.clust = clusters(g,"weak") #create the clusters

?subcomponent