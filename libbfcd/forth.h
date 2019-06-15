/* Forth.h - Низкий уровень BFCD VM
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 */

#ifndef FORTH_H
#define FORTH_H

#include "MemoryManager.h"
#include "stringhash.h"
#include <assert.h>

// require C11 standart in compiler
static_assert(sizeof(BfcdInteger) >= sizeof(StringHash::UID),
	"CELL size < StringHash::UID size. Unsupported configuration.");

/*
 * Заголовок словарной статьи
 */
struct WordHeader
{
	StringHash::UID name;
	CHAR_P help;
	CHAR_P source;
	int flags;
	WordHeader* next;
};

/*
 * Словарь
 */
struct Vocabulary
{
	WordHeader *last;
	Vocabulary *prev;
};

/*
 * Поток исполнения/компиляции BFCD VM
 */
typedef TStack<BfcdInteger> AStack;
typedef TStack<CELL> RStack;
enum VM_STATE {VM_EXECUTE=0, VM_COMPILE};

struct VMThreadData
{
	VMThreadData(TAbstractAllocator* _allocator, CELL* _code);

//---	
	TAbstractAllocator *allocator;

	AStack *AS;			// Арифметический стек
	RStack *RS;			// Стек возврата	
	BfcdInteger IP;				// Instruction Pointer
	CELL* code;					// Указатель на массив кода

	BfcdInteger STDIN, STDOUT, STDERR;
};

class VMThread
{

protected:
	MemoryManager* allocator;
};

/*
 * Forth low level words
 */

#endif //FORTH_H


