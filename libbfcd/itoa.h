/* itoa.c - itoa, utoa functions (absent in glibc2)
 * (C) Hell Design 2000
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 * $Id: itoa.h,v 1.1.1.1 2002/05/21 10:48:30 darkman Exp $
 *
 */

#ifndef __ITOA_H__
#define __ITOA_H__

#ifdef __cplusplus
extern "C"
{
#endif
	
char* itoa(int value,char *s,unsigned radix);
char* utoa(unsigned value,char *s,unsigned radix); 

#ifdef __cplusplus
}
#endif

#endif //__ITOA_H__	
