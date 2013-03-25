###get the command line arguments
args=(commandArgs(TRUE)); for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments
##should have read in:
#tax='fish'; wd = paste('/home/jc165798/working/NARP_FW_SDM/models_',tax,'/',sep=''); spp='Neosilurus_ater'

library(SDMTools); library(plotrix);library(sp)
source('/home/jc148322/scripts/libraries/cool_functions.r')

#working directory
setwd(wd)
load('/home/jc148322/NARPfreshwater/SDM/clip.Rdata') #load position data of segmentNo and provinces. object called clip.
load('/home/jc148322/NARPfreshwater/SDM/connectivity.file.Rdata') #load position data of segmentNo and connected 'sub-graphs'. object called connectivity.
load("/home/jc246980/Janet_Stein_data/Rivers.Rdata")
load("/home/jc246980/Janet_Stein_data/catchments.Rdata")

base.asc = read.asc.gz(paste('/home/jc148322/NARPfreshwater/SDM/SegmentNo_1km.asc.gz',sep='')) #read in the base asc file
pos=make.pos(base.asc)
pos$SegmentNo=extract.data(cbind(pos$lon,pos$lat),base.asc)


#working directory
spp.dir=paste(wd,spp,'/',sep='');setwd(spp.dir)
threshold=read.csv('output/maxentResults.csv',as.is=TRUE) #read in the data for threshold
threshold=threshold$Equate.entropy.of.thresholded.and.original.distributions.logistic.threshold #isolate threshold


##01. Clip to threshold
load('summary/RCP85.pot.mat.Rdata') #load the potential distribution data. object is called pot.mat
cois=c(1,2) #limit pot.mat to SegNo, Current, and 2085
pot.mat=pot.mat[,cois]

real.mat=pot.mat #create a copy of potential matrix for clipping, drop SegmentNo (rebind later)
real.mat[which(real.mat[,2]<=threshold),2]=0 #clip anything below threshold to 0


###02. Clip to realized
SegmentNo=read.csv('summary/clip.csv',as.is=TRUE)

real.mat[which(!(real.mat[,'SegmentNo'] %in% SegmentNo[,1])),2]=0  #apply the clip

colnames(real.mat)=c('SegmentNo','Current')

#image
pos=merge(pos,real.mat, by='SegmentNo',all.x=T)

occur=read.csv('occur.csv',as.is=T)
occur=occur[,1:2]; colnames(occur)=c('spp','SegmentNo')
occur=merge(occur,pos[,c('SegmentNo','lat','lon')],by='SegmentNo')
occur=occur[!duplicated(occur$SegmentNo),]

bins = seq(0,1,length=101); bins = cut(threshold,bins,labels=FALSE) # get the threshold bin for cols
cols = c(rep('lightgrey',bins),colorRampPalette(c("wheat","tan","forestgreen","darkgreen"))(100)[bins:100])

out.dir=paste('/home/jc148322/NARPfreshwater/SDM/images/',tax,'/',sep=''); dir.create(out.dir); setwd(out.dir)

assign.list(min.lon,max.lon,min.lat,max.lat) %=% dynamic.zoom(pos$lon[which(pos$Current>0)],pos$lat[which(pos$Current>0)], padding.percent=2)

xlim=c(min.lon,max.lon);
ylim=c(min.lat,max.lat)
		


png(paste(spp,'.current.png',sep=''),width=dim(base.asc)[1]*1+50,height=dim(base.asc)[2]*2+400,units='px', pointsize=30, bg='white')
	
par(mfrow=c(2,1),mar=c(10,2,2,2))
mat = matrix(c(3,3,4,4,
				1,1,1,1,
				1,1,1,1,
				1,1,1,1,
				2,2,2,2,
				2,2,2,2,
				2,2,2,2),nr=7,nc=4,byrow=TRUE) #create a layout matrix for images

	layout(mat) #call layout as defined above

		
		image(base.asc,ann=F,axes=F,col='lightgrey',xlim=xlim,ylim=ylim)
		plot(rivers, lwd=4, ann=FALSE,axes=FALSE, add=TRUE, col='cornflowerblue')
		plot(catchments, lwd=4, ann=FALSE,axes=FALSE, add=TRUE,border="black", lwd=1.5)
		assign.list(l,r,b,t) %=% par("usr")
		points(occur[,c('lon','lat')],pch=16,cex=1.5)
		mtext('Vetted occurrence records; rivers; basins',side=1,line=2,cex=4)
		
		tasc=make.asc(pos$Current)
		image(tasc,ann=F,axes=F,col=cols,zlim=c(0,1),xlim=xlim,ylim=ylim)
		plot(catchments, lwd=4, ann=FALSE,axes=FALSE, add=TRUE,border="black", lwd=1.5)
		mtext('Current suitability',side=1,line=2,cex=4)
		
		image(base.asc,ann=FALSE,axes=FALSE,col='lightgrey')
		image(clip.image(l,r,b,t),ann=FALSE,axes=FALSE, col="black",add=TRUE)
		

		plot(c(0,10),c(0,10),ann=F,axes=F,type='n')		
		color.legend(1,2,6,4,c(0,1),cols,cex=4)
		text(1,7,gsub('_',' ',spp),cex=7, font=3, pos=4)
dev.off()





















