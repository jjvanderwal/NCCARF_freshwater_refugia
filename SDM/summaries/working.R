library(SDMTools); library(maptools); library(plotrix) #define the libraries needed
source('/home/jc148322/scripts/libraries/cool_functions.r')

###Set up directories

wd = '/home/jc165798/Climate/CIAS/Australia/1km/baseline.76to05/'; setwd(wd) #define and set the working directory
data.dir="/home/jc148322/NARPfreshwater/SDM/richness/summaries/deltas/"
image.dir='/home/jc148322/NARPfreshwater/tmp/'; dir.create(image.dir,recursive=T)

###Set up base files
base.asc = read.asc.gz('base.asc.gz');

#manipulate data
setwd(data.dir)
files=list.files(pattern='.Rdata')
files=files[c(2,1,4,3)]
taxa=c('Fish','Crayfish','Turtles','Frogs')
cols = c("#A50026","#FFFFBF","#E0F3F8","#ABD9E9")

png(paste(image.dir,'agreement.png',sep=''),width=dim(base.asc)[1]+30, height=dim(base.asc)[2]*2+40, units='px', pointsize=20, bg='grey')
mat=matrix(c(5,5,
			 5,5,
			 1,2,
			 3,4),nr=4,nc=2,byrow=TRUE)
layout(mat)
par(mar=c(4,2,2,2))
for (ii in 1:4) { cat(taxa[ii],'\n')
	load(files[ii])
	rm(out); cat('file loaded ... ')

	if(ii==1) pos=outdelta[,c(1:8)]
	tdata=outdelta[,c(102:104)]
	rm(outdelta)

	tdata=as.matrix(tdata)
	tdata[which(tdata<0.8)]=0
	tdata[which(tdata>1.2)]=0
	tdata[which(tdata>0)]=1
	pos$total=rowSums(tdata)
	pos$tmp=pos$total; pos$tmp[which(is.finite(pos$tmp))]=1; pos$tmp[which(is.na(pos$tmp))]=0
	if(ii==1)pos$weight=pos$tmp else pos$weight=pos$weight+pos$tmp
	pos$total[which(is.na(pos$total))]=0
	if(ii==1) pos$final=pos$total else pos$final=pos$final+pos$total
	tasc=make.asc(pos$total); cat('ascii made ... ')

	##Image


		image(tasc, ann=F, axes=F, col=cols)
		mtext(taxa[ii],side=1,cex=6); cat('image plotted\n')
}
pos$final=pos$final/pos$weight; pos$final[which(is.nan(pos$final))]=0
tasc=make.asc(pos$final)
cols = c("#A50026",colorRampPalette(c("#D73027","#F46D43","#FDAE61","#FEE090","#FFFFBF","#E0F3F8","#ABD9E9","#74ADD1","#4575B4","#313695"))(12))
image(tasc, ann=F, axes=F, col=cols)
dev.off()
	