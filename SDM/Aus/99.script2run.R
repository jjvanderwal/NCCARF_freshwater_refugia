###get the command line arguments
args=(commandArgs(TRUE)); for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments


library(SDMTools); library(plotrix);library(parallel)
source('/home/jc148322/scripts/libraries/cool_functions.r')

#working directory
setwd(wd)
load('/home/jc148322/NARPfreshwater/SDM/clip.Rdata') #load position data of segmentNo and provinces. object called clip.
load('/home/jc148322/NARPfreshwater/SDM/connectivity.file.Rdata') #load position data of segmentNo and connected 'sub-graphs'. object called connectivity.


base.asc = read.asc.gz(paste('/home/jc148322/NARPfreshwater/SDM/SegmentNo_1km.asc.gz',sep='')) #read in the base asc file
pos=make.pos(base.asc)
pos$SegmentNo=extract.data(cbind(pos$lon,pos$lat),base.asc)
tpos=pos

es='RCP85'

species=list.files(wd)


	pos=tpos
	#working directory
	spp.dir=paste(wd,spp,'/',sep='');setwd(spp.dir)
	threshold=read.csv('output/maxentResults.csv',as.is=TRUE) #read in the data for threshold
	threshold=threshold$Equate.entropy.of.thresholded.and.original.distributions.logistic.threshold #isolate threshold


	##01. Clip to threshold
	load(paste('summary/',es,'.pot.mat.Rdata',sep='')) #load the potential distribution data. object is called pot.mat
	cois=c(1,2,grep(2085,colnames(pot.mat))) #limit pot.mat to SegNo, Current, and 2085
	pot.mat=pot.mat[,cois]
	real.mat=pot.mat[,2:ncol(pot.mat)] #create a copy of potential matrix for clipping, drop SegmentNo (rebind later)
	real.mat[which(real.mat<=threshold)]=0 #clip anything below threshold to 0


	###02. Clip to province (realized)
	# if(file.exists('summary/clip.csv')) {
		# SegmentNo=read.csv('summary/clip.csv',as.is=TRUE)
	# } else {
		occur=read.csv('occur.csv',as.is=T) #load occurrence data
		provinces=unique(clip$province[which(clip$SegmentNo %in% occur$lat)])#find the provinces in which species has been observed
		SegmentNo=clip$SegmentNo[which(clip$province %in% provinces)] #find the segment nos within those provinces
		
		real.mat[which(!(pot.mat[,'SegmentNo'] %in% SegmentNo)),]=0 #apply the clip
		SegmentNo=pot.mat[which(real.mat[,1]>0),1] #further limit the clip to streams connected to areas currently suitable - find all currently suitable SegmentNos
		
		catchments=unique(connectivity[which(connectivity[,1] %in% SegmentNo),2])#find the basins that have a suitable section currently
		SegmentNo=connectivity[which(connectivity[,2] %in% catchments),1] #find the segment nos within those catchments
		
		SegmentNo=as.data.frame(SegmentNo) #turn it into a data frame for saving ease
		write.csv(SegmentNo,'summary/clip.csv',row.names=FALSE) #save
	# }

	real.mat[which(!(pot.mat[,'SegmentNo'] %in% SegmentNo[,1])),]=0 #apply the clip
	tdata=real.mat[,grep(2085,colnames(real.mat))]
	
	ncore=6 #define number of cores
	cl <- makeCluster(getOption("cl.cores", ncore))#define the cluster for running the analysis
		tout = t(parApply(cl,tdata,1,function(x) { return(quantile(x,c(0.1,0.5,0.9),na.rm=TRUE,type=8)) }))
	stopCluster(cl) #stop the cluster for analysis

	real.mat=cbind(pot.mat[,1],real.mat[,1],tout);colnames(real.mat)=c('SegmentNo','Current','Tenth','Fiftieth','Ninetieth')
	#image
	pos=merge(pos,real.mat, by='SegmentNo',all.x=T)
	
	occur=read.csv('occur.csv',as.is=T)
	occur=occur[,1:2]; colnames(occur)=c('spp','SegmentNo')
	occur=merge(occur,pos[,c('SegmentNo','lat','lon')],by='SegmentNo')
	occur=occur[!duplicated(occur$SegmentNo),]
	
	bins = seq(0,1,length=101); bins = cut(threshold,bins,labels=FALSE) # get the threshold bin for cols
	cols = c(rep('lightgrey',bins),colorRampPalette(c("wheat","tan","forestgreen","darkgreen"))(100)[bins:100])

	out.dir=paste('/home/jc148322/NARPfreshwater/SDM/images/',tax,'/',sep=''); dir.create(out.dir); setwd(out.dir)
	
	vois=c('Current','Fiftieth','Tenth','Ninetieth')
	png(paste(es,'_',spp,'_2085.png',sep=''),width=dim(base.asc)[1]*2+200,height=dim(base.asc)[2]*2+50,units='px', pointsize=30, bg='white')
	par(mfrow=c(2,2),mar=c(2,2,2,2))
		for (voi in vois){ cat(spp,'-',voi,'\n')
			tasc=make.asc(pos[,voi])
			image(tasc,ann=F,axes=F,col=cols,zlim=c(0,1))
			if (voi==vois[1]) { mtext(voi,side=1,cex=4)
			points(occur[,c('lon','lat')],pch=16)
			} else { mtext(paste(voi,' percentile - 2085',sep=''),side=1,cex=4)}
					
		}
	color.legend(118,-42,140,-41,c(0,1),cols,cex=4)
	dev.off()
	
	
	

