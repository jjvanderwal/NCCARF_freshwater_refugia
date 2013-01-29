#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################

wd = '/home/jc148322/NARPfreshwater/SDM/richness/fish/'; setwd(wd)
script.file = '/home/jc148322/scripts/NARP_freshwater/SDM/05.script2run.R'
ESs=c('RCP3PD','RCP45','RCP6','RCP85')

for (es in ESs) {
	es.arg = paste('es="',es,'" ',sep='')

	zz = file(paste('05.',es,'.richness.percentiles.sh',sep=''),'w') ##create the sh file
		cat('#!/bin/sh\n',file=zz)
		cat('cd $PBS_O_WORKDIR\n',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz)
		cat('module load R-2.15.1\n',file=zz)
		cat("R CMD BATCH --no-save --no-load '--args ",es.arg,"' ",script.file,' 05.',es,'.richness.percentiles.Rout \n',sep='',file=zz)
	close(zz)
			
	#submit the job
	system(paste('qsub -m n -N ',es,' -l nodes=1:ppn=12 05.',es,'.richness.percentiles.sh',sep=''))
}
	