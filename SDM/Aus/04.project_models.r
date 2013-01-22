################################################################################
###To project the models###

wd = '/home/jc148322/NARPfreshwater/SDM/Fish/models/' #your /models/ directory
proj.dir = '/home/jc148322/NARPfreshwater/SDM/Env_layers/'
maxent.jar = "/home/jc165798/working/NARP_birds/maxent.jar"

proj.list=list.files(proj.dir,pattern='RCP')

#subset proj.list, if required
# proj.list=proj.list[-grep('RCP85',proj.list)]
proj.list=c('current.csv',proj.list)
species = list.files(wd) #get a list of species
species=species[c(140,149)]
#cycle through each of the species
for (spp in species) { cat(spp,'\n')
	spp.dir = paste(wd,spp,'/',sep=''); setwd(spp.dir) #set the working directory to the species directory
	
	lambdas.file=paste('output/',spp,'.lambdas',sep='')
	if (file.exists(lambdas.file)) { #only do the work if the lambdas file exists

	zz = file(paste('04.',spp,'.project.models.sh',sep=''),'w') ##create the sh file
		cat('#!/bin/bash\n',file=zz)
		cat('cd ',spp.dir,'\n',sep='',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz)
		cat('module load java\n',file=zz)
		dir.create('output/potential/',recursive=TRUE) #create the output directory for all maps
		#cycle through the projections
		for (tproj in proj.list) cat('java -mx2048m -cp ',maxent.jar,' density.Project ',spp.dir,'output/',spp,'.lambdas ',proj.dir,tproj,' ',spp.dir,'output/potential/',tproj,' fadebyclamping nowriteclampgrid\n',sep="",file=zz)

		
	close(zz)

	#submit the script
	system(paste('qsub -m n 04.',spp,'.project.models.sh',sep=''))
	}
	
}

 