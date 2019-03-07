#include "version.h"
#include <stdio.h>
#include "tools.h"
#include "memmanager.h"

int main(int argc, char* argv[])
{
	__CODE(printf("%s %s %s\nAuthor: %s\n%s\nAll rights reserved.\n\n", 
				  VERSION_NAME, VERSION_NUM, VERSION_DESCR, 
				  VERSION_AUTHOR, 
				  VERSION_COPYRIGHT))
	MemManager mm(Mb(32));
    return 0;
}
