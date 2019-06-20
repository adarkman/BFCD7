#include "forth.h"
#include <stdio.h>

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
}

Vocabulary::~Vocabulary()
{
	names->~StringHash();
	allocator->free(names);
	words->~WordsMap();
	allocator->free(words);
}

WordHeader*	Vocabulary::add_word(const char* _name, BFCD_OP CFA)
{
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
	return wh;
}
/*
 * VMThreadData
 */
VMThreadData::VMThreadData(TAbstractAllocator* _allocator, VocabularyStack *_vocs,
				 CELL _code, CELL start_IP,
				 BfcdInteger _tib_size):
	allocator(_allocator),
	vocs(_vocs),
	code(_code),
	IP(start_IP),
	vm_state(VM_EXECUTE),
	STDIN(STDIN_FILENO),
	STDOUT(STDOUT_FILENO),
	STDERR(STDERR_FILENO),
	TIB_SIZE(_tib_size),
	tib_index(0),
	tib_length(0)
{
	AS=XNEW(allocator,AStack) (allocator);
	RS=XNEW(allocator,RStack) (allocator);
	tib=(char*)allocator->malloc(TIB_SIZE);
}

VMThreadData::~VMThreadData()
{
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

