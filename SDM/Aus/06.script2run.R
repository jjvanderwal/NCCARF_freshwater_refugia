###get the command line arguments
args=(commandArgs(TRUE)); for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments
#es='RCP85'; tax='fish'

source('/home/jc148322/scripts/libraries/cool_functions.r')
library(SDMTools);library(plotrix); library(maptools)


load(paste('/home/jc148322/NARPfreshwater/SDM/richness/',tax,'/',es,'_richness.Rdata',sep=''))

outdelta=outquant[,3:ncol(outquant)]# make a copy

outdelta=outdelta/outquant[,2]
outdelta[which(is.nan(outdelta))]=1
outdelta[which(outdelta>2)]=2

outdelta=cbind(outquant[,1:2],outdelta)
zlim=c(0,2)

###02. Create image
base.asc = read.asc.gz(paste('/home/jc148322/NARPfreshwater/SDM/SegmentNo_1km.asc.gz',sep='')) #read in the base asc file
pos=make.pos(base.asc)
pos$SegmentNo=extract.data(cbind(pos$lon,pos$lat),base.asc)
pos=merge(pos,outdelta, by='SegmentNo',all.x=TRUE)

Drainageshape = readShapePoly('/home/jc246980/Janet_Stein_data/Drainage_division') #read in your shapefile

YEARs=seq(2015,2085,10)
out.dir=paste('/home/jc148322/NARPfreshwater/SDM/richness/',tax,'/images/',sep=''); dir.create(out.dir,recursive=TRUE); setwd(out.dir)
cols=colorRampPalette(c("#A50026","#D73027","#F46D43","#FDAE61","#FEE090","#FFFFBF","#E0F3F8","#ABD9E9","#74ADD1","#4575B4","#313695"))(11)

vois=c(10,50,90)

for (yr in YEARs) { 
	
	png(paste(es,'_delta_',yr,'.png',sep=''),width=dim(base.asc)[1]*1+80, height=dim(base.asc)[2]*3, units='px', pointsize=100, bg='lightgrey')
		par(mar=c(0,0,0,0),cex=1,oma=c(4,4,4,0)) #define the plot parameters

	    mat = matrix(c( 1,1,1,1,1,
					1,1,1,1,1,
					1,1,1,1,1,
					1,1,1,1,1,
					2,2,2,2,2,
					2,2,2,2,2,
					2,2,2,2,2,
					2,2,2,2,2,
					3,3,3,3,3,
					3,3,3,3,3,
					3,3,3,3,3,
					3,3,3,3,3,
					4,4,4,4,4),nr=13,nc=5,byrow=TRUE) #create a layout matrix for images
		
				layout(mat) #call layout as defined above
				
		for (voi in vois){ cat(yr,'-',voi,'\n')
			tasc=make.asc(pos[,paste(yr,'_',voi,sep='')])
			image(tasc,ann=F,axes=F,col=cols,zlim=zlim)
			plot(Drainageshape , lwd=10, ann=FALSE,axes=FALSE, add=TRUE)

					
		}
	labs=c("0",".2",".4",".6",".8","1","1.2","1.4","1.6","1.8",">=2")
	plot(1:20,axes=FALSE,ann=FALSE,type='n')
	text(10,18,"Proportion of current",cex=3)
	color.legend(2,10,18,15,labs,rect.col=cols,align="rb",gradient="x", cex=1.5)
	mtext(c('10th Percentile','50th Percentile','90th Percentile'),side=2,line=1,outer=TRUE,cex=2.5,at=c(0.3, 0.59, 0.875))
dev.off()
	
}


