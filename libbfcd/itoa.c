/* itoa.c - itoa, utoa functions (absent in glibc2)
 * (C) Hell Design 2000
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 * $Id: itoa.c,v 1.1.1.1 2002/05/21 10:48:30 darkman Exp $
 *
 */   
   
#include <stdlib.h>
#include <string.h>
#include "itoa.h"

char* itoa(int value,char *s,unsigned radix)
{
	unsigned m,i; char *s1=s; char s2[31];
	int minus=0;
	if(value<0)
		{
			minus=1;
			value=(-value);
		}
	if(value)
		{
			while(value)
				{
					m=value%radix; value/=radix;
					/*printf("%X %X\n",m,value);*/
					if(m>9) *s=(char)(m+('A'-'9')+0x31-2); else *s=(char)(m+0x30);
					s++;
				}
			*s='\0'; s=s1;
			for(m=strlen(s1)-1,i=0; i<=m; i++) s2[i]=s1[m-i];
			s2[i]='\0';
			if(minus)
				{
					strcpy(s,"-");
					strcat(s,s2);
				}
			else strcpy(s,s2);
		}
	else
		{
			s[0]='0'; s[1]='\0';
		}
	return s;
}

char* lltoa(long long int value,char *s,unsigned radix)
{
	unsigned m,i; char *s1=s; char s2[256];
	int minus=0;
	if(value<0)
		{
			minus=1;
			value=(-value);
		}
	if(value)
		{
			while(value)
				{
					m=value%radix; value/=radix;
					/*printf("%X %X\n",m,value);*/
					if(m>9) *s=(char)(m+('A'-'9')+0x31-2); else *s=(char)(m+0x30);
					s++;
				}
			*s='\0'; s=s1;
			for(m=strlen(s1)-1,i=0; i<=m; i++) s2[i]=s1[m-i];
			s2[i]='\0';
			if(minus)
				{
					strcpy(s,"-");
					strcat(s,s2);
				}
			else strcpy(s,s2);
		}
	else
		{
			s[0]='0'; s[1]='\0';
		}
	return s;
}

wchar_t* lltowcs(long long int value,wchar_t *s,unsigned radix)
{
	unsigned m,i; wchar_t *s1=s; wchar_t s2[256];
	int minus=0;
	if(value<0)
		{
			minus=1;
			value=(-value);
		}
	if(value)
		{
			while(value)
				{
					m=value%radix; value/=radix;
					/*printf("%X %X\n",m,value);*/
					if(m>9) *s=(wchar_t)(m+(L'A'-L'9')+0x31-2); else *s=(wchar_t)(m+0x30);
					s++;
				}
			*s=L'\0'; s=s1;
			for(m=wcslen(s1)-1,i=0; i<=m; i++) s2[i]=s1[m-i];
			s2[i]=L'\0';
			if(minus)
				{
					wcscpy(s,L"-");
					wcscat(s,s2);
				}
			else wcscpy(s,s2);
		}
	else
		{
			s[0]=L'0'; s[1]=L'\0';
		}
	return s;
}

char* utoa(unsigned value,char *s,unsigned radix)
{
	unsigned m,i; char *s1=s; char s2[31];
	if(value)
		{
			while(value)
				{
					m=value%radix; value/=radix;
					/*printf("%X %X\n",m,value);*/
					if(m>9) *s=(char)(m+('A'-'9')+0x31-2); else *s=(char)(m+0x30);
					s++;
				}
			*s='\0'; s=s1;
			for(m=strlen(s1)-1,i=0; i<=m; i++) s2[i]=s1[m-i];
			s2[i]='\0';
			strcpy(s,s2);
		}
	else
		{
			s[0]='0'; s[1]='\0';
		}
	return s;
}
