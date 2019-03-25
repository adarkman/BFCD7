with LibBFCD.C;
with POSIX.Memory_Mapping;

package body LibBFCD.MemManager is

	-- extern "C" int sysconf(int) -- Ada LibBFCD.C;
	-- external __SC_PAGE_SIZE
	package Mem renames POSIX.Memory_Mapping;

	procedure Init (Pool : in out Heap) is
	begin
		Pool.Page_Size := LibBFCD.C.sysconf(LibBFCD.C.__SC_PAGE_SIZE);
		Pool.Real_Size := (((Pool.Code_Size + Pool.DataSize)/Pool.Page_Size+1)*Pool.Page_Size;
		Pool.Base := Mem.Map_Memory_Anonymous(Heap_Base, Pool.Real_Size, 
			Mem.Allow_Read or Mem.Allow_Write,
			Mem.Map_Shared, Exact_Address);
		if Pool.Base = Mem.Failure then raise Memory_Mapping_Error; end if;
	end Init;

end LibBFCD.MemManager;
