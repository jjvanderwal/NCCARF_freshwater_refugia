args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

source('/home/jc148322/scripts/libraries/cool_functions.r')
library(SDMTools)

current=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/output/projection/current.csv',sep='')
if (file.exists(current)) {

base.asc = read.asc.gz(paste('/home/jc148322/NARPfreshwater/SDM/SegmentNo_1km.asc.gz',sep='')) #read in the base asc file
tpos = read.csv(paste('/home/jc165798/Climate/CIAS/Australia/1km/baseline.76to05/base.positions.csv',sep=''),as.is=TRUE)

tpos$SegmentNo=extract.data(cbind(pos$lon,pos$lat),base.asc)

cols=colorRampPalette(c('tan','forestgreen','olivedrab2'))(100)

spp.dir=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/',sep='');setwd(spp.dir)

files=list.files(paste(spp.dir,'output/projection/',sep='')


for (tfile in files) {
	filename=gsub('.csv','',tfile)
	pos=tpos
	spdata=read.csv(paste(spp.dir,'output/projection/',tfile,'.csv',sep=''),as.is=T)
	spdata=spdata[,c(1,3)]; colnames(spdata)=c('SegmentNo','spdata')
	pos=merge(pos,spdata, by='SegmentNo')
	tasc=make.asc(pos$spdata)
	
	occur=read.csv(paste(spp.dir,'occur.csv',sep=''),as.is=T)
	occur=occur[,1:2]; colnames(occur)[2]='SegmentNo'
	toccur=merge(occur,pos,by='SegmentNo')
	
	out.dir=paste(spp.dir,'images/',sep='');dir.create(out.dir)
	png(paste(out.dir,filename,'.png',sep=''),width=dim(base.asc)[1], height=dim(base.asc)[2], units='px', pointsize=20, bg='white')
	image(tasc,ann=F,axes=F,col=cols,zlim=c(0,1))
	points(toccur$lon,toccur$lat,pch=16)
	dev.off()
	pos$spdata=NULL

}
}
