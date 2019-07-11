/* Error-Codes.h - коды ошибок BFCD VM
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserverd.
 *
 */

#ifndef __ERROR_CODES_H__
#define __ERROR_CODES_H__

/*
 * Коды ошибок VM
 */
enum ErrorCodes
{
	VM_OK=0,
	VM_SEGFAULT,
	VM_TERMINATE_THREAD,			// На самом деле не ошибка, а запрос на остановку потока выполнения
									// см. defword(bye)
	VM_GET_SEGV,								
	VM_PUT_SEGV,
	VM_EXEC_SEGV,
	VM_EXECUTE_SEGV,
	VM_CFA_WH_NOT_LINKED,
	VM_FIND_SEGV,
	VM_READ_TIB_UNEXPECTED,
	VM_READ_TIB_EOF,
	VM_KEYI_EINVAL,
	VM_KEYI_UNEXPECTED,
	VM_E_ALLOT,
	VM_CCOMA_SEGV,
	VM_SH_SEGV,
	VM_SH_ALLOT,
	VM_E_MALLOC,
	VM_E_NUMBER,
	VM_LIT_SEGV,
	VM_E_COMPILE,
	VM_UNKNOWN_STATE,
	VM_SCREATE_SEGV,
	VM_CL_CONVERTION,
	VM_EMIT_PACK,
	VM_RESOLVE_SEGV,
	VM_BRANCH_SEGV,
	VM_DOES_FIND_ERROR,
	VM_DOES_SEGV,
	VM_APOST_FIND,
	VM_ERROR_LAST
};

extern const char* VM_Errors[VM_ERROR_LAST+1];

#endif // __ERROR_CODES_H__


