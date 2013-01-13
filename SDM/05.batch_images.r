


species=list.files('/home/jc148322/NARPfreshwater/SDM/models/')
wd='/home/jc148322/NARPfreshwater/SDM/models/';

for (spp in species) {
	spp.dir=paste(wd,spp,'/',sep=''); setwd(spp.dir)
		zz = file(paste('05.',spp,'.image.sh',sep=''),'w')
		 cat('#!/bin/bash\n',file=zz)
		 cat('cd $PBS_O_WORKDIR\n',file=zz)
		 cat('source /etc/profile.d/modules.sh\n',file=zz)
		 cat('module load R-2.15.1\n',file=zz)
		 cat("R CMD BATCH --no-save --no-restore '--args spp=\"",spp,"\" ' /home/jc148322/scripts/NARP_freshwater/SDM/05.run_images.r 02.",spp,'.image.Rout \n',sep='',file=zz) #run the R script in the background
	close(zz) 

	##submit the script
	system(paste('qsub -l nodes=1:ppn=1 05.',spp,'.image.sh',sep=''))
}
