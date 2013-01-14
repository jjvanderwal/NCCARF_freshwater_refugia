################################################################################
###To project the models###

wd = '/home/jc148322/NARPfreshwater/SDM/models/' #your /models/ directory
proj.dir = '/home/jc148322/NARPfreshwater/SDM/Env_layers/'
maxent.jar = "/home/jc165798/working/NARP_birds/maxent.jar"

proj.list=list.files(proj.dir,pattern='RCP')
proj.list=c('current.csv',proj.list)

species = list.files(wd) #get a list of species

#cycle through each of the species
for (spp in species) { cat(spp,'\n')
	spp.dir = paste(wd,spp,'/',sep=''); setwd(spp.dir) #set the working directory to the species directory
	
	lambdas.file=paste('output/',spp,'.lambdas',sep='')
	if (file.exists(lambdas.file)) { #only do the work if the lambdas file exists
	current='output/projection/current.csv'

	zz = file(paste('02.',spp,'.project.models.sh',sep=''),'w') ##create the sh file
		cat('#!/bin/bash\n',file=zz)
		cat('cd ',spp.dir,'\n',sep='',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz)
		cat('module load java\n',file=zz)
		dir.create('output/projection/',recursive=TRUE) #create the output directory for all maps
		#cycle through the projections
		for (tproj in proj.list[2:length(proj.list)]) cat('java -mx2048m -cp ',maxent.jar,' density.Project ',spp.dir,'output/',spp,'.lambdas ',proj.dir,tproj,' ',spp.dir,'output/projection/',tproj,' fadebyclamping nowriteclampgrid\n',sep="",file=zz)

		
	close(zz)

	#submit the script
	system(paste('qsub -m n 02.',spp,'.project.models.sh',sep=''))
	}
	
}

 