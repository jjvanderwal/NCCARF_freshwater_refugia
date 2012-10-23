##script to create table of runoff proportion
##serves two main purposes:
##	1. where two HydroIDs fall in a single reach, identified by 'SegmentNo', apportion the flow according to stream length
##	2. identify where bifurcation occurs, and determine proportion of flow to send down each channel, apportioned based on local catchment size.

##script drafted by Lauren Hodgseon and Cassie James
##---------------------------------------------------------------------------------
network=read.csv('/home/jc148322/NARPfreshwater/network.csv',as.is=T) # a file with columns of interest from NetworkAttributes.dbf and StreamAttributes.dbf from geofabric database: HydroID, SegmentNo, NextDownID, From_Node, To_Node, StreamLen, Area

wd = "/home/jc246980/Hydrology.trials/"; setwd(wd) 
load(file=paste(wd,'Reach_runoff_5km.Rdata',sep=''))  #load runoff aggregated to reach
runoff=Reach_runoff; colnames(runoff)[1]='SegmentNo' #rename object
runoff=runoff[which(runoff$SegmentNo %in% network$SegmentNo),] #remove SegmentNos for which runoff was not calculated, ie. islands
runoff=merge(network[,c('HydroID','SegmentNo','Shape_Leng')],runoff,by='SegmentNo') #attribute a hydroID to each SegNo

##---------------------------------------------------------------------------------
##1. Find the proportion of flow where two or more streams (HydroID) fall within a single reach (SegmentNo)

streamLength=aggregate(runoff$Shape_Leng, by = list(runoff$SegmentNo), sum) #find the total length of stream within each reach  
colnames(streamLength)=c('SegmentNo','TotLength') #rename columns

runoff=merge(runoff,streamLength, by='SegmentNo') #attach 'total stream length' column to runoff table

runoff$SegProp=runoff$Shape_Leng/runoff$TotLength #divide individual stream length by total length of streams in a reach to find proportion of local flow attributed to each stream.

runoff=runoff[,c('HydroID','SegmentNo', 'Runoff','SegProp')] #keep only necessary columns

##---------------------------------------------------------------------------------
##2. Find the proportion of flow where bifurcation occurs.
##a. identify where bifurcation occurs (ie. find duplication in From_Node) and label main and sub channels.
##Note: Where bifurcation occurs, the 'sub channel' is not listed as 'next down'.  We need to identify where this has occurred in order to send flow down the channel that is not 'next down'.

dup_nodes=network$From_Node[duplicated(network$From_Node)] # gives all the duplicate AND triplicated From_Nodes   (so there will still be some duplication in this file due to triplicates!)
dup_nodes=unique(dup_nodes) # list limited now to unique vales for duplicate from nodes

bifurc=network[which(network$From_Node %in% dup_nodes),c('HydroID','SegmentNo','From_Node','To_Node','NextDownID')]  # subset network attributes table to bifurcations only

NextUp=network[which(network$To_Node %in% bifurc$From_Node),]  #find the HydroID from which each set of bifurcations originates

bi_main=NextUp$NextDownID #create a vector of all 'main' channels beneath a bifurcation

bi_sub=bifurc$HydroID[which(!(bifurc$HydroID %in% bi_main))]#create a vector of all 'sub' channels beneath a bifurcation
mainchannel=network$HydroID[which(!(network$HydroID %in% bifurc$HydroID))]    # returns all networkatts that have been identified as main  (i.e.  HydroIds that are NOT below duplicated From_Nodes)

runoff["ChannelType"] <- NA #create column 
runoff$ChannelType[which(runoff$HydroID %in% bi_main)] = "bi_main"
runoff$ChannelType[which(runoff$HydroID %in% bi_sub)] = "bi_sub"
runoff$ChannelType[which(runoff$HydroID %in% mainchannel)] = "main"

##---------------------------------------------------------------------------------
##2. Find the proportion of flow where bifurcation occurs.
##b. apportion flow to a bifurcation based on area of subcatchment
##Note: We have Area data for each SegmentNo, but not for each HydroID.  To find Area that flows into each HydroID, times area by proportion of stream to which it contributes runoff

runoff=merge(runoff,network[,c('HydroID','From_Node','NextDownID','Area')],by='HydroID')
runoff$Hydro_Area=runoff$SegProp*runoff$Area

totArea=aggregate(runoff$Hydro_Area, by = list(runoff$From_Node), sum) #find the total local catchment area of branches of bifurcations
colnames(totArea)=c('From_Node','TotArea')

runoff=merge(runoff,totArea,by='From_Node')

runoff$BiProp=runoff$Hydro_Area/runoff$TotArea  #Proportion of flow that runs into a branch of a bifurcation is here apportioned based on the size of the local catchment

runoff$LocalRunoff=runoff$Runoff*runoff$SegProp #Calculate local runoff attributed to each HydroID
runoff=runoff[,c('HydroID','SegmentNo','From_Node','NextDownID','ChannelType','LocalRunoff','BiProp')] #keep only columns needed for accumulation

write.csv(runoff,'/home/jc148322/NARPfreshwater/local_runoff.csv',row.names=F)

