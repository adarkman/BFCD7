#include "bfcd-vm.h"

BfcdVM::BfcdVM()
{
	allocator = new MemoryManager();
	main_voc = XNEW(allocator,Vocabulary)(allocator,L"FORTH");
	vocs = XNEW(allocator,TStack<Vocabulary*>)(allocator);
	vocs->push(main_voc);
	create_base_vocabulary();
	create_main_thread();	
}

BfcdVM::~BfcdVM()
{
	main_thread->~VMThreadData();
	allocator->free(main_thread);
	main_voc->~Vocabulary();
	allocator->free(main_voc);
	vocs->~TStack<Vocabulary*>();
	allocator->free(vocs);
	delete allocator;
}

void BfcdVM::run()
{
	main_thread_run();
}

void BfcdVM::create_main_thread()
{
	main_thread = XNEW(allocator,VMThreadData)(L"BFCD",
				 allocator, vocs,
				 allocator->_base(), // _code, 
				 allocator->_base(), // start_IP, 
				 allocator->_base(), // _here,
				 allocator, // _main_VM_allocator,
				 "UTF-8", // _SYSTEM_ENCODING,
				 KB(4), // _tib_size=KB(4)
				 true,  // _use_tty = false,
				 1, // __trace = 0,
				 STDIN_FILENO, // _STDIN = STDIN_FILENO,
				 STDOUT_FILENO, // _STDOUT = STDOUT_FILENO,
				 STDERR_FILENO); // _STDERR = STDERR_FILENO);
}

void BfcdVM::main_thread_run()
{
	main_thread->find_word_to_astack(L"INTERPRET");
	main_thread->apop(); // drop flags
	f_execute(main_thread);
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
	_(L".STACK", print_stack);
	_(L"STEP", step);
	_(L"INTERPRET", interpret);
	_(L".", print);
	_(L"cr", cr);
	_(L"+", plus);
}
#undef _

