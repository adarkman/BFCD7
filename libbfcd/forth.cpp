#include "forth.h"
#include <stdio.h>
#include <wctype.h>
#include <limits.h>

/*
 * VM Error Messages
 */
const char *VM_Errors[] = 
{
	"No error",				//VM_OK
	"Invalid address"		//VM_SEGFAULT
};

/*
 * Словарь
 */
Vocabulary::Vocabulary (TAbstractAllocator* _alloc, CONST_WCHAR_P _name):
	allocator(_alloc)
{
	names=XNEW(allocator,WStringHash) (allocator);
	name=names->insert(_name);
	stl_allocator = XNEW(allocator,WordsMapAllocator) (allocator);
	words=XNEW(allocator,WordsMap)(0, *stl_allocator);
	pthread_mutex_init(&mutex, NULL); 
}

Vocabulary::~Vocabulary()
{
	names->~WStringHash();
	allocator->free(names);
	words->~WordsMap();
	allocator->free(words);
	pthread_mutex_destroy(&mutex);
}

WordHeader*	Vocabulary::_add_word(CONST_WCHAR_P _name, BFCD_OP CFA, BfcdInteger _flags, bool is_forth) 
{
	pthread_mutex_lock(&mutex);
	// WordHeader аллоцируется прямо в коде - так проще доступаться к нему имея CFA,
	// т.к. CFA получается сразу после WordHeader, как раз WordHeader::CFA на него и ссылается
	// (косвенный шитый код)
	WordHeader *wh = new(allocator->code_alloc(sizeof(WordHeader))) WordHeader();
	wh->name = names->insert(_name); //UID
	//__CODE(printf("Vocabulary::add_word %p %x\n",wh, wh->name));
	wh->voc = this;
	wh->prev = last;
	last = wh; // Последнее определённое слово
	wh->CFA = (BFCD_OP*)allocator->_code_head(); // Для форт-слов CFA указывает на область сразу за WordHeader
	wh->flags = _flags;
	wh->forth = is_forth; // Форт-слова и бинарные слова исполняются по разному, см. связку EXECUTE<->(EXEC)
	if(!wh->forth) // Binary word
	{
		wh->CFA=(BFCD_OP*)allocator->code_alloc(sizeof(BFCD_OP));
		*wh->CFA=CFA;
	}
	//
	__CODE(printf("\\ insert '%ls' in Vocabulary::words\n", names->get(wh->name)));
	// WordHeader в словарь
	(*words)[wh->name] = wh; // Вариант: words->insert(std::make_pair(wh->name,wh));
	//
	pthread_mutex_unlock(&mutex);
	return wh;
}

WordHeader* Vocabulary::cfa2wh(BFCD_OP* CFA)
{
	char *p=(char*)CFA;
	WordHeader* wh = (WordHeader*) (p-sizeof(WordHeader)); // Минус, не ->
	return wh->MARK==WH_MARK?wh:NULL; // Проверяем что смотрим на корректный WordHeader
}

WordHeader*	Vocabulary::_add_binary_word(CONST_WCHAR_P _name, BFCD_OP CFA, BfcdInteger _flags)
{
	return _add_word(_name, CFA, _flags, false);
}

Vocabulary::FindResult Vocabulary::find_self(CONST_WCHAR_P _name)
{
	auto uid = names->find(_name);
	if(!uid)
		return FindResult(0,NULL);
	else
	{
		return find_self(uid);
	}
}

Vocabulary::FindResult Vocabulary::find_self(WStringHash::UID _name)
{
	auto res = words->find(_name);
	if(res != words->end())
		return FindResult(res->second->flags==WordHeader::IMMEDIATE?-1:1, res->second);
	else
		return FindResult(0,NULL);
}

// Я тупой и не знаю как это оформить шаблоном не создавая отдельный шаблонный класс
#define find_all_chain_T(TYPE) \
Vocabulary::FindResult Vocabulary::find_all_chain(TYPE _name) \
{ \
	auto curr = this->prev; \
	auto res = curr->find_self(_name); \
	while (!res.first) \
	{ \
		res = curr->find_self(_name); \
		if(!(curr = curr->prev)) break; \
	} \
	return res; \
}
find_all_chain_T(const WCHAR_P);
find_all_chain_T(WStringHash::UID);

bool Vocabulary::check_CFA(BFCD_OP cfa)
{
	Vocabulary* curr = this;
	while(curr)
	{
		WordHeader* wh = curr->last;
		while(wh)
		{
			if(*wh->CFA == cfa) return true;
			wh = wh->prev;
		}
		curr = curr->prev;
	}
	return false;
}

/*
 * OS environment
 */
OSEnvironment::OSEnvironment()
{
	home = (char*)malloc(PATH_MAX);
	load_envs();
}

OSEnvironment::~OSEnvironment()
{
	free(home);
}

void OSEnvironment::load_envs()
{
	char *env = getenv("HOME");
	if(!home) throw OSError();
	if(snprintf(home,PATH_MAX,"%s/.bfcd",env)>=PATH_MAX) throw FileNameError();
}

char* OSEnvironment::full_config_path(CONST_WCHAR_P _name,CONST_WCHAR_P suffix)
{
	char *path=(char*)malloc(PATH_MAX);
	if(!path) throw OSError();
	if(snprintf(path,PATH_MAX,"%s/%ls%ls",home,_name,(suffix?suffix:L""))>=PATH_MAX) 
	{
		free(path);
		throw FileNameError();
	}
	return path;
}

/*
 * Общие данные для всех потоков
 */
TSharedData::TSharedData(OSEnvironment* _os): os(_os)
{
	pthread_mutex_init(&readline_mutex,NULL);
}

TSharedData::~TSharedData()
{
	pthread_mutex_destroy(&readline_mutex);
}

// libedit prompt function
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wwrite-strings"
char* libedit_prompt(EditLine*)
{
	return "";
}
#pragma GCC diagnostic pop

/*
 * VMThreadData
 */
VMThreadData::VMThreadData(CONST_WCHAR_P _name, TSharedData *_shared,
				 TAbstractAllocator* _allocator, VocabularyStack *_vocs,
				 CELL _code, CELL start_IP, CELL _here,
				 TAbstractAllocator* _main_VM_allocator,
				 const char* _SYSTEM_ENCODING,
				 BfcdInteger _tib_size,
				 bool _use_tty,
				 BfcdInteger __trace,
				 int _STDIN,
				 int _STDOUT,
				 int _STDERR):
	name(_name),
	shared(_shared),
	allocator(_allocator),
	main_VM_allocator(_main_VM_allocator),
	vocs(_vocs),
	local_vocs_order(_vocs),
	code(_code),
	IP((BFCD_OP)start_IP),
	vm_state(VM_EXECUTE),
	SYSTEM_ENCODING(_SYSTEM_ENCODING),
	use_tty(_use_tty),
	_trace(__trace),
	STDIN(_STDIN), STDOUT(_STDOUT), STDERR(_STDERR),
	TIB_SIZE(_tib_size),
	tib_index(0),
	tib_length(0),
	digit_base(10),
	last(NULL)
{
	AS=XNEW(allocator,AStack) (allocator);
	RS=XNEW(allocator,RStack) (allocator);
	tib=(char*)allocator->malloc(TIB_SIZE+TIB_PAD);
	word_buffer=(wchar_t*)allocator->malloc(sizeof(wchar_t)*(TIB_SIZE+TIB_PAD));
	// iconv
	iconv_in = iconv_open("WCHAR_T", SYSTEM_ENCODING);
	iconv_out = iconv_open(SYSTEM_ENCODING, "WCHAR_T");
	if (iconv_in == (iconv_t)-1 || iconv_out == (iconv_t)-1) throw IconvInitError();
	// libedit
	editLine = el_init("bfcd7", stdin, stdout, stderr);
	el_set(editLine, EL_PROMPT, libedit_prompt);
  	el_set(editLine, EL_EDITOR, "emacs");
	elHistory = history_init();
	el_history_size = 10000;
	history(elHistory, &el_hist_event, H_SETSIZE, el_history_size);
	el_set(editLine, EL_HIST, history, elHistory);
}

VMThreadData::~VMThreadData()
{
	history_end(elHistory);
	el_end(editLine);
	iconv_close(iconv_in);
	iconv_close(iconv_out);
	AS->~AStack();
	allocator->free(AS);
	RS->~RStack();
	allocator->free(RS);
	allocator->free(tib);
	allocator->free(word_buffer);
}

// Проверяет что адрес исполнения есть в словарях (во избежание SIGSEGV)
// требует постоянной доработки
// TODO: на текущий момент - сломан
bool VMThreadData::is_valid_for_execute(void* fn)
{
#ifdef __DEBUG__
/*	for(int i=1; i<=vocs->_size(); i++)
		if(vocs->nth(i)->check_CFA((BFCD_OP)fn)) return true;
	for(int i=1; i<=local_vocs_order->_size(); i++)
		if(local_vocs_order->nth(i)->check_CFA((BFCD_OP)fn)) return true;
	return false;*/
#endif
	return true;
}

const wchar_t* VMThreadData::readableName(WordHeader* wh)
{
	if(!wh) return NULL;
	return wh->voc->getName(wh);
}

void VMThreadData::find_word_to_astack(CONST_WCHAR_P _name)
{
	Vocabulary::FindResult res;
	for(int i=1; i<=local_vocs_order->_size(); i++)
	{
		res = local_vocs_order->nth(i)->find_self(_name);
		if(res.first) break;
	}
	apush(res.first?(BfcdInteger)res.second->CFA:(BfcdInteger)_name);
	apush(res.first);	
}

bool VMThreadData::astack_top2code()
{
	BfcdInteger* p=here();
	if(!allot(sizeof(CELL))) // 1 ALLOT
		return false;
	*p=apop();
	if(_trace>=TRACE_IN_C_WORDS)
		printf("\t\t\t\t\\ top2code PTR: %p HERE: %p VALUE: %p\n", p, here(), *p);
	return true;
}

bool VMThreadData::astack_top_cfa2code()
{
	BFCD_OP cfa=(BFCD_OP)apop();
	if(!is_valid_for_execute((CELL)cfa)) return false;
	apushp((CELL)cfa);
	return astack_top2code();
}


bool VMThreadData::compile_call(CONST_WCHAR_P _name)
{
	find_word_to_astack(_name);
	if(!apop()) // Не нашли, чё за хня ?
		return false;
	if(!astack_top_cfa2code()) return false; // CFA уже на стеке
	return true;
}

bool VMThreadData::is_pointer_valid(void* p)
{
	return main_VM_allocator->is_address_valid(p);
}

bool VMThreadData::allot(BfcdInteger size)
{
	if(size<0) return false;
	try
	{
		allocator->code_alloc(size);
	}
	catch (VMOutOfMemory &ex)
	{
		return false;
	}
	return true;
}

wchar_t* VMThreadData::process_str(wchar_t* s)
{
	wchar_t* so=allocator->wstrdup(s);
	wchar_t* res = so;
	while(*s)
	{
		if(*s==L'\\')
		{
			wchar_t c;
			switch(*(++s))
			{
				case 't': c=L'\t'; break;
				case 'n': c=L'\n'; break;
				case '\\': c=L'\\'; break;
				default: break;		  
			}
			*so++=c;
		}
		else
			*so++=*s++;
	}
	*so=L'\0';
	return res;
}

bool VMThreadData::create_word(wchar_t* _name)
{
	//BFCD_OP cfa=(BFCD_OP)here;
	WordHeader *wh=local_vocs_order->_top()->_add_word(_name,NULL);
	if(_trace>=TRACE_EXEC)
		printf("\t\t\t\t\\ CREATE: WH %p CFA %p %p\n", wh, wh->CFA, *wh->CFA);
	//wh->CFA=cfa;
	last = wh;
	return true;
}
/*
 * Forth low level words
 */
//********************************************************** Базовые
//слова
// bl
defword(bl)
{
	data->apush(L' '); // wchar_t !
	return true;
}

// ?dup
defword(ifdup)
{
	BfcdInteger i=data->atop();
	if(i) data->apush(i);
	return true;
}

// 1+
defword(inc)
{
	data->apush(data->apop()+1);
	return true;
}

// 1-
defword(dec)
{
	data->apush(data->apop()-1);
	return true;
}

// STATE
defword(state)
{
	data->apush(data->vm_state);
	return true;
}

// @
defword(get)
{
	BfcdInteger* p = (BfcdInteger*) data->apop();
	if(!data->is_pointer_valid(p))
	{
		data->_errno=VM_SEGFAULT;
		return false;
	}
	data->apush(*p);
	return true;
}

// !
defword(put)
{
	BfcdInteger* p = (BfcdInteger*) data->apop();
	if(!data->is_pointer_valid(p))
	{
		data->_errno=VM_SEGFAULT;
		return false;
	}
	*p = data->apop();
	return true;
}

// BYE
defword(bye)
{
	data->_errno=VM_TERMINATE_THREAD;
	return false;
}

// (EXEC)
defword(exec)
{
	// Старт исполнения Форт-слова
	while(true)
	{
		BFCD_OP* fn=(BFCD_OP*)data->IP; // CFA форт слова, IP устанавливатся в EXECUTE
		if(data->_trace>=TRACE_EXEC)
			printf("\t\t\t\t*F* %p %p\n", fn, *fn);
		// Косвенный шитый код, получаем BFCD_OP через **fn; 
		BFCD_OP* op=(BFCD_OP*)*fn;
		if(!op) return false; // Указатель куда-то в неаллоцированную область
		if(*op==f_exit) 
		{
			if(data->_trace>=TRACE_EXEC)
				printf("\t\t\t\t*F* EXIT at %p\n", op);
			break; // EXIT, прерываем цикл, 
								// поскольку rpush не делается, получается завуалированный rpop
		}
		//
		data->apushp((void*)*fn);
		if(!f_execute(data)) return false; // Да, взаимная рекурсия с EXECUTE
	}
	return true;
}

// EXECUTE ( CFA - )
defword(execute)
{
	BFCD_OP* fn=(BFCD_OP*)data->apop(); // *CFA
	if(data->_trace>=TRACE_EXEC) 
		printf("\t\t\t\t*** %p %p\n", fn, *fn);
#ifdef __DEBUG__	
	if(!data->is_valid_for_execute((void*)*fn))
	{
		data->_errno=VM_SEGFAULT;
		return false;
	}
#endif	
	if(!data->is_pointer_valid((void*)fn)) // *CFA _должен_ быть в пределах ПУЛА
		return false;
	if(!*fn) return false; // *СFA смотрит в неаллоцированную область
	if(data->_trace>=TRACE_EXEC)
	{
		WordHeader *wh = Vocabulary::cfa2wh(fn);
		if(wh)
			printf("\t\t\t\t*** %ls\n", data->readableName(wh));			
	}
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpointer-arith"
	// ВНИМАТЕЛЬНО с адресной арифметикой, не везде очевидные смещения !
	data->rpush(data->IP+sizeof(BFCD_OP)); // На стеке возврата адрес следующего слова
	WordHeader* wh=Vocabulary::cfa2wh(fn);
	if(!wh) // Не найден WH_MARK -> CFA липовый, во избежание SIGSEGV
		return false;
	data->IP = (BFCD_OP)fn; // В случае форт-слова IP:=CFA
	// .STACK
	if(data->_trace>=TRACE_STACK_IN_EXEC) f_print_stack(data);
	if(data->_trace>=TRACE_RSTACK_IN_EXEC) f_print_rstack(data);
	//
	bool res = wh->forth ? f_exec(data) /*Форт слово*/: (*fn)(data)/*Сишная функция*/;
	// .STACK
	if(data->_trace>=TRACE_STACK_IN_EXEC) f_print_stack(data);
	if(data->_trace>=TRACE_RSTACK_IN_EXEC) f_print_rstack(data);
	//
	data->IP = data->rpop(); // Просто использовать 'data->IP++' нельзя -
							 // слово может модифицировать стек возврата,
							 // что и делают слова типа LIT или ?BRANCH
#pragma GCC diagnostic pop
	return res;
}

// FIND
defword(find)
{
	const WCHAR_P _name = (const WCHAR_P) data->apop();
	if(data->is_pointer_valid((void*)_name))
	{
		data->find_word_to_astack(_name);
		return true;
	}
	else
		return false;
}

// read>tib
defword(read_tib)
{
	if(data->tib_length > data->TIB_SIZE) // Something WRONG
		return false;
	if(!data->use_tty)
	{
		data->tib_length = read(data->STDIN,&(data->tib[data->tib_length]),data->TIB_SIZE-data->tib_length);
		if(!data->tib_length) // EOF
			return false;
	}
	else // Read from terminal (interactive mode)
	{
		char prompt[256];
		snprintf(prompt,255,"%ls%s> ", data->name, data->vm_state==VM_COMPILE?"(COMPILE)":"");
		pthread_mutex_lock(&data->shared->readline_mutex);
		int count;
		printf("%s", prompt);
		//char *s = readline(prompt);
		char *s = (char*)el_gets(data->editLine,&count);
		if(s && count>0) //add_history(s);
			history(data->elHistory, &data->el_hist_event, H_ENTER, s);
		pthread_mutex_unlock(&data->shared->readline_mutex);
		data->tib_length = (strlen(s)>data->TIB_SIZE-1) ? data->TIB_SIZE : strlen(s);
		strncpy (data->tib,s,data->tib_length);
		data->tib_index = 0;
		//free(s); - commented out in libedit - internal buffer returns in el_gets
	}
	// Заменяем все вайтспейсы и нули на пробел,
	// на всяк пож добавляем пробел в конец буфера
	if(data->tib_length)
	{
		int i=0;
		for (;i<=data->tib_length; i++)
			if (isspace(data->tib[i]) || !data->tib[i]) data->tib[i]=' ';
		data->tib[data->tib_length++]=' ';
		data->tib[data->tib_length]='\0';
	}
	return true;
}

// TIB 
defword(tib) { data->apush((BfcdInteger)data->tib); return true; }
// >IN
defword(tib_index) { data->apush(data->tib_index); return true; }
// #TIB
defword(tib_length) { data->apush(data->tib_length); return true; }
// (KEY)
defword(key_internal)
{
	char outbuf[SIZEOF_WCHAR_T];
	char *outbuf_p = outbuf;
	size_t outbytes=SIZEOF_WCHAR_T;
	char* inbuf = &(data->tib[data->tib_index]);
	size_t inbytesleft = data->tib_length - data->tib_index;
	// Инициализация цикла iconv, т.к. конвертируем только один символ
	// инициализуруем при каждом вызове - в конце функции цикл iconv уже завершён
	size_t res = iconv(data->iconv_in,NULL,NULL,NULL,NULL); 	
	if(data->tib_index>=data->tib_length) // TIB вычитан - перезаполняем
	{
		data->tib_index = 0;
		if(!f_read_tib(data))
		{
			data->apush(0);
			return false;
		}
		// Перечитали буфер - перерасчитываем входные данные для iconv
		inbuf = &(data->tib[data->tib_index]);
		inbytesleft = data->tib_length - data->tib_index;
	}
	res = iconv (data->iconv_in, &inbuf, &inbytesleft, &outbuf_p, &outbytes);
	if (res == -1 && errno == EINVAL) // Incomplete multibyte sequence
	{
		size_t converted_size = data->tib - inbuf;
		memmove(data->tib, &data->tib[converted_size], data->tib_length-converted_size);
		data->tib_index = 0;
		data->tib_length-=converted_size;
		f_read_tib(data);
		data->apush(-1);
		return false;
	}
	else if (res == -1 && errno == E2BIG); // Всё нормально, мы обрабатываем только один символ
										 	// остаток в TIB и вызывает E2BIG 
	else if (res == -1) // Something BAD, errno other than EINVAL || E2BIG
	{
		if(data->_trace>=TRACE_IN_C_WORDS) printf("\t\t\t\tf_key_internal: %s\n", strerror(errno));
		data->apush(0);
		return false;
	}
	// All OK, converted from Local Encoding
	data->tib_index = data->tib_length-inbytesleft;
	BfcdInteger i;
	memmove(&i,outbuf,SIZEOF_WCHAR_T);
	data->apush(i);
	return true;
}
// KEY
defword(key)
{
	bool res = f_key_internal(data);
	if (!res) // Convertion failed
	{
		BfcdInteger errcode = data->apop();
		if(errcode == -1) // Incomplete multibyte sequence, TIB renewed, recall convertion
		{
			if(!f_key_internal(data)) // Something BAD, convetion failed, errcode already on stack
				return false;
		}
		else // bad errcode
		{
			data->apush(0);
			return false;
		}
	}
	// Convertion success, wchar_t on stack
	return true;
}

// EOF
defword(eof)
{
	return f_bye(data);
}

//WORD
defword(word)
{
	BfcdInteger wbuf_index=0;
	wmemset(data->word_buffer, 0, data->TIB_SIZE+TIB_PAD);
	wchar_t delim = (wchar_t)data->apop(); // Разделитель
	bool start = true;
	wchar_t wc;
	while (f_key(data))
	{
		wc = data->apop();
		if (start) // Сбрасываем стартовые разделители
		{
			if(delim == L' ' && iswspace(wc)) continue;
			if(wc == delim) continue;
			start = false; // Стартовые разделители сброшены
		}
		// Забиваем word_buffer пока не встретили разделитель
		if(wc == delim) // Сразу после предыдущего if разделителя здесь быть не может, 
						// значит в буфере уже что-то есть, получается мы выделили слово
		{
			data->apushp(data->word_buffer);
			return true;
		}
		if(wbuf_index>data->TIB_SIZE) // Кто-то охуел
		{
			data->apushp(data->word_buffer);
			return true;
		}
		data->word_buffer[wbuf_index++] = wc;
	}
	// Error in KEY
	data->apop(); // Сбрасываем код возврата KEY
	if(!data->tib_length) // EOF in read>tib
	{
		if(!wbuf_index) // Мы ничего прочитать не смогли - буфер пуст
		{
			wcscpy(data->word_buffer,L"BYE"); 
			wbuf_index = 3;
		}	
	}
	if(wbuf_index) // что-то таки в буфере есть
	{
		data->apushp(data->word_buffer);
		return true;
	}
	// Дошли до сюда, значит какая-то ЖОПА
	data->apushp(data->word_buffer); // пофиг что пустой, может пригодиться
	return false;
}

// allot
defword(allot)
{
	BfcdInteger count = data->apop();
	if(data->allot(sizeof(CELL)*count))
		return true;
	else
		return false;
}

// ,
defword(coma)
{
	return data->astack_top2code();
}

// CODE,
defword(ccoma)
{
	return data->astack_top_cfa2code();
}

// S>H
defword(str2here)
{
	wchar_t* s=(wchar_t*)data->apop();
	if(!data->is_pointer_valid(s)) return false;
	s=data->process_str(s); 	// Обработка \\, выделенная память остаётся на совести GC аллокатора
	BfcdInteger size_in_bytes=wcslen(s)*sizeof(wchar_t);
	// Выделение памяти в коде под строку
	CELL dst = data->here();
	data->apush(size_in_bytes/sizeof(CELL)+1);
	if(!f_allot(data)) return false;
	// Копирование строки в словарь
	bzero(dst,size_in_bytes+1);
	memcpy(dst,s,size_in_bytes);
	return true;
}

// malloc
defword(malloc)
{
	void *p = data->allocator->malloc(data->apop());
	if(!p) return false;
	data->apushp(p);
	return true;
}

// BASE
defword(base)
{
	data->apushp(&data->digit_base);
	return true;
}

// NUMBER
defword(number)
{
	wchar_t* end; // Указатель на нечало несконвертированного фрагмента
	data->number_word = (WCHAR_P)data->apop();
	BfcdInteger i;
	if(!wcsncmp(data->number_word,L"0x",2)) // Слово в 16-ричной системе. Игнорируем BASE
		i = wcstol(data->number_word+2, &end, 16);
	else
		i = wcstol(data->number_word, &end, data->digit_base);
	if(end[0]!=L'\0') // '!=', значит что не сконвертировалось (лишние/неправильные символы)
		return false;
	data->apush(i);
	return true;
}

// LIT
defword(lit)
{
	BfcdInteger* i=(BfcdInteger*)data->rpop(); // Адрес следующего за собой слова,
											  // см. EXECUTE
	if(data->_trace>=TRACE_IN_C_WORDS) printf("\t\t\t\t| LIT: %p %lx %ld\n", i,*i,*i);			  
	if(!data->is_pointer_valid(i)) return false;
	data->apush(*i);
	// На стек возврата кладётся адрес сразу за извлечённым числом,
	// EXECUTE занесёт в 'data->IP' уже новый адрес
	// учитываем что sizeof(BfcdInteger*) === sizeof(CELL) === sizeof(BFCD_OP)
	data->rpush((BFCD_OP)++i);
	return true;
}

// LITERAL
defword(literal)
{
	if(data->vm_state==VM_COMPILE)
	{
		if(!data->compile_call(L"LIT")) return false;
		if(!f_coma(data)) return false; // Собственно число, оно уже на стеке _перед_ вызовом LITERAL
	}
	// VM_EXECUTE - нихрена не делаем, просто оставляем число на стеке
	return true;
}

// .STACK
defword(print_stack)
{
	if(!data->AS->_size())
		puts("\t\t\t\t| stack empty.");
	for(int i=1; i<=data->AS->_size(); i++)
		printf("\t\t\t\t| S[%d]: %lx %ld\n", i, data->AS->nth(i), data->AS->nth(i));
	return true;
}

// .RSTACK
defword(print_rstack)
{
	if(!data->RS->_size())
		puts("\t\t\t\t| Rstack empty.");
	for(int i=1; i<=data->RS->_size(); i++)
		printf("\t\t\t\t| R[%d]: %lx %ld\n", i, data->RS->nth(i), data->RS->nth(i));
	return true;
}

// STEP
#define _do(__code) { if(!f_##__code(data)) return false; } 
defword(step)
{
	if(data->_trace>=TRACE_STACK) _do(print_stack);
	if(data->_trace>=TRACE_RSTACK) _do(print_rstack);
	// Считываем слово из входного потока
	_do(bl);
	_do(word);
	if(data->_trace>=TRACE_EXEC) printf("\t\t\t\t| WORD: %ls\n", (WCHAR_P)data->atop());
	// Ищем его в словаре
	_do(find);
	BfcdInteger flags = data->apop();
	if(flags) // Слово найдено
	{
		if(flags==WordHeader::IMMEDIATE)
			_do(execute) // CFA уже на стеке после FIND
		else
			switch (data->vm_state)
			{
				case VM_COMPILE: _do(ccoma); break;		// CFA заносится на вершину HERE,
								 						// по сути - компиляция
				case VM_EXECUTE: _do(execute); break;
				default: return false;					// Прозошла какая-то херня.
			}
	}	
	// Слово не нашли, пробуем парсить как число
	else
	{
		if(!f_number(data))
		{
			// Нераспарсилось
			// TODO: Добавить парсилку как Float/Double (в Форте для этих чисел отдельный стек)
			return false;
		}
		else
			_do(literal);
	}
	return true;
}
//#undef _do

// INTERPRET
defword(interpret)
{
	while(true)
	{
		if(data->_trace>=TRACE_EXEC)
			printf("\t\t\t\t| step - Thread: \"%ls\" IP: %p Head: %p\n", data->name, data->IP, data->here());
		try
		{
			if(!f_step(data)) 
			{
				switch(data->_errno)
				{
					case VM_TERMINATE_THREAD:
						if(data->_trace>=TRACE_EXEC) 
							printf("\t\t\t\t| Terminating thread \"%ls\".\n", data->name);
						return true;
					default:
						printf("\t\t\t\tThread \"%ls\" execution error.\n", data->name);
						if(data->_errno>0 && data->_errno<VM_ERROR_LAST)
							printf("\t\t\t\t%s\n", VM_Errors[data->_errno]);
						if(data->_trace>TRACE_STACK) f_print_stack(data);
						if(data->_trace>TRACE_RSTACK) f_print_rstack(data);
						return false;
				}
			}
		}
		catch (SimpleException &ex)
		{
			printf("\t\t\t\tError in thread \"%ls\": %s\n", data->name, ex());
			return false;
		}
	}
}

// .
defword(print)
{
	// TODO: может нужен wchar_t и конверт в локальную кодировку ?
	char s[256];
	lltoa(data->apop(), s, data->digit_base);
	write(data->STDOUT, s, strlen(s));
	return true;
}

// cr
defword(cr)
{
	write(data->STDOUT, "\n", 1);
	return true;
}

// +
defword(plus)
{
	data->apush(data->apop()+data->apop());
	return true;
}

// >CREATE
defword(create_from_str)
{
	wchar_t* name = (wchar_t*)data->apop();
	if(!data->is_pointer_valid(name)) return false;
	if(!data->create_word(name)) return false;
	//data->compile_call(L"(EXEC)");
	return true;
}

// CREATE
defword(create)
{
	_do(bl);
	_do(word);
	_do(create_from_str);
	data->compile_call(L"(DOES)");	// Помещает на стек адрес +3 CFA - там по сути будут данные
	data->compile_call(L"NOP");		// PAD для BRANCH <addr> - подставляется при исполнении (DOES>)	
	data->compile_call(L"NOP");	
	return true;
}

// C>LOCALE
defword(char_to_locale)
{
	char outbuf[sizeof(BfcdInteger)];
	char *outbuf_p = outbuf;
	size_t outbytesleft=sizeof(BfcdInteger);
	wchar_t inbuf = (wchar_t)data->apop();
	char* inbuf_p=(char*)&inbuf;
	size_t inbytesleft = SIZEOF_WCHAR_T;
	size_t res = iconv(data->iconv_out,NULL,NULL,NULL,NULL);
	res = iconv (data->iconv_out, &inbuf_p, &inbytesleft, &outbuf_p, &outbytesleft);
	if (res == -1) // Error in convertion
	{
		return false;
	}
	// All OK, converted to Local Encoding
	BfcdInteger i=0;
	BfcdInteger len=sizeof(BfcdInteger)-outbytesleft;
	memmove(&i,outbuf,len);
	//printf("%d %d\n", inbytesleft, len);
	data->apush(i);
	data->apush(len);
	return true;
}

// emit
defword(emit)
{
	_do(char_to_locale);
	BfcdInteger len = data->apop();
	BfcdInteger packed = data->apop();
	if(len>sizeof(packed)) // Вообще-то этого не должно случиться, так - перестраховка
		return false;
	write(data->STDOUT,&packed,len);
	return true;
}

// ]
defword(state_execute)
{
	data->vm_state=VM_EXECUTE;
	return true;
}
// ]
defword(state_compile)
{
	data->vm_state=VM_COMPILE;
	return true;
}
// EXIT
defword(exit)
{
	//data->rpop();  - Закоменчено - EXIT особым образом обрабатывается в (EXEC)
	return true;
}
// :
defword(dcolon)
{
	_do(bl);
	_do(word);
	_do(create_from_str);
	_do(state_compile);
	return true;
}
// ;
defword(word_end_def)
{
	if(data->last) data->last->end=(BFCD_OP*)data->here();
	if(!data->compile_call(L"EXIT")) return false;
	_do(state_execute);
	return true;
}

// DECOMPILE
defword(decompile)
{
	BFCD_OP* cfa = (BFCD_OP*)data->apop();
	if(!data->is_pointer_valid(cfa) || !Vocabulary::cfa2wh(cfa))
	{
		printf("DECOMPILE - invalid CFA: %p\n", cfa);
		return true;
	}
	WordHeader *wh = Vocabulary::cfa2wh(cfa);
	BFCD_OP* end=wh->end;
	if(!end)
	{
		printf("Warning: DECOMPILE - Word '%ls' end unspecified, reading from stack.\n", 
			   data->readableName(wh));
		end=(BFCD_OP*)cfa+data->apop();
	}
	printf("Decompiling '%ls':\n", data->readableName(wh));
	while(cfa<end)
	{
		wh=NULL;
		if (data->is_pointer_valid((void*)*cfa)) wh=Vocabulary::cfa2wh((BFCD_OP*)*cfa);
		if(!wh) printf("%p: %lx %ld\n", cfa, *cfa, *cfa);
		else
			printf("%p: %p %ls\n", cfa, *cfa, data->readableName(wh));
		cfa++;
	}
	return true;
}

// TRACE
defword(trace)
{
	data->apushp(&data->_trace);
	return true;
}

// <MARK
defword(mark)
{
	void *p=data->here();
	data->allot(sizeof(CELL));
	data->apushp(p);
	return true;
}

// RESOLVE
defword(resolve)
{
	BFCD_OP* p=(BFCD_OP*)data->apop();
	if(!data->is_pointer_valid((CELL)p)) return false;
	*p=(BFCD_OP)data->here();
	return true;
}

// BRANCH
defword(branch)
{
	BFCD_OP* p=(BFCD_OP*)data->rpop();
	if(!data->is_pointer_valid((CELL)p)) return false;
	if(!data->is_pointer_valid((CELL)*p)) return false;
	data->rpush(*p);
	return true;

}

// NOP
defword(nop)
{
	return true;
}

// (DOES>)
defword(does_code)
{
	// Адрес следующего слова
	BfcdInteger* i=(BfcdInteger*)data->RS->_top();
	if(data->_trace>=TRACE_IN_C_WORDS)
		printf("\t\t\t\t| (DOES>) RTOP: %p Last: %p LCFA: %p DOES2: %p\n", 
			   i, data->last, data->last->CFA, i+1);
	BfcdInteger* last_code=(BfcdInteger*)data->last->CFA;
	// Компилируем BRANCH <addr> сразу после (DOES) последнего определенного (data->last) слова
	// см. CREATE
	data->find_word_to_astack(L"BRANCH");
	if(!data->apop()) return false;
	*(last_code+1) = data->apop();
	*(last_code+2) = (BfcdInteger)(i+1);
	return true;
}

// (DOES)
defword(does2)
{
	// Адрес следующего слова
	BfcdInteger* i=(BfcdInteger*)data->RS->_top();
	if(data->_trace>=TRACE_IN_C_WORDS)
		printf("\t\t\t\t| (DOES) RTOP: %p\n", i);
	data->apushp(i+2); // Адрес данных на стек - см. CREATE
	return true;
}

// DOES>
defword(does)
{
	data->compile_call(L"(DOES>)");
	data->compile_call(L"EXIT");
	return true;
}

// '
defword(apostroph)
{
	_do(bl);
	_do(word);
	_do(find);
	if(!data->apop()) return false;
	return true;
}

