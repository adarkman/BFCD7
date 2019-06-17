/* BFCD-VM - BFCD7 Virtual Machine
 * (C) Hell Design 2019
 * Author: Alexandr Darkman
 * All rights reserved.
 *
 */

#ifndef BFCD_VM_H
#define BFCD_VM_H

#include "forth.h"

class BfcdVM
{
public:
	BfcdVM();
	~BfcdVM();

	// Создание базового словаря для нового образа
	void create_base_vocabulary();
protected:
	MemoryManager* allocator;
	// Базовый словарь
	Vocabulary* main_voc;
	// Список всех словарей
	TStack<Vocabulary*>* vocs;
};

#endif //BFCD_VM_H


