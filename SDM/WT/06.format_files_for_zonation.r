wd='/home/jc165798/working/NARP_FW_SDM/models_fish/';

exclude=read.csv('/home/jc148322/NARPfreshwater/SDM/fish.to.exclude.csv',as.is=TRUE)
exclude=exclude[which(exclude[,2]=='exclude'),1]
species=list.files(wd)
species=setdiff(species,exclude)

out.dir='/home/jc148322/NARPfreshwater/SDM/Zonation/'

asciis=list.files('/home/jc148322/NARPfreshwater/SDM/Fish/models/Acanthopagrus_berda/output/asciis/WT_realized')
asciis=asciis[-grep('current',asciis)]
gcms=unique(sapply(strsplit(asciis,'_'),'[',2))
years=unique(sapply(strsplit(asciis,'_'),'[',3)); years=gsub('.asc.gz','',years)
#gcms=c('median','diff')
gcms=gcms[-c(grep('ninetieth',gcms),grep('tenth',gcms))]

for (gcm in gcms){ cat(gcm,'\n')

	dir.create(paste(out.dir,gcm,'/',sep=''),recursive=TRUE)

	for (spp in species) { cat(spp,'...')
		spp.dir=paste(wd, spp,'/output/asciis/',sep=''); setwd(spp.dir)
		 for (yr in years){
			system(paste('cp ',spp.dir,'WT_realized/RCP85_',gcm,'_',yr,'.asc.gz ',out.dir,gcm,'/',sep=''))
			system(paste('mv ',out.dir,gcm,'/RCP85_',gcm,'_',yr,'.asc.gz ',out.dir,gcm,'/',spp,'_',yr,'.asc.gz',sep=''))
			system(paste('gzip -d ',out.dir,gcm,'/',spp,'_',yr,'.asc.gz',sep=''))
		 }
	}
}

dir.create(paste(out.dir,'current/',sep=''),recursive=TRUE)
for (spp in species) {
	spp.dir=paste(wd, spp,'/output/asciis/',sep=''); setwd(spp.dir)

	system(paste('cp ',spp.dir,'WT_realized/current.asc.gz ',out.dir,'current/',sep=''))
	system(paste('mv ',out.dir,'current/current.asc.gz ',out.dir,'current/',spp,'.asc.gz',sep=''))
	system(paste('gzip -d ',out.dir,'current/',spp,'.asc.gz',sep=''))

	}
	