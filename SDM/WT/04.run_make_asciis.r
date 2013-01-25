args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

library(SDMTools) #load libraries and functions
source('/home/jc148322/scripts/libraries/cool_functions.r')

wd=paste('/home/jc148322/NARPfreshwater/SDM/Fish/models/',spp,'/output/WT_realized/',sep=''); setwd(wd) #set working directory
out.dir=paste('/home/jc148322/NARPfreshwater/SDM/Fish/models/',spp,'/output/asciis/WT_realized/',sep='')
dir.create(out.dir,recursive=TRUE)

### Prepare data for making asciis
base.asc=read.asc('/home/jc248851/ZONATION/CASSIE/RF/SegmentNo_AWT.asc') #need an ascii with SegmentNos		
pos=make.pos(base.asc) #make positions file (row, col, lat, lon) from 'base.asc'
pos$SegmentNo=extract.data(cbind(pos$lon, pos$lat),base.asc) #extract the SegmentNos to be merged with later

### Get the list of files to be made into asciis
files=list.files(wd)
#files=files[intersect(grep('RCP85',files),grep(yr,files))]
files=c(files[grep('median',files)],files[grep('diff',files)])

for (tfile in files) { cat(tfile,'\n')
	setwd(wd)
### Read in WT current and future SDM data
	tdata=read.csv(tfile,as.is=TRUE)
	filename=gsub('.csv','',tfile)
	if (ncol(tdata)==2) {} else {tdata=tdata[,c(1,3)] }#read in data clip away unnecessary columns
	colnames(tdata)=c('SegmentNo',filename)#name columns appropriately for merging with pos file later
	
### Merge current and future SDM data attributed to a SegmentNo with spatial positions of those SegmentNos
	pos=merge(pos,tdata,by='SegmentNo', all.x=TRUE)

### Create asciis for current and future and write them out
	tasc=make.asc(pos[,filename])
	setwd(out.dir)
	write.asc.gz(tasc, filename)

}
