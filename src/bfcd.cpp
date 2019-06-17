/* BFCD.cpp - BFCD7 Forth IDE/Compiler
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 */

#include <bfcd-vm.h>
#include <version.h>
#include <stdio.h>

void copyright()
{
	printf("%s - %s version %s\n%s\nAuthor: %s\nAll rights reserved.\n\n",
		   VERSION_NAME, VERSION_DESCR, VERSION_NUM,
		   VERSION_COPYRIGHT, VERSION_AUTHOR);
}

int main(int argc, char* argv[])
{
	copyright();
	BfcdVM vm;
	return 0;
}

