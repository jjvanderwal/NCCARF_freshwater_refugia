###get the command line arguments
args=(commandArgs(TRUE)); for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments
# tax='fish'

source('/home/jc148322/scripts/libraries/cool_functions.r')
library(SDMTools);library(plotrix); library(maptools)

wd = '/home/jc165798/Climate/CIAS/Australia/1km/baseline.76to05/'; setwd(wd) #define and set the working directory
base.asc = read.asc.gz('base.asc.gz');
data.dir='/home/jc148322/NARPfreshwater/SDM/richness/summaries/deltas/'; setwd(data.dir)
load(paste(tax,'_delta.Rdata',sep=''))
pos=as.data.frame(outdelta[,c(1:5)])

cois=grep('RCP',colnames(outdelta))
outdelta=as.matrix(outdelta[,cois])
outdelta[which(is.na(outdelta))]=-0.1 #add -0.1 for white

deltalims=c(-0.1,2)
deltalabs=c('0','>=2')
###02. Create image

Drainageshape = readShapePoly('/home/jc246980/Janet_Stein_data/Drainage_division') #read in your shapefile

YEARs=seq(2015,2085,10)
out.dir=paste('/home/jc148322/NARPfreshwater/Appendix/richness/',tax,'/',sep=''); dir.create(out.dir,recursive=TRUE); setwd(out.dir)
cols=c('white',colorRampPalette(c("#A50026","#D73027","#F46D43","#FDAE61","#FEE090","#FFFFBF","#E0F3F8","#ABD9E9","#74ADD1","#4575B4","#313695"))(21))
legend.cols=colorRampPalette(c("#A50026","#D73027","#F46D43","#FDAE61","#FEE090","#FFFFBF","#E0F3F8","#ABD9E9","#74ADD1","#4575B4","#313695"))(21)

taxname=gsub(substr(tax,1,1),toupper(substr(tax,1,1)),tax)
if (substr(tax,nchar(tax),nchar(tax))=='s') taxname=gsub(substr(tax,nchar(tax),nchar(tax)),'',taxname)


for (year in YEARs) { cat(year,'\n') #cycle through each of the years
	##first work with RCPs
	ESs = c('RCP3PD','RCP45','RCP6','RCP85') #define the emission scenarios of interest
	png(paste('RCP_delta_',year,'.png',sep=''),width=dim(base.asc)[1]*4+150, height=dim(base.asc)[2]*3+300, units='px', pointsize=20, bg='lightgrey')
		par(mar=c(0,3,0,3),mfrow=c(3,4),cex=1,oma=c(10,10,10,0)) #define the plot parameters
		first=TRUE
		for (percentile in c(10,50,90)) { cat(percentile,'\n') #cycle through the percentiles
			for (es in ESs) { cat(es,'\n') #cycle through the emission scenarios of interst
				##plot the delta
				tasc = base.asc; tasc[cbind(pos$row,pos$col)] = outdelta[,paste(es,year,percentile,sep='_')] #get the data
				tasc[which(tasc<deltalims[1])] = deltalims[1]; tasc[which(tasc>deltalims[2])] = deltalims[2] #ensure all data within limits
				image(tasc,ann=FALSE,axes=FALSE,zlim=deltalims,col=cols) #create the image
				if (percentile==90 & es==ESs[length(ESs)]) color.legend(118,-44,140,-41,deltalabs,legend.cols,cex=10)
			}
		}
		mtext(ESs,side=3,line=1,outer=TRUE,cex=10,at=seq(1/8,0.99,1/4))
		mtext(paste(year,' Change in ',taxname,' Environment Richness',sep=''),side=1,line=3,outer=TRUE,cex=10)
		mtext(c('90th','50th','10th'),side=2,line=1,outer=TRUE,cex=10,at=seq(1/6,0.99,1/3))
	dev.off()
}
