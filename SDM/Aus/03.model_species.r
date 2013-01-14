###written by Lauren Hodgson, modified from Jeremy VanDerWal's SDM scripts. Jan 2013
########################################################################################################
### Define inputs, working directories and necessary libraries
library(SDMTools) #define the libraries needed

occur.file="/home/jc246980/Zonation/Fish_reach_aggregated.Rdata" #give the full file path of your species data
env.file="/home/jc148322/NARPfreshwater/SDM/Env_layers/current.Rdata"
maxent.jar = "/home/jc165798/working/NARP_birds/maxent.jar" #define the location of the maxent.jar file

wd="/home/jc148322/NARPfreshwater/SDM/";setwd(wd)
########################################################################################################

###1. Read in current environmental layers

load(env.file) #load the current environmental layers file. The object is named 'current'
env.vars=colnames(current)
to.remove=c('lat','long','bioclim_02','bioclim_03','bioclim_07','bioclim_16','total.severity','num.month.contribution')
env.vars=setdiff(env.vars,to.remove)

###2. Load species occurrence data
occur=load(occur.file)
occur=get(occur) #rename species occurrence data to 'occur'
species=colnames(occur); species=species[-grep('SegmentNo',species)] #get species names, to loop through later


###3. Tidy occur file - remove any SegmentNos that have no presence records, and append env layers to the end

occur$count=rowSums(occur[,2:ncol(occur)]) #count all presence records for each SegmentNo
occur=occur[which(occur$count>0),] #remove SegmentNos (rows) with no occurrence records for any species
occur=occur[,-grep('count',colnames(occur))];  #remove the 'count' column


###4. Merge occur file with environmental layers file - to do this, rename 'SegmentNo' to 'lat' and merge by it

colnames(occur)[1]='lat' #rename 'SegmentNo' to 'lat'
occur=merge(occur,current, by='lat') #merge occur and env layers by fake 'lat'


###5. Prepare the background file.  This will be all SegmentNos with a presence record in the taxa.

bkgd=cbind('bkgd',occur[,env.vars]) #bind 'background' species onto lats and longs and env.vars for all SegmentNos with a presence record.  '
colnames(bkgd)[1]='spp' #rename the 'background' species column as 'species'
write.csv(bkgd,'bkgd.csv',row.names=FALSE) #write out your target group background


###6. Cycle through each species and submit jobs to be modelled

for (spp in species[1:10]) { cat(spp,'\n')
	if(nrow(occur[which(occur[,spp]>0),])>0) { #check that there are presence records for the species
	toccur = cbind(spp,occur[which(occur[,spp]>0),c('lat','long',env.vars)]) #get the observations for the species - get only the rows with occurrences (>0), and the environmental variables

	if (nrow(toccur)<10) { #if there are fewer records than 10, do not model the species
	} else { #else model the species
	spp.dir = paste(wd,'models/',spp,'/',sep='') #define the species directory
	dir.create(paste(spp.dir,'output',sep=''),recursive=TRUE) #create the species directory
	
	write.csv(toccur,paste(spp.dir,'occur_SegNo.csv',sep=''),row.names=FALSE) #write out the file
	toccur=toccur[,c('spp',env.vars)]
	write.csv(toccur,paste(spp.dir,'occur.csv',sep=''),row.names=FALSE) #write out modelling file
	 
	# create the shell script which will run the modelling jobs
	zz = file(paste(spp.dir,'01.',spp,'.model.sh',sep=''),'w') #create the shell script to run the maxent model
		cat('#!/bin/bash\n',file=zz)
		cat('cd ',spp.dir,'\n',sep='',file=zz)
		cat('source /etc/profile.d/modules.sh\n',file=zz) #this line is necessary for 'module load' to work in tsch
		cat('module load java\n',file=zz)
		# cat('java -mx2048m -jar ',maxent.jar,' -e ',wd,'bkgd.csv -s occur.csv -o output nothreshold nowarnings novisible replicates=10 nooutputgrids -r -a \n',sep="",file=zz) #run maxent bootstrapped to get robust model statistics
		cat('cp -af output/maxentResults.csv output/maxentResults.crossvalide.csv\n',file=zz) #copy the maxent results file so that it is not overwritten
		cat('java -mx2048m -jar ',maxent.jar,' -e ',wd,'bkgd.csv -s occur.csv -o output nothreshold outputgrids plots nowarnings  responsecurves jackknife novisible nowriteclampgrid nowritemess writeplotdata -P -J -r -a \n',sep="",file=zz) #run a full model to get the best parameterized model for projecting
	close(zz)
	setwd(spp.dir); system(paste('qsub -m n 01.',spp,'.model.sh',sep='')); setwd(wd) #submit the script
	}
	}
}




