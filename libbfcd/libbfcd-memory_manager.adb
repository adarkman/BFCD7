with POSIX;	use POSIX;
with POSIX.Memory_Mapping;
with POSIX.Configurable_System_Limits;
with Ada.Unchecked_Conversion;
with System.Address_To_Access_Conversions;
with Interfaces.C;

package body LibBFCD.Memory_Manager is

	package Mem renames POSIX.Memory_Mapping;
	package CSL renames POSIX.Configurable_System_Limits;
	package Code_Word_Access is new System.Address_To_Access_Conversions (Object => Code_Word);
	package C renames Interfaces.C;
	use type System.Address;

	procedure Init (Pool : in out Heap) is
		use type Mem.Protection_Options;
	begin
		Pool.Code_Word_Size := (if (Code_Word'Size rem 8) = 0 
											then (Code_Word'Size/8)
											else (Code_Word'Size/8+1));
		Pool.Page_Size := Storage_Count(CSL.Page_Size);
		-- ensure page aligned
		Pool.Real_Code_Size := (Pool.Code_Size/Pool.Page_Size+1)*Pool.Page_Size;
		Pool.Real_Data_Size := (Pool.Data_Size/Pool.Page_Size+1)*Pool.Page_Size;
		--
		Pool.Real_Size := Pool.Real_Code_Size + Pool.Real_Data_Size;
		Pool.Base := Mem.Map_Memory_Anonymous(Heap_Base, Pool.Real_Size, 
			Mem.Allow_Read + Mem.Allow_Write,
			Mem.Map_Shared, Mem.Exact_Address);
		--
		Pool.Code := Pool.Base; --  Code started at mmaped area start
		Pool.Code_Top := 1;
		Pool.Code_Word_Array_Size := Positive(Pool.Real_Code_Size)/Pool.Code_Word_Size-1; -- (-1) - ensure we are have pad
		--
		Pool.Data := Pool.Code+Storage_Offset(Pool.Real_Code_Size);
		Pool.Data_MSpace := create_mspace_with_base (Pool.Data, size_t(Pool.Real_Data_Size), 1);
		if Pool.Data_MSpace = mspace(To_Address(0)) then raise Memory_Mapping_Error; end if;
		-- MSPACE tuning
		declare 
			track : C.int; 
			limit : size_t; 
		begin
			-- disable separated allocation of large chunks
			track := mspace_track_large_chunks (Pool.Data_MSpace, 1); 
			-- disable additional system memory chunks allocation
			limit := mspace_set_footprint_limit (Pool.Data_MSpace, 0);  
		end;
		--
	end Init;

	-- Unsafe version - do not check index range, use only if you know what you do
	function Get_Code_Word_Unsafe(Pool : in out Heap; Index : in Natural) return Code_Word_Ptr is
	begin
		return Code_Word_Ptr(Code_Word_Access.To_Pointer (Pool.Code + Storage_Offset(Pool.Code_Word_Size*(Index-1))));
	end Get_Code_Word_Unsafe;

	function Get_Code_Word(Pool : in out Heap; Index : in Positive) return Code_Word_Ptr is
		use type System.Address;
	begin
		if Index > Pool.Code_Top then raise Code_Range_Error; end if;
		return Get_Code_Word_Unsafe(Pool, Index);
	end Get_Code_Word;

	function Allocate_Code_Word(Pool : in out Heap; Data_Type : in Word_Type) return Code_Word_Ptr is
		ptr : Code_Word_Ptr;
		word : Code_Word(Data_Type);
	begin
		Pool.Code_Top := Pool.Code_Top+1;
		ptr := Get_Code_Word_Unsafe (Pool, Pool.Code_Top);
		word.index := Pool.Code_Top;
		ptr.all := word; -- ensure memory initialized
		return ptr;
	end Allocate_Code_Word;

	function Storage_Size (Pool : in Heap) return Storage_Count is (Pool.Real_Size);

	procedure Allocate (
		Pool : in out Heap;
		Address : out System.Address;
		Size : in Storage_Count;
		Alignment : in Storage_Count) is
	begin
		Address := mspace_malloc (Pool.Data_MSpace, size_t(Size));
		if Address = NULL_ADDR then raise Memory_Allocation_Error; end if;
	end Allocate;

	overriding
	procedure Deallocate (
		Pool : in out Heap;
		Address : in System.Address;
		Size : in Storage_Count;
		Alignment : in Storage_Count) is
	begin
		mspace_free (Pool.Data_MSpace, Address);
	end Deallocate;

end LibBFCD.Memory_Manager;

