/* Forth-word.h - BFCD VM binary Forth words
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 */

#ifndef FORTH_WORDS_H
#define FORTH_WORDS_H

#include "forth.h"

//********************************************************** History file per VM Thread
defword(save_history);		// !hs
defword(load_history);		// !hl

//********************************************************** Восстановление после сбоев
defword(dropall);			// dropall
defword(rdropall);			// Rdropall
defword(protected_exec);	// (EXECUTE-PROTECTED) - слово исполняется с перехватом всех исключений
							// всегда возвращает 'true'. В основном используется в контексте 
							// сабпулов или потоков исполнения
defword(subpool_start);		// !subpool: <name> <startup_word>
defword(print_info);		// !info

#endif // FORTH_WORDS_H

