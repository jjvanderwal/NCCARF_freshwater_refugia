#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
#required to run ... module load R-2.15.1

### read in the necessary info
args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

### sample data 
proportionate.accumulation=FALSE #false is accumulate area; true is accumulation runnoff
wd = "/home/jc165798/working/NARP_hydro/flow_accumulation/" #define the working directory
data.file="/home/jc165798/working/NARP_hydro/flow_accumulation/area_runoff.csv" #define the name of the data file
network.file="/home/jc165798/working/NARP_hydro/flow_accumulation/NetworkAttributes.csv" #define the name of the network attribute data file
proportion.file="/home/jc165798/working/NARP_hydro/flow_accumulation/proportion.csv" #define the name of the proportionate attribute data file
accum.function.file="/home/jc165798/SCRIPTS/git_code/NCCARF_freshwater_refugia/hydrology/dev/accumulate_functions.R" #define the location of the accumulation functions

################################################################################
library(igraph); library(parallel) #load the necessary libraries
source(accum.function.file) #source the accumulation functions
setwd(wd) #define and set working directory

###read in necessary data
network = read.csv(network.file,as.is=TRUE) #read in the netowrk attribute data
proportion = read.csv(proportion.file,as.is=TRUE) #read in the proportionate data
stream.data = read.csv(data.file,as.is=TRUE) #read in the stream data to be summarized

#prepare all data
cois=colnames(attribute)[-grep('SegmentNo',colnames(attribute))] #define a vector of your colnames of interest
db = merge(network,proportion[,c(1,4,5)],all=TRUE) #read in proportion rules and merge with network data
attribute=as.data.frame(attribute) #convert attributes to dataframe
attribute=attribute[which(attribute$SegmentNo %in% network$SegmentNo),] #remove extra SegmentNos
attribute=na.omit(attribute)
db = merge(db,attribute,all=TRUE) #merge data into db
db[,cois]=db[,cois]*db$SegProp #Calculate local attribute attributed to each HydroID and overwrite SegNo attribute
db = db[,c(11,12,1:10,13:ncol(db))] #reorder the columns
db=db[which(is.finite(db[,cois[1]])),] #remove NAs (islands, etc)
if (use.proportion==FALSE) db$BiProp=1
rm(list=c("network","attribute","proportion")) #cleanup extra files

### create graph object and all possible subgraphs
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs

### do the accumulation

###do the actual accumulation
ncore=5 #this number of cores seems most appropriate
cl <- makeCluster(getOption("cl.cores", ncore))#define the cluster for running the analysis
	print(system.time({ tout = parLapplyLB(cl,gg,accum, cois=cois) }))
stopCluster(cl) #stop the cluster for analysis

###need to store the outputs
out = do.call("rbind",tout) #aggregate the list into a single matrix
db2 = merge(db,out) #merge this back into the overall database

write.csv(out,paste(out.dir,filename,'.csv',sep=''),row.names=F)