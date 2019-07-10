#include "forth-words.h"

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
