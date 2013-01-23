#### Batch Script to prepare future environmental data for modelling
#### C. James, L.Hodgson...............9th January 2012

futdir = "/home/jc165798/Climate/CIAS/Australia/5km/monthly_csv/"	

ESs = list.files(futdir, pattern="RCP") # list the emission scenarios
GCMs = list.files(paste(futdir,ESs[1],sep=''))	# get a list of GCMs
YEAR=seq(2015, 2085, 10)	

sh.dir='/home/jc148322/scripts/NARP_freshwater/SDM/prep_data.sh/'; setwd(sh.dir)
for (es in ESs) {
	for (gcm in GCMs) {			
		for (yy in YEAR) {
			zz = file(paste('02.',es,'.',gcm,'.',yy,'.prep_data.sh',sep=''),'w')
			 cat('#!/bin/bash\n',file=zz)
			 cat('cd $PBS_O_WORKDIR\n',file=zz)
			 cat('source /etc/profile.d/modules.sh\n',file=zz)
			 cat('module load R-2.15.1\n',file=zz)
			 cat("R CMD BATCH --no-save --no-restore '--args es=\"",es,"\" gcm=\"",gcm,"\" yy=\"",yy,"\" ' /home/jc148322/scripts/NARP_freshwater/SDM/02.run_env_swd_prep.r 02.",es,'.',gcm,'.',yy,'.Rout \n',sep='',file=zz) #run the R script in the background
		close(zz) 

		##submit the script
		system(paste('qsub -l nodes=1:ppn=4 02.',es,'.',gcm,'.',yy,'.prep_data.sh',sep=''))

		}
	}
}
	