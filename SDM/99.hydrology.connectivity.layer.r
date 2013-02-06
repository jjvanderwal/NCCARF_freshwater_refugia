library(igraph); library(SDMTools)
wd="/home/jc148322/NARPfreshwater/SDM/models/";setwd(wd)

network.file="/home/jc148322/NARPfreshwater/SDM/network.file.Rdata" #define the name of the 
load(network.file) #read in the netowrk attribute data


db=network
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs

out=NULL
counter=0
for (i in 1:length(gg)){
	if(counter==100) {cat('.'); counter=0} else {counter=counter+1}
	gt=gg[[i]]
	tout=cbind(E(gt)$SegmentNo,i)
	out=rbind(out,tout)
}

colnames(out)=c('SegmentNo', 'catchments')
connectivity=unique(out)

#fill holes in the data
base.asc = read.asc.gz(paste('/home/jc148322/NARPfreshwater/SDM/SegmentNo_1km.asc.gz',sep='')) #read in the base asc file
reaches=unique(base.asc,na.rm=T)
holes=setdiff(reaches,connectivity[,'SegmentNo'])
holes=na.omit(holes)

ids=NULL
for (ii in 1:length(holes)){
	id=i+ii
	ids=c(ids,id)
}
holes=cbind(holes,ids)


connectivity=rbind(connectivity,holes)

save(connectivity, file='/home/jc148322/NARPfreshwater/SDM/connectivity.file.Rdata')

##make an ascii to check it
pos=make.pos(base.asc)
pos$SegmentNo=extract.data(cbind(pos$lon,pos$lat),base.asc)
pos=merge(pos,connectivity, by='SegmentNo',all.x=TRUE)
tasc=make.asc(pos$catchments)
write.asc(tasc,'/home/jc148322/NARPfreshwater/connectivity.asc')



