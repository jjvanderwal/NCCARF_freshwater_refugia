//---------------------------------------------------------------------------

#ifndef DownscalingFuncsH
#define DownscalingFuncsH
#include <string.h>
#include <iostream.h>
#include <fstream.h>
int RunBudykoBucketModel_5km (void);
double CalculateNetRadiation(const double arg_d_lat,    // latitiude RADIANS
                             const double arg_d_Z,      // altitude METRES
                             const double arg_d_dr,     //
                             const double arg_d_declination,  //declination
                             const float arg_f_kRs,
                             const double arg_d_Tmax,
                             const double arg_d_Tmin);
double CalculatePTEvaporation(const double arg_d_T,   // mean temp
                              const double arg_d_Z,      // altitude METRES
                              const double arg_d_Rn);  // net radiation
void SkipASCIIHeader(ifstream* argFileStream);
void OutputASCIIHeader(ofstream* argFileStream,
                       const int arg_n_cols,
                       const int arg_n_rows,
                       const float arg_f_xll,
                       const float arg_f_yll,
                       const float arg_f_cellsize,
                       const float arg_f_nodata);

//---------------------------------------------------------------------------
#endif
