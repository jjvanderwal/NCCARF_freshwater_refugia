#### Run Script to prepare future environmental data for modelling
#### C. James, L.Hodgson...............9th January 2012

# Load in necessary data and libraries
### read in the necessary info
args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

###check if file exists
out.dir ="/home/jc148322/NARPfreshwater/SDM/Env_layers/"
# tfile=paste(out.dir,es,"_",gcm,"_",yy,".csv",sep='')
# if (file.exists(tfile)) {
# } else {


library(SDMTools)

# Set up directories
accum.dir = "/home/jc246980/Hydrology.trials/Accumulated_reach/Output_futures/Qrun_accumulated2reach_1976to2005/"
runoff.dir="/home/jc246980/Hydrology.trials/Aggregate_reach/Output_futures/Qrun_aggregated2reach_1976to2005/"
bioclim.dir ="/home/jc246980/Climate/5km/Future/Bioclim_reach/"
dryseason.dir = "/home/jc246980/DrySeason/DrySeason_reach/"



wd ="/home/jc246980/Hydrology.trials/Accumulated_reach/Output_futures/Qrun_accumulated2reach_1976to2005/"

current_dynamic=read.csv(paste(wd, "Current_dynamic.csv", sep=''))
current_static=read.csv(paste(wd, "Current_static.csv", sep=''))
currents=cbind(current_dynamic,current_static[,-1]) #the two current runoff files are in the same order by SegmentNo and can therefore be joined with cbind
rm(list=c("current_dynamic","current_static"));gc()
### Get runoff data
	load(paste(runoff.dir,es,"_",gcm,".Rdata",sep='')) #loads runoff data
	
	cois= c(1,grep(yy,names(Runoff)))#columns of interest plus SegmentNo
	runoff.data= Runoff[,cois]
	runoff.data$Annual_mean =rowSums(runoff.data[,c(2:13)]) # determine annual mean runoff
	
	accum.data= read.csv(paste(accum.dir,es,"_",gcm,".",yy,".csv",sep='')) #loads acummulated data
	tdata=merge(currents, accum.data, by="SegmentNo")
	tdata$Annual_mean=rowSums((tdata[,c(2:13)]+1)*((tdata[,c(26:37)])/(tdata[,c(14:25)]+1))) # apply correction
	
	Accum_flow=tdata[,c("SegmentNo", "Annual_mean")]
	Runoff_local=runoff.data[,c("SegmentNo", "Annual_mean")]
	Hydro_missing=Runoff_local[which(!(Runoff_local$SegmentNo %in% Accum_flow$SegmentNo)),]   
	ANNUAL_MEAN=rbind(Accum_flow, Hydro_missing)
	rm(list=c("Runoff","runoff.data","accum.data","tdata","Accum_flow","Runoff_local","Hydro_missing"));gc() #cleanup extra files


### Get dry season metrics
	VOIS=c("num_month", "total_severity", "max_clust_length","fut_clust_severity", "fut_month_max_clust") #dry season variables
	for (voi in VOIS) { #loop through to load them in
		tdata=read.csv(paste(dryseason.dir,es,"_",gcm,"_",voi,".csv",sep='')) #loads dry season metrics
		cois= c(1,grep(yy,names(tdata)))# years of interest plus SegmentNo
		tdata=tdata[,cois]
		if (voi==VOIS[1]) dryseason_dat=tdata else dryseason_dat=cbind(dryseason_dat,tdata[,2])
		#the dry season files are in the same order and can therefore be joined by cbind
	}
	
### Get bioclim variables
	
	bioclim.dat=read.csv(paste(bioclim.dir,es,"_",gcm, ".csv", sep=''))
	cois= c(1,grep(yy,names(bioclim.dat)))# years of interest plus SegmentNo
	bioclim=bioclim.dat[,cois]; rm(bioclim.dat); gc()
	
### MERGE dryseason data with bioclim data, then merge with annual flow
	Enviro_dat=merge(bioclim, dryseason_dat, by="SegmentNo", all.x=TRUE); rm(bioclim); gc()
	Enviro_dat=merge(Enviro_dat, ANNUAL_MEAN, by="SegmentNo", all.x=TRUE)
	
### Create a fake lat/lon from SegmentNo - maxent demands lat/lon
	Enviro_dat=cbind(Enviro_dat[,1],Enviro_dat)

### LABEL the future env layers with the exact same column names as current layers.  IMPORTANT!
	tt=c('lat','long',paste('bioclim_',sprintf('%02i',c(1:19)),sep=""),"num.month", "total.severity", "max.clust.length","clust.severity", "month.max.clust", 'MeanAnnual')
	
	colnames(Enviro_dat)=tt
	
	
	write.csv(Enviro_dat,paste(out.dir,es,"_",gcm,"_",yy,".csv",sep=''),row.names=F)	
# }