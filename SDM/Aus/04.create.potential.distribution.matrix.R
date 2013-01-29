#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################

wd = '/home/jc165798/working/NARP_FW_SDM/models_fish/'; setwd(wd)
script.file = '/home/jc148322/scripts/NARP_freshwater/SDM/05.script2run.R'

species = list.files() #get a list of all the species

for (spp in species) {
	spp.folder = paste(wd,spp,"/",sep=""); setwd(spp.folder) #define and set the species folder
	spp.arg = paste('spp="',spp,'" ',sep='')

	zz = file('05.create.real.mat.sh','w') ##create the sh file
		cat('#!/bin/sh\n',file=zz)
		cat('cd $PBS_O_WORKDIR\n',file=zz)
		cat("R CMD BATCH --no-save --no-load '--args ",spp.arg,"' ",script.file,' 05.create.real.mat.Rout \n',sep='',file=zz)
	close(zz)
			
	#submit the job
	system(paste('qsub -m n -N ',spp,' -l nodes=1:ppn=3 05.create.real.mat.sh',sep=''))
}
	
