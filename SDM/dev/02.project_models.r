################################################################################
###To project the models###

work.dir = '/home/jc148322/NARPfreshwater/SDM/models/' #your /models/ directory
proj.dir = '/home/jc148322/NARPfreshwater/SDM/'
maxent.jar = "/home/jc165798/working/NARP_birds/maxent.jar"

tfile=list.files(proj.dir,pattern='current')


species = list.files(work.dir) #get a list of species

#cycle through each of the species
for (spp in species) { #spp=species[1]
	spp.dir = paste(work.dir,spp,'/',sep=''); setwd(spp.dir) #set the working directory to the species directory

	zz = file(paste('02.',spp,'project.models.sh',sep=''),'w') ##create the sh file
		cat('#!/bin/bash\n',file=zz)
		cat('cd ',spp.dir,'\n',sep='',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz)
		cat('module load java\n',file=zz)
		dir.create('output/projection/',recursive=TRUE) #create the output directory for all maps
		#cycle through the projections
		#for (tproj in proj.list) cat('java -mx1024m -cp ',maxent.jar,' density.Project ',spp.dir,'output/',spp,'.lambdas ',proj.dir,tproj,' ',spp.dir,'output/ascii_WT/',tproj,'.csv fadebyclamping nowriteclampgrid\n',sep="",file=zz)
		cat('java -mx1024m -cp ',maxent.jar,' density.Project ',spp.dir,'output/',spp,'.lambdas ',proj.dir,tfile,' ',spp.dir,'output/projection/',tfile,' fadebyclamping nowriteclampgrid\n',sep="",file=zz)
		
	close(zz)

	#submit the script
	system(paste('qsub -m n 02.',spp,'project.models.sh',sep=''))
	}

 