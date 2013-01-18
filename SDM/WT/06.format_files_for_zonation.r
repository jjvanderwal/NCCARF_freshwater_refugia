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


asciis=list.files('/home/jc148322/NARPfreshwater/SDM/models/Acanthopagrus_berda/output/asciis/WT_realized')
asciis=asciis[-1]
gcms=unique(sapply(strsplit(asciis,'_'),'[',2))
years=unique(sapply(strsplit(asciis,'_'),'[',3)); years=gsub('.asc.gz','',years)



for (gcm in gcms){

	dir.create(paste(out.dir,gcm,'/',sep=''),recursive=TRUE)

	for (spp in species) {
		spp.dir=paste(wd, spp,'/output/asciis/',sep=''); setwd(spp.dir)
		for (yr in years){
			system(paste('cp ',spp.dir,'WT_realized/RCP85_',gcm,'_',yr,'.asc.gz ',out.dir,gcm,'/',sep=''))
			system(paste('mv ',out.dir,gcm,'/RCP85_',gcm,'_',yr,'.asc.gz ',out.dir,gcm,'/',spp,'_',yr,'.asc.gz',sep=''))
			system(paste('gzip -d ',out.dir,gcm,'/',spp,'_',yr,'.asc.gz',sep=''))
		}
	}
}

dir.create(paste(out.'current/',sep=''),recursive=TRUE)
for (spp in species) {
	spp.dir=paste(wd, spp,'/output/asciis/',sep=''); setwd(spp.dir)

	system(paste('cp ',spp.dir,'WT_realized/current.asc.gz ',out.dir,'current/',sep=''))
	system(paste('mv ',out.dir,gcm,'/current.asc.gz ',out.dir,'current/',spp,'.asc.gz',sep=''))
	system(paste('gzip -d ',out.dir,'current/',spp,'.asc.gz',sep=''))

	}
	