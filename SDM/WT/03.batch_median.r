wd='/home/jc165798/working/NARP_FW_SDM/models_fish/';

exclude=read.csv('/home/jc148322/NARPfreshwater/SDM/fish.to.exclude.csv',as.is=TRUE)
exclude=exclude[which(exclude[,2]=='exclude'),1]
species=list.files(wd)
species=setdiff(species,exclude)


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
	system(paste('qsub -l nodes=1:ppn=1 03.',spp,'.median.sh',sep=''))
}
