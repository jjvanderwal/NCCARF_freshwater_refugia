
wd="/home/jc148322/NARPfreshwater/SDM/models/";setwd(wd)

network.file="/home/jc165798/working/NARP_hydro/flow_accumulation/NetworkAttributes.csv" #define the name of the 
network = read.csv(network.file,as.is=TRUE) #read in the netowrk attribute data

network=network[,c('From_Node','To_Node','SegmentNo')]

occur.file="/home/jc246980/Zonation/Fish_reach_aggregated.Rdata" #give the full file path of your species data
occur=load(occur.file)
occur=get(occur) #rename species occurrence data to 'occur'
species=colnames(occur); species=species[-grep('SegmentNo',species)] #get species names, to loop through later

occur=merge(network,occur,by='SegmentNo',all.x=T)

species=list.files(wd)

db=occur[,c('From_Node','To_Node','SegmentNo',species)]
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs

for (spp in species) { cat(spp,'\n')
	spp.dir=paste(wd,spp,'/output/',sep='')
	clip=NULL
	counter=0
	for (i in 1:length(gg)){
		if(counter==100) {cat('.'); counter=0} else {counter=counter+1}
		gt=gg[[i]]
		presence=get.edge.attribute(gt, spp);presence=sum(presence)
		if(presence>0) clip=c(clip,E(gt)$SegmentNo)

	}
	clip=as.data.frame(clip)
	colnames(clip)[1]='SegmentNo'
	
	out.dir=paste(spp.dir,'realized/',sep=''); dir.create(out.dir); setwd(out.dir)
	write.csv(clip,'realized.clip.csv',row.names=F)

}
