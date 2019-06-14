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

struct SimpleException { virtual ~SimpleException()=0; virtual char* operator () ()=0;  };
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

	virtual ~TAbstractAllocator()=0;
};
#define ZNEW(TYPE) malloc(sizeof(TYPE))

// Глобальный системный аллокатор на стандартных malloc/free
// Thread safe according to POSIX
class SystemAllocator: public TAbstractAllocator
{
public:
	virtual CELL malloc(BfcdInteger size) {return ::malloc(size);}
	virtual void free(CELL ptr) {return ::free(ptr);}
	virtual ~SystemAllocator() {}
};

extern SystemAllocator systemAllocator;

/* Реализация стека не типична.
 * Стек сделан на двухсвязном списке для возможности быстрой передачи слайсов
 * между стеками.
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


	void push(T _item) 
	{
		TStackElement* e=new (allocator->ZNEW(TStackElement)) TStackElement();
		e->item = _item;
		e->prev = top;
		top->next = e;
		top = e;
		size++;
	}
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
		while (i<index) { e = e.prev; i++; }
		return e;
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
	
};

/*
 * МemoryManager - Менеджер памяти с GC, 
 * отображением файла образа в память, блэкджеком и шлюхами.  
 */
exception (VMMemoryError, SimpleException);
exception (MSpaceError, VMMemoryError);
exception (VMImageCreationError, VMMemoryError);
exception (VMOutOfMemory, VMMemoryError);

#define HERE_ADDR 0x900000000
#define HERE_DELTA 0x100000000

class MemoryManager: public TAbstractAllocator
{
public:
	MemoryManager(BfcdInteger _vm_code_size = MB(128), BfcdInteger _vm_data_size = MB(128) );
	virtual ~MemoryManager();

	// Data allocation
	BfcdInteger getFreeSpace();
	virtual CELL alloc(BfcdInteger size);
	virtual void free(CELL ptr);

	char* strdup(const char* s);

	// Code allocation
	CELL code_alloc(BfcdInteger size);

private:
	bool createDataFile(BfcdInteger _vm_data_size);

protected:
	BfcdInteger vm_code_size;
	BfcdInteger vm_data_size;
	int data_fd;
	CELL base;
	long PAGE_SIZE;
	mspace heap;
	pthread_mutex_t mutex;
	BfcdInteger code_head;		// Top index in *base for code allocation 

	// Список всех выделенных кусков памяти.
	// Нужен для GC.
	TStack<CELL>* allocatedChunks;
};

#endif //MEMORY_MANAGER_H

