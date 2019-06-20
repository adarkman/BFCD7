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
#include <functional> // Инстанциированные темплейты типа std::hash<unsigned int>
#include <utility>
#include <unordered_map>

// require C11 standart in compiler
static_assert(sizeof(BfcdInteger) >= sizeof(StringHash::UID),
	"CELL size < StringHash::UID size. Unsupported configuration.");

/*
 * Заголовок словарной статьи
 */
struct VMThreadData;
typedef bool (*BFCD_OP)(VMThreadData*);
struct Vocabulary;

struct WordHeader
{
	StringHash::UID name;
	CHAR_P help;
	CHAR_P source;
	int flags;
	WordHeader* prev;
	Vocabulary *voc;
	BFCD_OP CFA;

	WordHeader(): name(0), help(NULL), source(NULL), flags(0), prev(NULL), voc(NULL), CFA(NULL) {}
};

/*
 * Словарь
 */
struct Vocabulary
{
	Vocabulary (TAbstractAllocator* _alloc, const char* _name);
	~Vocabulary();

	WordHeader* add_word(const char* _name, BFCD_OP CFA);
	//WordHeader* find_self(const char* _name); 
	//WordHeader* find_all_chain(const char* _name);
//---	
protected:
	StringHash::UID name;
	// Добавление в словарь не потокобезопасно 
	pthread_mutex_t mutex;
	// Последнее определённое слово
	WordHeader *last;
	// Предыдущий словарь, на момент определения словаря (см. find_all_chain)
	Vocabulary *prev;
	
	TAbstractAllocator* allocator;
	// Юзаем STL unordered_map в качестве хеш-таблицы и кастомным аллокатором.
	// (пора подучить современный C++ :/ )
	typedef STLAllocator<std::pair<StringHash::UID, WordHeader*>> WordsMapAllocator;
	typedef std::unordered_map<StringHash::UID,
				WordHeader*,
				std::hash<StringHash::UID>,
				std::equal_to<StringHash::UID>,
				WordsMapAllocator> WordsMap;
	WordsMapAllocator* stl_allocator;
	// Хеш имён слов
	StringHash* names;
	// Собственно список слов в словаре
	WordsMap* words;
};

/*
 * Коды ошибок VM
 */
enum ErrorCodes
{
	VM_OK=0,
	VM_SEGFAULT,
	VM_TERMINATE_THREAD,			// На самом деле не ошибка, а запрос на остановку потока выполнения
									// см. defword(bye)
	VM_ERROR_LAST
};

extern const char* VM_Errors[VM_ERROR_LAST];
/*
 * Поток исполнения/компиляции BFCD VM
 */
typedef TStack<BfcdInteger> AStack;
typedef TStack<CELL> RStack;
typedef TStack<Vocabulary*> VocabularyStack;

enum VM_STATE {VM_EXECUTE=0, VM_COMPILE};

struct VMThreadData
{
	VMThreadData(TAbstractAllocator* _allocator, VocabularyStack *_vocs,
				 CELL _code, CELL start_IP,
				 BfcdInteger _tib_size=KB(4));
	~VMThreadData();

	void apush(BfcdInteger a) {AS->push(a);}
	BfcdInteger apop() {return AS->pop();}
	BfcdInteger atop() {return AS->_top();}

	// Проверяет что адрес исполнения есть в словарях (во избежание SIGSEGV)
	// требует постоянной доработки
	bool is_valid_for_execute(void* fn);
//---	
	TAbstractAllocator *allocator;

	AStack *AS;			// Арифметический стек
	RStack *RS;			// Стек возврата	
	CELL IP;				// Instruction Pointer
	CELL code;					// Указатель на массив кода
	BfcdInteger vm_state;		// VM_STATE
	BfcdInteger _errno;			// Код ошибки, выставляется в словах

	// Входной поток
	BfcdInteger STDIN, STDOUT, STDERR;
	BfcdInteger TIB_SIZE;
	char* tib;
	BfcdInteger tib_index;
	BfcdInteger tib_length;

	// Основание чисел при парсинге
	BfcdInteger digit_base;

	// Список _всех_ словарей - общий для всех потоков.
	TStack<Vocabulary*> *vocs;
};

#define defword(NAME) bool f_##NAME(VMThreadData *data)

class VMThread
{

protected:
	MemoryManager* allocator;
};

/*
 * Forth low level words
 */
//********************************************************** Базовые
//слова
defword(bl); 		// bl
defword(ifdup); 	// ?dup
defword(inc);		// 1+
defword(dec);		// 1-
defword(state);		// STATE
defword(get);		// @
defword(put);		// !
defword(bye);		// BYE
defword(execute);	// EXECUTE

#endif //FORTH_H


