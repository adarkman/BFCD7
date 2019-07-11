#include "error-codes.h"

/*
 * VM Error Messages
 */
const char *VM_Errors[] = 
{
	"No error",				// VM_OK
	"Invalid address",		// VM_SEGFAULT
	"",						// VM_TERMINATE_THREAD
	"Invalid address in @",	//	VM_GET_SEGV,
	"Invalid address in !",	// VM_PUT_SEGV,
	"Operator pointer NULL in (EXEC)",	// VM_EXEC_SEGV,
	"Invalid CFA in EXECUTE",	// VM_EXECUTE_SEGV,
	"CFA not linked to Word Header in EXECUTE",	// VM_CFA_WH_NOT_LINKED,
	"Invalid name pointer in FIND",	// VM_FIND_SEGV,
	"Unexpected error in read>tib",	// VM_READ_TIB_UNEXPECTED,
	"EOF in read>tib",	// VM_READ_TIB_EOF,
	"Incomplete multibyte sequence in (KEY)",	// VM_KEYI_EINVAL,
	"Unxepected error in (KEY)", // VM_KEYI_UNEXPECTED,
	"ALLOT - code allocation error", // VM_E_ALLOT,
	"invalid CFA in CODE,",	// VM_CCOMA_SEGV,
	"Invalid string pointer in S>H",	// VM_SH_SEGV,
	"Code allocation error in S>H",	// VM_SH_ALLOT,
	"Heap allocation error",	// VM_E_MALLOC,
	"Invalid number or mistyped word",	// VM_E_NUMBER,
	"Invalid pointer in LIT",	// VM_LIT_SEGV,
	"Word compilation failed",	// VM_E_COMPILE,
	"Unknown compiler state",	// VM_UNKNOWN_STATE,
	"invalid string pointer in >CREATE",	// VM_SCREATE_SEGV,
	"C>LOCALE - failed convertion to local encoding",	// VM_CL_CONVERTION,
	"emit - packing error",	// VM_EMIT_PACK,
	"RESOLVE> - invalid pointer",	// VM_RESOLVE_SEGV,
	"BRANCH - invalid pointer",	// VM_BRANCH_SEGV,
	"(DOES>) - BRANCH not found, ***internal*** vocabulary error",	// VM_DOES_FIND_ERROR,
	"(DOES>) - invalid CFA",	// VM_DOES_SEGV,
	"' - word no found",	// VM_APOST_FIND,
	""
};

