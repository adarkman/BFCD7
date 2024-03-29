#ifndef STRINGHASH_H
#define STRINGHASH_H

#include "MemoryManager.h"
#include "randarray.h"
#include <stdint.h>

exception (HashError, SimpleException);
exception (HashOversizeError, HashError)

class StringHash
{
    RandArray<int>* RA;
    size_t size;
    TAbstractAllocator* mem;
    unsigned bits, mask;
    pthread_mutex_t mutex;

    public:
		typedef uint32_t UID;
        struct TData
        {
            const char* s;
            TData* next, *prev;
            TData* last;

            TData(const char* _data = NULL):s(_data), next(NULL), prev(NULL), last(NULL) {}
        };

    private:
        TData** data;

    public:
        StringHash(TAbstractAllocator* _mem, size_t _size = 4096, // 2, 4, 8, 16, 32 ....
                   unsigned _bits = 12); // степень двойки _size
        ~StringHash();

        int hash256(const char* s);
        unsigned hash4096(const char* s);
        UID insert(const char* s);
        TData* valueList(int key) { return data[key]; }
        const char* get(UID uid);
		const char* operator() (UID uid) { return get(uid); }
		UID find(const char *s);
		UID findOrInsert(const char *s);

    protected:
        unsigned key(const char* s) { return hash4096(s); }
        uint32_t getUniqueID(const char*s);
        uint32_t getUniqueIDwithKey(unsigned h, const char *s);
};

#endif // STRINGHASH_H
