
taxa=c('fish','crayfish','frog','turtles')

for (tax in taxa) { cat('\n',tax,'\n')

	if (tax==taxa[1]) { wd='/home/jc165798/working/NARP_FW_SDM/models_fish/'
	} else { wd=paste('/home/jc148322/NARPfreshwater/SDM/models_',tax,'/',sep='') }
	
	exclude=read.csv('/home/jc148322/NARPfreshwater/SDM/fish.to.exclude.csv',as.is=TRUE)
	exclude=exclude[which(exclude[,2]=='exclude'),1]
	species=list.files(wd)
	species=setdiff(species,exclude)
	
	tt=c('Species','Number of observations','AUC (mean)','AUC (SD)', 'Threshold','Omission rate')
	out=matrix(NA,nr=length(species),nc=length(tt))
	colnames(out)=tt
	i=0
	for (spp in species) { cat('.')
	i=i+1
		out[i,1]=gsub('_',' ',spp)
		tdata=read.csv(paste(wd,spp,'/output/maxentResults.crossvalide.csv', sep=''),as.is=TRUE)
		
		out[i,2]=round(tdata$X.Training.samples[11]+tdata$X.Test.samples[11])
		if (is.na(out[i,2])) out[i,2]=round(mean(tdata$X.Training.samples)+mean(tdata$X.Test.samples))
		out[i,3]=tdata$Test.AUC[11]
		if (is.na(out[i,3])) out[i,3]=mean(tdata$Test.AUC)
		out[i,4]=tdata$AUC.Standard.Deviation[11]
		if (is.na(out[i,4])) out[i,4]=mean(tdata$AUC.Standard.Deviation)
		tdata=read.csv(paste(wd,spp,'/output/maxentResults.csv', sep=''),as.is=TRUE)
		out[i,5]=tdata$Equate.entropy.of.thresholded.and.original.distributions.logistic.threshold[1]
		out[i,6]=tdata$Equate.entropy.of.thresholded.and.original.distributions.training.omission[1]

	}
	write.csv(out,paste('/home/jc148322/NARPfreshwater/Report/',tax,'_info_table.csv',sep=''), row.names=FALSE)

}
