args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

wd='/home/jc148322/NARPfreshwater/SDM/Fish/models/';
spp.dir=paste(wd,spp,'/output/',sep='');setwd(spp.dir)
clip=read.csv('/home/jc148322/NARPfreshwater/SDM/WT_clip.csv',as.is=TRUE)
out.dir=paste(spp.dir,'WT_realized',sep=''); dir.create(out.dir)
files=list.files(paste(spp.dir,'potential/',sep=''))
files=c('current.csv',files[grep('RCP85',files)])
#files=files[intersect(grep('RCP85',files),grep('2025',files))]

for (tfile in files) { cat(tfile,'\n')
	tdata=read.csv(paste(spp.dir,'potential/',tfile,sep=''))
	tdata=tdata[which(tdata[,1] %in% clip[,1]),]	
	write.csv(tdata,paste(out.dir,'/',tfile,sep=''),row.names=FALSE)
	
	}
