with POSIX;	use POSIX;
with POSIX.Memory_Mapping;
with POSIX.Configurable_System_Limits;

package body LibBFCD.MemManager is

	-- extern "C" int sysconf(int) -- Ada LibBFCD.C;
	-- external __SC_PAGE_SIZE
	package Mem renames POSIX.Memory_Mapping;
	package CSL renames POSIX.Configurable_System_Limits;

	procedure Init (Pool : in out Heap) is
		use type Mem.Protection_Options;
	begin
		Pool.Page_Size := Storage_Count(CSL.Page_Size);
		Pool.Real_Size := ((Pool.Code_Size + Pool.Data_Size)/Pool.Page_Size+1)*Pool.Page_Size;
		Pool.Base := Mem.Map_Memory_Anonymous(Heap_Base, Pool.Real_Size, 
			Mem.Allow_Read + Mem.Allow_Write,
			Mem.Map_Shared, Mem.Exact_Address);
	end Init;

end LibBFCD.MemManager;
