#include "forth.h"
#include <stdio.h>
#include <readline/readline.h>
#include <readline/history.h>

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
Vocabulary::Vocabulary (TAbstractAllocator* _alloc, const char *_name):
	allocator(_alloc)
{
	names=XNEW(allocator,StringHash) (allocator);
	name=names->insert(_name);
	stl_allocator = XNEW(allocator,WordsMapAllocator) (allocator);
	words=XNEW(allocator,WordsMap)(0, *stl_allocator);
	pthread_mutex_init(&mutex, NULL); 
}

Vocabulary::~Vocabulary()
{
	names->~StringHash();
	allocator->free(names);
	words->~WordsMap();
	allocator->free(words);
	pthread_mutex_destroy(&mutex);
}

WordHeader*	Vocabulary::add_word(const char* _name, BFCD_OP CFA)
{
	pthread_mutex_lock(&mutex);
	WordHeader *wh = XNEW(allocator,WordHeader)();
	wh->name = names->insert(_name);
	__CODE(printf("Vocabulary::add_word %p %x\n",wh, wh->name));
	wh->voc = this;
	wh->prev = last;
	last = wh;
	wh->CFA = CFA;
	//words->push(wh);
	__CODE(printf("\\ insert '%s' in Vocabulary::words\n", names->get(wh->name)));
	(*words)[wh->name] = wh; // Вариант: words->insert(std::make_pair(wh->name,wh));
	pthread_mutex_unlock(&mutex);
	return wh;
}

Vocabulary::FindResult Vocabulary::find_self(const char* _name)
{
	auto uid = names->find(_name);
	if(!uid)
		return FindResult(0,NULL);
	else
	{
		return find_self(uid);
	}
}

Vocabulary::FindResult Vocabulary::find_self(StringHash::UID _name)
{
	auto res = words->find(_name);
	if(res != words->end())
		return FindResult(res->second->flags==WordHeader::IMMEDIATE?-1:1, res->second);
	else
		return FindResult(0,NULL);
}

// Я тупой и не знаю как это оформить шаблоном не создавая шаблонный класс
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
find_all_chain_T(const char*);
find_all_chain_T(StringHash::UID);

bool Vocabulary::check_CFA(BFCD_OP cfa)
{
	Vocabulary* curr = this;
	while(curr)
	{
		WordHeader* wh = curr->last;
		while(wh)
		{
			if(wh->CFA == cfa) return true;
			wh = wh->prev;
		}
		curr = curr->prev;
	}
	return false;
}
/*
 * VMThreadData
 */
VMThreadData::VMThreadData(TAbstractAllocator* _allocator, VocabularyStack *_vocs,
				 CELL _code, CELL start_IP,
				 TAbstractAllocator* _main_VM_allocator,
				 const char* _SYSTEM_ENCODING,
				 BfcdInteger _tib_size,
				 bool _use_tty,
				 int _STDIN,
				 int _STDOUT,
				 int _STDERR):
	allocator(_allocator),
	main_VM_allocator(_main_VM_allocator),
	vocs(_vocs),
	local_vocs_order(_vocs),
	code(_code),
	IP(start_IP),
	vm_state(VM_EXECUTE),
	SYSTEM_ENCODING(_SYSTEM_ENCODING),
	use_tty(_use_tty),
	STDIN(_STDIN), STDOUT(_STDOUT), STDERR(_STDERR),
	TIB_SIZE(_tib_size),
	tib_index(0),
	tib_length(0)
{
	AS=XNEW(allocator,AStack) (allocator);
	RS=XNEW(allocator,RStack) (allocator);
	tib=(char*)allocator->malloc(TIB_SIZE+16);
	iconv_in = iconv_open("WCHAR_T", SYSTEM_ENCODING);
	iconv_out = iconv_open(SYSTEM_ENCODING, "WCHAR_T");
	if (iconv_in == (iconv_t)-1 || iconv_out == (iconv_t)-1) throw IconvInitError();
}

VMThreadData::~VMThreadData()
{
	iconv_close(iconv_in);
	iconv_close(iconv_out);
	AS->~AStack();
	allocator->free(AS);
	RS->~RStack();
	allocator->free(RS);
	allocator->free(tib);
}

// Проверяет что адрес исполнения есть в словарях (во избежание SIGSEGV)
// требует постоянной доработки
bool VMThreadData::is_valid_for_execute(void* fn)
{
#ifdef __DEBUG__
	for(int i=1; i<=vocs->_size(); i++)
		if(vocs->nth(i)->check_CFA((BFCD_OP)fn)) return true;
	for(int i=1; i<=local_vocs_order->_size(); i++)
		if(local_vocs_order->nth(i)->check_CFA((BFCD_OP)fn)) return true;
	return false;
#endif
	return true;
}

void VMThreadData::find_word_to_astack(const char* _name)
{
	Vocabulary::FindResult res;
	for(int i=1; i++; i<=local_vocs_order->_size())
	{
		res = local_vocs_order->nth(i)->find_self(_name);
		if(res.first) break;
	}
	apush(res.first?(BfcdInteger)res.second->CFA:(BfcdInteger)_name);
	apush(res.first);	
}
	
bool VMThreadData::is_pointer_valid(void* p)
{
	return main_VM_allocator->is_address_valid(p);
}
/*
 * Forth low level words
 */
//********************************************************** Базовые
//слова
// bl
defword(bl)
{
	data->apush(' ');
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
	if(!data->allocator->is_address_valid(p))
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
	if(!data->allocator->is_address_valid(p))
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

// EXECUTE
defword(execute)
{
	BFCD_OP fn=(BFCD_OP)data->apop();
	if(!data->is_valid_for_execute((void*)fn))
	{
		data->_errno=VM_SEGFAULT;
		return false;
	}
	return fn(data);
}


// FIND
defword(find)
{
	const char* _name = (const char*) data->apop();
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
	}
	else // Read from terminal (interactive mode)
	{
		char *s = readline(NULL);
		data->tib_length = (strlen(s)>data->TIB_SIZE-1) ? data->TIB_SIZE : strlen(s);
		strncpy (data->tib,s,data->tib_length);
		data->tib_index = 0;
		add_history(s);
		free(s);
	}
	// Заменяем все вайтспейсы и нули на пробел,
	// на всяк пож добавляем пробел в конец буфера
	if(data->tib_length)
	{
		int i=0;
		for (;i<=data->tib_length; i++)
			if (isspace(data->tib[i] || !data->tib[i])) data->tib[i]=' ';
		data->tib[data->tib_length+1]=' ';
		data->tib[data->tib_length+2]='\0';
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
	size_t res = iconv(data->iconv_in,NULL,NULL,NULL,NULL);
	if(data->tib_index>=data->tib_length)
	{
		data->tib_index = 0;
		if(!f_read_tib(data))
		{
			data->apush(0);
			return false;
		}
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
	else if (res == -1) // Something BAD, errno other than EINVAL
	{
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


