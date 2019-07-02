/* Forth.h - Низкий уровень BFCD VM
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 */

#ifndef FORTH_H
#define FORTH_H

#include "MemoryManager.h"
#include "WStringHash.h"
#include <assert.h>
#include <functional> // Инстанциированные темплейты типа std::hash<unsigned int>
#include <utility>
#include <unordered_map>
#include <iconv.h>

// require C11 standart in compiler
static_assert(sizeof(BfcdInteger) >= sizeof(WStringHash::UID),
	"CELL size < StringHash::UID size. Unsupported configuration.");

static_assert(sizeof(BfcdInteger) >= sizeof(wchar_t),
			  "CELL size < sizeof(wchar_t). Unsupported configuration.");

/*
 * Заголовок словарной статьи
 */
struct VMThreadData;
typedef bool (*BFCD_OP)(VMThreadData*);
struct Vocabulary;

struct WordHeader
{
	enum Flags {IMMEDIATE=-1};
	WStringHash::UID name;
	WCHAR_P help;
	WCHAR_P source;
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
	Vocabulary (TAbstractAllocator* _alloc, CONST_WCHAR_P _name);
	~Vocabulary();

	WordHeader* add_word(CONST_WCHAR_P _name, BFCD_OP CFA);

	typedef std::pair<int, WordHeader*> FindResult;
	// Поиск только в текущем словаре
	FindResult find_self(CONST_WCHAR_P _name); 
	FindResult find_self(WStringHash::UID _name); 
	// Поиск в цепочке словарей через this->prev
	FindResult find_all_chain(const WCHAR_P _name); 
	FindResult find_all_chain(WStringHash::UID _name); 
	// Проверяет наличие слова с нужным CFA в словаре.
	bool check_CFA(BFCD_OP cfa);
//---	
protected:
	WStringHash::UID name;
	// Добавление в словарь не потокобезопасно 
	pthread_mutex_t mutex;
	// Последнее определённое слово
	WordHeader *last;
	// Предыдущий словарь, на момент определения словаря (см. find_all_chain)
	Vocabulary *prev;
	
	TAbstractAllocator* allocator;
	// Юзаем STL unordered_map в качестве хеш-таблицы и кастомным аллокатором.
	// (пора подучить современный C++ :/ )
	typedef STLAllocator<std::pair<const WStringHash::UID, WordHeader*>> WordsMapAllocator;
	typedef std::unordered_map<WStringHash::UID,
				WordHeader*,
				std::hash<WStringHash::UID>,
				std::equal_to<WStringHash::UID>,
				WordsMapAllocator> WordsMap;
	WordsMapAllocator* stl_allocator;
	// Хеш имён слов
	WStringHash* names;
	// Собственно список слов в словаре
	WordsMap* words;
};

/*
 	//Поиск слова в стэке словарей	//Поиск слова в стэке словарей..* Коды ошибок VM
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
 * Общие данные для всех потоков
 */
struct TSharedData
{
	pthread_mutex_t readline_mutex;

	TSharedData();
	~TSharedData();
};

/*
 * Поток исполнения/компиляции BFCD VM
 */
typedef TStack<BfcdInteger> AStack;
typedef TStack<CELL> RStack;
typedef TStack<Vocabulary*> VocabularyStack;

enum VM_STATE {VM_EXECUTE=0, VM_COMPILE};

exception (VMDataError, SimpleException);
exception (IconvInitError, VMDataError);

#define TIB_PAD 16
struct VMThreadData
{
	VMThreadData(CONST_WCHAR_P _name, TSharedData *_shared,
				 TAbstractAllocator* _allocator, VocabularyStack *_vocs,
				 CELL _code, CELL start_IP, CELL _here,
				 TAbstractAllocator* _main_VM_allocator,
				 const char *_SYSTEM_ENCODING,
				 BfcdInteger _tib_size=KB(4),
				 bool _use_tty = false,
				 BfcdInteger __trace = 0,
				 int _STDIN = STDIN_FILENO,
				 int _STDOUT = STDOUT_FILENO,
				 int _STDERR = STDERR_FILENO);
	~VMThreadData();

	void apush(BfcdInteger a) {AS->push(a);}
	void apushp(void* p) {AS->push((BfcdInteger)p);}
	BfcdInteger apop() {return AS->pop();}
	BfcdInteger atop() {return AS->_top();}
	BFCD_OP rpop() {return (BFCD_OP)RS->pop();}
	void rpush(BFCD_OP p) {RS->push((CELL)p);}
	BFCD_OP rtop() {return (BFCD_OP)RS->_top();}

	//Поиск слова в локальном стэке словарей.
	void find_word_to_astack(CONST_WCHAR_P _name);

	// Проверяет что адрес исполнения есть в словарях (во избежание SIGSEGV)
	// требует постоянной доработки
	bool is_valid_for_execute(void* fn);
	// Проверяет что указатель находится в пределах пула
	bool is_pointer_valid(void* p);
	// Резервирует память в области кода
	bool allot(BfcdInteger size);
	// Обработчик \\ последовательностей в строках
	wchar_t* process_str(wchar_t* s);

//---	
	// Имя потока
	CONST_WCHAR_P name;
	// Общие данные всех потоков
	TSharedData *shared;
	// Локальный аллокатор потока
	TAbstractAllocator *allocator;
	// Глобальный аллокатор VM, используется для проверки валидности указателей.
	TAbstractAllocator *main_VM_allocator;

	AStack *AS;			// Арифметический стек
	RStack *RS;			// Стек возврата	
	BFCD_OP IP;				// Instruction Pointer
	CELL code;					// Указатель на массив кода
	BfcdInteger vm_state;		// VM_STATE
	BfcdInteger _errno;			// Код ошибки, выставляется в словах
	BfcdInteger _trace;			// Флаг включения трассировки
	BfcdInteger* here;			// HERE - вершина компиляции

	// Входной поток
	const char* SYSTEM_ENCODING;
	BfcdInteger STDIN, STDOUT, STDERR;
	BfcdInteger TIB_SIZE;
	bool use_tty;
	char* tib;
	BfcdInteger tib_index;
	BfcdInteger tib_length;
	wchar_t* word_buffer; // Буфер для WORD;
	wchar_t* number_word; // Строка конвертируемая в число. См. NUMBER, &NUMBER
	// iconv
	iconv_t iconv_in;
	iconv_t iconv_out;
	// База счисления слов при вводе/выводе
	BfcdInteger base;

	// Основание чисел при парсинге
	BfcdInteger digit_base;

	// Список _всех_ словарей - общий для всех потоков.
	VocabularyStack* vocs;
	// Локальный для потока порядок поиска в словарях. 
	VocabularyStack* local_vocs_order;
};

#define defword(NAME) bool f_##NAME(VMThreadData *data)

class VMThread
{

protected:
	MemoryManager* allocator;
};

/*
 * Forth low level words
 *
 * Большими БУКВАМИ - слова _низкого_ уровня, или работа с входным потоком 
 *
 */
//********************************************************** Базовые
//слова
defword(bl); 		// BL
defword(ifdup); 	// ?dup
defword(inc);		// 1+
defword(dec);		// 1-
defword(state);		// STATE
defword(get);		// @
defword(put);		// !
defword(bye);		// BYE
defword(execute);	// EXECUTE

//********************************************************** Слова
//работы со словарем и входным буффером
defword(find);		// FIND
defword(read_tib);	// read>tib - чтение из входного потока в TIB ( -- )
defword(tib);		// TIB
defword(tib_index);	// >IN
defword(tib_length);// #TIB
defword(key_internal);		// (KEY) - символ из TIB, переводит из Local Encoding в WCHAR_T (см. iconv)
							// самостоятельно вызываться не должен - см. KEY
defword(key);		// KEY
defword(eof);		// EOF
defword(word);		// WORD

//********************************************************** Компиляция
//и выделение памяти
defword(allot);		// ALLOT
defword(coma);		// ,
defword(str2here);	// S>H
defword(malloc);	// malloc - В байтах ! Не в CELL's. 
					// Освобождение памяти на совести GC аллокатора
defword(base);		// BASE
defword(number);	// NUMBER 
defword(lit);		// LIT - кладём на стек число лежащее сразу за собой в коде
defword(literal);	// LITERAL
defword(print_stack);		// .STACK
defword(step);		// STEP - один шаг интерпретатора					
defword(interpret);	// INTERPRET

//********************************************************** Мелочи для тестирования
defword(print);		// .
defword(cr);		// cr
defword(plus);		// +

#endif //FORTH_H


