#ifndef __METRICS_H__
#define __METRICS_H__

#include "math.h"
#include "common.h"

typedef float (*arc_weight_function) (float *f1, float *f2, int n);

typedef enum
{
  EUCLIDIAN          = 0,
  LOG_EUCLIDIAN      = 1,
  /*GAUSSIAN           = 2,*/
  CHI_SQUARE         = 2,
  MANHATTAN          = 3,
  CANBERRA           = 4,
  SQUARED_CHORD      = 5,
  SQUARED_CHI_SQUARE = 6,
  BRAY_CURTIS        = 7
} METRIC;

#ifdef __METRICS_MAIN__
arc_weight_function arc_weight = NULL;
int use_precomputed_distance = FALSE;
float **distance_value = NULL;
#else
extern arc_weight_function arc_weight;
extern int use_precomputed_distance;
extern float **distance_value;
#endif

#endif  /* __METRICS_H__ */
