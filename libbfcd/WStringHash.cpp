#include "WStringHash.h"
#include <new>			// For Placement NEW

WStringHash::WStringHash(TAbstractAllocator* _mem, size_t _size, unsigned _bits):
    size(_size), mem(_mem), bits(_bits), mask(size-1)
{
    if(size>65535) throw HashOversizeError();
    pthread_mutex_init(&mutex, NULL);
    void *p = mem->malloc(sizeof(RandArray<int>));
    printf("Rand Array %lu %p\n",sizeof(RandArray<int>), p);
    RA = new (p) RandArray<int> (mem, size);
    data = (TData**) mem->malloc(sizeof(TData*)*size);
    bzero(data, sizeof(TData*)*size);
}

WStringHash::~WStringHash()
{
	RA->~RandArray();
    mem->free(RA);
    pthread_mutex_destroy(&mutex);
}

int WStringHash::hash256(const wchar_t* s)
{
    int h = 0;
    while(*s) h = RA->get(h ^ *s++ & 256 );
    return h;
}

unsigned WStringHash::hash4096(const wchar_t* s)
{
    unsigned h = 0;
    unsigned shl = 0;
    while(*s)
    {
        wint_t i = *s++;
        shl = ++shl > bits ? 0 : shl;
        i = ((i<<shl)|(i>>(bits-shl))) & mask; // Циклический сдвиг влево внутри bits битного слова
        //printf("%d %d\n", h, i);
        h = (RA->get(h ^ i) +1) & mask; // +1 для того, чтобы гарантировать (hash != 0)
    }
    return h;
}

WStringHash::UID WStringHash::insert(const wchar_t* s)
{
    uint32_t UID = getUniqueID(s);
    if(UID != 0) return UID; // Уже есть
    unsigned h = key(s);
    void* p = mem->malloc(sizeof(TData));
    TData* d = new (p) TData(mem->wstrdup(s));
    pthread_mutex_lock(&mutex);
    if(data[h] == NULL)
    {
        data[h] = d;
        data[h]->last = d;
    }
    else
    {
        data[h]->last->next = d;
        data[h]->last = d;
    }
    pthread_mutex_unlock(&mutex);
    return getUniqueIDwithKey(h,s);
}

uint32_t WStringHash::getUniqueID(const wchar_t *s)
{
    return getUniqueIDwithKey(key(s),s);
}

uint32_t WStringHash::getUniqueIDwithKey(unsigned h, const wchar_t *s)
{
    TData *p = data[h];
    while(p)
    {
        unsigned i = 0;
        if(!wcscmp(p->s, s))
        {
            uint32_t u = i << 16 | (h & 0xffff);
            return u;
        }
        p = p->next;
        i++;
    }
    return 0;
}

const wchar_t* WStringHash::get(UID uid)
{
    unsigned h = uid & 0xffff;
    unsigned n = (uid & 0xffff0000) >> 16;
    TData* list = data[h];
    unsigned i = 0;
    while (i<n)
    {
        list = list->next;
    }
    return (const wchar_t*)list->s;
}

WStringHash::UID WStringHash::find(const wchar_t *s)
{
	return getUniqueID(s);
}

WStringHash::UID WStringHash::findOrInsert(const wchar_t *s)
{
	int uid = find(s);
	if(uid) return uid;
	else
		return insert(s);
}



