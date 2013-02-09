args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

source('/home/jc148322/scripts/libraries/cool_functions.r')
library(SDMTools)


cols=colorRampPalette(c('tan','forestgreen','olivedrab2'))(100)

spp.dir=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/',sep='');setwd(spp.dir)

base.asc=read.asc.gz('/home/jc148322/NARPfreshwater/SDM/SegmentNo_AWT.asc.gz') #need an ascii with SegmentNos		
pos=make.pos(base.asc) #make positions file (row, col, lat, lon) from 'base.asc'
pos$SegmentNo=extract.data(cbind(pos$lon, pos$lat),base.asc) #extract the SegmentNos to be merged with later

occur=read.csv(paste(spp.dir,'occur_SegNo.csv',sep=''),as.is=T)
occur=occur[,1:2]; colnames(occur)[2]='SegmentNo'
toccur=merge(occur,pos,by='SegmentNo')
toccur=toccur[!(duplicated(toccur[,1])),]	

cp=read.asc.gz('output/asciis/WT_potential/current.asc.gz') #current potential
cr=read.asc.gz('output/asciis/WT_realized/current.asc.gz') #current realized
fp=read.asc.gz('output/asciis/WT_potential/RCP85_2085_median.asc.gz') #current potential
fr=read.asc.gz('output/asciis/WT_realized/RCP85_2085_median.asc.gz') #current realized

out.dir='/home/jc148322/NARPfreshwater/SDM/images_WT/';dir.create(out.dir)

png(paste(out.dir,spp,'.png',sep=''),width=dim(base.asc)[1]*4, height=dim(base.asc)[2]+50, units='px', pointsize=20, bg='white')
par(mfrow=c(1,4), mar=c(2,0,0,0),oma=c(0,0,0,0))
image(cp,ann=F,axes=F,col=cols,zlim=c(0,1))
points(toccur$lon,toccur$lat,pch=16,cex=0.5)
mtext('Current potential',side=1)
image(cr,ann=F,axes=F,col=cols,zlim=c(0,1))
points(toccur$lon,toccur$lat,pch=16, cex=0.5)
mtext('Current realized',side=1)
image(fp,ann=F,axes=F,col=cols,zlim=c(0,1))
mtext('Future potential (RCP85 - 2085)',side=1)
image(fr,ann=F,axes=F,col=cols,zlim=c(0,1))
mtext('Future realized (RCP85 - 2085)',side=1)
dev.off()
	
