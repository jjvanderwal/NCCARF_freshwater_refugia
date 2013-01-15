
library(SDMTools)
source('/home/jc148322/scripts/libraries/cool_functions.r')

### Find out which SegmentNos are in the Wet Tropics region

raster=read.asc('/home/jc248851/ZONATION/CASSIE/RF/SegmentNo_AWT.asc') #read in contintental aust 250m segNo raster
base.asc=read.asc('/home/jc248851/ZONATION/CASSIE/RF/mask_AWT.asc')

pos=make.pos(base.asc)
pos$mask=extract.data(cbind(pos$lon, pos$lat),base.asc)
pos$SegmentNo=extract.data(cbind(pos$lon, pos$lat),raster) #extract the SegmentNos for the WT
pos$SegmentNo[which(is.na(pos$mask))]=NA

WT_clip=as.data.frame(na.omit(unique(pos$SegmentNo)))
colnames(WT_clip)[1]='SegmentNo'

write.csv(WT_clip,'/home/jc148322/NARPfreshwater/SDM/WT_clip.csv',row.names=F)

### Also create WT SegmentNo ascii for use later

tasc=make.asc(pos$SegmentNo)
write.asc.gz(tasc,'/home/jc148322/NARPfreshwater/SDM/SegmentNo_AWT')

