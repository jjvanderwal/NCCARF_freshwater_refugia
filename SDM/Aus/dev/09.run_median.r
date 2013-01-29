args=(commandArgs(TRUE)) #get the command line arguements
for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments


spp.dir=paste('/home/jc148322/NARPfreshwater/SDM/models/',spp,'/output/realized/',sep=''); setwd(spp.dir)

ESs=c('RCP3PD','RCP45','RCP6','RCP85')
YEARs=seq(2015,2085,10)

for (es in ESs) {

	for (yr in YEARs) {


		if(file.exists(paste(es,'_',yr,'_median.csv',sep=''))) {
		files=list.files(pattern=es)
		files=files[grep(yr,files)]
		files=files[-grep('median',files)]
		} else { 
		files=list.files(pattern=es)
		files=files[grep(yr,files)]}


		out=NULL
		for (tfile in files) { cat(tfile,'\n')
			tdata=read.csv(tfile, as.is=TRUE)
			
			if (tfile==files[1]) out=tdata[,c(1,3)] else out=cbind(out,tdata[,3])

		}

		outquant=t(apply(out[,2:ncol(out)],1,function(x) { return(quantile(x,0.5,na.rm=TRUE,type=8)) }))

		outquant=cbind(out[,1],as.vector(outquant))

		write.csv(outquant,paste(es,'_',yr,'_median.csv',sep=''),row.names=FALSE)
	}
}
