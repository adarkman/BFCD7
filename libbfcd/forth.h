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
#include <histedit.h>
#include "error-codes.h"

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

#define WH_MARK (0x42464344)
struct WordHeader
{
	enum Flags {IMMEDIATE=-1};
	BfcdInteger MARK;				// Маркер валидного хидера, используется для проверки при адресной арифметике
	WStringHash::UID name;			
	WCHAR_P help;
	WCHAR_P source;
	int flags;
	bool forth;						// false - значит слово бинарное, не нужен вызов через (EXEC)
	WordHeader* prev;
	Vocabulary *voc;
	BFCD_OP* end;					// Конец слова, устанавливается фортовским ';'
	BFCD_OP* CFA;					// указатель на указатель (косвеный шитый код)

	WordHeader(): MARK(WH_MARK), name(0), help(NULL), source(NULL), flags(0), forth(false), prev(NULL), voc(NULL), end(NULL), CFA(NULL) {}
};

/*
 * Словарь
 */
struct Vocabulary
{
	Vocabulary (TAbstractAllocator* _alloc, CONST_WCHAR_P _name);
	~Vocabulary();

	WordHeader* _add_word(CONST_WCHAR_P _name, BFCD_OP CFA, BfcdInteger _flags=0, bool is_forth=true);
	WordHeader* _add_binary_word(CONST_WCHAR_P _name, BFCD_OP CFA, BfcdInteger _flags=0);

	// CFA -> WordHeader
	static WordHeader* cfa2wh(BFCD_OP* CFA);

	typedef std::pair<int, WordHeader*> FindResult;
	// Поиск только в текущем словаре
	FindResult find_self(CONST_WCHAR_P _name); 
	FindResult find_self(WStringHash::UID _name); 
	// Поиск в цепочке словарей через this->prev
	FindResult find_all_chain(const WCHAR_P _name); 
	FindResult find_all_chain(WStringHash::UID _name); 
	// Проверяет наличие слова с нужным CFA в словаре.
	bool check_CFA(BFCD_OP cfa);
	// Имя слова по WordHeader
	const wchar_t* getName(WordHeader* wh) { return names->get(wh->name); }
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
 * OS environment
 */
exception (OSError, SimpleException);
exception (FileNameError, OSError);
exception (HomeDirError, OSError);

#define HOME_CONFIG_DIR ".bfcd"
class OSEnvironment
{
public:	
	OSEnvironment();
	~OSEnvironment();

	// Получить полное имя файла в конфигурационном каталоге
	// free() must be called on returned value
	char* full_config_path(CONST_WCHAR_P _name,CONST_WCHAR_P suffix=NULL);
	// Проверка на существование регулярного файла с правами RW для текущего процесса
	bool rw_file_exists(const char* fname);
	// Проверяем наличие '~/.bfcd/' 
	void check_home_config_dir();
//---
protected:
	char *home;

	// Получаем данные из переменных среды
	void load_envs();
};

/*
 * Общие данные для всех потоков
 */
struct TSharedData
{
	pthread_mutex_t readline_mutex;
	OSEnvironment* os;

	TSharedData(OSEnvironment* _os);
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
exception (ThreadLocked, VMDataError);

// Уровни трасировки
enum TRACE_LEVELS
{
	NO_TRACE=0,
	TRACE_EXEC,
	TRACE_STACK,
	TRACE_RSTACK,
	TRACE_IN_C_WORDS, 	// Отладочная печать внутри С-шных слов отличных от INTERPRET, EXECUTE, (EXEC)
	TRACE_STACK_IN_EXEC,
	TRACE_RSTACK_IN_EXEC
};
#define TIB_PAD 16
// libedit prompt function
char* libedit_prompt(EditLine*);

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

	// libedit initialization
	void libedit_init();

	void apush(BfcdInteger a) {AS->push(a);}
	void apushp(void* p) {AS->push((BfcdInteger)p);}
	BfcdInteger apop() {return AS->pop();}
	BfcdInteger atop() {return AS->_top();}
	BFCD_OP rpop() {return (BFCD_OP)RS->pop();}
	void rpush(BFCD_OP p) {RS->push((CELL)p);}
	BFCD_OP rtop() {return (BFCD_OP)RS->_top();}

	// Поиск слова в локальном стэке словарей.
	void find_word_to_astack(CONST_WCHAR_P _name);
	// Имя слова по его WordHeader, т.к. в WH хранится String UID а не полное имя
	const wchar_t* readableName(WordHeader* wh);
	// CELL с вершины арифметического стека перемещаем на вершину кода,
	// по сути это и есть фортовская ','
	bool astack_top2code();
	// CFA с вершины арифметического стека -> на вершину кода, фортовское 'CODE,'
	// на самом деле ',' и 'CODE,' не отличаются 
	// просто в 'CODE,' есть дополнительные проверки
	bool astack_top_cfa2code();
	// Компилируем слово по имени
	bool compile_call(CONST_WCHAR_P _name);

	// Проверяет что адрес исполнения есть в словарях (во избежание SIGSEGV)
	// требует постоянной доработки
	bool is_valid_for_execute(void* fn);
	// Проверяет что указатель находится в пределах пула
	bool is_pointer_valid(void* p);
	// Резервирует память в области кода
	bool allot(BfcdInteger size);
	// Обработчик \\ последовательностей в строках
	wchar_t* process_str(wchar_t* s);

	// Создание слова
	bool create_word(wchar_t* _name);

	// Создание нового потока исполнения занимающего всю оставшуюся памать,
	// используется для защиты от сбоев.
	// После создания текщий поток приостанавливается, выставляется флаг 'locked'
	// и управление передаётся порождённому потоку.
	// При сбое просто удаляется порождённый поток, и текущий продолжает своё выполнение.
	VMThreadData* fullCloneToSubpool(CONST_WCHAR_P _subname);

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
	BfcdInteger _trace;			// Уровень трассировки
	BfcdInteger* here() {return (BfcdInteger*)allocator->_code_head();}			// HERE - вершина компиляции

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
	// libedit  
	EditLine *editLine; 
	History *elHistory;
	HistEvent el_hist_event;
	BfcdInteger el_history_size;
	// iconv
	iconv_t iconv_in;
	iconv_t iconv_out;
	// База счисления слов при вводе/выводе
	BfcdInteger digit_base;

	// Список _всех_ словарей - общий для всех потоков.
	VocabularyStack* vocs;
	// Локальный для потока порядок поиска в словарях. 
	VocabularyStack* local_vocs_order;
	// Слово определённое последним в словаре
	WordHeader* last;

	// Блокировка выделения памяти в текущем потоке,
	// включается при создании нового потока занимающего всю оставшуюся свободную память.
	#define LOCKED if(locked) throw ThreadLocked() 
	bool locked;
};

#define defword(NAME) bool f_##NAME(VMThreadData *data)

class VMThread
{

protected:
	MemoryManager* allocator;
};

/*
 * Forth low level words
 * Здесь только самый минимум необходимый для того, чтобы как-то походить на Forth
 *
 * Большими БУКВАМИ - слова _низкого_ уровня, или работа с входным потоком 
 *
 */
// Используется вместо 'return false' внутри бинарных слов
#define FAILED(__errno__) {data->_errno=__errno__; return false; }
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
defword(exec);		// (EXEC)
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
defword(ccoma);		// CODE,
defword(str2here);	// S>H
defword(malloc);	// malloc - В байтах ! Не в CELL's. 
					// Освобождение памяти на совести GC аллокатора
defword(base);		// BASE
defword(number);	// NUMBER 
defword(lit);		// LIT - кладём на стек число лежащее сразу за собой в коде
defword(literal);	// LITERAL
defword(print_stack);		// .STACK
defword(print_rstack);		// .RSTACK
defword(step);		// STEP - один шаг интерпретатора					
defword(interpret);	// INTERPRET

//********************************************************** Мелочи для тестирования
defword(print);		// .
defword(cr);		// cr
defword(plus);		// +

//********************************************************** Создание слов
defword(create_from_str);		// >CREATE
defword(create);				// CREATE - не использовать (!) без DOES> 
defword(char_to_locale);		// C>LOCALE ( wchar_t -- local_char_as_bytes length_in_bytes )
									// байты упакованы прямо внутри значения на стеке,
									// благо sizeof(BfcdInteger) должно хватать даже для упаковки UTF-8 символа
defword(emit);					// emit 
defword(state_execute);			// ]
defword(state_compile);			// [
defword(exit);					// EXIT
defword(dcolon);				// :
defword(word_end_def);			// ;
defword(decompile);				// DECOMPILE ( CFA -- )
defword(trace);					// TRACE

//********************************************************** DOES>
defword(mark);					// MARK> - резервирует место для адреса вперёд, адрес места - на стек
defword(resolve);				// RESOLVE> - снимает адрес зарезервированного места со стека, и записывает туда текущий HERE
defword(branch);				// BRANCH
defword(nop);					// NOP
defword(does_code);				// (DOES>)
defword(does2);					// (DOES)
defword(does);					// DOES>			
defword(apostroph);				// '

#endif //FORTH_H


