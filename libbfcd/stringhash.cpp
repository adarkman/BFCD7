#include "stringhash.h"
#include <new>			// For Placement NEW

StringHash::StringHash(TAbstractAllocator* _mem, size_t _size, unsigned _bits):
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

StringHash::~StringHash()
{
	RA->~RandArray();
    mem->free(RA);
    pthread_mutex_destroy(&mutex);
}

int StringHash::hash256(const char* s)
{
    int h = 0;
    while(*s) h = RA->get(h ^ *s++);
    return h;
}

unsigned StringHash::hash4096(const char* s)
{
    unsigned h = 0;
    unsigned shl = 0;
    while(*s)
    {
        int i = *s++;
        shl = ++shl > bits ? 0 : shl;
        i = ((i<<shl)|(i>>(bits-shl))) & mask; // Циклический сдвиг влево внутри 12-ти (bits) битного слова
        //printf("%d %d\n", h, i);
        h = (RA->get(h ^ i) +1) & mask; // +1 для того, чтобы гарантировать (hash != 0)
    }
    return h;
}

StringHash::UID StringHash::insert(const char* s)
{
    uint32_t UID = getUniqueID(s);
    if(UID != 0) return UID; // Уже есть
    unsigned h = key(s);
    void* p = mem->malloc(sizeof(TData));
    TData* d = new (p) TData(mem->strdup(s));
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

uint32_t StringHash::getUniqueID(const char *s)
{
    return getUniqueIDwithKey(key(s),s);
}

uint32_t StringHash::getUniqueIDwithKey(unsigned h, const char *s)
{
    TData *p = data[h];
    while(p)
    {
        unsigned i = 0;
        if(!strcmp(p->s, s))
        {
            uint32_t u = i << 16 | (h & 0xffff);
            return u;
        }
        p = p->next;
        i++;
    }
    return 0;
}

const char* StringHash::get(UID uid)
{
    unsigned h = uid & 0xffff;
    unsigned n = (uid & 0xffff0000) >> 16;
    TData* list = data[h];
    unsigned i = 0;
    while (i<n)
    {
        list = list->next;
    }
    return (const char*)list->s;
}

StringHash::UID StringHash::find(const char *s)
{
	return getUniqueID(s);
}

StringHash::UID StringHash::findOrInsert(const char *s)
{
	int uid = find(s);
	if(uid) return uid;
	else
		return insert(s);
}



