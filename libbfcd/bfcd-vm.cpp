#include "bfcd-vm.h"

BfcdVM::BfcdVM()
{
	allocator = new MemoryManager();
	main_voc = XNEW(allocator,Vocabulary)(allocator,"FORTH");
	vocs = XNEW(allocator,TStack<Vocabulary*>)(allocator);
	vocs->push(main_voc);
	create_base_vocabulary();
}

BfcdVM::~BfcdVM()
{
	main_voc->~Vocabulary();
	allocator->free(main_voc);
	vocs->~TStack<Vocabulary*>();
	allocator->free(vocs);
	delete allocator;
}

#define _(name,op) main_voc->add_word(name,f_##op)
void BfcdVM::create_base_vocabulary()
{
	_("bl",bl); 
	_("?dup",ifdup);
	_("1+",inc);
	_("1-",dec);
	_("STATE",state);
	_("@",get);	
	_("!",put);
	_("BYE",bye);
	_("EXECUTE",execute);
	_("FIND", find);
	_("read>tib", read_tib);
	_("TIB", tib);
	_(">IN",tib_index);
	_("#TIB",tib_length);
	_("(KEY)",key_internal);	
	_("KEY",key);
}
#undef _

