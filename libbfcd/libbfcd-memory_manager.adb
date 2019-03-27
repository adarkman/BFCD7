with POSIX;	use POSIX;
with POSIX.Memory_Mapping;
with POSIX.Configurable_System_Limits;
with Ada.Unchecked_Conversion;
with System.Address_To_Access_Conversions;

package body LibBFCD.Memory_Manager is

	package Mem renames POSIX.Memory_Mapping;
	package CSL renames POSIX.Configurable_System_Limits;
	package Code_Word_Access is new System.Address_To_Access_Conversions (Object => Code_Word);

	procedure Init (Pool : in out Heap) is
		use type Mem.Protection_Options;
	begin
		Pool.Code_Word_Size := (if (Code_Word'Size rem 8) = 0 
											then (Code_Word'Size/8)
											else (Code_Word'Size/8+1));
		Pool.Page_Size := Storage_Count(CSL.Page_Size);
		Pool.Real_Size := ((Pool.Code_Size + Pool.Data_Size)/Pool.Page_Size+1)*Pool.Page_Size;
		Pool.Base := Mem.Map_Memory_Anonymous(Heap_Base, Pool.Real_Size, 
			Mem.Allow_Read + Mem.Allow_Write,
			Mem.Map_Shared, Mem.Exact_Address);
		Pool.Code := Pool.Base; --  Code started at mmaped area start
		Pool.Code_Top := 1;
		Pool.Code_Word_Array_Size := Positive(Pool.Code_Size)/Pool.Code_Word_Size;
	end Init;

	function Get_Code_Word(Pool : in out Heap; Index : in Natural) return Code_Word_Ptr is
		use type System.Address;
	begin
		if Index > Pool.Code_Top then raise Code_Range_Error; end if;
		return Code_Word_Ptr(Code_Word_Access.To_Pointer (Pool.Code + Storage_Offset(Pool.Code_Word_Size*(Index-1))));
	end Get_Code_Word;

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

