/* BFCD.cpp - BFCD7 Forth IDE/Compiler
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 */

#include <bfcd-vm.h>
#include <version.h>
#include <stdio.h>
#include <locale.h>
#include <errno.h>

void copyright()
{
	printf("%s - %s version %s\n%s\nAuthor: %s\nAll rights reserved.\n\n",
		   VERSION_NAME, VERSION_DESCR, VERSION_NUM,
		   VERSION_COPYRIGHT, VERSION_AUTHOR);
}

int main(int argc, char* argv[])
{
	//try
	{
		copyright();
		printf("Current locale: %s\n", setlocale(LC_ALL,getenv("LC_ALL")));
		BfcdVM vm;
		vm.run();
	}
	/*catch(SimpleException &ex)
	{
		printf("At TOP level:\n\tException: %s\n\t_errno: %s\n", ex(), strerror(errno));
	}*/
	return 0;
}

