### Script to setup files for MAXENT run trials

library(SDMTools) #define the libraries needed

out.dir="/home/jc148322/NARPfreshwater/SDM/"

### read in data (need to read in runoff and get runoff values for segments that don't occur in hydro (i.e. not in network)
hydro=read.csv("/home/jc246980/Hydrology.trials/Accumulated_reach/Output_futures/Qrun_accumulated2reach_1976to2005/Current_dynamic.csv")
hydro$MeanAnnual=rowMeans(hydro[,2:13])

load("/home/jc246980/Hydrology.trials/Aggregate_reach/Output_futures/Qrun_aggregated2reach_1976to2005/Current_dynamic.Rdata")
Runoff$MeanAnnual=rowMeans(Runoff[,2:13])
hydro_extra=Runoff[which(!(Runoff$SegmentNo %in% hydro$SegmentNo)),]   
HYDRO=hydro[,c(1,14)]
HYDRO_EXTRA=hydro_extra[, c(1,14)]
HYDROLOGY=rbind(HYDRO,HYDRO_EXTRA)

#select bioclim variables
bioclim=read.csv("/home/jc246980/Climate/5km/Future/Bioclim_reach/Current_bioclim_agg2reach_1976to2005.csv")
vars = c('SegmentNo',paste('bioclim_',sprintf('%02i',c(1,4,5,6,12,15,16,17)),sep=''))
bioclim=bioclim[,vars]

current=merge(HYDROLOGY, bioclim,by="SegmentNo")
current$lat=current$SegmentNo; current$long=current$SegmentNo;
current=current[,-grep('SegmentNo',colnames(current))]; current=current[,c(11,10,1:9)]
env.vars=colnames(current)

write.csv(current,paste(out.dir,"current.csv",sep=''),row.names=F)                                

### load species data

load("/home/jc246980/Zonation/Fish_reach_aggregated.Rdata")
occur=species.data.final
species=colnames(occur); species=species[-grep('SegmentNo',species)]

occur$bkgd=rowSums(occur[,2:ncol(occur)])
occur=occur[which(occur$bkgd>0),]
occur=occur[,-grep('bkgd',colnames(occur))]; colnames(occur)[1]='long'
occur=merge(occur,current, by='long')

### prepare background data
bkgd=cbind('bkgd',occur[,env.vars]); colnames(bkgd)[1]='spp'

write.csv(bkgd,'bkgd.csv',row.names=FALSE) #write out your target group background


wd="/home/jc148322/NARPfreshwater/SDM/"; setwd(wd)
maxent.jar = "/home/jc165798/working/NARP_birds/maxent.jar" #define the location of the maxent.jar file

###cycle through each species and submit jobs to be modelled
for (spp in species) { cat(spp,'\n')
	coi=grep(spp,colnames(occur))
	toccur = cbind(spp,occur[which(occur[,coi]>0),env.vars]) #get the observations for the species

	spp.dir = paste(wd,'models/',spp,'/',sep='') #define the species directory
	dir.create(paste(spp.dir,'output',sep=''),recursive=TRUE) #create the species directory
	write.csv(toccur,paste(spp.dir,'occur.csv',sep=''),row.names=FALSE) #write out the file
	 
	#create the shell script which will run the modelling jobs
	zz = file(paste(spp.dir,'01.',spp,'.model.sh',sep=''),'w') #create the shell script to run the maxent model
		cat('#!/bin/bash\n',file=zz)
		cat('cd ',spp.dir,'\n',sep='',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz) 
		cat('module load java\n',file=zz)
		cat('java -mx2048m -jar ',maxent.jar,' -e ',wd,'bkgd.csv -s occur.csv -o output nothreshold nowarnings novisible replicates=10 nooutputgrids -r -a \n',sep="",file=zz) #run maxent bootstrapped to get robust model statistics
		cat('cp -af output/maxentResults.csv output/maxentResults.crossvalide.csv\n',file=zz) #copy the maxent results file so that it is not overwritten
		cat('java -mx2048m -jar ',maxent.jar,' -e ',wd,'bkgd.csv -s occur.csv -o output nothreshold outputgrids plots nowarnings  responsecurves jackknife novisible nowriteclampgrid nowritemess writeplotdata -P -J -r -a \n',sep="",file=zz) #run a full model to get the best parameterized model for projecting
	close(zz)
	setwd(spp.dir); system(paste('qsub -m n 01.',spp,'.model.sh',sep='')); setwd(wd) #submit the script
}




