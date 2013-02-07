#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
tax='frog'
sh.dir=paste('/home/jc148322/scripts/NARP_freshwater/SDM/richness/',tax,'/',sep='');dir.create(sh.dir,recursive=TRUE); setwd(sh.dir)
# wd = paste('/home/jc165798/working/NARP_FW_SDM/models_',tax,'/',sep=''); #use this for fish for now.
wd = paste('/home/jc148322/NARPfreshwater/SDM/models_',tax,'/',sep=''); 
# clip.column='province' #basins2, province
clip.column='basins2'
script.file = '/home/jc148322/scripts/NARP_freshwater/SDM/05.script2run.R'
ESs=c('RCP3PD','RCP45','RCP6','RCP85')


for (es in ESs) {
	#arguments 
	es.arg = paste('es="',es,'" ',sep='')
	wd.arg = paste('wd="',wd,'" ',sep='')
	tax.arg = paste('tax="',tax,'" ',sep='')
	clip.arg = paste('clip.column="',clip.column,'" ',sep='')

	#create sh file
	zz = file(paste('05.',es,'.richness.percentiles.sh',sep=''),'w') ##create the sh file
		cat('#!/bin/sh\n',file=zz)
		cat('cd $PBS_O_WORKDIR\n',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz)
		cat('module load R-2.15.1\n',file=zz)
		cat("R CMD BATCH --no-save --no-load '--args ",es.arg,tax.arg,wd.arg,clip.arg,"' ",script.file,' 05.',es,'.richness.percentiles.Rout \n',sep='',file=zz)
	close(zz)
			
	#submit the job
	system(paste('qsub -m n -N ',tax,'_',es,' -l nodes=1:ppn=12 05.',es,'.richness.percentiles.sh',sep=''))
}
	