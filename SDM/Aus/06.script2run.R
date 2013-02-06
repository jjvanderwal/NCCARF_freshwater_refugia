###get the command line arguments
args=(commandArgs(TRUE)); for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

source('/home/jc148322/scripts/libraries/cool_functions.r')
library(SDMTools);library(plotrix)


load(paste('/home/jc148322/NARPfreshwater/SDM/richness/',tax,'/',es,'_richness.Rdata',sep=''))

outdelta=outquant[,3:ncol(outquant)]# make a copy

outdelta=outdelta/outquant[,2]
outdelta[which(is.nan(outdelta))]=1
outdelta[which(outdelta>4)]=4

outdelta=cbind(outquant[,1:2],outdelta)
zlim=c(0,4)

###02. Create image
base.asc = read.asc.gz(paste('/home/jc148322/NARPfreshwater/SDM/SegmentNo_1km.asc.gz',sep='')) #read in the base asc file
pos=make.pos(base.asc)
pos$SegmentNo=extract.data(cbind(pos$lon,pos$lat),base.asc)
pos=merge(pos,outdelta, by='SegmentNo',all.x=TRUE)

YEARs=seq(2015,2085,10)
out.dir=paste('/home/jc148322/NARPfreshwater/SDM/richness/',tax,'/images/',sep=''); dir.create(out.dir,recursive=TRUE); setwd(out.dir)
cols=colorRampPalette(c("#D73027","#FFFFBF","#E0F3F8","#74ADD1","#313695"))(100)

vois=c(10,50,90)

for (yr in YEARs) { 
	
	png(paste(es,'_delta_',yr,'.png',sep=''),width=dim(base.asc)[1]*3+200,height=dim(base.asc)[2]+50,units='px', pointsize=30, bg='lightgrey')
	par(mfrow=c(1,3),mar=c(2,2,2,2))
		for (voi in vois){ cat(yr,'-',voi,'\n')
			tasc=make.asc(pos[,paste(yr,'_',voi,sep='')])
			image(tasc,ann=F,axes=F,col=cols,zlim=zlim)
			mtext(paste(voi,'th percentile',sep=''),side=1,cex=4)
					
		}
	color.legend(118,-42,140,-41,zlim,cols,cex=4)
	dev.off()
	
}


