with System.Address_To_Access_Conversions;
with LibBFCD; use LibBFCD;

package body LibBFCD.Code_Types is

	procedure Create_Local_Memory_Pool (Pool : in out Memory_Manager.Heap; Code_Size, Data_Size : Storage_Count) is
	begin
		Memory_Manager.Create_Pool(Pool, Code_Size, Data_Size, Code_Word_Size);
	end Create_Local_Memory_Pool;

	-- Unsafe version - do not check index range, use only if you know what you do
	function Get_Code_Word_Unsafe(Pool : in out memory_Manager.Heap; Index : in Natural) return Code_Word_Ptr is
	begin
		return Code_Word_Ptr(Code_Word_Access.To_Pointer (Memory_Manager.Get_Code_Word_Address_Unsafe(Pool, Index)));
	end Get_Code_Word_Unsafe;

	function Get_Code_Word(Pool : in out Memory_Manager.Heap; Index : in Positive) return Code_Word_Ptr is
		use type System.Address;
	begin
		return Code_Word_Ptr(Code_Word_Access.To_Pointer(Memory_Manager.Get_Code_Word_Address(Pool, Index)));
	end Get_Code_Word;

	function Allocate_Code_Word(Pool : in out Memory_Manager.Heap; Data_Type : in Word_Type) return Code_Word_Ptr is
		ptr : Code_Word_Ptr;
		word : Code_Word(Data_Type);
	begin
		ptr := Code_Word_Ptr(Code_Word_Access.To_Pointer(Memory_Manager.Allocate_Code_Word_Address (Pool, word.index)));
		ptr.all := word; -- ensure memory initialized
		return ptr;
	end Allocate_Code_Word;

	--
	-- Forth String
	--
	function AllocateF(Pool : in out Memory_Manager.Heap; str : in Forth_String) return access Forth_String is
		pragma Default_Storage_Pool (Pool);
		ptr : access Forth_String := new Forth_String'(str);
	begin
		return ptr;
	end AllocateF;
	--
	-- Vocabulary
	--
	protected body Vocabulary is
		entry Create (lPool : in out Memory_Manager.Heap; lName : in Forth_String) when not Inited is
		begin
			Memory_Manager.Clone (Pool, lPool);
			Name := AllocateF(Pool, lName);
			elements := null;
			top := null;
			next := null;
			Inited := True;
		end Create;
	end Vocabulary;

end LibBFCD.Code_Types;

