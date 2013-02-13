args=(commandArgs(TRUE)); for(i in 1:length(args)) { eval(parse(text=args[[i]])) } #evaluate the arguments


library(SDMTools); #define the libraries needed

##  define input and output directories
data.dir='/home/jc148322/NARPfreshwater/SDM/richness/summaries/deltas/'
rb.dir="/home/jc148322/NARPfreshwater/SDM/richness/summaries/River_basins/"; dir.create(rb.dir,recursive=T)
ram.dir='/home/jc148322/NARPfreshwater/SDM/richness/summaries/Ramsars/'; dir.create(ram.dir, recursive=T)

## define variables, in this case, taxa
ESs=c('RCP3PD','RCP45','RCP6','RCP85')
YEARs=seq(2015, 2085, 10)

taxa=list.files(data.dir)
regiontypes=c('Riverbasin','ramsar')
vois=c('out','outdelta')


load(paste(data.dir,tax,sep='')) #object name: out, outdelta

for(r in regiontypes) {

	regions=sort(unique(na.omit(out[,r]))) #create regions vector
	
	#create some empty matrices
		## create river basins and ramsar output matrices
		region_table = matrix(NA,nrow=length(regions)*3,ncol=(3*length(ESs)*length(YEARs))); 
		## colnames
		tt = expand.grid(c(10,50,90),YEARs,ESs); tt = paste(tt[,3],tt[,2],tt[,1],sep='_'); colnames(region_table) = tt
		## rownames
		tt = expand.grid(c('quant_10', 'quant_50', 'quant_90'),regions); tt = paste(tt[,2],tt[,1],sep='_'); rownames(region_table)=tt
	

	##summarise by region
	table_delta = table_abs = region_table #create a copy of the empty matrix
	for (region in regions) { cat(region,'\n') #cycle through each basin
		for (voi in vois) { cat(voi,'\n')
			##create a summary table 
			if (voi==vois[1]) tout = out[which(out[,r]==region),] #get only region data
			if (voi==vois[2]) tout = outdelta[which(outdelta[,r]==region),] #get only region data
			
			cois=grep('RCP',colnames(tout))
			outquant = apply(tout[,cois],2,function(x) { return(quantile(x,c(0.1,0.5,0.9),na.rm=TRUE,type=8)) })#get the percentiles					
			rowname=paste(region,"_quant_", c(10,50,90), sep='')
			if (voi==vois[1]) table_abs[rownames(table_abs)==rowname,]=outquant[,]
			if (voi==vois[2]) table_delta[rownames(table_abs)==rowname,]=outquant[,]
		}	
	}
	
	if (r==regiontypes[1]) save(table_abs,table_delta,file=paste(rb.dir,"rb_",tax,sep=''))	
	if (r==regiontypes[2]) save(table_abs,table_delta,file=paste(ram.dir,"ram_",tax,sep=''))	
}
			
