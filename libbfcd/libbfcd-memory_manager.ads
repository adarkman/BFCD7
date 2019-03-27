-- Separate memory pool for BFCD7 code/data
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Storage_Elements;		use System.Storage_Elements;
with System.Storage_Pools;			use System.Storage_Pools;
with LibBFCD.Code_Types;			use LibBFCD.Code_Types;
with malloc_2_8_6_h;				use malloc_2_8_6_h; 		-- Doug Lea malloc interface

package LibBFCD.Memory_Manager is

	type Heap (Code_Size, Data_Size : Storage_Count) is new Root_Storage_Pool with private;

	Memory_Mapping_Error : exception;
	Memory_Allocation_Error : exception;
	Code_Range_Error : exception;

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

	function Get_Code_Word(Pool : in out Heap; Index : in Positive) return Code_Word_Ptr;
	function Allocate_Code_Word(Pool : in out Heap; Data_Type : in Word_Type) return Code_Word_Ptr;

private
	
	type Byte is mod 256;
	NULL_ADDR : constant System.Address := To_Address(0);

	type Heap (Code_Size, Data_Size : Storage_Count) is new Root_Storage_Pool with record
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
	end record;

	Heap_Base : constant System.Address := To_Address(16#90_000_000#); -- WARNING: Must be PAGE Aligned !!!

	function Get_Code_Word_Unsafe(Pool : in out Heap; Index : in Natural) return Code_Word_Ptr;

end LibBFCD.Memory_Manager;

