args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

wd='/home/jc148322/NARPfreshwater/SDM/models/';
spp.dir=paste(wd,spp,'/output/',sep='');setwd(spp.dir)
clip=read.csv('realized/realized.clip.csv',as.is=TRUE)

files=list.files(paste(spp.dir,'projection/',sep=''))

for (tfile in files) { cat(tfile,'\n')
	tdata=read.csv(paste(spp.dir,'projection/',tfile,sep=''))
	tdata[which(!(tdata[,1] %in% clip[,1])),3]=0	
	write.csv(tdata,paste('realized/',tfile,sep=''),row.names=FALSE)
	
	}


