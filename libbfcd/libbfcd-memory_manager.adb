with POSIX;	use POSIX;
with POSIX.Memory_Mapping;
with POSIX.Configurable_System_Limits;

package body LibBFCD.Memory_Manager is

	package Mem renames POSIX.Memory_Mapping;
	package CSL renames POSIX.Configurable_System_Limits;

	procedure Init (Pool : in out Heap) is
		use type Mem.Protection_Options;
		Code_Word_Size : Positive := (if (Code_Word'Size rem 8) = 0 
										then (Code_Word'Size/8)
										else (Code_Word'Size/8+1));
	begin
		Pool.Page_Size := Storage_Count(CSL.Page_Size);
		Pool.Real_Size := ((Pool.Code_Size + Pool.Data_Size)/Pool.Page_Size+1)*Pool.Page_Size;
		Pool.Base := Mem.Map_Memory_Anonymous(Heap_Base, Pool.Real_Size, 
			Mem.Allow_Read + Mem.Allow_Write,
			Mem.Map_Shared, Mem.Exact_Address);
	end Init;

	function Storage_Size (Pool : in Heap) return Storage_Count is (Pool.Real_Size);

	procedure Allocate (
		Pool : in out Heap;
		Address : out System.Address;
		Size : in Storage_Count;
		Alignment : in Storage_Count) is
	begin
		null;
	end Allocate;

	overriding
	procedure Deallocate (
		Pool : in out Heap;
		Address : in System.Address;
		Size : in Storage_Count;
		Alignment : in Storage_Count) is
	begin
		null;
	end Deallocate;

end LibBFCD.Memory_Manager;

