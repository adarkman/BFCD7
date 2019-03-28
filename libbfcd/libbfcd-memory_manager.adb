with POSIX;	use POSIX;
with POSIX.Memory_Mapping;
with POSIX.Configurable_System_Limits;
with Ada.Unchecked_Conversion;
with Interfaces.C;
with Ada.Text_IO; use Ada.Text_IO;

package body LibBFCD.Memory_Manager is

	package Mem renames POSIX.Memory_Mapping;
	package CSL renames POSIX.Configurable_System_Limits;
	package C renames Interfaces.C;
	use type System.Address;

	procedure Init (Pool : in out Heap; Code_Size, Data_Size : Storage_Count; Code_Word_Size : Positive) is
		use type Mem.Protection_Options;
	begin
		Pool.Code_Word_Size := Code_Word_Size;
		Pool.Page_Size := Storage_Count(CSL.Page_Size);
		-- ensure page aligned
		Pool.Real_Code_Size := (Code_Size/Pool.Page_Size+1)*Pool.Page_Size;
		Pool.Real_Data_Size := (Data_Size/Pool.Page_Size+1)*Pool.Page_Size;
		--
		Pool.Real_Size := Pool.Real_Code_Size + Pool.Real_Data_Size;
		--Pool.Base := Mem.Map_Memory_Anonymous(Heap_Base, Pool.Real_Size, 
		Pool.Base := Mem.Map_Memory_Anonymous(To_Address(140573701693440), Pool.Real_Size, 
			Mem.Allow_Read + Mem.Allow_Write,
			Mem.Map_Shared, Mem.Exact_Address); -- or Mem.Nearby_Address
		--
		Pool.Code := Pool.Base; --  Code started at mmaped area start
		Put_Line("Heap init: " & Integer_Address'Image(To_Integer(Pool.Base)));
		Pool.Code_Top := 1;
		Pool.Code_Word_Array_Size := Positive(Pool.Real_Code_Size)/Pool.Code_Word_Size-1; -- (-1) - ensure we are have pad
		--
		Pool.Data := Pool.Code+Storage_Offset(Pool.Real_Code_Size);
		Put_Line("Heap data: " & Integer_Address'Image(To_Integer(Pool.Data)));
		Pool.Data_MSpace := create_mspace_with_base (Pool.Data, size_t(Pool.Real_Data_Size), 1);
		if Pool.Data_MSpace = mspace(To_Address(0)) then raise Memory_Mapping_Error; end if;
		-- MSPACE tuning
		declare 
			track : C.int; 
			limit : size_t; 
		begin null;
			-- disable separated allocation of large chunks
			track := mspace_track_large_chunks (Pool.Data_MSpace, 1); 
			-- disable additional system memory chunks allocation
			limit := mspace_set_footprint_limit (Pool.Data_MSpace, 0);  
		end;
		--
		Pool.Allocated := Memory_Map.Empty_Map;
	end Init;

	-- Unsafe version - do not check index range, use only if you know what you do
	function Get_Code_Word_Address_Unsafe(Pool : in out Heap; Index : in Natural) return System.Address is
	begin
		return Pool.Code + Storage_Offset(Pool.Code_Word_Size*(Index-1));
	end Get_Code_Word_Address_Unsafe;

	function Get_Code_Word_Address(Pool : in out Heap; Index : in Positive) return System.Address is
		use type System.Address;
	begin
		if Index > Pool.Code_Top then raise Code_Range_Error; end if;
		return Get_Code_Word_Address_Unsafe(Pool, Index);
	end Get_Code_Word_Address;

	function Allocate_Code_Word_Address(Pool : in out Heap; Index : out Positive) return System.Address is
	begin
		Pool.Code_Top := Pool.Code_Top+1;
		Index := Pool.Code_Top;
		return Get_Code_Word_Address_Unsafe (Pool, Pool.Code_Top);
	end Allocate_Code_Word_Address;

	function Storage_Size (Pool : in Heap) return Storage_Count is (Pool.Real_Size);

	procedure Allocate (
		Pool : in out Heap;
		Address : out System.Address;
		Size : in Storage_Count;
		Alignment : in Storage_Count) is
	begin
		Address := mspace_malloc (Pool.Data_MSpace, size_t(Size));
		Put("Alloc: " & Integer_Address'Image(To_Integer(Address)));
		Put_Line(" " & Storage_Count'Image(Size));
		if Address = NULL_ADDR then raise Memory_Allocation_Error; end if;
		Memory_Map.Insert(Pool.Allocated, Address, False);
	end Allocate;

	overriding
	procedure Deallocate (
		Pool : in out Heap;
		Address : in System.Address;
		Size : in Storage_Count;
		Alignment : in Storage_Count) is
	begin
		mspace_free (Pool.Data_MSpace, Address);
		Memory_Map.Delete(Pool.Allocated, Address);
	end Deallocate;

end LibBFCD.Memory_Manager;

