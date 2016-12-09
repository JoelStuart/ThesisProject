#ifndef _sgp4ext_
#define _sgp4ext_
/*     ----------------------------------------------------------------
*
*                                 sgp4ext.h
*
*    this file contains extra routines needed for the main test program for sgp4.
*    these routines are derived from the astro libraries.
*
*                            companion code for
*               fundamentals of astrodynamics and applications
*                                    2007
*                              by david vallado
*
*       (w) 719-573-2600, email dvallado@agi.com
*
*    current :
*              20 apr 07  david vallado
*                           misc documentation updates
*    changes :
*              14 aug 06  david vallado
*                           original baseline
*       ----------------------------------------------------------------      */

#include <string.h>
#include <math.h>

#include "sgp4unit.h"


// ------------------------- function declarations -------------------------

__device__ double  sgn
        (
          double x
        );

__device__ double  mag
        (
          double x[3]
        );

__device__ void    cross
        (
          double vec1[3], double vec2[3], double outvec[3]
        );

__device__ double  dot
        (
          double x[3], double y[3]
        );

__device__ double  angle
        (
          double vec1[3],
          double vec2[3]
        );

__device__ void    newtonnu
        (
          double ecc, double nu,
          double& e0, double& m
        );

__device__ double  asinh
        (
          double xval
        );

__device__ void    rv2coe
        (
          double r[3], double v[3], double mu,
          double& p, double& a, double& ecc, double& incl, double& omega, double& argp,
          double& nu, double& m, double& arglat, double& truelon, double& lonper
        );

__device__ void    jday
        (
          int year, int mon, int day, int hr, int minute, double sec,
          double& jd
        );

__device__ void    days2mdhms
        (
          int year, double days,
          int& mon, int& day, int& hr, int& minute, double& sec
        );

__device__ void    invjday
        (
          double jd,
          int& year, int& mon, int& day,
          int& hr, int& minute, double& sec
        );

#endif

