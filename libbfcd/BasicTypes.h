/* BasicTypes.h - Internal BFCD VM types 
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 */

#ifndef BASIC_TYPES_H
#define BASIC_TYPES_H

#include <wchar.h>

#if SIZEOF_INTP == SIZEOF_LONG_LONG
typedef long long BfcdInteger;
#elif SIZEOF_INTP == SIZEOF_INT
typedef int BfcdInteger int;
#else
#error "Unsupported Integer size."
#endif

#if SIZEOF_LONG_LONG < 4 // UTF-8 maximum 4 bytes long https://stijndewitt.com/2014/08/09/max-bytes-in-a-utf-8-char/
#error "Unsupported Integer size - can not hold UTF-8 character."
#endif

const unsigned CELL_SIZE = SIZEOF_INTP;
typedef void* CELL;
typedef wchar_t* WCHAR_P; 
typedef const wchar_t* CONST_WCHAR_P; 

#if SIZEOF_LONG_LONG!=SIZEOF_INT*2
 	#error sizeof(long long)!=sizeof(int)*2
#endif

#endif //BASIC_TYPES_H


