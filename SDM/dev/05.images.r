source('/home/jc148322/scripts/libraries/cool_functions.r')


raster=read.asc('/home/jc246980/Hydrology.trials/catchmentraster250m2.asc')

base.asc = read.asc.gz(paste('/home/jc165798/Climate/CIAS/Australia/1km/baseline.76to05/base.asc.gz',sep='')) #read in the base asc file
pos = read.csv(paste('/home/jc165798/Climate/CIAS/Australia/1km/baseline.76to05/base.positions.csv',sep=''),as.is=TRUE)

pos$SegmentNo=extract.data(cbind(pos$lon,pos$lat),raster)

cols=colorRampPalette(c('tan','forestgreen','olivedrab2'))(100)

out.dir=('/home/jc148322/NARPfreshwater/SDM/image_tests/')

species=list.files('/home/jc148322/NARPfreshwater/SDM/models/')


for (spp in species) { cat(spp, '\n')
	spp.dir=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/',sep='');setwd(spp.dir)
	
	spdata=read.csv(paste(spp.dir,'output/projection/current.csv',sep=''),as.is=T)
	spdata=spdata[,2:3]; colnames(spdata)=c('SegmentNo','spdata')
	pos=merge(pos,spdata, by='SegmentNo')
	tasc=make.asc(pos$spdata)
	
	occur=read.csv(paste(spp.dir,'occur.csv',sep=''),as.is=T)
	occur=occur[,1:2]; colnames(occur)[2]='SegmentNo'
	toccur=merge(occur,pos,by='SegmentNo')
	

	png(paste(out.dir,spp,'.test.png',sep=''),width=dim(base.asc)[1], height=dim(base.asc)[2], units='px', pointsize=20, bg='white')
	image(tasc,ann=F,axes=F,col=cols,zlim=c(0,1))
	points(toccur$lon,toccur$lat,pch=16)
	dev.off()
	pos$spdata=NULL

}
