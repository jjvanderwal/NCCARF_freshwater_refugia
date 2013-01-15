args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments


spp.dir=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/output/WT_potential/',sep=''); setwd(spp.dir)

if(file.exists('RCP85_2085_median.csv')) {
files=list.files(pattern='2085')
files=files[-grep('median',files)]
} else { files=list.files(pattern='2085')}

out=NULL
for (tfile in files) { cat(tfile,'\n')
	tdata=read.csv(tfile, as.is=TRUE)
	
	if (tfile==files[1]) out=tdata[,c(1,3)] else out=cbind(out,tdata[,3])

}

outquant=t(apply(out[,2:ncol(out)],1,function(x) { return(quantile(x,0.5,na.rm=TRUE,type=8)) }))

outquant=cbind(out[,1],as.vector(outquant))

write.csv(outquant,'RCP85_2085_median.csv',row.names=FALSE)
