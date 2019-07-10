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

	// Запуск
	void run();

	// Создание базового словаря для нового образа
	void create_base_vocabulary();
	// Создание главного потока исполнения
	void create_main_thread();
	// Запуск главного потока
	void main_thread_run();

protected:
	MemoryManager* allocator;
	// Базовый словарь
	Vocabulary* main_voc;
	// Список всех словарей
	VocabularyStack* vocs;
	// Главный поток исполнения
	VMThreadData* main_thread;
	// Общие данные потоков
	OSEnvironment* os;
	TSharedData *shared;
};

#endif //BFCD_VM_H


