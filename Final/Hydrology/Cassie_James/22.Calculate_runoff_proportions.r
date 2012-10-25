##script to create table of runoff proportion
##serves two main purposes:
##	1. where two HydroIDs fall in a single reach, identified by 'SegmentNo', apportion the flow according to stream length
##	2. identify where bifurcation occurs, and determine proportion of flow to send down each channel, apportioned based on local catchment size.

##script drafted by Lauren Hodgseon and Cassie James
##---------------------------------------------------------------------------------
network=read.csv('/home/jc148322/NARPfreshwater/Hydrology/network.csv',as.is=T) # a file with columns of interest from NetworkAttributes.dbf and StreamAttributes.dbf from geofabric database: HydroID, SegmentNo, NextDownID, From_Node, To_Node, StreamLen, Area

proportion=network[,c('HydroID','SegmentNo','Shape_Leng')] #create a data frame to work on
##---------------------------------------------------------------------------------
##1. Find the proportion of flow where two or more streams (HydroID) fall within a single reach (SegmentNo)

streamLength=aggregate(proportion$Shape_Leng, by = list(proportion$SegmentNo), sum) #find the total length of stream within each reach  
colnames(streamLength)=c('SegmentNo','TotLength') #rename columns

proportion=merge(proportion,streamLength, by='SegmentNo') #attach 'total stream length' column to proportion table

proportion$SegProp=proportion$Shape_Leng/proportion$TotLength #divide individual stream length by total length of streams in a reach to find proportion of local flow attributed to each stream.

proportion=proportion[,c('HydroID','SegmentNo','SegProp')] #keep only necessary columns

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

proportion["ChannelType"] <- NA #create column 
proportion$ChannelType[which(proportion$HydroID %in% bi_main)] = "bi_main"
proportion$ChannelType[which(proportion$HydroID %in% bi_sub)] = "bi_sub"
proportion$ChannelType[which(proportion$HydroID %in% mainchannel)] = "main"

##---------------------------------------------------------------------------------
##2. Find the proportion of flow where bifurcation occurs.
##b. apportion flow to a bifurcation based on area of subcatchment
##Note: We have Area data for each SegmentNo, but not for each HydroID.  To find Area that flows into each HydroID, times area by proportion of stream to which it contributes proportion

proportion=merge(proportion,network[,c('HydroID','From_Node','Area')],by='HydroID')
proportion$Hydro_Area=proportion$SegProp*proportion$Area

totArea=aggregate(proportion$Hydro_Area, by = list(proportion$From_Node), sum) #find the total local catchment area of branches of bifurcations
colnames(totArea)=c('From_Node','TotArea')

proportion=merge(proportion,totArea,by='From_Node')

proportion$BiProp=proportion$Hydro_Area/proportion$TotArea  #Proportion of flow that runs into a branch of a bifurcation is here apportioned based on the size of the local catchment

proportion=proportion[,c('HydroID','SegmentNo','ChannelType','BiProp','SegProp')] #keep only columns needed for accumulation

write.csv(proportion,'/home/jc148322/NARPfreshwater/Hydrology/proportion.csv',row.names=F)

