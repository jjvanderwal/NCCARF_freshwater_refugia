######################################################################W############################
#Script to generate quantile maps for all RAMSARS
#C. James..........................................23rd Jan 2013

module load R-2.15.1

### start r
###Load necessary libraries
library(SDMTools); library(maptools); library(plotrix) #define the libraries needed
source('/home/jc148322/scripts/libraries/cool_functions.r')

###Set up directories

wd = '/home/jc165798/Climate/CIAS/Australia/1km/baseline.76to05/'; setwd(wd) #define and set the working directory
data.dir="/home/jc148322/NARPfreshwater/SDM/richness/summaries/deltas/"
image.dir='/home/jc148322/NARPfreshwater/Ramsars/richness_delta_maps/'; dir.create(image.dir,recursive=T)

###Set up base files
baseasc = read.asc.gz('base.asc.gz');
base5k = read.asc.gz('/home/jc165798/working/NARP_hydro/stability/OZ_5km/data/base.asc.gz') #define and set working directory

###Load RAMSAR data
RAMinfo = read.dbf('/home/jc246980/RAMSAR/RAMSAR_info.dbf')
Ramsarshape = readShapePoly('/home/jc246980/RAMSAR/GISlayers/ramsar_wetlands_for_download.shp') #read in your shapefile
load("/home/jc246980/Janet_Stein_data/Rivers.Rdata")
load("/home/jc246980/Janet_Stein_data/catchments.Rdata")

cols = colorRampPalette(c("#A50026","#D73027","#F46D43","#FDAE61","#FEE090","#FFFFBF","#E0F3F8","#ABD9E9","#74ADD1","#4575B4","#313695"))(21) #define the color ramp

deltalims = c(0,2)                                                                         #define the delta limits
deltalabs = c(paste('<',deltalims[1]),1,paste('>',deltalims[2]))


### set up data frame to create names and zoom extent for each ramsar
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

### Load all delta richness data for each taxa
setwd(data.dir)
vois=list.files()
yy="2085"
es="RCP85"

 for (voi in vois) { 
	tax=gsub("_delta.Rdata","",voi)

	load(voi) #object name: outdelta
		
	tdata = outdelta[,c(1:8,intersect(grep(yy,colnames(outdelta)),grep(es,colnames(outdelta))))]
	assign(tax,tdata)
}
pos=tdata[,c(1:8)]
RAMSARS=na.omit(sort(unique(tdata$ramsar)))

setwd(image.dir)
taxa=c('crayfish','fish','frog','turtles')

for(ram in RAMSARS) {
	
	Ramsar_name=ref_table[which(ref_table$ram==ram), 'RAMSAR_NAM'] [1]
	Ramsar_zoom=ref_table[which(ref_table$ram==ram), 'zoom'] [1]
	
	### Make the image
	png(paste(Ramsar_name,'.png',sep=''),width=dim(base5k)[1]*4+30, height=dim(base5k)[1]*3+120, units='px', pointsize=20, bg='grey90')

	par(mar=c(2,2,2,2),cex=1,oma=c(6,2,2,2))

	  mat = matrix(c( 13,13,13,14,14,14,14,14,14,15,15,15,
					  13,13,13,14,14,14,14,14,14,15,15,15,
					  13,13,13,14,14,14,14,14,14,15,15,15,
					  1,1,1,4,4,4,7,7,7,10,10,10,
					  1,1,1,4,4,4,7,7,7,10,10,10,
					  1,1,1,4,4,4,7,7,7,10,10,10,
					  2,2,2,5,5,5,8,8,8,11,11,11,
					  2,2,2,5,5,5,8,8,8,11,11,11,
					  2,2,2,5,5,5,8,8,8,11,11,11,
					  3,3,3,6,6,6,9,9,9,12,12,12,
					  3,3,3,6,6,6,9,9,9,12,12,12,
					  3,3,3,6,6,6,9,9,9,12,12,12),nr=12,nc=12,byrow=TRUE) #create a layout matrix for images

	layout(mat) #call layout as defined above
	counter=0
	for (tax in taxa){ 
		counter=counter+1
		tdata=get(taxa[counter])
		ram_data=tdata[which(tdata$ramsar==ram),] #used only in determining zoom
			
		assign.list(min.lon,max.lon,min.lat,max.lat) %=% dynamic.zoom(ram_data$lon,ram_data$lat, padding.percent=Ramsar_zoom)

		xlim=c(min.lon,max.lon);
		ylim=c(min.lat,max.lat)

		for (ii in 9:11) { cat(tax, '-', ii-8,'\n')
			image(baseasc, ann=FALSE,axes=FALSE,col='white',  xlim=xlim,ylim=ylim) 
			tasc = baseasc; tasc[cbind(pos$row,pos$col)] = tdata[,9]
			image(tasc,ann=FALSE,axes=FALSE,zlim=deltalims,col=cols, add=TRUE) 
			plot(rivers, lwd=2, ann=FALSE,axes=FALSE, add=TRUE, col='cornflowerblue')
			plot(catchments, lwd=2, ann=FALSE,axes=FALSE, add=TRUE,border="darkgrey", lwd=1.5)	
			plot(Ramsarshape, lwd=2, ann=FALSE,axes=FALSE, add=TRUE)			
			mtext('10th', line=1,  side=2, cex=2.5)
		}

	}
	assign.list(l,r,b,t) %=% par("usr") # make sure this follows a plot to get the extent correct!
	image(baseasc,ann=FALSE,axes=FALSE,col='white', zlim=c(0,1))
	image(clip.image(l,r,b,t),ann=FALSE,axes=FALSE, col="black",add=TRUE)

	plot(1:20,axes=FALSE,ann=FALSE,type='n')
	text(10,15,Ramsar_name,cex=3) 
	text(10,10,variable_name,cex=3) 
	text(10,5,'RCP8.5 2085',cex=3) 

	plot(1:20,axes=FALSE,ann=FALSE,type='n')
	text(10,14,"Difference from current",cex=3)
	color.legend(4,2,16,8,deltalabs,cols,align="rb",gradient="x", cex=2)

	dev.off()
}
