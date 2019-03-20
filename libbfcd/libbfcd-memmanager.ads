-- Separate memory pool for BFCD7 code/data
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Storage_Elements;		use System.Storage_Elements;
with System.Storage_Pools;			use System.Storage_Pools;

package LibBFCD.MemManager is

	type Heap (Size : Storage_Count) is new Root_Storage_Pool with private;

	overriding
	procedure Allocate (
		Pool : in out Heap,
		Address : out System.Address,
		Size : in Storage_Count,
		Alignment : in Storage_Count);

	overriding
	procedure Deallocate (
		Pool : in out Heap,
		Address : in System.Address,
		Size : in Storage_Count,
		Alignment : in Storage_Count);

	overriding
	function Storage_Size (Pool : in Heap) return Storage_Count;

private

	type Heap (Size : Storage_Count) is new Root_Storage_Pool with record
	end Heap;

end LibBFCD.MemManager;

