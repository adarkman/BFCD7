/* GENSYS.H - "sys.bf" file generator for BFCD2
 * (C) Hell Design 2000
 * Author: Alexandr Darkman
 *
 * $Id: gensys.c,v 1.2 2002/05/31 12:26:16 darkman Exp $
 *
 */

#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/utsname.h>

#define BUF_SIZE 10240
FILE *f;

void SIG_gen(void)
{
  char s[BUF_SIZE];
  printf(" * SIGNAL contstants... ");
  snprintf(s,BUF_SIZE,
   "#define SIGHUP 	%d\n"
   "#define SIGINT 	%d\n"
   "#define SIGQUIT 	%d\n"
   "#define SIGILL 	%d\n"
   "#define SIGTRAP 	%d\n"
   "#define SIGABRT	%d\n"
   "#define SIGIOT	%d\n"
   "#define SIGBUS 	%d\n"
   "#define SIGFPE	%d\n"
   "#define SIGKILL	%d\n"
   "#define SIGUSR1	%d\n"
   "#define SIGSEGV	%d\n"
   "#define SIGUSR2	%d\n"
   "#define SIGPIPE	%d\n"
   "#define SIGALRM	%d\n"
   "#define SIGTERM	%d\n"
#ifndef OS_BSD   
   "#define SIGSTKFLT	%d\n"
   "#define SIGCLD	%d\n"
#endif   
   "#define SIGCHLD	%d\n"
   "#define SIGCONT	%d\n"
   "#define SIGSTOP	%d\n"
   "#define SIGTSTP	%d\n"
   "#define SIGTTIN	%d\n"
   "#define SIGTTOU	%d\n"
   "#define SIGURG	%d\n"
   "#define SIGXCPU	%d\n"
   "#define SIGXFSZ	%d\n"
   "#define SIGVTALRM	%d\n"
   "#define SIGPROF	%d\n"
   "#define SIGWINCH	%d\n"
#ifndef OS_BSD   
   "#define SIGPOLL	%d\n"
#endif   
   "#define SIGIO	%d\n"
#ifndef OS_BSD   
   "#define SIGPWR	%d\n"
   "#define SIGUNUSED	%d\n"
   "#define _NSIG	%d\n"
#endif   
   "\n",
    SIGHUP, SIGINT, SIGQUIT, SIGILL, SIGTRAP, SIGABRT, SIGIOT,
    SIGBUS, SIGFPE, SIGKILL, SIGUSR1, SIGSEGV, SIGUSR2, SIGPIPE,
    SIGALRM, SIGTERM, 
#ifndef OS_BSD   
	SIGSTKFLT, 
	SIGCLD, 
#endif	
	SIGCHLD, SIGCONT, 
    SIGSTOP, SIGTSTP, SIGTTIN, SIGTTOU, SIGURG, SIGXCPU, SIGXFSZ,
    SIGVTALRM, SIGPROF, SIGWINCH, 
#ifndef OS_BSD   
	SIGPOLL, 
#endif	
	SIGIO 
#ifndef OS_BSD   
	, SIGPWR, SIGUNUSED,
    _NSIG
#endif	
	);
  fputs(s,f);  
  puts("done");
}

void CHMOD_gen(void)
{
	char s[BUF_SIZE];
	printf(" * CHMOD constants...");
	snprintf(s,BUF_SIZE,
	 	"#define S_IRWXU %d\n"
		"#define S_IRUSR %d\n"
		"#define S_IWUSR %d\n"
		"#define S_IXUSR %d\n"
		"#define S_IRWXG %d\n"
		"#define S_IRGRP %d\n"
		"#define S_IWGRP %d\n"
		"#define S_IXGRP %d\n"
		"#define S_IRWXO %d\n"
		"#define S_IROTH %d\n"
		"#define S_IWOTH %d\n"
		"#define S_IXOTH %d\n\n",
		S_IRWXU, S_IRUSR, S_IWUSR, S_IXUSR,
		S_IRWXG, S_IRGRP, S_IWGRP, S_IXGRP,
		S_IRWXO, S_IROTH, S_IWOTH, S_IXOTH); 
	fputs(s,f);
	puts("done");
}

void TYPE_gen(void)
{
  char s[BUF_SIZE];
  printf(" * TYPE constants... ");
  snprintf(s, BUF_SIZE,
   " %d dup const INT const UINT \n"
   " %d const CHAR	\n"
   " CHAR const BYTE 	\n"
   " %d const PTR*	\n"
   " %d const CHAR*	\n"
   " %d const INT*	\n"
   " %d const FN*	\n"
   " %d dup const SHORT const USHORT \n"
   " %d dup const LONG const ULONG \n"
   " %d dup const LLONG const ULLONG \n\n",
   sizeof(int), sizeof(char), sizeof(void*), sizeof(char*),
   sizeof(int*), sizeof(void (*)(void)), sizeof(short int),
   sizeof(long int), sizeof(long long int));
  fputs(s,f);  
  puts("done");
}

void FD_gen(void)
{
   char s[BUF_SIZE];
   struct timeval tv;
   printf(" * SELECT constants... ");
   snprintf(s,BUF_SIZE,
    " %d const FD_SIZE 	\n"
    " %d const FD_SETSIZE \n \n"
    " struct timeval	\n"
    "  %d -- tv_sec	\n"
    "  %d -- tv_usec	\n"
    " ends		\n\n ",
    sizeof(fd_set), FD_SETSIZE,
    sizeof(tv.tv_sec), sizeof(tv.tv_usec));
   fputs(s,f);   
   puts("done");
}


void HEAD_gen(void)
{
  char s[BUF_SIZE];
  struct utsname un;
  printf(" * Header... ");
  uname(&un);
  snprintf(s,BUF_SIZE,
   "( SYS.BF - system constant/types definition for BFCD2 \n"
   "  Target system: %s %s %s %s %s  \n"
   "  Target: BFCD 2 v2.2.4 \n"
   "\n"
   "  * Warning: DO NOT MODIFY THIS FILE \n"
   ")\n\n",
   un.sysname, un.nodename, un.release, un.version,
   un.machine/*, un.__domainname*/);
  fputs(s,f);

  snprintf(s,BUF_SIZE,
   " ` %s %s %s %s %s ` const SYSTEM_NAME \n\n",
   un.sysname, un.nodename, un.release, un.version,
   un.machine/*,un.__domainname*/);
  fputs(s,f); 
  puts("done");     
}

void STDF_gen(void)
{
  char s[BUF_SIZE];
  printf(" * STD*_FILENO constants... ");
  snprintf(s,BUF_SIZE,
   "#define STDIN_FILENO 	%d\n"
   "#define STDOUT_FILENO	%d\n"
   "#define STDERR_FILENO	%d\n\n",
   STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO);
  fputs(s,f); 
  puts("done");
}

int main()
{
  f=fopen("../kernel/sys.bf","wb");
  if(!f)
  {
    fprintf(stderr,"gensys: unable to create \"sys.bf\"\n");
    return 1;
  }  
  HEAD_gen();
  SIG_gen();
  CHMOD_gen();
  TYPE_gen();
  FD_gen();
  STDF_gen();
  fclose(f);
  return 0;
}



