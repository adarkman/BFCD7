#ifndef RANDARRAY_H
#define RANDARRAY_H

#include "MemoryManager.h"
#include <unistd.h>
#include <stdio.h>

exception (RandArrayError,SimpleException);

template <typename T> class RandArray
{
    size_t size;
    TAbstractAllocator* mem;
    T* data;

    public:
        RandArray(TAbstractAllocator* _mem, size_t _size):
                             size(_size), mem(_mem)
        {
            FILE* f = fopen("/dev/urandom", "r");
            data = (T*) mem->malloc(sizeof(T)*size);
            fread(data, sizeof(T), size, f);
            fclose(f);
        }
        ~RandArray()
        {
            mem->free(data);
        }

        T operator[] (size_t index)
        {
            if(index>=size) throw RandArrayError();
            return data[index];
        }
        T get(size_t index) { return operator[](index); }
};

#endif // RANDARRAY_H
