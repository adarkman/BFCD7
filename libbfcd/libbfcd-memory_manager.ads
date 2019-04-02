-- Separate memory pool for BFCD7 code/data
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Storage_Elements;		use System.Storage_Elements;
with System.Storage_Pools;			use System.Storage_Pools;
with malloc_2_8_6_h;				use malloc_2_8_6_h; 		-- Doug Lea malloc interface
with Ada.Containers.Ordered_Maps;
with BC.Support.Managed_Storage;
with BC.Containers;
with BC.Containers.Lists;
with BC.Containers.Lists.Single;

package LibBFCD.Memory_Manager is

	type Heap is new Root_Storage_Pool with private;

	Memory_Mapping_Error : exception;
	Memory_Allocation_Error : exception;
	Code_Range_Error : exception;
	Remap_Failed : exception;

	--
	-- Глобальные счётчики. Применяются для тестирования.
	--
	Global_Allocs : Natural := 0;
	Global_Deallocs : Natural := 0;
	--

	-- Внимание ! 
	-- Если не хотим странных косяков, то Pool используется только как instance 
	-- т.е. 'Pool : aliased Heap', никаких 'access' и прочих '...Ptr' - иначе 
	-- Ада нормально не работает с динамически создаваемыми пулами.
	-- Это как-то связано с областью видимости, - надо копать RM'12.
	procedure Create_Pool (Pool : in out Heap; Code_Size, Data_Size : Storage_Count; Code_Word_Size : Positive);

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
	-- Local, Unmamanged Storage Pool for Booch Components 
	-- только для внутренних технических целей
	--
	subtype Local_Pool is BC.Support.Managed_Storage.Pool;
	-- Максимальный размер объекта, который может быть выделен в пуле.
	-- при привышении - Storage Error
	Maximum_Object_Size : constant Storage_Offset := 10240; 
	--
    Local_Storage_Pool : Local_Pool (Maximum_Object_Size); 
   	Local_Storage : System.Storage_Pools.Root_Storage_Pool'Class
     	renames System.Storage_Pools.Root_Storage_Pool'Class (Local_Storage_Pool);
	--
	-- Тип списка выделенных mspace. (Да, у Booch Components странная система инициализации)
	--
	package MSpace_Containers is new BC.Containers (mspace);
	package MSpace_Lists is new MSpace_Containers.Lists;
	package Local_MSpaces_List is new MSpace_Lists.Single (Local_Storage);
	use Local_MSpaces_List;
	
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
	Top_Heap_ID : Natural := 0; -- Global created pools counter;
	type Real_Heap is record
		ID : Positive;
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
		Data_MSpaces : Local_MSpaces_List.List := Null_Container;	-- Data MSpaces for Doug Lea malloc
		--
		Allocated : Memory_Map.Map;			-- Map Allocated(Address)->Reacheable(Boolean) for GC
	end record;
	-- Да, здесь _Ptr - Real_Heap выделяется только в глобальном пуле.
	type Real_Heap_Ptr is access Real_Heap;

	type Heap is new Root_Storage_Pool with record
		r : Real_Heap_Ptr;
	end record;

	Heap_Base : constant System.Address := To_Address(16#90_000_000#); -- WARNING: Must be PAGE Aligned !!!

	function Current_MSpace(Pool: Heap) return mspace;

	--
	-- Map of all created pools - см. Create_Pool
	--
	package Pools_Map is new Ada.Containers.Ordered_Maps (
		Key_Type => Positive, -- Real_Heap.ID
		Element_Type => Real_Heap_Ptr);
	Created_Pools : Pools_Map.Map := Pools_Map.Empty_Map;
	
	--
	-- Internal procedures
	--
	-- Initialise newly created Pool
	procedure Init (Pool : in out Real_Heap; Code_Size, Data_Size : Storage_Count; Code_Word_Size : Positive);
	-- Create new mspace
	function Create_MSpace(Base : System.Address; Size : Storage_Count) return mspace;

	function Get_Current_Free_Space(Pool : in Heap) return Storage_Count;

end LibBFCD.Memory_Manager;

