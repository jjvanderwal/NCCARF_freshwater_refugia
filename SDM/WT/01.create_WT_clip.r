
library(SDMTools)
source('/home/jc148322/scripts/libraries/cool_functions.r')

### Find out which SegmentNos are in the Wet Tropics region

raster=read.asc('/home/jc148322/NARPfreshwater/Hydrology/catchmentraster250m.asc') #read in contintental aust 250m segNo raster
base.asc=read.asc.gz('/home/jc165798/Climate/CIAS/AWT/250m/baseline.76to05/base.asc.gz')
pos=make.pos(base.asc)

pos$SegmentNo=extract.data(cbind(pos$lon, pos$lat),raster) #extract the SegmentNos for the WT

WT_clip=as.data.frame(na.omit(unique(pos$SegmentNo)))
colnames(WT_clip)[1]='SegmentNo'

write.csv(WT_clip,'/home/jc148322/NARPfreshwater/SDM/WT_clip.csv',row.names=F)
