#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
taxa=c('fish','crayfish','turtles','frog')
taxon=taxa[4] #change as appropriate
wd = paste('/home/jc148322/NARPfreshwater/SDM/models_',taxon,'/',sep=''); setwd(wd)
script.file = '/home/jc148322/scripts/NARP_freshwater/SDM/07.script2run.R'
if (taxon==taxa[1]) clip.column='provinces' else clip.column='basins2'

exclude=read.csv('/home/jc148322/NARPfreshwater/SDM/fish.to.exclude.csv',as.is=TRUE)
exclude=exclude[which(exclude[,2]=='exclude'),1]
species=list.files(wd); #species=species[-grep('bkgd',species)]
species=setdiff(species,exclude)

for (spp in species) {
	spp.folder = paste(wd,spp,"/",sep=""); setwd(spp.folder) #define and set the species folder
	spp.arg = paste('spp="',spp,'" ',sep='')
	wd.arg = paste('wd="',wd,'" ',sep='')
	tax.arg = paste('taxon="',taxon,'" ',sep='')
	clip.arg = paste('clip.column="',clip.column,'" ',sep='')

	zz = file('07.images.sh','w') ##create the sh file
		cat('#!/bin/sh\n',file=zz)
		cat('cd $PBS_O_WORKDIR\n',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz)
		cat('module load R-2.15.1\n',file=zz)
		cat("R CMD BATCH --no-save --no-load '--args ",spp.arg,wd.arg,tax.arg,clip.arg,"' ",script.file,' 07.images.Rout \n',sep='',file=zz)
	close(zz)
			
	#submit the job
	system(paste('qsub -m n -N ',spp,' -l nodes=1:ppn=1 07.images.sh',sep=''))
}
	