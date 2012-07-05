#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
####################################################################################
#required to build code OUTSIDE R
cd /home/jc165798/SCRIPTS/sdmcode/R_development/hydrology

R CMD SHLIB Budyko.c    # compiles c for use in R 

####################################################################################
#START R
#the function
dyn.load("/home/jc165798/SCRIPTS/sdmcode/R_development/hydrology/Budyko.so")

library(SDMTools) #load the necessary library
data.dir = "/home/jc165798/Climate/AWAP.direct.download/summaries/Oz/baseline.76to05"
out.dir = "/home/jc165798/working/NARP_hydro/"; dir.create(out.dir); setwd(out.dir)
pos = read.csv('/home/jc165798/working/NARP_stability/OZ_5km/data/base.positions.csv',as.is=TRUE)
PAWHC.asc = read.asc(paste(out.dir,'inputs/PAWHC_5km.asc', sep='')) #read in the base ascii grid file
kRs.asc = read.asc(paste(out.dir,'inputs/kRs_5km.asc', sep=''))
DEM_5km.asc = read.asc(paste(out.dir,'inputs/DEM_5km.asc', sep=''))

tmincur = read.csv(paste(data.dir,"/monthly.tmin.csv",sep=''),as.is=TRUE)
tmeancur = read.csv(paste(data.dir,"/monthly.tmean.csv",sep=''),as.is=TRUE)
tmaxcur = read.csv(paste(data.dir,"/monthly.tmax.csv",sep=''),as.is=TRUE)
prcur = read.csv(paste(data.dir,"/monthly.pr.csv",sep=''),as.is=TRUE)

tmincursub = tmincur[,-c(1:2)]
tmeancursub = tmeancur[,-c(1:2)]
tmaxcursub = tmaxcur[,-c(1:2)]
prcursub = prcur[,-c(1:2)]

PAWHC.mat = pos; PAWHC.mat$PAWHCcur = extract.data(cbind(pos$lon,pos$lat),PAWHC.asc)
kRs.mat = pos; kRs.mat$kRscur = extract.data(cbind(pos$lon,pos$lat),kRs.asc)
DEM_5km.mat = pos; DEM_5km.mat$DEM_5kmcur = extract.data(cbind(pos$lon,pos$lat),DEM_5km.asc)

PAWHCsub= PAWHC.mat[,5]
kRssub=  kRs.mat[,5]
DEM_5kmsub= DEM_5km.mat[,5]
latssub= PAWHC.mat[,1]


R_dem = DEM_5kmsub
R_rain = as.matrix(prcursub)
R_tmin = as.matrix(tmincursub)
R_tmax = as.matrix(tmaxcursub)
R_V_max = PAWHCsub/12
R_kRs = kRssub
R_lats_radians = latssub / (180/pi)
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

#######
#make an image of ouputs
base.asc = read.asc.gz('/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/base.asc.gz') #read in the base asc file
months=c('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
pnts=cbind(x=c(112,116,116,112), y=c(-11,-11,-18.5,-18.5))
cols = colorRampPalette(c('skyblue','slateblue','forestgreen','yellow','red'))(101)
image.dir=paste(out.dir,'images/',sep='')

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

#image for runoff
zlim=c(min(R_Q_run,na.rm=T),max(R_Q_run,na.rm=T))
png(paste(image.dir,'Qrun.png',sep=''), width=28, height=19, units='cm', res=300, pointsize=5, bg='white')

#make 4 columns of 3 rows of images 
par(mfrow=c(3,4),mar=c(0,1,0,1), oma=c(0,3,3,0))

for (ii in 1:12) { cat(ii, '\n')

	Qrun.asc=base.asc; Qrun.asc[cbind(pos$row,pos$col)]=R_Q_run[,ii]
	image(Qrun.asc, zlim=zlim, ann=FALSE,axes=FALSE,col=cols)
    text (130, -40, months[ii], cex=4)
    if (ii==1) {legend.gradient(pnts,cols=cols,limits=round(zlim,digits=4), title='Qrun', cex=3)}

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
