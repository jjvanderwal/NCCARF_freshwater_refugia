#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
####################################################################################
#required to build code OUTSIDE R
cd /home/jc165798/SCRIPTS/sdmcode/R_development/hydrology

R CMD SHLIB Budyko.c    # compiles c for use in R 

####################################################################################
#START R

library(SDMTools) #load the necessary library
#set directories and basic data layers
data.dir = "/home/jc165798/Climate/AWAP.direct.download/summaries/Oz/baseline.76to05"
out.dir = "/home/jc165798/working/NARP_hydro/"; setwd(out.dir)
image.dir=paste(out.dir,'images/',sep='')
base.asc = read.asc.gz('/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/base.asc.gz') #read in the base asc file
pos = read.csv('/home/jc165798/working/NARP_stability/OZ_5km/data/base.positions.csv',as.is=TRUE)

# setup plot info
months=c('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
pnts=cbind(x=c(112,116,116,112), y=c(-11,-11,-18.5,-18.5))
cols = colorRampPalette(c('skyblue','slateblue','forestgreen','yellow','red'))(101)

#read in common enviro data
PAWHC.asc = read.asc(paste(out.dir,'inputs/bullshite.asc', sep='')) #read in the base ascii grid file
pos$PAWHC = extract.data(cbind(pos$lon,pos$lat),PAWHC.asc) #append data to pos
kRs.asc = read.asc(paste(out.dir,'inputs/kRs_5km.asc', sep=''))
pos$kRs = extract.data(cbind(pos$lon,pos$lat),kRs.asc)
DEM_5km.asc = read.asc(paste(out.dir,'inputs/DEM_5km.asc', sep=''))
pos$DEM = extract.data(cbind(pos$lon,pos$lat),DEM_5km.asc)

#read in monthly data
tmin = read.csv(paste(data.dir,"/monthly.tmin.csv",sep=''),as.is=TRUE)[,-c(1:2)]
tmax = read.csv(paste(data.dir,"/monthly.tmax.csv",sep=''),as.is=TRUE)[,-c(1:2)]
pr = read.csv(paste(data.dir,"/monthly.pr.csv",sep=''),as.is=TRUE)[,-c(1:2)]

# save.image(file='wd.RData')
#the function
dyn.load("/home/jc165798/SCRIPTS/sdmcode/R_development/hydrology/Budyko.so")
library(SDMTools) #load the necessary library
#load("/home/jc165798/working/NARP_hydro/wd.RData")
setwd(out.dir)

###prep data for input to function
R_dem = pos$DEM
R_rain = as.matrix(pr)
R_tmin = as.matrix(tmin)
R_tmax = as.matrix(tmax)
R_V_max = pos$PAWHC
R_kRs = pos$kRs
R_lats_radians = pos$lat / (180/pi)
R_rows = nrow(R_rain)

system.time({
tt = .Call('RunBudykoBucketModel_5km',
	R_dem,
	R_rain,
	R_tmin,
	R_tmax,
	R_V_max,
	R_kRs,
	R_lats_radians,
	R_rows
	)
 })

R_E_act = tt[[1]]
R_E_pot = tt[[2]]
R_Q_run = tt[[3]]
R_Rn = tt[[4]]

#create an image
pos$area = grid.area(base.asc)[cbind(pos$row,pos$col)] #get area of pixels
png(paste(image.dir,'annual.png',sep=''), width=dim(base.asc)[1]*2/100, height=dim(base.asc)[2]*3/100, units='cm', res=300, pointsize=5, bg='white')
	par(mfrow=c(3,2),mar=c(0,1,0,1), oma=c(0,3,3,0))
	#get annual rainfall
	tasc = base.asc; tasc[cbind(pos$row,pos$col)]=rowSums(R_rain,na.rm=TRUE) 
	zlims = range(c(0,as.vector(tasc)),na.rm=TRUE)
	image(tasc, ann=FALSE,axes=FALSE,col=cols,zlim=zlims)
	legend.gradient(pnts,cols=cols,limits=round(zlims,digits=4), title='annual rain', cex=3)
	#get annual runoff
	tasc = base.asc; tasc[cbind(pos$row,pos$col)]=rowSums(R_Q_run,na.rm=TRUE) 
	#tasc[which(tasc>=1000)] = 1000
	tasc = tasc / 1000 #convert depth to metres
	tasc = tasc * grid.area(tasc) #calclate volume of water on each pixel in cubic meters
	tasc = tasc / 1000 #calc to number of megaliters per pixel
	tasc = tasc / (grid.area(tasc)/1000000) #calc megaliters / km2
	tasc[which(tasc==0)] = 0
	tasc[which(tasc>0 & tasc<10)] = 1
	tasc[which(tasc>=10 & tasc<50)] = 2
	tasc[which(tasc>=50 & tasc<100)] = 3
	tasc[which(tasc>=100 & tasc<250)] = 4
	tasc[which(tasc>=250 & tasc<350)] = 5
	tasc[which(tasc>=350 & tasc<500)] = 6
	tasc[which(tasc>=500 & tasc<1000)] = 7
	tasc[which(tasc>=1000)] = 8
	zlims = range(c(0,as.vector(tasc)),na.rm=TRUE)
	image(tasc, ann=FALSE,axes=FALSE,col=cols,zlim=zlims)
	legend.gradient(pnts,cols=cols,limits=round(zlims,digits=4), title='annual runnoff', cex=3)
	#get annual pot evap
	tasc = base.asc; tasc[cbind(pos$row,pos$col)]=rowSums(R_E_pot,na.rm=TRUE) 
	zlims = range(c(0,as.vector(tasc)),na.rm=TRUE)
	image(tasc, ann=FALSE,axes=FALSE,col=cols,zlim=zlims)
	legend.gradient(pnts,cols=cols,limits=round(zlims,digits=4), title='annual pot evap', cex=3)
	#get annual rainfall
	tasc = base.asc; tasc[cbind(pos$row,pos$col)]=rowSums(R_E_act,na.rm=TRUE) 
	#zlims = range(c(0,as.vector(tasc)),na.rm=TRUE)
	image(tasc, ann=FALSE,axes=FALSE,col=cols,zlim=zlims)
	legend.gradient(pnts,cols=cols,limits=round(zlims,digits=4), title='annual act evap', cex=3)
	#get annual radiation
	tasc = base.asc; tasc[cbind(pos$row,pos$col)]=rowSums(R_Rn,na.rm=TRUE) 
	zlims = range(c(0,as.vector(tasc)),na.rm=TRUE)
	image(tasc, ann=FALSE,axes=FALSE,col=cols,zlim=zlims)
	legend.gradient(pnts,cols=cols,limits=round(zlims,digits=4), title='annual net radiation', cex=3)

dev.off()


#######
#make an image of ouputs
#image for runoff
zlim=c(min(R_Q_run,na.rm=T),max(R_Q_run,na.rm=T))
png(paste(image.dir,'Qrun_4_newpork.png',sep=''), width=28, height=19, units='cm', res=300, pointsize=5, bg='white')

#make 4 columns of 3 rows of images 
par(mfrow=c(3,4),mar=c(0,1,0,1), oma=c(0,3,3,0))

for (ii in 1:12) { cat(ii, '\n')

	Qrun.asc=base.asc; Qrun.asc[cbind(pos$row,pos$col)]=R_Q_run[,ii]
	image(Qrun.asc, zlim=zlim, ann=FALSE,axes=FALSE,col=cols)
    text (130, -40, months[ii], cex=4)
    if (ii==1) {legend.gradient(pnts,cols=cols,limits=round(zlim,digits=4), title='Qrun', cex=3)}

      }

dev.off()


#image for Ea
zlim=c(min(R_E_act,na.rm=T),max(R_E_act,na.rm=T))
png(paste(image.dir,'Ea.png',sep=''), width=28, height=19, units='cm', res=300, pointsize=5, bg='white')

#make 4 columns of 3 rows of images 
par(mfrow=c(3,4),mar=c(0,1,0,1), oma=c(0,3,3,0))

for (ii in 1:12) { cat(ii, '\n')

	Ea.asc=base.asc; Ea.asc[cbind(pos$row,pos$col)]=R_E_act[,ii]
	image(Ea.asc, zlim=zlim, ann=FALSE,axes=FALSE,col=cols)
    text (130, -40, months[ii], cex=4)
    if (ii==1) {legend.gradient(pnts,cols=cols,limits=round(zlim,digits=4), title='Ea', cex=3)}

      }

dev.off()

#image for Epot
zlim=c(min(R_E_pot,na.rm=T),max(R_E_pot,na.rm=T))
png(paste(image.dir,'Epot.png',sep=''), width=28, height=19, units='cm', res=300, pointsize=5, bg='white')

#make 4 columns of 3 rows of images 
par(mfrow=c(3,4),mar=c(0,1,0,1), oma=c(0,3,3,0))

for (ii in 1:12) { cat(ii, '\n')

	Epot.asc=base.asc; Epot.asc[cbind(pos$row,pos$col)]=R_E_pot[,ii]
	image(Epot.asc, zlim=zlim, ann=FALSE,axes=FALSE,col=cols)
    text (130, -40, months[ii], cex=4)
    if (ii==1) {legend.gradient(pnts,cols=cols,limits=round(zlim,digits=4), title='Epot', cex=3)}

      }

dev.off()


#image for Rn
zlim=c(min(R_Rn,na.rm=T),max(R_Rn,na.rm=T))
png(paste(image.dir,'Rn.png',sep=''), width=28, height=19, units='cm', res=300, pointsize=5, bg='white')

#make 4 columns of 3 rows of images 
par(mfrow=c(3,4),mar=c(0,1,0,1), oma=c(0,3,3,0))

for (ii in 1:12) { cat(ii, '\n')

	Rn.asc=base.asc; Rn.asc[cbind(pos$row,pos$col)]=R_Rn[,ii]
	image(Rn.asc, zlim=zlim, ann=FALSE,axes=FALSE,col=cols)
    text (130, -40, months[ii], cex=4)
    if (ii==1) {legend.gradient(pnts,cols=cols,limits=round(zlim,digits=4), title='Rn', cex=3)}

      }

dev.off()
