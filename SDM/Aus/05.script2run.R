###get the command line arguments
args=(commandArgs(TRUE)); for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

library(SDMTools); library(parallel)
source('/home/jc148322/scripts/libraries/cool_functions.r')

#working directory
setwd(wd)
load('/home/jc148322/NARPfreshwater/SDM/clip.Rdata') #load position data of segmentNo and provinces. object called clip.
load('/home/jc148322/NARPfreshwater/SDM/connectivity.file.Rdata') #load position data of segmentNo and connected 'sub-graphs'. object called connectivity.

exclude=read.csv('/home/jc148322/NARPfreshwater/SDM/fish.to.exclude.csv',as.is=TRUE)
exclude=exclude[which(exclude[,2]=='exclude'),1]
species=list.files(wd)
species=setdiff(species,exclude)


richness=NULL
for (spp in species) {cat (spp,'\n')
	#working directory
	spp.dir=paste(wd,spp,'/',sep='');setwd(spp.dir)
	threshold=read.csv('output/maxentResults.csv',as.is=TRUE) #read in the data for threshold
	threshold=threshold$Equate.entropy.of.thresholded.and.original.distributions.logistic.threshold #isolate threshold


	##01. Clip to threshold
	load(paste('summary/',es,'.pot.mat.Rdata',sep='')) #load the potential distribution data. object is called pot.mat
	
	real.mat=pot.mat[,2:ncol(pot.mat)] #create a copy of potential matrix for clipping, drop SegmentNo (rebind later)
	real.mat[which(real.mat<=threshold)]=0 #clip anything below threshold to 0


	###02. Clip to province (realized)
	# if(file.exists('summary/clip.csv')) {
		# SegmentNo=read.csv('summary/clip.csv',as.is=TRUE)
	# } else {
		occur=read.csv('occur.csv',as.is=T) #load occurrence data
		provinces=unique(clip[which(clip$SegmentNo %in% occur$lat),clip.column])#find the provinces in which species has been observed
		SegmentNo=clip$SegmentNo[which(clip[,clip.column] %in% provinces)] #find the segment nos within those provinces
		
		real.mat[which(!(pot.mat[,'SegmentNo'] %in% SegmentNo)),]=0 #apply the clip
		SegmentNo=pot.mat[which(real.mat[,1]>0),1] #further limit the clip to streams connected to areas currently suitable - find all currently suitable SegmentNos
		
		catchments=unique(connectivity[which(connectivity[,1] %in% SegmentNo),2])#find the basins that have a suitable section currently
		SegmentNo=connectivity[which(connectivity[,2] %in% catchments),1] #find the segment nos within those catchments
		
		SegmentNo=as.data.frame(SegmentNo) #turn it into a data frame for saving ease
		write.csv(SegmentNo,'summary/clip.csv',row.names=FALSE) #save
	# }

	real.mat[which(!(pot.mat[,'SegmentNo'] %in% SegmentNo[,1])),]=0 #apply the clip
	real.mat[which(real.mat>0)]=1
	
	###03. Clip to connected basins (determined using igraph and connected From_Node To_Node)
	

	if(spp==species[1]) richness=real.mat else richness=richness+real.mat
	
}


#deal with future richness
save(richness,file=paste(es,'_richness.Rdata',sep='')) #save out the data in case
YEARs=seq(2015,2085,10)
out.dir=paste('/home/jc148322/NARPfreshwater/SDM/richness/',tax,'/',sep=''); dir.create(out.dir); setwd(out.dir)
outquant=NULL
for (yr in YEARs) {

	cois=grep(yr,colnames(richness))
	tdata=richness[,cois]

	ncore=8 #define number of cores
	cl <- makeCluster(getOption("cl.cores", ncore))#define the cluster for running the analysis
		tout = t(parApply(cl,tdata,1,function(x) { return(quantile(x,c(0.1,0.5,0.9),na.rm=TRUE,type=8)) }))
	stopCluster(cl) #stop the cluster for analysis

###need to store the outputs
	outquant=cbind(outquant,tout)
	

}
outquant=cbind(pot.mat[,1],richness[,1],outquant)
tt=expand.grid(c(10,50,90),YEARs)
colnames(outquant)=c('SegmentNo','current',paste(tt[,2],'_',tt[,1],sep=''))
save(outquant,richness,file=paste(es,'_richness.Rdata',sep=''))


