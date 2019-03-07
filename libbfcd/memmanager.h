#ifndef MEMMANAGER_H
#define MEMMANAGER_H

#define MSPACES 1
#define ONLY_MSPACES 1
#define USE_DL_PREFIX 1
#define HAVE_MMAP 1
#include "malloc-2.8.6.h"

#include <string.h>
#include <stdlib.h>
#include <pthread.h>

#define KB(a) (1024*a)
#define MB(a) (1024*KB(1)*a)
#define GB(a) (1024*MB(1)*a)

#define HERE_ADDR 0x90000000

class exMemory
{
    char *msg;

    public:
        exMemory (const char* asciiMsg) { msg = strdup(asciiMsg); }
        virtual ~exMemory() { free(msg); }

        char* operator() () { return msg;}
};

class exFreeMemory: public exMemory
{
    public: exFreeMemory(): exMemory("VM out of memory.") {}
};

class exSystem: public exMemory
{
    public: exSystem(const char* msg): exMemory(msg) {}
};

class MemManager
{
    protected:
        size_t vm_code_size;
		size_t vm_data_size;
        int data_fd;
        void *base;
        long PAGE_SIZE;
        mspace heap;
        pthread_mutex_t mutex;

    public:
        MemManager(size_t _vm_code_size = MB(128), size_t _vm_data_size = MB(128) );
        ~MemManager();

        size_t getFreeSpace();
        void* alloc(size_t size);
        void free(void* ptr);

        char* strdup(const char* s);

    private:
        bool createDataFile(size_t _vm_data_size);

};

#endif // MEMMANAGER_H
