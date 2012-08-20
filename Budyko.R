#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
####################################################################################
#required to build code OUTSIDE R
cd /home/jc165798/SCRIPTS/sdmcode/R_development/hydrology

R CMD SHLIB Budyko.c    # compiles c for use in R 

####################################################################################
#START R
####################################################################################
dyn.load('/home/jc165798/SCRIPTS/sdmcode/R_development/hydrology/Budyko.so') #load the C code

##### run Budyko code simply providing matrix 12xn where columns represent 12 months -- static analysis
base.asc='/home/jc165798/Climate/AWAP.direct.download/summaries/Oz/base.asc.gz'
pos='/home/jc165798/Climate/AWAP.direct.download/summaries/Oz/base.positions.csv'
tmin='/home/jc165798/Climate/AWAP.direct.download/summaries/Oz/monthly.csv/tmin19402009.csv'
tmax='/home/jc165798/Climate/AWAP.direct.download/summaries/Oz/monthly.csv/tmax19402009.csv'
pr='/home/jc165798/Climate/AWAP.direct.download/summaries/Oz/monthly.csv/rain19402009.csv'
outname='current'

library(SDMTools) #load the necessary library
dyn.load('/home/jc165798/SCRIPTS/sdmcode/R_development/hydrology/Budyko.so') #load the C code

###set directories
wd = '/home/jc165798/working/NARP_hydro/'; setwd(wd) #deifne and set the working directory

####read in all necessary inputs
base.asc = read.asc.gz(base.asc) #read in the base asc file
pos = read.csv(pos,as.is=TRUE)
pos$PAWHC = extract.data(cbind(pos$lon,pos$lat),read.asc('inputs/PAWHC_5km.asc')) #append data to pos
pos$PAWHC[which(is.na(pos$PAWHC))] = mean(pos$PAWHC,na.rm=TRUE) #set missing data to mean values
pos$kRs = extract.data(cbind(pos$lon,pos$lat),read.asc('inputs/kRs_5km.asc'))
pos$kRs[which(is.na(pos$kRs))] = 0.16 #set missing data to 0.16
pos$DEM = extract.data(cbind(pos$lon,pos$lat),read.asc('inputs/DEM_5km.asc'))

if (outname=='current') {
	tmin = read.csv(tmin,as.is=TRUE)[,-c(1:2)] #read in monthly tmin
	tmax = read.csv(tmax,as.is=TRUE)[,-c(1:2)] #read in monthly tmax
	pr = read.csv(pr,as.is=TRUE)[,-c(1:2)] #read in precipitatation
} else {
	tmin = read.csv(tmin,as.is=TRUE) #read in monthly tmin
	tmax = read.csv(tmax,as.is=TRUE) #read in monthly tmax
	pr = read.csv(pr,as.is=TRUE) #read in precipitatation
}

#trim up the data to years of interest
yois = 1976:2005
cois = NULL; for (yy in yois) cois = c(cois,grep(yy,colnames(pr)))
tmin = tmin[,cois]; tmax = tmax[,cois]; pr = pr[cois]

###run the analysis and write out data
tt = .Call('BudykoBucketModelDynamic',
	pos$DEM, #dem info
	as.matrix(pr), # monthly precip
	as.matrix(tmin), #monthly tmin
	as.matrix(tmax), #monthly tmax
	pos$PAWHC, #soil water holding capacity
	pos$kRs, #unknown kRs values 
	pos$lat / (180/pi), #latitudes in radians
	nrow(pr), #number of rows that need run
	ncol(pr) #number of months to run through
)
summary(as.vector(tt[[1]]))
summary(as.vector(tt[[2]]))
summary(as.vector(tt[[3]]))
summary(as.vector(tt[[4]]))


Eact = tt[[1]]; save(Eact, file=paste('output/Eact.',outname,'.Rdata',sep='')) #save the actual evapotranspiration
Epot = tt[[2]]; save(Epot, file=paste('output/Epot.',outname,'.Rdata',sep='')) #save the potential evapotranspiration
Qrun = tt[[3]]; save(Qrun, file=paste('output/Qrun.',outname,'.Rdata',sep='')) #save the runoff
Rnet = tt[[4]]; save(Rnet, file=paste('output/Rnet.',outname,'.Rdata',sep='')) #save the net radiation




####################################################################################
##### run Budyko code simply providing matrix 12xn where columns represent 12 months -- static analysis
base.asc='/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/base.asc.gz'
pos='/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/base.positions.csv'
tmin='/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/monthly.tmin.csv'
tmax='/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/monthly.tmax.csv'
pr='/home/jc165798/Climate/CIAS/Australia/5km/baseline.76to05/monthly.pr.csv'
outname='current'

library(SDMTools) #load the necessary library
dyn.load('/home/jc165798/SCRIPTS/sdmcode/R_development/hydrology/Budyko.so') #load the C code

###set directories
wd = '/home/jc165798/working/NARP_hydro/'; setwd(wd) #deifne and set the working directory

####read in all necessary inputs
base.asc = read.asc.gz(base.asc) #read in the base asc file
pos = read.csv(pos,as.is=TRUE)
pos$PAWHC = extract.data(cbind(pos$lon,pos$lat),read.asc('inputs/PAWHC_5km.asc')) #append data to pos
pos$PAWHC[which(is.na(pos$PAWHC))] = mean(pos$PAWHC,na.rm=TRUE) #set missing data to mean values
pos$kRs = extract.data(cbind(pos$lon,pos$lat),read.asc('inputs/kRs_5km.asc'))
pos$kRs[which(is.na(pos$kRs))] = 0.16 #set missing data to 0.16
pos$DEM = extract.data(cbind(pos$lon,pos$lat),read.asc('inputs/DEM_5km.asc'))

if (outname=='current') {
	tmin = read.csv(tmin,as.is=TRUE)[,-c(1:2)] #read in monthly tmin
	tmax = read.csv(tmax,as.is=TRUE)[,-c(1:2)] #read in monthly tmax
	pr = read.csv(pr,as.is=TRUE)[,-c(1:2)] #read in precipitatation
} else {
	tmin = read.csv(tmin,as.is=TRUE) #read in monthly tmin
	tmax = read.csv(tmax,as.is=TRUE) #read in monthly tmax
	pr = read.csv(pr,as.is=TRUE) #read in precipitatation
}

###run the analysis and write out data
tt = .Call('BudykoBucketModelStatic',
	pos$DEM, #dem info
	as.matrix(pr), # monthly precip
	as.matrix(tmin), #monthly tmin
	as.matrix(tmax), #monthly tmax
	pos$PAWHC, #soil water holding capacity
	pos$kRs, #unknown kRs values 
	pos$lat / (180/pi), #latitudes in radians
	nrow(pr) #number of rows that need run
)

summary(as.vector(tt[[1]]))
summary(as.vector(tt[[2]]))
summary(as.vector(tt[[3]]))
summary(as.vector(tt[[4]]))


Eact = tt[[1]]; save(Eact, file=paste('output/Eact.',outname,'.Rdata',sep='')) #save the actual evapotranspiration
Epot = tt[[2]]; save(Epot, file=paste('output/Epot.',outname,'.Rdata',sep='')) #save the potential evapotranspiration
Qrun = tt[[3]]; save(Qrun, file=paste('output/Qrun.',outname,'.Rdata',sep='')) #save the runoff
Rnet = tt[[4]]; save(Rnet, file=paste('output/Rnet.',outname,'.Rdata',sep='')) #save the net radiation

# setup plot info
months=c('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')
pnts=cbind(x=c(112,116,116,112), y=c(-11,-11,-18.5,-18.5))
cols = colorRampPalette(c('skyblue','slateblue','forestgreen','yellow','red'))(101)
#image for runoff
zlim=c(min(Qrun,na.rm=T),max(Qrun,na.rm=T))
png(paste('output/Qrun.',outname,'.png',sep=''), width=28, height=19, units='cm', res=300, pointsize=5, bg='white')
	par(mfrow=c(3,4),mar=c(0,1,0,1), oma=c(0,3,3,0)) #make 4 columns of 3 rows of images 
	for (ii in 1:12) { cat(ii, '\n')
		Qrun.asc=base.asc; Qrun.asc[cbind(pos$row,pos$col)]=Qrun[,ii]
		image(Qrun.asc, zlim=zlim, ann=FALSE,axes=FALSE,col=cols)
		text (130, -40, months[ii], cex=4)
		if (ii==1) {legend.gradient(pnts,cols=cols,limits=round(zlim,digits=4), title='Qrun', cex=3)}
	}

dev.off()

