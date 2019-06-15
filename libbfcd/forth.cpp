#include "forth.h"
#include <stdio.h>

/*
 * VMThreadData
 */
VMThreadData::VMThreadData(TAbstractAllocator* _allocator, CELL _code):
	allocator(_allocator),
	code(_code),
	IP(NULL),
	STDIN(STDIN_FILENO),
	STDOUT(STDOUT_FILENO),
	STDERR(STDERR_FILENO)
{
	AS=XNEW(allocator,AStack) (allocator);
	RS=XNEW(allocator,RStack) (allocator);
}

