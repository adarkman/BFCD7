-- Separate memory pool for BFCD7 code/data
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Storage_Elements;		use System.Storage_Elements;
with System.Storage_Pools;			use System.Storage_Pools;
with LibBFCD.Code_Types;			use LibBFCD.Code_Types;

package LibBFCD.Memory_Manager is

	type Heap (Code_Size, Data_Size : Storage_Count) is new Root_Storage_Pool with private;

	Memory_Mapping_Error : exception;

	procedure Init (Pool : in out Heap);

	overriding
	procedure Allocate (
		Pool : in out Heap;
		Address : out System.Address;
		Size : in Storage_Count;
		Alignment : in Storage_Count);

	overriding
	procedure Deallocate (
		Pool : in out Heap;
		Address : in System.Address;
		Size : in Storage_Count;
		Alignment : in Storage_Count);

	overriding
	function Storage_Size (Pool : in Heap) return Storage_Count;

private
	
	type Code_Pool is array (Positive range <>) of Code_Word;
	type Code_Pool_Ptr is access all Code_Pool;

	type Heap (Code_Size, Data_Size : Storage_Count) is new Root_Storage_Pool with record
		Size : Storage_Count;
		Base : System.Address;
		Page_Size : Storage_Count;
		Real_Size : Storage_Count;
		Code : Code_Pool_Ptr;
	end record;

	Heap_Base : constant System.Address := To_Address(16#90_000_000#);

end LibBFCD.Memory_Manager;

