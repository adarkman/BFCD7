/* MemoryManager.h - Types for Pool allocate based memory manager with GC
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 */

#ifndef MEMORY_MANAGER_H
#define MEMORY_MANAGER_H

#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <stdio.h>
#include <fcntl.h>
#include "tools.h"
#include <stdlib.h>
#include "malloc-2.8.6.h"
#include <pthread.h>
#include <errno.h>
#include <new>
#include <wchar.h>
#include <functional> // Инстанциированные темплейты типа std::hash<unsigned int>
#include <utility>
#include <unordered_map>

struct SimpleException { virtual ~SimpleException() {} virtual char* operator () ()=0;  };
#define exception(Name,Parent) struct Name: public Parent { char* Name##_name; \
	Name() {Name##_name = strdup(#Name);} ~Name() {free(Name##_name);} \
	virtual char* operator () () {return Name##_name;} };
exception (StackError, SimpleException);
exception (StackEmptyError, StackError);
exception (StackUnderflowError, StackError);

class TAbstractAllocator
{
public:
	virtual CELL malloc(BfcdInteger)=0;
	virtual void free(CELL)=0;
	virtual char* strdup(const char*)=0;
	virtual wchar_t* wstrdup(const wchar_t*)=0;
	virtual CELL code_alloc(BfcdInteger size)=0;
	virtual CELL _code_head()=0;
	virtual bool is_address_valid(void*) {return true;}

	virtual ~TAbstractAllocator() {}
};
#define ZNEW(TYPE) malloc(sizeof(TYPE))
#define XNEW(ALLOC,TYPE) new (ALLOC->ZNEW(TYPE)) TYPE

// Глобальный системный аллокатор на стандартных malloc/free
// Thread safe according to POSIX
class SystemAllocator: public TAbstractAllocator
{
public:
	virtual CELL malloc(BfcdInteger size) {return ::malloc(size);}
	virtual void free(CELL ptr) {return ::free(ptr);}
	virtual char* strdup(const char*s) {return ::strdup(s);}
	virtual wchar_t* wstrdup(const wchar_t *s) {return ::wcsdup(s);}
	virtual CELL code_alloc(BfcdInteger size) {return NULL;}
	virtual CELL _code_head() {return NULL;}
	virtual ~SystemAllocator() {}
};

extern SystemAllocator systemAllocator;

/* Реализация стека не типична.
 * Стек сделан на двухсвязном списке для возможности быстрой передачи слайсов
 * между стеками.
 * Заодно имеет интерфейс типа Vector, чтоб два раза не вставать.
 * Плюс отдельный аллокатор.
 */
template <typename T> class TStack
{
protected:
	struct TStackElement
	{
		T item;
		TStackElement *next,*prev; 

		TStackElement(): next(NULL), prev(NULL) {};
	};

	TAbstractAllocator *allocator;

	TStackElement *start, *top;
	BfcdInteger size;

public:	
	TStack(TAbstractAllocator* _allocator):
		allocator(_allocator),
		size(0)
	{
		top = start = new (allocator->ZNEW(TStackElement)) TStackElement();
	}

	~TStack()
	{
		TStackElement *e=top, *current;
		while (e)
		{
			current = e;
			e = e->prev;
			allocator->free(current);
		}
	}


	bool isEmpty() {return top==start;}
	void push(T _item) 
	{
		TStackElement* e=new (allocator->ZNEW(TStackElement)) TStackElement();
		e->item = _item;
		e->prev = top;
		top->next = e;
		top = e;
		size++;
	}
	void add(T _item) {puth(_item);}
	T pop()
	{
		if (!size) throw StackEmptyError();
		TStackElement* e = top;
		T item = e->item;
		top = e->prev;
		size--;
		allocator->free(e);
		return item;
	}

	T _top()
	{ 
		if (!size) throw StackEmptyError();
		return top->item;
	}
	BfcdInteger _size() { return size; }
	T nth(BfcdInteger index)
	{
		if(index>size) throw StackUnderflowError();
		if(index==1) return top->item;
		TStackElement* e = top;
		int i = 1;
		while (i<index) { e = e->prev; i++; }
		return e->item;
	}
	T& operator[] (BfcdInteger index)
	{
		if(index>size) throw StackUnderflowError();
		if(index==1) return start->next->item;
		TStackElement* e = start->next;
		int i = 1;
		while (i<index) { e = e->next; i++; }
		return e->item;
	}
	T rot() 
	{
		if(size<3) throw StackUnderflowError();
		TStackElement* e = top->prev->prev; // nth 3
		// Изымаем третий элемент
		e->prev->next = e->next;
		e->next->prev = e->prev;
		// Добавляем его наверх
		top->next = e;
		e->prev = top;
		e->next = NULL;
		top = e;
		//
		return top->item;
	}
	T mrot() // -rot
	{
		TStackElement* e, e3;
		e3 = top->prev->prev; // nth 3
		e = top;
		// top => nth 1
		top = e->prev;
		top->next = NULL;
		// Вставляем бывший top перед nth 3
		e3->prev->next = e;
		e->prev = e3->prev;
		e->next = e3;
		e3->prev = e;
		//
		return top->item;
	}

	TStack<T>* clone()
	{
		TStack<T> *ns=XNEW(allocator,TStack<T>)(allocator);
		TStackElement* e=start->next;
		while(e) 
		{
			ns->push(e->item);
			e=e->next;
		}
		return ns;
	}
};

/*
 * Адаптер для STL
 */
template <class T> class STLAllocator
{
public:	
	using value_type = T;
	STLAllocator(TAbstractAllocator *_mm): mm(_mm) {}
	template <class U> STLAllocator(const STLAllocator<U> &other) { mm=other.mm; }

	// STL вызывает аллокатор не с количеством байт, а c количеством елементов T
	// В C++11: a.allocate(n) - allocates storage suitable for n objects of type T
	T* allocate(std::size_t count) { return static_cast<T*>(mm->malloc(count*sizeof(T))); }
	void deallocate(T* p, std::size_t) { if(p && mm->is_address_valid(p)) mm->free(p); }

//---
	TAbstractAllocator* mm;
};

template <class T, class U> bool operator==(const STLAllocator<T>& a, const STLAllocator<U>& b) { return a->mm==b->mm; }
template <class T, class U> bool operator!=(const STLAllocator<T>& a, const STLAllocator<U>& b) { return ! operator == (a,b); }

/*
 * МemoryManager - Менеджер памяти с GC, 
 * отображением файла образа в память, блэкджеком и шлюхами.  
 */
exception (VMMemoryError, SimpleException);
exception (MSpaceError, VMMemoryError);
exception (VMImageCreationError, VMMemoryError);
exception (VMOutOfMemory, VMMemoryError);
exception (VMAllocatorLocked, VMMemoryError);

#define HERE_ADDR 0x900000000
#define HERE_DELTA 0x100000000

// Список всех выделенных кусков памяти.
// Нужен для GC.
struct GCD
{
	bool reachable;
	mspace heap;
	CELL p;

	GCD():reachable(false), heap(0), p(NULL) {}
	GCD(mspace _heap, CELL _p): reachable(false), heap(_heap), p(_p) {}

	bool is_empty() { return heap == 0; }
};
typedef STLAllocator<std::pair<void* const, GCD>> Ptr_Map_Allocator;
typedef std::unordered_map<void*,
			GCD,
			std::hash<void*>,
			std::equal_to<void*>,
			Ptr_Map_Allocator> Ptr_Map;

/*
 * Базовый пул.
 */
class SubPool;
class BasicPool: public TAbstractAllocator
{
public:	
	BasicPool(CELL _base, BfcdInteger _code_size): base(_base),heap(NULL),
		vm_code_size(_code_size),code_head(0),locked(false), GC(NULL)
	{
		pthread_mutex_init(&mutex,NULL);
	}
	virtual ~BasicPool() {}

	virtual void gc_mark_allocated(mspace ms, CELL p)=0;
	virtual void gc_mark_accessible(CELL p)=0;
	virtual void gc_mark_freed(CELL p)=0;

	// base address
	CELL _base() {return base;}

	// Cоздания сабпула на всю оставшуюся память.
	// Внимание ! Используется тот же mspace.
	friend SubPool* createFullSubpool(BasicPool* mem);

	// Lock flag
	virtual void lock() { locked=true; }
	virtual void unlock() { locked=false; }

	virtual BasicPool* _GC() { return GC; }
	
protected:	
	BfcdInteger vm_code_size;
	pthread_mutex_t mutex;
	CELL base;
	mspace heap;
	BfcdInteger code_head;		// Top index in *base for code allocation 
	// Блокировка любых выделений памяти, при созданном полном сабпуле.
	bool locked;
	// Базовый менеджер памяти, отвечающий за GC - NULL по умолчанию
	BasicPool* GC;
};
// Мало объявить 'friend' в классе, нужен ещё прототип как обычной функции.
// иначе: not declared in this scope
extern SubPool* createFullSubpool(BasicPool* mem);

class MemoryManager: public BasicPool
{
public:
	MemoryManager(BfcdInteger _vm_code_size = MB(128), BfcdInteger _vm_data_size = MB(128) );
	virtual ~MemoryManager();

	// Data allocation
	BfcdInteger getFreeSpace();
	virtual CELL malloc(BfcdInteger size);
	virtual void free(CELL ptr);
	virtual bool is_address_valid(void* p);

	virtual char* strdup(const char* s);
	virtual wchar_t* wstrdup(const wchar_t* s);

	// Code allocation
	virtual CELL code_alloc(BfcdInteger size);
	virtual CELL _code_head();


	// === GC
	// mark address allocated
	virtual void gc_mark_allocated(mspace ms, CELL p) {(*allocatedChunks)[p]=GCD(ms,p);}
	// mark address accessible - must NOT be freed
	virtual void gc_mark_accessible(CELL p) {(*allocatedChunks)[p].reachable=true;}
	// mark freed - remove from GC list
	virtual void gc_mark_freed(CELL p) {allocatedChunks->erase(p);}
	// ===
	
private:
	bool createDataFile(BfcdInteger _vm_data_size);

protected:
	BfcdInteger vm_data_size;
	int data_fd;
	long PAGE_SIZE;

	// Список всех выделенных кусков памяти.
	// Нужен для GC.
	Ptr_Map_Allocator* ptr_sys_alloc;
	Ptr_Map* allocatedChunks;
};

/*
 * Пул внутри MemoryManager - для Task/Thread
 */
class SubPool: public BasicPool
{
public:
	SubPool(CELL _code_base, BfcdInteger _code_size, 
			mspace _heap, BasicPool* _GC);
	virtual ~SubPool();
	
	BfcdInteger getFreeSpace();
	virtual CELL malloc(BfcdInteger size);
	virtual void free(CELL ptr);
	virtual char* strdup(const char* s);
	virtual wchar_t* wstrdup(const wchar_t* s);
	virtual CELL code_alloc(BfcdInteger size);
	virtual CELL _code_head();

	virtual void gc_mark_allocated(mspace ms,CELL p) {if(GC) GC->gc_mark_allocated(ms,p); }
	virtual void gc_mark_accessible(CELL p) {if(GC) GC->gc_mark_accessible(p); }
	virtual void gc_mark_freed(CELL p) {if(GC) GC->gc_mark_freed(p); }

protected:
	// Список выделенных адресов
	Ptr_Map* selfAllocatedChunks;
};

#endif //MEMORY_MANAGER_H


