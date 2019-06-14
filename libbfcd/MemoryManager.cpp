#include "MemoryManager.h"
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <stdio.h>
#include <fcntl.h>
#include "tools.h"

/*
 * Global system allocator
 */
SystemAllocator systemAllocator;

/*
 * MemoryManager
 */

MemoryManager::MemoryManager(BfcdInteger _vm_code_size, BfcdInteger _vm_data_size):
    data_fd (-1),
    base (NULL),
    PAGE_SIZE(sysconf(_SC_PAGE_SIZE)),
    heap(NULL),
	code_head(0)
{
    pthread_mutex_init(&mutex, NULL);
	allocatedChunks = new TStack<CELL>(&systemAllocator);
	// Align Code/Data size to PAGE boundary
    int page_count_data = (_vm_data_size/PAGE_SIZE)+1;
    vm_data_size = PAGE_SIZE*page_count_data;
	int page_count_code = (_vm_code_size/PAGE_SIZE)+1;
	vm_code_size = PAGE_SIZE*page_count_code;
	//
    __CODE(printf("MemoryManager PAGES=%d SIZE=%ld Mb\n", page_count_data+page_count_code, (vm_data_size+vm_code_size)/MB(1)));
    if(!createDataFile(vm_data_size+vm_code_size)) throw VMImageCreationError();
	heap = create_mspace_with_base(((char*)base)+vm_code_size, vm_data_size, 1);
    if(!heap) throw MSpaceError();
	// MSPACE tuning
	// disable separated allocation of large chunks
	mspace_track_large_chunks (heap, 1); 
	// disable additional system memory chunks allocation
	mspace_set_footprint_limit (heap, 0);
}

MemoryManager::~MemoryManager()
{
	if(allocatedChunks) delete allocatedChunks;
    if(heap) destroy_mspace(heap);
    if(base != MAP_FAILED)
    {
        msync(base, vm_data_size, MS_SYNC);
        munmap(base, vm_data_size);
    }
    if(data_fd != -1) close(data_fd);
    pthread_mutex_destroy(&mutex);
}

BfcdInteger MemoryManager::getFreeSpace()
{
    mallinfo info = mspace_mallinfo(heap);
    return info.fordblks;
}

CELL MemoryManager::alloc(BfcdInteger size)
{
    if(size>=getFreeSpace()) throw VMOutOfMemory();
    pthread_mutex_lock(&mutex);
    void* p = mspace_malloc(heap, size);
	allocatedChunks->push(p);
    pthread_mutex_unlock(&mutex);
    return p;
}

void MemoryManager::free(CELL ptr)
{
    if(ptr)
    {
        pthread_mutex_lock(&mutex);
        mspace_free(heap, ptr);
        pthread_mutex_unlock(&mutex);
    }
}

char* MemoryManager::strdup(const char* s)
{
    char* ds = (char*) this->alloc(strlen(s)+1);
    strcpy(ds, s);
    return ds;
}

CELL MemoryManager::code_alloc(BfcdInteger size)
{
	void* ptr = ((char*)base)+size;
	code_head += size;
	if (size % sizeof(CELL) != 0) { code_head += sizeof(CELL) - size; }
}

//************************************************************ Private
bool MemoryManager::createDataFile(BfcdInteger _vm_data_size)
{
    /*mktemp(ft);
     *FILE* f = fopen(ft,"w+");
     *if(!f) return false;
     *__CODE(printf("VM data file '%s'\n", ft));
     *for(size_t i=0; i<_vm_data_size+PAGE_SIZE; i++) fputc(0,f);
     *data_fd = fileno(f);
     *fsync(data_fd);
	 */
#ifdef O_TMPFILE
	data_fd = open("/tmp",O_TMPFILE|O_RDWR|S_IRUSR|S_IWUSR);
#else	
    char ft[] = "1dfvmXXXXXX";
	data_fd = mkstemp(ft);
#endif	
    if(data_fd == -1) 
	{
		printf ("Error creating VM file: %s\n", strerror(errno));
		return false;
	}
#ifndef O_TMPFILE	
	char path[PATH_MAX],rpath[PATHMAX];
    snprintf(path, PATH_MAX,  "/proc/self/fd/%d", fd);
	if(!realpath(path,rpath))
	{
		printf ("Error: %s\n", strerror(errno));
		close(data_fd);
		return false;
	}
    unlink(rpath);
#endif	
	if(ftruncate(data_fd,_vm_data_size) == -1)
	{
		printf ("Error creating VM file: %s\n", strerror(errno));
        close(data_fd);
		return false;
	}
    //lseek(data_fd, 0, SEEK_SET);
    base = mmap ((void*)HERE_ADDR, _vm_data_size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, data_fd, 0);
    if(base == MAP_FAILED)
    {
		printf ("Error creating VM file: %s\n", strerror(errno));
        close(data_fd);
        return false;
    }
    __CODE(printf("VM Mapped at 0x%p\n", base));
    return true;
}

