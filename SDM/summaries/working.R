#Script to generate trend maps for each RAMSAR
# Code to produce trend graphs for ramsars
#required to run ... module load R-2.15.1
library(SDMTools);library(maptools); library(plotrix)
source('/home/jc148322/scripts/libraries/cool_functions.r') 

##########################################
#input variables
data_type='delta' #'absolute' or 'delta'
##########################################

wd = '/home/jc165798/working/NARP_hydro/stability/OZ_5km/data/'; setwd(wd) #define and set working directory
baseasc = read.asc.gz('base.asc.gz')

ESs=c('RCP3PD','RCP45','RCP6','RCP85') 
YEARs=seq(2015,2085,10) 
data.dir="/home/jc148322/NARPfreshwater/SDM/richness/summaries/Ramsars/"
image.dir=paste('/home/jc148322/NARPfreshwater/Ramsars/richness_trends/',data_type,'/',sep='');dir.create(image.dir,recursive=T)

### set up data frame to create names and zoom extent for each ramsar

RAMinfo = read.dbf('/home/jc246980/RAMSAR/RAMSAR_info.dbf')
ram= c(13,27,26,32,31,33,9,15,17,14,12,6,1,3,2,5,24,4,29,22,28,36,37,7,8,10,11, 16, 23, 25, 30)
refcode=c(64,56,55,39,38,36,24,52,28,65,53,50,43,41,51,44,34,42,33,32,31,2,1,48,62, 49, 47, 23, 54, 35, 37)
zoom=c(20,100,100,100,100,50,150,15,15,15,100,20,50,20,20,20,20,20,50,30,30,30,30,80, 30, 80, 80, 100, 30, 50, 30)
ref_table=cbind(as.data.frame(ram), as.data.frame(refcode),as.data.frame(zoom))
ref_table=merge(ref_table,RAMinfo[, c("REFCODE","RAMSAR_NAM")], by.x='refcode', by.y='REFCODE')
ref_table$RAMSAR_NAM=as.character(ref_table$RAMSAR_NAM)

ref_table$RAMSAR_NAM[ which(ref_table$RAMSAR_NAM=="Toolibin Lake (also known as Lake Toolibin)")] <- "Toolibin Lake"
ref_table$RAMSAR_NAM[ which(ref_table$RAMSAR_NAM=="Currawinya Lakes (Currawinya National Park)")] <- "Currawinya Lakes"
ref_table$RAMSAR_NAM[ which(ref_table$RAMSAR_NAM=="Shoalwater and Corio Bays Area (Shoalwater Bay Training Area, in part - Corio Bay)")] <- "Shoalwater and Corio Bays Area"
ref_table$RAMSAR_NAM[ which(ref_table$RAMSAR_NAM=="Gwydir Wetlands: Gingham and Lower Gwydir (Big Leather) Watercourses")] <- "Gwydir Wetlands"
ref_table$RAMSAR_NAM[ which(ref_table$RAMSAR_NAM=="Great Sandy Strait (including Great Sandy Strait, Tin Can Bay and Tin Can Inlet).")] <- "Great Sandy Strait"

taxa=list.files(data.dir)
setwd(data.dir)
for (tax in taxa) {
	load(tax)

	if(data_type=='absolute') tdata=table_abs
	if(data_type=='delta') tdata=table_delta
	#rearrange data to be same format as script requires
	rois=grep('quant_50',rownames(tdata))
	tdata=tdata[rois,]
	RAMSARS=gsub('_quant_50','',rownames(tdata))

	out=expand.grid(RAMSARS, YEARs,ESs)

	vois=c('_10','_50','_90')
	for (voi in vois) {
		cois=grep(voi,colnames(tdata))
		out=cbind(out,as.vector(tdata[,cois]))
	}
	colnames(out)=c('RAMSARS','YEARs','ESs','Q10th','Q50th','Q90th')
	out=out[,c(1,3,2,4,5,6)]
	out=out[order(out$RAMSARS,out$ESs),]
	out[,c(4:6)]=round(out[c(4:6)],1)

	tax=strsplit(tax,'_')[[1]][2]
	for (ram in RAMSARS) {		
			

		Ramsar_name=ref_table[which(ref_table$ram==ram), 'RAMSAR_NAM'] [1]
		
		graph_data = out[(out$RAMSARS==ram) & (out$ESs=="RCP85") |(out$RAMSARS==ram) &(out$ESs=="RCP45") ,]	
		ylim=c(round(min(graph_data[,4:6])-0.5),round(max(graph_data[,4:6])+0.6))
		
		if(ylim[1]==0 & ylim[2]==1 | is.na(ylim[1]) | is.na(ylim[2])) { #do not make an image
		} else {

		
		png(paste(image.dir,Ramsar_name,'_',tax,'_trends.png',sep=''),width=dim(baseasc)[1]*2+30, height=dim(baseasc)[1], units='px', pointsize=20, bg='white') 
		par(mfrow=c(1,2),mar=c(5,5,2,1), oma=c(2,0,1,0)) 	
		
		graph_data = out[(out$RAMSARS==ram) & (out$ESs=="RCP45"),]	

		plot(graph_data[,3],graph_data[,5],xlab='', ylab='Richness (# of species)', font.sub=2, font.lab=1, xlim=c(2015,2085),ylim=ylim, type='n', cex.lab=1.8, cex.axis=1, axes=F,xaxs='i',yaxs='i', col.axis='grey20')
		rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = "grey90")
		abline(h=c(seq(ylim[1],ylim[2],1)),v=YEARs, col="white")
		polygon(c(graph_data[,3], rev(graph_data[,3])), c(graph_data[,4], rev(graph_data[,6])), col=adjustcolor('orange',alpha.f=0.5),lty=0) 	
		lines(graph_data[,3],graph_data[,5], col='grey20')  	
		axis(1,YEARs[2:7],labels=YEARs[2:7],lwd=0.5,lwd.ticks=0.5,cex.axis=1.6,col='grey20') 	
		axis(2,seq(ylim[1],ylim[2],1),labels=round(seq(ylim[1],ylim[2],1)),lwd=0.5,lwd.ticks=0.5,cex.axis=1.6,col='grey20') 	 	
		legend(2016,(((ylim[2]-(ylim[1]))/5)*0.5)+(ylim[1]), 'Best estimate (50th percentile)',lwd=1, bty='n',xjust=0, cex=1.25) 	
		legend(2018,(((ylim[2]-(ylim[1]))/5)*0.85)+(ylim[1]), 'Variation between GCMs (10th-90th)', fill=adjustcolor('orange',alpha.f=0.5),border=adjustcolor('orange',alpha.f=0.5),bty='n', cex=1.25) 	
		mtext('Low (RCP45)', line=3,  side=1, cex=2,font=2)  	
	
		
		graph_data = out[(out$RAMSARS==ram) & (out$ESs=="RCP85"),]	
		plot(graph_data[,3],graph_data[,5],xlab='', ylab='Richness (# of species)', font.sub=2, font.lab=1, xlim=c(2015,2085),ylim=ylim, type='n', cex.lab=1.8, cex.axis=1, axes=F,xaxs='i',yaxs='i', col.axis='grey20')
		rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = "grey90")
		abline(h=c(seq(ylim[1],ylim[2],1)),v=YEARs, col="white")			
		polygon(c(graph_data[,3], rev(graph_data[,3])), c(graph_data[,4], rev(graph_data[,6])), col=adjustcolor('orange',alpha.f=0.5),lty=0) 	
		lines(graph_data[,3],graph_data[,5], col='grey20')  	
		axis(1,YEARs[2:7],labels=YEARs[2:7],lwd=0.5,lwd.ticks=0.5,cex.axis=1.6,col='grey20') 	
		axis(2,seq(ylim[1],ylim[2],1),labels=round(seq(ylim[1],ylim[2],1)),lwd=0.5,lwd.ticks=0.5,cex.axis=1.6,col='grey20') 	 	
		legend(2016,(((ylim[2]-(ylim[1]))/5)*0.5)+(ylim[1]), 'Best estimate (50th percentile)',lwd=1, bty='n',xjust=0, cex=1.25) 	
		legend(2018,(((ylim[2]-(ylim[1]))/5)*0.85)+(ylim[1]), 'Variation between GCMs (10th-90th)', fill=adjustcolor('orange',alpha.f=0.5),border=adjustcolor('orange',alpha.f=0.5),bty='n', cex=1.25) 	
		mtext('High (RCP85)', line=3,  side=1, cex=2,font=2)  
		
		dev.off() 
		}
	}
}

