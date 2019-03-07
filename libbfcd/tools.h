/* Tools.h - misc tools for BFCD3
 * (C) Hell Design 2000, 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 * $Id: tools.h,v 1.1.1.1 2002/05/21 10:48:30 darkman Exp $
 *
 */

#ifndef __BFCD3_TOOLS_H__
#define __BFCD3_TOOLS_H__

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <stdlib.h>

#include "itoa.h"
#include "config.h"

#if SIZEOF_INT==SIZEOF_INTP
 	#define BCELL int
#elif SIZEOF_LONG_LONG==SIZEOF_INTP
	#define BCELL long long
#else
 	#error Unable to define BCELL
#endif

#if SIZEOF_LONG_LONG!=SIZEOF_INT*2
 	#error sizeof(long long)!=sizeof(int)*2
#endif

#ifdef __DEBUG__
#define __CODE(c) { c; }
#else
#define __CODE(c)
#endif

#define __MARK { fprintf(stderr,"** mark\n"); fflush(stderr); }

#define Kb(k) (1024*k)
#define Mb(m) (Kb(Kb(m)))

#endif //__BFCD3_TOOLS_H__
