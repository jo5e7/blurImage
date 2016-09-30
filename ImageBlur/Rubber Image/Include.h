#ifndef __INCLUDE_H__
#define __INCLUDE_H__

#include <OpenGLES/ES1/gl.h>
#include <math.h>
#include <assert.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <vector>
#include <list>
#include <map>
#include <iostream>
#include <fstream>
#include <sstream>


class v2;
extern v2 SCREEN_SIZE;
extern v2 IMAGE_SIZE;

// ********************************* macros *********************************
#define RAND                                  (float(rand())/RAND_MAX)
#define RRAND                                 (RAND*2.f-1.f)
#define RAD2DEG(x)                            ((x)*57.2957795f)
#define DEG2RAD(x)                            ((x)/57.2957795f)

// ********************************* constants *********************************
const float PI                                 = 3.14159265f;
const float TWICEPI                            = 6.28318531f;
const float HALFPI                             = 1.57079633f;

#endif // #ifndef __INCLUDE_H__
