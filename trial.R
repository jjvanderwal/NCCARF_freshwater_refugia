#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
####################################################################################
#required to build code OUTSIDE R
cd /home/jc165798/SCRIPTS/sdmcode/R_development/hydrology/

R CMD SHLIB Budkyo.c


####################################################################################
#START R
#the function
dyn.load("/home/jc165798/SCRIPTS/sdmcode/R_development/hydrology/Budkyo.so")

(R_dem = seq(10,100,length=10))
(R_rain = matrix(1:120,nrow=10,ncol=12)) 
(R_tmin = matrix(1:120,nrow=10,ncol=12)) 
(R_tmax = matrix(1:120,nrow=10,ncol=12)+1) 
(R_V_max = seq(10,100,length=10))
(R_kRs = seq(10,100,length=10)) 
(R_lats_radians = seq(0,90,length=10) / (180/pi)) 
(R_rows = nrow(R_rain))

tt = .Call('RunBudykoBucketModel_5km',
	R_dem,
	R_rain, 
	R_tmin, 
	R_tmax, 
	R_V_max,
	R_kRs, 
	R_lats_radians, 
	R_rows 
	)

(R_E_act = tt[[1]])
(R_E_pot = tt[[2]])
(R_Q_run = tt[[3]])
(R_Rn = tt[[4]])

