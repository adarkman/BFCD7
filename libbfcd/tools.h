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

#define __DEBUG__
#include "itoa.h"
#include "config.h"
#include "BasicTypes.h"

#ifdef __DEBUG__
#define __CODE(c) { c; }
#else
#define __CODE(c)
#endif

#define __MARK { fprintf(stderr,"** mark\n"); fflush(stderr); }

#define KB(a) (1024*a)
#define MB(a) (1024*KB(1)*a)
#define GB(a) (1024*MB(1)*a)


#endif //__BFCD3_TOOLS_H__
