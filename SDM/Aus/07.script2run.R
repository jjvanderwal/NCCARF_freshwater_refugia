###get the command line arguments
args=(commandArgs(TRUE)); for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments
##should have read in:
#taxon='frog'; wd = paste('/home/jc148322/NARPfreshwater/SDM/models_',taxon,'/',sep=''); spp='Adelotus_brevis'; clip.column='basins2'

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
distdata=read.csv('output/potential/current_1990.csv',as.is=T) #read the potential distribution data.
cois=c(2,3) #limit current distribution to SegNo, Current
distdata=distdata[,cois]; colnames(distdata)=c('SegmentNo',spp)

distdata[which(distdata[,2]<=threshold),2]=0 #clip anything below threshold to 0


###02. Clip to realized

###02a. First, find all SegmentNos of basins or fish provinces in which occurence has been recorded and clip the distribution model to this
occur=read.csv('occur.csv',as.is=T) #load occurrence data
regions=unique(clip[which(clip$SegmentNo %in% occur$lat),clip.column])#find the regions in which species has been observed - this will be fish provinces for fish, and level 2 basins for other taxa. Remember that occur$lat is actually SegmentNo
SegmentNo=clip$SegmentNo[which(clip[,clip.column] %in% regions)] #find the segment nos within those regions
distdata[which(!(distdata[,'SegmentNo'] %in% SegmentNo)),spp]=0 #apply the clip

###02b. Second, limit future distributions to connected catchments in projected to have at least one suitable segment
SegmentNo=distdata[which(distdata[,spp]>0),'SegmentNo'] #further limit the clip to streams connected to areas currently suitable - find all currently suitable SegmentNos

catchments=unique(connectivity[which(connectivity[,'SegmentNo'] %in% SegmentNo),'catchments'])#find the basins that have a suitable section currently
SegmentNo=connectivity[which(connectivity[,'catchments'] %in% catchments),'SegmentNo'] #find the segment nos within those catchments

SegmentNo=as.data.frame(SegmentNo) #turn it into a data frame for saving ease
write.csv(SegmentNo,'summary/clip.csv',row.names=FALSE) #save

distdata[which(!(distdata[,'SegmentNo'] %in% SegmentNo[,1])),spp]=0  #apply the clip

colnames(distdata)=c('SegmentNo','Current')

#image
pos=merge(pos,distdata, by='SegmentNo',all.x=T)

occur=read.csv('occur.csv',as.is=T)
occur=occur[,1:2]; colnames(occur)=c('spp','SegmentNo')
occur=merge(occur,pos[,c('SegmentNo','lat','lon')],by='SegmentNo')
occur=occur[!duplicated(occur$SegmentNo),]

bins = seq(0,1,length=101); bins = cut(threshold,bins,labels=FALSE) # get the threshold bin for cols
cols = c(rep('lightgrey',bins),colorRampPalette(c("wheat","tan","forestgreen","darkgreen"))(100)[bins:100])

out.dir=paste('/home/jc148322/NARPfreshwater/SDM/images/',taxon,'/',sep=''); dir.create(out.dir); setwd(out.dir)

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
		# plot(catchments, lwd=4, ann=FALSE,axes=FALSE, add=TRUE,border="black", lwd=1.5)
		assign.list(l,r,b,t) %=% par("usr")
		points(occur[,c('lon','lat')],pch=16,cex=1.5)
		mtext('Vetted occurrence records; rivers; basins',side=1,line=5,cex=4)
		
		tasc=make.asc(pos$Current)
		image(tasc,ann=F,axes=F,col=cols,zlim=c(0,1),xlim=xlim,ylim=ylim)
		# plot(catchments, lwd=4, ann=FALSE,axes=FALSE, add=TRUE,border="black", lwd=1.5)
		mtext('Current suitability',side=1,line=5,cex=4)
		
		image(base.asc,ann=FALSE,axes=FALSE,col='lightgrey')
		image(clip.image(l,r,b,t),ann=FALSE,axes=FALSE, col="black",add=TRUE)
		

		plot(c(0,10),c(0,10),ann=F,axes=F,type='n')		
		color.legend(1,2,6,4,c(0,1),cols,cex=4)
		text(1,7,gsub('_',' ',spp),cex=7, font=3, pos=4)
dev.off()





















