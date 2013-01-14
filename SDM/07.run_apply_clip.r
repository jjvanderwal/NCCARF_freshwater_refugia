args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments

spp.dir=paste(wd,spp,'/output/',sep='')
clip=read.csv('realized/realized.clip.csv',as.is=TRUE)

files=list.files(paste(spp.dir,'projection/',sep=''))

for (tfile in files) { cat('make realized distribution\n')
	tdata=read.csv(paste(spp.dir,'projection/',tfile,sep=''))
	tdata[which(!(tdata[,1] %in% clip[,1])),3]=0	
	write.csv(tdata,tfile,row.names=FALSE)
	
	}


