-- Separate memory pool for BFCD7 code/data
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Storage_Elements;		use System.Storage_Elements;
with System.Storage_Pools;			use System.Storage_Pools;
with malloc_2_8_6_h;				use malloc_2_8_6_h; 		-- Doug Lea malloc interface
with Ada.Containers.Ordered_Maps;

package LibBFCD.Memory_Manager is

	-- нельзя сохраняться на диск если есть 
	-- выделенные Storage_Pool с флагом Heap_Temporary
	type Heap_Type is (Heap_Fixed, Heap_Temporary); 
	type Heap is new Root_Storage_Pool with private;

	Memory_Mapping_Error : exception;
	Memory_Allocation_Error : exception;
	Code_Range_Error : exception;

	-- Внимание ! 
	-- Если не хотим странных косяков, то Pool используется только как instance 
	-- т.е. 'Pool : aliased Heap', никаких 'access' и прочих '...Ptr' - иначе 
	-- Ада нормально не работает с динамически создаваемыми пулами.
	-- Это как-то связано с областью видимости, - надо копать RM'12.
	procedure Create_Pool (Pool : in out Heap; Code_Size, Data_Size : Storage_Count; Code_Word_Size : Positive; Flags : Heap_Type := Heap_Fixed);
	procedure Init (Pool : in out Heap; Code_Size, Data_Size : Storage_Count; Code_Word_Size : Positive);

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

	function Get_Code_Word_Address(Pool : in out Heap; Index : in Positive) return System.Address;
	function Allocate_Code_Word_Address(Pool : in out Heap; Index : out Positive) return System.Address;
	function Get_Code_Word_Address_Unsafe(Pool : in out Heap; Index : in Natural) return System.Address;

private
	
	type Byte is mod 256;
	NULL_ADDR : constant System.Address := To_Address(0);
	
	--
	-- Allocated memory map
	--
	use type System.Address;
	package Memory_Map is new Ada.Containers.Ordered_Maps (
		Key_Type => System.Address,
		Element_Type => Boolean);

	--
	-- Main Forth storage pool
	--
	type Heap is new Root_Storage_Pool with record
		Real_Code_Size, Real_Data_Size:	Storage_Count;	-- Code_Size, Data_Size - PAGE aligned
		Size : Storage_Count;				-- Code_Size+Data_Size
		Base : System.Address;				-- Heap_Base
		Page_Size : Storage_Count;			-- Get from system via 'sysconf'
		Real_Size : Storage_Count;			-- Size wish pads, PAGE aligned
		--
		Code : System.Address;				-- code pool
		Code_Word_Size : Positive;			-- size of Code_Word
		Code_Top : Positive;				-- Top Index of Allocated Code_Word, start from '1'
		Code_Word_Array_Size : Positive;	-- code pool size calculated in Code_Word's
		--
		Data : System.Address;				-- Data pool base address
		Data_MSpace : mspace;				-- Data MSpace for Doug Lea malloc
		--
		Allocated : Memory_Map.Map;			-- Map Allocated(Address)->Reacheable(Boolean) for GC
	end record;

	--Heap_Base : constant System.Address := To_Address(16#90_000_000#); -- WARNING: Must be PAGE Aligned !!!
	
	--
	-- Dynamic Pool Maps
	--
	package Pools_Map is new Ada.Containers.Ordered_Maps (
		Key_Type => System.Address,
		Element_Type => Storage_Count);

	Pools : Pools_Map.Map := Pools_Map.Empty_Map;

end LibBFCD.Memory_Manager;

