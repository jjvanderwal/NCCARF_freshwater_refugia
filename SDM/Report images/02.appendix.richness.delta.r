#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
taxa=c('fish','crayfish','turtles','frog')

script.file = '/home/jc148322/scripts/NARP_freshwater/Appendix/02.script2run.r'

for (tax in taxa) {
	wd = paste('/home/jc148322/scripts/NARP_freshwater/Appendix/',tax,'/tmp.sh/',sep=''); dir.create(wd,recursive=TRUE); setwd(wd)

	tax.arg = paste('tax="',tax,'" ',sep='')

	zz = file(paste('06.',tax,'.richness.delta.sh',sep=''),'w') ##create the sh file
		cat('#!/bin/sh\n',file=zz)
		cat('cd $PBS_O_WORKDIR\n',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz)
		cat('module load R-2.15.1\n',file=zz)
		cat("R CMD BATCH --no-save --no-load '--args ",tax.arg,"' ",script.file,' 06.',tax,'.richness.delta.Rout \n',sep='',file=zz)
	close(zz)
			
	#submit the job
	system(paste('qsub -m n -N ',tax,' -l nodes=1:ppn=12 06.',tax,'.richness.delta.sh',sep=''))
}
	