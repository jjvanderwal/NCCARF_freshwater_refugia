
region_types=c('River_basins','Ramsars')

for (r in region_types){
	setwd(paste('/home/jc148322/NARPfreshwater/SDM/richness/summaries/',r,'/',sep=''))
	files=list.files()

	out=NULL
	for (ii in 1:4) {
		load(files[ii])
		cois=grep('RCP85_2085',colnames(table_delta))
		rois=grep('quant_50',rownames(table_delta))
		tout=table_delta[rois,cois]
		if (r==region_types[1]) tout=round(tout,2) else tout=round(tout,1)
		regions=gsub('_quant_50','',rownames(tout))
		tout=paste(tout[,2],' (',tout[,1],' - ',tout[,3],')',sep='')
		
		if(ii==1) out=cbind(regions,tout) else out=cbind(out, tout)

		}

	colnames(out)=c('Region','Crayfish','Fish','Frogs','Turtles')
	out=out[,c(1,3,2,5,4)]
	write.csv(out,'report_table.csv',row.names=F)
}
