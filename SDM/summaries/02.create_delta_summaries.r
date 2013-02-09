library(SDMTools); library(maptools) #define the libraries needed

##  define input and output directories
data.dir='/home/jc148322/NARPfreshwater/SDM/richness/summaries/deltas/'
rb.dir="/home/jc148322/NARPfreshwater/SDM/richness/summaries/River_basins/"; dir.create(rb.dir,recursive=T)
ram.dir='/home/jc148322/NARPfreshwater/SDM/richness/summaries/Ramsars/'; dir.create(ram.dir, recursive=T)

## define variables, in this case, taxa
ESs=c('RCP3PD','RCP45','RCP6','RCP85')
YEARs=seq(2015, 2085, 10)

vois=list.files(data.dir)

for (voi in vois) { cat(voi,'\n') 

	load(paste(data.dir,voi,sep='')) #object name: out
	
	## create some vectors of variables and empty matrices during first loop
	if (voi==vois[1]) {
		RiverBasins=sort(unique(na.omit(out$Riverbasin))) #create RiverBasins vector
		RAMSARS=RiverBasins=sort(unique(na.omit(out$ramsar)))
		
		## create river basins and ramsar output matrices
		rb_delta = matrix(NA,nrow=length(RiverBasins)*3,ncol=(3*length(ESs)*length(YEARs))); 
		ramdelta = matrix(NA,nrow=length(RAMSARS)*3,ncol=(3*length(ESs)*length(YEARs)));
		## colnames
		tt = expand.grid(c(10,50,90),YEARs,ESs); tt = paste(tt[,3],tt[,2],tt[,1],sep='_'); colnames(rb_delta) = tt; colnames(ram_delta) = tt
		## rownames
		tt = expand.grid(c('quant_10', 'quant_50', 'quant_90'),RiverBasins); tt = paste(tt[,2],tt[,1],sep='_'); rownames(rb_delta)=tt
		tt = expand.grid(c('quant_10', 'quant_50', 'quant_90'),RAMSARS); tt = paste(tt[,2],tt[,1],sep='_'); rownames(ram_delta)=tt
	}
		
	##summarise by river basin
	table_delta = rb_delta #create a copy of the empty matrix
	for (rb in RiverBasins) { cat(rb,'\n') #cycle through each basin
			
			tout = out[which(out$Riverbasin==rb),] #get the data only for the rb of interest
			cois=grep('RCP',colnames(tout))
			outquant = apply(tout[,cois],2,function(x) { return(quantile(x,c(0.1,0.5,0.9),na.rm=TRUE,type=8)) })#get the percentiles					
			rowname=paste(rb,"_quant_", c(10,50,90), sep='')
			table_delta[rownames(table_delta)==rowname,]=outquant[,]

	}
		
	write.csv(table_delta,paste(rb.dir,"rb_",gsub('.Rdata','.csv',voi),sep=''),row.names=T)	 

	## summarise by ramsar
	table_delta = ram_delta #create a copy of the empty matrix
	for (ram in RAMSARS) { cat(ram,'\n') #cycle through each basin

			tout = out[which(out$ramsar==ram),] #get the data only for the rb of interest
			cois=grep('RCP',colnames(tout))
			outquant = apply(tout[,cois],2,function(x) { return(quantile(x,c(0.1,0.5,0.9),na.rm=TRUE,type=8)) })#get the percentiles					
			rowname=paste(rb,"_quant_", c(10,50,90), sep='')
			table_delta[rownames(table_delta)==rowname,]=outquant[,]

			}; 

	write.csv(table_delta,paste(ram.dir,"ram_",gsub('.Rdata','.csv',voi),sep=''),row.names=T)	 

}			
