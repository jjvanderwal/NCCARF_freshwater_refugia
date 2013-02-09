wd='/home/jc148322/NARPfreshwater/SDM/Fish/models/';


###1. Load species occurrence data
occur.file="/home/jc246980/Species_data/Reach_data/Fish_reach_master.Rdata" #give the full file path of your species data
occur=load(occur.file)
occur=get(occur) #rename species occurrence data to 'occur'

###2. Clip occurrence data to WT area only
clip=read.csv('/home/jc148322/NARPfreshwater/SDM/WT_clip.csv',as.is=TRUE)
occur=occur[which(occur[,1] %in% clip[,1]),]
###3. Tidy occur file - remove any SegmentNos and species that have no presence records

occur$count=rowSums(occur[,2:ncol(occur)]) #count all presence records for each SegmentNo
occur=occur[which(occur$count>0),] #remove SegmentNos (rows) with no occurrence records for any species
occur=occur[,-grep('count',colnames(occur))];  #remove the 'count' column

count=apply(occur,2,sum)
count=count[which(count>1)]
count=as.data.frame(count)
species=rownames(count); species=species[-1]
species=intersect(species,list.files(wd)) #only get species that have been modelled


for (spp in species) { 
	spp.dir=paste(wd,spp,'/',sep=''); setwd(spp.dir)
		zz = file(paste('03.',spp,'.median.sh',sep=''),'w')
		 cat('#!/bin/bash\n',file=zz)
		 cat('cd $PBS_O_WORKDIR\n',file=zz)
		 cat('source /etc/profile.d/modules.sh\n',file=zz)
		 cat('module load R-2.15.1\n',file=zz)
		 cat("R CMD BATCH --no-save --no-restore '--args spp=\"",spp,"\" ' /home/jc148322/scripts/NARP_freshwater/SDM/WT/realized/03.run_median.r 03.",spp,'.median.Rout \n',sep='',file=zz) #run the R script in the background
	close(zz) 

	##submit the script
	system(paste('qsub -a 2100 -l nodes=1:ppn=1 03.',spp,'.median.sh',sep=''))
}
