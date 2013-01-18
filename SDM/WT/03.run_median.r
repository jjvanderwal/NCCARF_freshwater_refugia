args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments


spp.dir=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/output/WT_realized/',sep=''); setwd(spp.dir)
years=seq(2015,2085,10)

for (yr in years) {
	files=list.files(pattern=as.character(yr))

	out=NULL
	for (tfile in files) { cat(tfile,'\n')
		tdata=read.csv(tfile, as.is=TRUE)
		
		if (tfile==files[1]) out=tdata[,c(1,3)] else out=cbind(out,tdata[,3])

	}

	outquant=t(apply(out[,2:ncol(out)],1,function(x) { return(quantile(x,c(0.1,0.5,0.9),na.rm=TRUE,type=8)) }))

	outquant=cbind(out[,1],outquant); colnames(outquant)[1]='SegmentNo'

	write.csv(outquant[,c(1,2)],paste('RCP85_tenth_',yr,'.csv',sep=''),row.names=FALSE)
	write.csv(outquant[,c(1,3)],paste('RCP85_median_',yr,'.csv',sep=''),row.names=FALSE)
	write.csv(outquant[,c(1,4)],paste('RCP85_ninetieth_',yr,'.csv',sep=''),row.names=FALSE)
	
	difference=cbind(outquant[,1],outquant[,3]-outquant[,2])
	write.csv(difference,paste('RCP85_diff_',yr,'.csv',sep=''),row.names=FALSE)
	
}
