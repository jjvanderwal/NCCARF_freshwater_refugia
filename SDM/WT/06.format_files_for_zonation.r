wd='/home/jc148322/NARPfreshwater/SDM/models/';


###1. Determine which species are WT species - Load species occurrence data
occur.file="/home/jc246980/Zonation/Fish_reach_aggregated.Rdata" #give the full file path of your species data
occur=load(occur.file)
occur=get(occur) #rename species occurrence data to 'occur'

###2. Clip occurrence data to WT area only
clip=read.csv('/home/jc148322/NARPfreshwater/SDM/WT_clip.csv',as.is=TRUE)
occur=occur[which(occur[,1] %in% clip[,1]),]
###3. Tidy occur file - remove any SegmentNos and species that have no presence records

occur$count=rowSums(occur[,2:ncol(occur)]) #count all presence records for each SegmentNo
occur=occur[which(occur$count>0),] #remove SegmentNos (rows) with no occurrence records for any species
occur=occur[,-grep('count',colnames(occur))];  #remove the 'count' column

count=apply(occur,2,sum)
count=count[which(count>1)]
count=as.data.frame(count)
species=rownames(count); species=species[-1]
species=intersect(species,list.files(wd)) #only get species that have been modelled

out.dir='/home/jc148322/NARPfreshwater/SDM/Zonation/'
dir.create(paste(out.dir,'potential/current/',sep=''),recursive=TRUE)
dir.create(paste(out.dir,'potential/RCP85_2085/',sep=''),recursive=TRUE)
dir.create(paste(out.dir,'realized/current/',sep=''),recursive=TRUE)
dir.create(paste(out.dir,'realized/RCP85_2085/',sep=''),recursive=TRUE)

for (spp in species[2:length(species)]) {
	spp.dir=paste(wd, spp,'/output/asciis/',sep=''); setwd(spp.dir)
	
	system(paste('cp ',spp.dir,'WT_potential/current.asc.gz ',out.dir,'potential/current/',sep=''))
	system(paste('mv ',out.dir,'potential/current/current.asc.gz ',out.dir,'potential/current/',spp,'.asc.gz',sep=''))
	system(paste('gzip -d ',out.dir,'potential/current/',spp,'.asc.gz',sep=''))

	system(paste('cp ',spp.dir,'WT_potential/RCP85_2085_median.asc.gz ',out.dir,'potential/RCP85_2085/',sep=''))
	system(paste('mv ',out.dir,'potential/RCP85_2085/RCP85_2085_median.asc.gz ',out.dir,'potential/RCP85_2085/',spp,'_2085.asc.gz',sep=''))
	system(paste('gzip -d ',out.dir,'potential/RCP85_2085/',spp,'_2085.asc.gz',sep=''))

	system(paste('cp ',spp.dir,'WT_realized/current.asc.gz ',out.dir,'realized/current/',sep=''))
	system(paste('mv ',out.dir,'realized/current/current.asc.gz ',out.dir,'realized/current/',spp,'.asc.gz',sep=''))
	system(paste('gzip -d ',out.dir,'realized/current/',spp,'.asc.gz',sep=''))

	system(paste('cp ',spp.dir,'WT_realized/RCP85_2085_median.asc.gz ',out.dir,'realized/RCP85_2085/',sep=''))
	system(paste('mv ',out.dir,'realized/RCP85_2085/RCP85_2085_median.asc.gz ',out.dir,'realized/RCP85_2085/',spp,'_2085.asc.gz',sep=''))
	system(paste('gzip -d ',out.dir,'realized/RCP85_2085/',spp,'_2085.asc.gz',sep=''))


}
