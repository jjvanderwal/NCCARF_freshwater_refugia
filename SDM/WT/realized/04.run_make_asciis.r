args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

library(SDMTools) #load libraries and functions
source('/home/jc148322/scripts/libraries/cool_functions.r')

wd=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/output/WT_realized/',sep=''); setwd(wd) #set working directory

### Prepare data for making asciis
base.asc=read.asc.gz('/home/jc148322/NARPfreshwater/SDM/SegmentNo_AWT.asc.gz') #need an ascii with SegmentNos		
pos=make.pos(base.asc) #make positions file (row, col, lat, lon) from 'base.asc'
pos$SegmentNo=extract.data(cbind(pos$lon, pos$lat),base.asc) #extract the SegmentNos to be merged with later

### Read in WT current and future SDM data
current=read.csv('current.csv',as.is=TRUE); current=current[,c(1,3)] #read in current, clip away unnecessary columns
colnames(current)=c('SegmentNo','current') #name columns appropriately for merging with pos file later

future=read.csv('RCP85_2085_median.csv',as.is=TRUE) #read in future SDM data
colnames(future)=c('SegmentNo','RCP85_2085_median')#name columns appropriately for merging with pos file later

### Merge current and future SDM data attributed to a SegmentNo with spatial positions of those SegmentNos
pos=merge(pos,current,by='SegmentNo', all.x=TRUE)
pos=merge(pos,future,by='SegmentNo',all.x=TRUE)

### Create asciis for current and future and write them out
current.asc=make.asc(pos$current)
future.asc=make.asc(pos$RCP85_2085_median)

out.dir=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/output/asciis/WT_realized/',sep='')
dir.create(out.dir,recursive=TRUE); setwd(out.dir)

write.asc.gz(current.asc, 'current')
write.asc.gz(future.asc,'RCP85_2085_median')
