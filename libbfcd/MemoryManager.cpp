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
	BasicPool(NULL,0),
    data_fd (-1),
    PAGE_SIZE(sysconf(_SC_PAGE_SIZE))
{
	ptr_sys_alloc = new Ptr_Map_Allocator(&systemAllocator);
	allocatedChunks = new Ptr_Map(0,*ptr_sys_alloc);
	// Align Code/Data size to PAGE boundary
    int page_count_data = (_vm_data_size/PAGE_SIZE)+1;
    vm_data_size = PAGE_SIZE*page_count_data;
	int page_count_code = (_vm_code_size/PAGE_SIZE)+1;
	vm_code_size = PAGE_SIZE*page_count_code;
	//
    __CODE(printf("MemoryManager PAGES=%d SIZE=%lldMb\n", page_count_data+page_count_code, (vm_data_size+vm_code_size)/MB(1)));
    if(!createDataFile(vm_data_size+vm_code_size)) throw VMImageCreationError();
	heap = create_mspace_with_base(((char*)base)+vm_code_size, vm_data_size, 1);
    if(!heap) throw MSpaceError();
	// MSPACE tuning
	// disable separated allocation of large chunks
	mspace_track_large_chunks (heap, 1); 
	// disable additional system memory chunks allocation
	mspace_set_footprint_limit (heap, 0);
	locked = false;
	GC = this;
}

MemoryManager::~MemoryManager()
{
	if(allocatedChunks)
	{
	   delete allocatedChunks;
	   delete ptr_sys_alloc;
	}
    if(heap) destroy_mspace(heap);
    if(base != MAP_FAILED)
    {
        msync(base, vm_code_size+vm_data_size, MS_SYNC);
        munmap(base, vm_code_size+vm_data_size);
    }
    if(data_fd != -1) close(data_fd);
	pthread_mutex_destroy(&mutex);
}

CELL MemoryManager::malloc(BfcdInteger size)
{
	if(locked) throw VMAllocatorLocked();
    if(size>=data_available()) throw VMOutOfMemory();
    pthread_mutex_lock(&mutex);
	//__CODE(printf("\\ MM::malloc - start %ld\n", size));
    void* p = mspace_malloc(heap, size);
	gc_mark_allocated(heap,p);
	//__CODE(printf("\\ MM::malloc - %p\n", p));
    pthread_mutex_unlock(&mutex);
    return p;
}

void MemoryManager::free(CELL ptr)
{
    if(ptr)
    {
        pthread_mutex_lock(&mutex);
		auto gcd=allocatedChunks->find(ptr);
		if(gcd!=allocatedChunks->end())
		{
			gc_mark_freed(ptr);
    	    mspace_free(gcd->second.heap, gcd->second.p);
		}
        pthread_mutex_unlock(&mutex);
    }
}

bool MemoryManager::is_address_valid(void* p)
{
	return (base<=p) && (((char*)base)+vm_code_size+vm_data_size)>(char*)p;
}

char* MemoryManager::strdup(const char* s)
{
    char* ds = (char*) this->malloc(strlen(s)+1);
    strcpy(ds, s);
    return ds;
}

wchar_t* MemoryManager::wstrdup(const wchar_t* s)
{
    wchar_t* ds = (wchar_t*) this->malloc((wcslen(s)+1)*sizeof(wchar_t));
    wcscpy(ds, s);
    return ds;
}

CELL MemoryManager::code_alloc(BfcdInteger size)
{
	if(locked) throw VMAllocatorLocked();
	void* ptr = ((char*)base)+code_head;
	code_head += size;
	if (size % sizeof(CELL) != 0) { code_head += sizeof(CELL) - size; }
	if(code_head>vm_code_size) throw VMOutOfMemory();
	return ptr;
}

CELL MemoryManager::_code_head()
{
	return ((char*)base)+code_head;
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
	data_fd = open("/tmp",O_TMPFILE|O_RDWR,S_IRUSR|S_IWUSR);
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

// Cоздания сабпула на всю оставшуюся память.
// Внимание ! Используется тот же mspace.
SubPool* createFullSubpool(BasicPool *mem)
{
	//CELL new_base=mem->code_alloc(/*PAD*/sizeof(CELL)*2);
	CELL new_base=mem->code_alloc(0);
	BfcdInteger new_code_size = mem->vm_code_size-mem->code_head-/*PAD*/sizeof(BfcdInteger)*2;
	SubPool* sub=new (mem->malloc(sizeof(SubPool))) SubPool(new_base, new_code_size, mem->heap, mem->GC);
	return sub;
}

/*
 * SubPool
 */

SubPool::SubPool(CELL _code_base, BfcdInteger _code_size, mspace _heap, BasicPool* _GC):
	BasicPool(_code_base,_code_size)
{
	GC = _GC;
    heap = _heap;
	selfAllocatedChunks = XNEW(GC,Ptr_Map)(0,&systemAllocator);
}

SubPool::~SubPool()
{
	selfAllocatedChunks->~Ptr_Map();
	GC->free(selfAllocatedChunks);
    pthread_mutex_destroy(&mutex);
}

BfcdInteger SubPool::getFreeSpace()
{
    mallinfo info = mspace_mallinfo(heap);
    return info.fordblks;
}

CELL SubPool::malloc(BfcdInteger size)
{
	if(locked) throw VMAllocatorLocked();
    if(size>=getFreeSpace()) throw VMOutOfMemory();
    pthread_mutex_lock(&mutex);
    void* p = mspace_malloc(heap, size);
	gc_mark_allocated (heap,p);
    pthread_mutex_unlock(&mutex);
    return p;
}

void SubPool::free(CELL ptr)
{
    if(ptr)
    {
        pthread_mutex_lock(&mutex);
		if(selfAllocatedChunks->find(ptr)!=selfAllocatedChunks->end()) // Allocated by self
		{
			gc_mark_freed(ptr);
    	    mspace_free(heap, ptr);
		}
        pthread_mutex_unlock(&mutex);
    }
}

char* SubPool::strdup(const char* s)
{
    char* ds = (char*) this->malloc(strlen(s)+1);
    strcpy(ds, s);
    return ds;
}

wchar_t* SubPool::wstrdup(const wchar_t* s)
{
    wchar_t* ds = (wchar_t*) this->malloc((wcslen(s)+1)*sizeof(wchar_t));
    wcscpy(ds, s);
    return ds;
}

CELL SubPool::code_alloc(BfcdInteger size)
{
	void* ptr = ((char*)base)+code_head;
	code_head += size;
	if (size % sizeof(CELL) != 0) { code_head += sizeof(CELL) - size; }
	if(code_head>vm_code_size) throw VMOutOfMemory();
	return ptr;
}

CELL SubPool::_code_head()
{
	return ((char*)base)+code_head;
}

