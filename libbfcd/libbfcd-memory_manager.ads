-- Separate memory pool for BFCD7 code/data
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Storage_Elements;		use System.Storage_Elements;
with System.Storage_Pools;			use System.Storage_Pools;
with malloc_2_8_6_h;				use malloc_2_8_6_h; 		-- Doug Lea malloc interface
with Ada.Containers.Ordered_Maps;

package LibBFCD.Memory_Manager is

	type Heap is new Root_Storage_Pool with private;

	Memory_Mapping_Error : exception;
	Memory_Allocation_Error : exception;
	Code_Range_Error : exception;
	Remap_Failed : exception;

	-- Внимание ! 
	-- Если не хотим странных косяков, то Pool используется только как instance 
	-- т.е. 'Pool : aliased Heap', никаких 'access' и прочих '...Ptr' - иначе 
	-- Ада нормально не работает с динамически создаваемыми пулами.
	-- Это как-то связано с областью видимости, - надо копать RM'12.
	procedure Create_Pool (Pool : in out Heap; Code_Size, Data_Size : Storage_Count; Code_Word_Size : Positive);
	procedure Resize_Pool (Pool : in out Heap; New_Size_Delta : Storage_Count);

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
	-- Main Forth storage pool type - Each VM Thread have pesonal 'Heap' instance
	--
	type Heap is new Root_Storage_Pool with record
		Real_Code_Size, Real_Data_Size:	Storage_Count;	-- Code_Size, Data_Size - PAGE aligned
		Page_Size : Storage_Count;			-- Get from system via 'sysconf'
		--
		Code : System.Address;				-- code pool
		Code_Word_Size : Positive;			-- size of Code_Word
		Code_Top : Positive;				-- Top Index of Allocated Code_Word, start from '1'
		Code_Word_Array_Size : Natural;	-- code pool size calculated in Code_Word's
		--
		Data : System.Address;				-- Data pool base address
		-- Здесь должен быть список MSpace'ов создаваемых
		-- по мере расширения пула через mremap(2)
		Data_MSpace : mspace;				-- Data MSpace for Doug Lea malloc
		--
		Allocated : Memory_Map.Map;			-- Map Allocated(Address)->Reacheable(Boolean) for GC
	end record;

	Heap_Base : constant System.Address := To_Address(16#90_000_000#); -- WARNING: Must be PAGE Aligned !!!
	
	--
	-- Internal procedures
	--
	-- Initialise newly created Pool
	procedure Init (Pool : in out Heap; Code_Size, Data_Size : Storage_Count; Code_Word_Size : Positive);
	-- Create new mspace
	function Create_MSpace(Base : System.Address; Size : Storage_Count) return mspace;

	function Get_Current_Free_Space(Pool : in Heap) return Storage_Count;

end LibBFCD.Memory_Manager;

