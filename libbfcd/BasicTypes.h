/* BasicTypes.h - Internal BFCD VM types 
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 */

#ifndef BASIC_TYPES_H
#define BASIC_TYPES_H

#if SIZEOF_INTP == SIZEOF_LONG_LONG
typedef long long BfcdInteger;
#elif SIZEOF_INTP == SIZEOF_INT
typedef int BfcdInteger int;
#else
#error "Unsupported Integer size."
#endif
const unsigned CELL_SIZE = SIZEOF_INTP;
typedef void* CELL;
typedef char* CHAR_P; 

#if SIZEOF_LONG_LONG!=SIZEOF_INT*2
 	#error sizeof(long long)!=sizeof(int)*2
#endif

#endif //BASIC_TYPES_H


