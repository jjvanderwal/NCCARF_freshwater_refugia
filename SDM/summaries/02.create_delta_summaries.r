#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties
##get the delta data in the same format as cassie's delta outputs in preparation for input into her stability summary script
################################################################################
data.dir='/home/jc148322/NARPfreshwater/SDM/richness/summaries/deltas/'
script.file = '/home/jc148322/scripts/NARP_freshwater/SDM/summaries/02.script2run.R'
sh.dir='/home/jc148322/scripts/NARP_freshwater/SDM/summaries/summary_tables.sh/'; dir.create(sh.dir,recursive=T); setwd(sh.dir)

taxa=list.files(data.dir)

for (tax in taxa) {
	tax.arg = paste('tax="',tax,'" ',sep='')

	zz = file(paste('02.',tax,'.delta.summary.sh',sep=''),'w') ##create the sh file
		cat('#!/bin/sh\n',file=zz)
		cat('cd $PBS_O_WORKDIR\n',file=zz)
		cat("R CMD BATCH --no-save --no-load '--args ",tax.arg,"' ",script.file,' 02.',tax,'.delta.summary.Rout \n',sep='',file=zz)
	close(zz)
			
	#submit the job
	system(paste('qsub -m n -N ',gsub('_delta.Rdata','',tax),'_summary',' -l nodes=1:ppn=12 02.',tax,'.delta.summary.sh',sep=''))
}
	