source('/home/jc148322/scripts/libraries/cool_functions.r')
library(SDMTools);library(plotrix)

es='RCP85'
load(paste('/home/jc148322/NARPfreshwater/SDM/richness/fish/',es,'_richness.Rdata',sep=''))

zlim=c(0,round(max(outquant[,2:ncol(outquant)])))

base.asc = read.asc.gz(paste('/home/jc148322/NARPfreshwater/SDM/SegmentNo_1km.asc.gz',sep='')) #read in the base asc file
pos=make.pos(base.asc)
pos$SegmentNo=extract.data(cbind(pos$lon,pos$lat),base.asc)
pos=merge(pos,outquant, by='SegmentNo',all.x=TRUE)

YEARs=seq(2015,2085,10)
out.dir='/home/jc148322/NARPfreshwater/SDM/richness/fish/images/'; dir.create(out.dir); setwd(out.dir)
cols=colorRampPalette(c("tan","forestgreen","darkblue"))(100)
vois=c('current',50,10,90)

for (yr in YEARs) { 
	
	png(paste(es,'_richness_',yr,'.png',sep=''),width=dim(base.asc)[1]*2+200,height=dim(base.asc)[2]*2+50,units='px', pointsize=30, bg='lightgrey')
	par(mfrow=c(2,2),mar=c(2,2,2,2))
		for (voi in vois){ cat(yr,'-',voi,'\n')
			if (voi==vois[1]) {
			tasc=make.asc(pos[,voi])
			image(tasc,ann=F,axes=F,col=cols,zlim=zlim)
			mtext('Current',side=1,cex=4)
			
			} else {
			tasc=make.asc(pos[,paste(yr,'_',voi,sep='')])
			image(tasc,ann=F,axes=F,col=cols,zlim=zlim)
			mtext(paste(voi,'th percentile',sep=''),side=1,cex=4)
			}
					
		}
	color.legend(118,-42,140,-41,zlim,cols,cex=4)
	dev.off()
	
}
