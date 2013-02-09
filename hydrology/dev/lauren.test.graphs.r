accum.function.file="/home/jc165798/SCRIPTS/git_code/NCCARF_freshwater_refugia/hydrology/dev/accumulate_functions.R" #define the location of the accumulation functions
source(accum.function.file)
cois='Runoff'
	
db=data.frame('From_Node'=c(1,2,3),'To_Node'=c(3,3,4),'HydroID'=letters[1:3],'Runoff'=c(10,20,30),'BiProp'=1)
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs
gt=gg[[1]]
accum.runoff(gt,cois)
sum(E(gt)$Runoff)

db=data.frame('From_Node'=c(1,2,2),'To_Node'=c(2,3,4),'HydroID'=letters[1:3],'Runoff'=c(10,20,30),'BiProp'=c(1,0.5,0.5))
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs
gt=gg[[1]]
accum.runoff(gt,cois)
sum(E(gt)$Runoff)

db=data.frame('From_Node'=c(1,1,2),'To_Node'=c(2,2,3),'HydroID'=letters[1:3],'Runoff'=c(10,20,30),'BiProp'=1)
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs
gt=gg[[1]]
accum.runoff(gt,cois)
sum(E(gt)$Runoff)

db=data.frame('From_Node'=c(1,2,2),'To_Node'=c(2,3,3),'HydroID'=letters[1:3],'Runoff'=c(10,20,30),'BiProp'=c(1,0.5,0.5))
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs
gt=gg[[1]]
accum.runoff(gt,cois)
sum(E(gt)$Runoff)

db=data.frame('From_Node'=c(1,2,3,4,5),'To_Node'=c(3,3,5,5,6),'HydroID'=letters[1:5],'Runoff'=c(10,20,30,40,50),'BiProp'=1)
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs
gt=gg[[1]]
accum.runoff(gt,cois)
sum(E(gt)$Runoff)

db=data.frame('From_Node'=c(1,2,5,6,3,7,8),'To_Node'=c(3,3,7,7,8,8,9),'HydroID'=letters[1:7],'Runoff'=c(10,20,30,40,50,60,70),'BiProp'=1)
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs
gt=gg[[1]]
accum.runoff(gt,cois)
sum(E(gt)$Runoff)

db=data.frame('From_Node'=c(1,2,3,4,5),'To_Node'=c(2,3,5,5,6),'HydroID'=letters[1:5],'Runoff'=c(10,20,30,40,50),'BiProp'=1)
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs
gt=gg[[1]]
accum.runoff(gt,cois)
sum(E(gt)$Runoff)

db=data.frame('From_Node'=c(1,1,2,3,4,5),'To_Node'=c(2,2,3,5,5,6),'HydroID'=letters[1:6],'Runoff'=c(10,20,30,40,50,60),'BiProp'=c(0.5,0.5,1,1,1,1))
g = graph.data.frame(db,directed=TRUE) #create the graph
gg = decompose.graph(g,"weak") #break the full graph into 10000 + subgraphs
gt=gg[[1]]
accum.runoff(gt,cois)
sum(E(gt)$Runoff)


