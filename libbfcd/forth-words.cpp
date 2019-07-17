#include "forth-words.h"

// !hs
defword(save_history)
{
	char *fname=data->shared->os->full_config_path(data->name,L"-history");
	if(data->_trace>=TRACE_IN_C_WORDS)
		printf("\t\t\t\t| !hs - '%s'\n", fname);
	int fd;
	if((fd=open(fname,O_CREAT|O_RDWR|O_TRUNC,0644))!=-1)
	{
		close(fd);
		history(data->elHistory, &data->el_hist_event, H_SAVE, fname);
	}
	else
		if(data->_trace>=TRACE_IN_C_WORDS)
			printf("\t\t\t\t| !hs - invalid file: %s.\n",strerror(errno));
	return true;
}

// !hl
defword(load_history)
{
	char *fname=data->shared->os->full_config_path(data->name,L"-history");
	if(data->_trace>=TRACE_IN_C_WORDS)
		printf("\t\t\t\t| !hl - '%s'\n", fname);
	if(data->shared->os->rw_file_exists(fname))
		history(data->elHistory, &data->el_hist_event, H_LOAD, fname);
	else
		if(data->_trace>=TRACE_IN_C_WORDS)
			printf("\t\t\t\t| !hl - invalid file.\n");
	return true;
}

// dropall
defword(dropall)
{
	int i;
	for(i=0; i<data->AS->_size(); i++) data->apop();
	return true;
}

// Rdropall
defword(rdropall)
{
	int i;
	for(i=0; i<data->RS->_size(); i++) data->rpop();
	return true;
}

// (EXECUTE-PROTECTED)
defword(protected_exec)
{
	//try
	{
		// CFA on stack
		f_execute(data);
	}
	/*catch (SimpleException &ex)
	{
		printf("\t\t\t\tError in thread \"%ls\": %s\n", data->name, ex());
	}*/
	return true;
}

//!subpool:
defword(subpool_start)
{
	_do(bl);
	_do(word);
	WCHAR_P name=data->allocator->wstrdup((WCHAR_P)data->apop());
	_do(bl);
	_do(word);
	WCHAR_P startup_name = (WCHAR_P) data->AS->_top();
	if(data->_trace>=TRACE_IN_C_WORDS)
		printf("\t\t\t\t| !subpool: %ls %ls\n", name, startup_name);
	_do(find);
	if(!data->apop()) // Startup word not found
	{
		printf("!subpool: - startup word '%ls' not found.\n", startup_name);
		return false;
	}
	CELL cfa = (CELL)data->apop(); // CFA от f_find
	VMThreadData* new_pool = data->fullCloneToSubpool(name);
	// current pool locked, push CFA to new stack
	new_pool->apushp(cfa);
	// start in new pool
	f_protected_exec(new_pool);
	// unlock pool
	data->unlock();
	data->allocator->free(name);
	return true;
}




