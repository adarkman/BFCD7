#include "bfcd-vm.h"

BfcdVM::BfcdVM()
{
	allocator = new MemoryManager();
	main_voc = XNEW(allocator,Vocabulary)(allocator,L"FORTH");
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
	_(L"BL",bl); 
	_(L"?dup",ifdup);
	_(L"1+",inc);
	_(L"1-",dec);
	_(L"STATE",state);
	_(L"@",get);	
	_(L"!",put);
	_(L"BYE",bye);
	_(L"EXECUTE",execute);
	_(L"FIND", find);
	_(L"read>tib", read_tib);
	_(L"TIB", tib);
	_(L">IN",tib_index);
	_(L"#TIB",tib_length);
	_(L"(KEY)",key_internal);	
	_(L"KEY",key);
	_(L"EOF",eof);
	_(L"WORD",word);
	_(L"ALLOT",allot);
	_(L",", coma);
	_(L"S>H", str2here);
	_(L"malloc", malloc);
	_(L"BASE", base);
	_(L"NUMBER", number);
	_(L"LIT", lit);
	_(L"LITERAL", literal);
	_(L"STEP", step);
}
#undef _

