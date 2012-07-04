//---------------------------------------------------------------------------

#include <string.h>
#include <iostream.h>
#include <fstream.h>
#include <sstream>
#include <math.h>
//include "defines.h"

#include "DynamicArray.h"
#include "DownscalingFuncs.h"

//---------------------------------------------------------------------------
//*****************************************************************************
// Run Budkyo Bucket Model
// Runs a bucket model at 5km for every month, based on precipitation ,
// temperature and ground characteristics
//
// Outputs
// Monthly grids of ACTUAL EVAPORATION (for further downscaling)
// Monthly grids of RUNOFF (for Cassie)
int RunBudykoBucketModel_5km (void)
{
int n_rows=691;     // grid dimensions
int n_cols=886;
int i_row,i_col;  // row col counters
int i_month; // month of year  0-11
int i_year;  // year for Budyko loop
float ** f_P_rain[12]; // array of pointers to monthly rain grids
float ** f_E_pot[12]; // array of pointers to monthly Potential Evap grids
float f_E_act; //  monthly Actual Evap grids
float ** f_Q_run; //  to monthly Runoff grids
float ** f_V_store; // Soil water actually present
float ** f_V_max; // Max soil water(total PAWCH)
float ** f_Z_elev; // height above sea level
float ** f_kRs; // Hargreaves coast/interior constant
float * f_latitude_radians;    // latitude for each row
float f_latitude_degrees;   // decimal degrees
//I/O
std::stringstream out; // stringstream to build filename
string s_path;   // file path
ifstream AFileStream;
ifstream BFileStream;
ofstream QResultsFileStream;
ofstream EaResultsFileStream;
ofstream RnResultsFileStream;
// Radiation calcs
double d_dr;
double d_declination;
double d_J[12]={15,45,74,105,135,166,196,227,258,288,319,349};   // Julian day for each month
float f_Tmax, f_Tmin; //max and min temps
double d_Rn; // Net Radiation
float d_W;   // Total water Precipitation Plus Storage
float d_T;   // Mean temp
int b_success;
b_success=0;


// Step 1 Calculate monthly Potential Evaporation using Preistley Taylor
// need max and min temp, Z
   // Load elevation and latitude
   f_latitude_radians=AllocateFloat1DArray(n_rows);
   f_Z_elev=AllocateFloat2DArray(n_rows,n_cols);
   f_kRs=AllocateFloat2DArray(n_rows,n_cols);
   // Open Elevation file and jump over header
   s_path="DEM_5km.asc";
   if(AFileStream.is_open()) AFileStream.close();
   AFileStream.open(s_path.c_str());
   SkipASCIIHeader(&AFileStream);
   s_path="kRs_5km.asc";
   if(BFileStream.is_open()) BFileStream.close();
   BFileStream.open(s_path.c_str());
   SkipASCIIHeader(&BFileStream);
   for(i_row=0;i_row<n_rows;i_row++)
     {
     // Calculate latitude in radians from grid position
     f_latitude_degrees=-44.525 + (690-i_row)* 0.05;
     f_latitude_radians[i_row]= f_latitude_degrees/57.29577951;
     for(i_col=0;i_col<n_cols;i_col++)
       {
       AFileStream>>f_Z_elev[i_row][i_col];
       BFileStream>>f_kRs[i_row][i_col];
       }// end for i_col
     }// end for i_row
   // Read in.. close files
   if(AFileStream.is_open()) AFileStream.close();
   if(BFileStream.is_open()) BFileStream.close();

   // Now a monthly loop to calculate things from temperature
   for(i_month=0;i_month<12;i_month++)
     {
     f_E_pot[i_month]=AllocateFloat2DArray(n_rows,n_cols);
     d_dr=1 + 0.033*cos(2*3.141592654*d_J[i_month]/365); //Allen eq23
     d_declination=0.409*sin((2*3.141592654*d_J[i_month]/365)-1.39);  // Allen eq 24

     // Open month specific files
     if(i_month<9) out <<"tasmax0"<< i_month+1 <<".asc";
     else out <<"tasmax"<< i_month+1 <<".asc";
     s_path = out.str();
     if(AFileStream.is_open()) AFileStream.close();
     AFileStream.open(s_path.c_str());
     SkipASCIIHeader(&AFileStream);
     // Now min temp
     out.str("");
     out.clear();
     if(i_month<9) out <<"tasmin0"<< i_month+1 <<".asc";
     else out <<"tasmin"<< i_month+1 <<".asc";
     s_path = out.str();
     if(BFileStream.is_open()) BFileStream.close();
     BFileStream.open(s_path.c_str());
     SkipASCIIHeader(&BFileStream);
     // Now Net Radiation output file
     out.str("");
     out.clear();
     if(i_month<9) out <<"rn0"<< i_month+1 <<".asc";
     else out <<"rn"<< i_month+1 <<".asc";
     s_path = out.str();
     if(RnResultsFileStream.is_open())
        RnResultsFileStream.close();
     RnResultsFileStream.open(s_path.c_str());
     OutputASCIIHeader(&RnResultsFileStream,n_cols,n_rows,111.975,-44.525,0.05,-9999);

     // Now A and B file streams point to the Tmax and Tmin files respectively
     for(i_row=0;i_row<n_rows;i_row++)
       {
       for(i_col=0;i_col<n_cols;i_col++)
         {
         // Load temp range
         AFileStream>>f_Tmax;
         BFileStream>>f_Tmin;
         // Calc rad at top of atmosphere
         d_Rn= CalculateNetRadiation(f_latitude_radians[i_row],    // latitiude RADIANS
                                     f_Z_elev[i_row][i_col],      // altitude METRES
                                     d_dr,     //
                                     d_declination,  //declination
                                     f_kRs[i_row][i_col],
                                     f_Tmax,
                                     f_Tmin);
         //Output this now
         RnResultsFileStream<<(float)d_Rn<<" ";
         //Temp
         d_T=(f_Tmax +f_Tmin)/2;
         // Calc potential evaporation Priestley Taylor
         f_E_pot[i_month][i_row][i_col]=CalculatePTEvaporation(d_T, // mean temp
                                                               f_Z_elev[i_row][i_col],// altitude
                                                               d_Rn) ; // net rad
         }// end for i_col
       RnResultsFileStream<<endl;
       }// end for i_row
     // Close files
     if(AFileStream.is_open())
       AFileStream.close();
     if(BFileStream.is_open())
       BFileStream.close();
     }// end for i_month

   //Create new arrays to hold the Budyko world
   f_Q_run=AllocateFloat2DArray(n_rows,n_cols);; //  to monthly Runoff grids
   f_V_store=AllocateFloat2DArray(n_rows,n_cols);; // Soil water actually present
   f_V_max=AllocateFloat2DArray(n_rows,n_cols);; // Max soil water(total PAWCH)
   //Read in Vmax == PAWCH
   s_path="PAWHC_5km.asc";
   if(AFileStream.is_open())
      AFileStream.close();
   AFileStream.open(s_path.c_str());
   SkipASCIIHeader(&AFileStream);
   for(i_row=0;i_row<n_rows;i_row++)
     {
     for(i_col=0;i_col<n_cols;i_col++)
       {
       AFileStream>>f_V_max[i_row][i_col];
       f_V_store[i_row][i_col]=f_V_max[i_row][i_col]/2;
       }// end for i_col
     }// end for i_row
   // Read in.. close files
   if(AFileStream.is_open())
      AFileStream.close();
   // Now load up the Rain

   for(i_month=0;i_month<12;i_month++)
     {
     f_P_rain[i_month]=AllocateFloat2DArray(n_rows,n_cols);
     out.str("");
     out.clear();
     if(i_month<9) out <<"pr0"<< i_month+1 <<".asc";
     else out <<"pr"<< i_month+1 <<".asc";
     s_path = out.str();
     if(AFileStream.is_open())
        AFileStream.close();
     AFileStream.open(s_path.c_str());
     SkipASCIIHeader(&AFileStream);

     // Now A and B file streams point to the Tmax and Tmin files respectively
     for(i_row=0;i_row<n_rows;i_row++)
       {
       for(i_col=0;i_col<n_cols;i_col++)
         {
         // Load temp range
         AFileStream>>f_P_rain[i_month][i_row][i_col];
         }// end for i_col
       }// end for i_row
     if(AFileStream.is_open())
        AFileStream.close();
     }// end for i_month
   //Now we're all loaded.. go round for 3 years to near equilibrium then export
   // results to file
   for(i_year=0;i_year<4;i_year++)
     {
     if(i_year==3) // Open files for output and output headers
       {
       s_path="Runoff_5km.asc";
       QResultsFileStream.open(s_path.c_str());
       OutputASCIIHeader(&QResultsFileStream,n_cols,n_rows,111.975,-44.525,0.05,-9999);
       s_path="Ea_5km.asc";
       EaResultsFileStream.open(s_path.c_str());
       OutputASCIIHeader(&EaResultsFileStream,n_cols,n_rows,111.975,-44.525,0.05,-9999);
       }// end year 3 output year
     // Loop through all the months
     for(i_month=0;i_month<12;i_month++)
       {
       for(i_row=0;i_row<n_rows;i_row++)
         {
         for(i_col=0;i_col<n_cols;i_col++)
           {
           // Do bucket
           // Add precipitation to soil
           d_W=f_V_store[i_row][i_col] + f_P_rain[i_month][i_row][i_col];
           // do Budyko
           f_E_act= (f_E_pot[i_month][i_row][i_col]*d_W)/
                            pow((pow(d_W,1.9)+pow(f_E_pot[i_month][i_row][i_col],1.9))  ,1.9);
           // How much water is left?
           f_V_store[i_row][i_col]=d_W-f_E_act;
           // Calc runoff
           if(f_V_store[i_row][i_col]>f_V_max[i_row][i_col])
             {// runoff
             f_Q_run[i_row][i_col]=f_V_store[i_row][i_col]-f_V_max[i_row][i_col];
             f_V_store[i_row][i_col]=f_V_max[i_row][i_col];  // soil stays full
             }
           else
             f_Q_run[i_row][i_col]=0;
           // Spew out results in the fourth year
           if(i_year==3)
             {
             QResultsFileStream<<f_Q_run[i_row][i_col]<<" ";
             EaResultsFileStream<<f_E_act<<" ";
             }// end if i_year==3
           }// end for i_col
         QResultsFileStream<<endl;
         EaResultsFileStream<<endl;
         }// end for i_row
       }// end for i_month
     }  // end for i_year
     if(QResultsFileStream.is_open())
       QResultsFileStream.close();
     if(EaResultsFileStream.is_open())
       EaResultsFileStream.close();
   // Free the world!
   FreeFloat1DArray(f_latitude_radians);
   FreeFloat2DArray(f_Z_elev);
   FreeFloat2DArray(f_kRs);
   // Note we still have an array of Epots allocated

   FreeFloat2DArray(f_Q_run);
   FreeFloat2DArray(f_V_store);
   FreeFloat2DArray(f_V_max);
   for(i_month=0;i_month<12;i_month++)
     {
     FreeFloat2DArray(f_E_pot[i_month]);
     FreeFloat2DArray(f_P_rain[i_month]);
     }
// return successfulness
  b_success=1;
  return b_success;
}// end func Run Budyko Bucket

//*************************************************************************
// Calculate Net radiation.. does what it says on the box, based on Temp range
// Uses procedures from Allen et al
// Arguments:
//
// Returns: double Net Radiation  Rnl
//*************************************************************************
double CalculateNetRadiation(const double arg_d_lat,
                             const double arg_d_Z,
                             const double arg_d_dr,
                             const double arg_d_declination,
                             const float arg_f_kRs,
                             const double arg_d_Tmax,
                             const double arg_d_Tmin)
{
double d_omega; // sunset hour angle
double d_Ra;  // Radiation at top of atmosphere
double d_Rs;  // incoming shortwave
double d_Rn;  // Net Radiation
double d_Rso; // outgoing shortwave
double d_Rns; // Net shortwave
double d_Rnl; //Net longwave
double d_sTminK4, d_sTmaxK4, d_sigma_etc;  //Stephan Boltzmann corrections
double d_ea,d_ea_etc,d_rso_etc;     // dewpoint stuff
  //Sunseet hour angle
  d_omega=acos( -tan(arg_d_lat)*tan(arg_d_dr)  );    // Allen eq 25

// Calc rad at top of atmosphere
  d_Ra=37.58603136*arg_d_dr*(
      d_omega*sin(arg_d_lat)*sin(arg_d_declination)+
      cos(arg_d_lat)*cos(arg_d_declination)*sin(d_omega) );     // Allen eq 21
  // Now calculate Shortwave radiation
  d_Rs=arg_f_kRs*sqrt(arg_d_Tmax-arg_d_Tmin)*d_Ra;    // Allen eq 50
  d_Rso=(0.75+200000*arg_d_Z)*d_Ra; // Allen eq 37
  d_Rns=0.77*d_Rs;  // for grass ref albedo
  d_sTmaxK4=0.5195*arg_d_Tmax+26.361;         // steph boltz correction
  d_sTminK4=0.5195*arg_d_Tmin+26.361;
  d_sigma_etc= (d_sTmaxK4+d_sTminK4)/2;      // Allen eq 39
  d_ea=0.6108*exp(17.27*arg_d_Tmin/ (arg_d_Tmin+273.3));  // Allen eq 14
  d_ea_etc=0.34-0.14*sqrt(d_ea);   // Allen eq39
  d_rso_etc=1.35*(d_Rs/d_Rso)-1.35;
  d_Rnl=d_sigma_etc*d_ea_etc*d_rso_etc;
  d_Rn=d_Rns-d_Rnl;

  return (d_Rn);
} // end func CalcNetRadiation
//*************************************************************************
// Calculate Preistley-Taylor evaporation..
// Uses procedures from Allen et al
// Arguments:
//
// Returns: double Potential evaporation calced as Preistly-Taylor
//*************************************************************************
double CalculatePTEvaporation(const double arg_d_T,   // mean temp
                              const double arg_d_Z,      // altitude METRES
                              const double arg_d_Rn)  // net radiation
{
double d_P; // pressure
double d_esT;   // sat vap pressure
double d_lambda; //lat heat vap water
double d_gamma; // Psychometric constant
double d_Delta; // slope of sat vp curve
double d_E_pot; // potential evaporation
  //Pressure
  d_P=101.38*pow(((293-0.0065*arg_d_Z)/293),5.26);
  //Saturation Vapour Pressure
  d_esT=0.6108*exp(17.27*arg_d_T/ (arg_d_T+273.3));
  //Latent heat of vapourisation of water
  d_lambda=2.501-0.002361*arg_d_T;
  //Psychometric constant
  d_gamma=0.0016286*d_P/d_lambda;
  //Slope of saturation vapour pressure curve
  d_Delta=4098*d_esT/pow((arg_d_T+237.3),2);
  //Potential Evapotranspiration store to array
  d_E_pot=1.26*arg_d_Rn/(d_lambda*(1+d_gamma/d_Delta));
  // all done, return
  return (d_E_pot);
}// end func Calc PT Evaporation


//*************************************************************************
// Skip ASCII header reads an ASCII header in from the supplied open file stream
// and does nothing with it..just makes code in calling func more readable
//*************************************************************************
void SkipASCIIHeader(ifstream* argFileStream)
{
string s_buffer;
double d_buffer;
int i_buffer;

    // Read in input file headers 
    *argFileStream>>s_buffer;
    *argFileStream>>i_buffer;
    *argFileStream>>s_buffer;
    *argFileStream>>i_buffer;
    *argFileStream>>s_buffer;
    *argFileStream>>d_buffer;
    *argFileStream>>s_buffer;
    *argFileStream>>d_buffer;
    *argFileStream>>s_buffer;
    *argFileStream>>d_buffer;
    *argFileStream>>s_buffer;
    *argFileStream>>i_buffer;
}

//*************************************************************************
// Output ASCII header writes an ASCII header in to the supplied open file stream
//
//*************************************************************************
void OutputASCIIHeader(ofstream* argFileStream,
                       const int arg_n_cols,
                       const int arg_n_rows,
                       const float arg_f_xll,
                       const float arg_f_yll,
                       const float arg_f_cellsize,
                       const float arg_f_nodata)
{
  *argFileStream<<"ncols         ";
  *argFileStream<<arg_n_cols<<endl;
  *argFileStream<<"nrows         ";
  *argFileStream<<arg_n_rows<<endl;
  *argFileStream<<"xllcorner     ";
  *argFileStream<<arg_f_xll<<endl;
  *argFileStream<<"yllcorner    ";
  *argFileStream<<arg_f_yll<<endl;
  *argFileStream<<"cellsize      ";
  *argFileStream<<arg_f_cellsize<<endl;
  *argFileStream<<"NODATA_value  ";
  *argFileStream<<arg_f_nodata<<endl;
}
#pragma package(smart_init)
