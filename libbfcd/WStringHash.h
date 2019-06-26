#ifndef STRINGHASH_H
#define STRINGHASH_H

#include "MemoryManager.h"
#include "randarray.h"
#include <stdint.h>
#include <wctype.h>
#include <wchar.h>

exception (HashError, SimpleException);
exception (HashOversizeError, HashError)

class WStringHash
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
            const wchar_t* s;
            TData* next, *prev;
            TData* last;

            TData(const wchar_t* _data = NULL):s(_data), next(NULL), prev(NULL), last(NULL) {}
        };

    private:
        TData** data;

    public:
        WStringHash(TAbstractAllocator* _mem, size_t _size = 8192, // 2, 4, 8, 16, 32 ....
                   unsigned _bits = 13); // степень двойки _size
        ~WStringHash();

        int hash256(const wchar_t* s);
        unsigned hash4096(const wchar_t* s);
        UID insert(const wchar_t* s);
        TData* valueList(int key) { return data[key]; }
        const wchar_t* get(UID uid);
		const wchar_t* operator() (UID uid) { return get(uid); }
		UID find(const wchar_t *s);
		UID findOrInsert(const wchar_t *s);

    protected:
        unsigned key(const wchar_t* s) { return hash4096(s); }
        uint32_t getUniqueID(const wchar_t*s);
        uint32_t getUniqueIDwithKey(unsigned h, const wchar_t *s);
};

#endif // STRINGHASH_H
