#include "memmanager.h"
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <stdio.h>
#include <fcntl.h>
#include "tools.h"

MemManager::MemManager(size_t _vm_code_size, size_t _vm_data_size):
    data_fd (-1),
    base (NULL),
    PAGE_SIZE(sysconf(_SC_PAGE_SIZE)),
    heap(NULL),
	code_head(0)
{
    pthread_mutex_init(&mutex, NULL);
    int page_count_data = (_vm_data_size/PAGE_SIZE)+1;
    vm_data_size = PAGE_SIZE*page_count_data;
	int page_count_code = (_vm_code_size/PAGE_SIZE)+1;
	vm_code_size = PAGE_SIZE*page_count_code;
    __CODE(printf("MemManager PAGES=%d SIZE=%ld Mb\n", page_count_data+page_count_code, (vm_data_size+vm_code_size)/MB(1)));
    if(!createDataFile(vm_data_size+vm_code_size))
        throw exMemory("Error allocate VM data.");
	heap = create_mspace_with_base(((char*)base)+vm_code_size, vm_data_size, 1);
    if(!heap)
        throw exMemory("Error creating mspace.");
}

MemManager::~MemManager()
{
    if(heap) destroy_mspace(heap);
    if(base != MAP_FAILED)
    {
        msync(base, vm_data_size, MS_SYNC);
        munmap(base, vm_data_size);
    }
    if(data_fd != -1) close(data_fd);
    pthread_mutex_destroy(&mutex);
}

MALLINFO_FIELD_TYPE MemManager::getFreeSpace()
{
    mallinfo info = mspace_mallinfo(heap);
    return info.fordblks;
}

void* MemManager::alloc(size_t size)
{
    if(size>=getFreeSpace())
        throw exFreeMemory();
    pthread_mutex_lock(&mutex);
    void* p = mspace_malloc(heap, size);
    pthread_mutex_unlock(&mutex);
    return p;
}

void MemManager::free(void* ptr)
{
    if(ptr)
    {
        pthread_mutex_lock(&mutex);
        mspace_free(heap, ptr);
        pthread_mutex_unlock(&mutex);
    }
}

char* MemManager::strdup(const char* s)
{
    char* ds = (char*) this->alloc(strlen(s)+1);
    strcpy(ds, s);
    return ds;
}

void* MemManager::code_alloc(size_t size)
{
	void* ptr = ((char*)base)+size;
	code_head += size;
	if (size % sizeof(BCELL) != 0) { code_head += sizeof(BCELL) - size; }
}

//************************************************************ Private
bool MemManager::createDataFile(size_t _vm_data_size)
{
    char ft[] = "1dfvmXXXXXX";
    mktemp(ft);
    FILE* f = fopen(ft,"w+");
    if(!f) return false;
    __CODE(printf("VM data file '%s'\n", ft));
    for(size_t i=0; i<_vm_data_size+PAGE_SIZE; i++) fputc(0,f);
    data_fd = fileno(f);
    fsync(data_fd);
    if(data_fd == -1) return false;
    unlink(ft);
    //lseek(data_fd, 0, SEEK_SET);
	//Проверить работу без создания файла (см. man mmap: MAP_ANONYMOUS)
    base = mmap ((void*)HERE_ADDR, _vm_data_size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, data_fd, 0);
    if(base == MAP_FAILED)
    {
        close(data_fd);
        return false;
    }
    __CODE(printf("VM Mapped at 0x%p\n", base));
    return true;
}
