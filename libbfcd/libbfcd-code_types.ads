-- LibBFCD.Code_Types - BFCD Compiler data types
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Address_To_Access_Conversions;
with Ada.Containers;
with System.Storage_Elements; use System.Storage_Elements;
with LibBFCD; use LibBFCD;
with LibBFCD.Memory_Manager;

package LibBFCD.Code_Types is

	--
	-- Forth Word types
	--
	type Binary_Word_Ptr is access procedure (Pool : in out Memory_Manager.Heap; Data_Address : System.Address);

	type Forth_String is new Wide_String;
	function AllocateF(Pool : in out Memory_Manager.Heap; str : in Forth_String) return access Forth_String;

	type Forth_Data_Type is (Type_Integer, Type_String, Type_Double, Type_Code, Type_Vocabulary);

	--
	-- Forth Vocabulary data --
	--
	type Code_Word;
	type Vocabulary_Element is record
		word : access Code_Word;
		next : access all Vocabulary_Element;
	end record;

	--type Vocabulary_ID is new Positive;
	protected type Vocabulary is
		entry Create (lPool : in out Memory_Manager.Heap; lName : in Forth_String);
	private
		Inited : Boolean := False;
		Pool : Memory_Manager.Heap;
		Name : access Forth_String;
		elements, top : access Vocabulary_Element;
		next : access Vocabulary;
	end Vocabulary;

	--
	-- Forth Word with Data
	-- 
	type Forth_Data_Word(Data_Type : Forth_Data_Type := Type_Double) is record
		case Data_Type is
			when Type_Integer =>
				int : Integer;
			when Type_String =>
				str : access Wide_String;
			when Type_Double =>
				float : Long_Float;
			when Type_Code =>
				code : access Code_Word;
			when Type_Vocabulary =>
				voc : access Vocabulary;
		end case;
	end record;

	--
	-- Forth Code
	--
	type Word_Type is (Binary_Word, Data_Word, Forth_Word);
	type Code_Word_Flags is (None, Immediate);
		for Code_Word_Flags use (None => 0, Immediate => 1);

	-- Code_Word must have default discriminant value for 
	-- array of Code_Word can be declared
	type Code_Word (Data_Type : Word_Type := Data_Word) is record
		Index : Natural := 0;
		Name : access Wide_String;
		Name_Hash : Ada.Containers.Hash_Type;
		Help : access Wide_String;
		Flags : Code_Word_Flags;
		case Data_Type is
			when Binary_Word =>
				operator : Binary_Word_Ptr;
			when Data_Word =>
				data : access Forth_Data_Word;
			when Forth_Word =>
				code : access all Code_Word;
		end case;
	end record;

	package Code_Word_Access is new System.Address_To_Access_Conversions (Object => Code_Word);
	subtype Code_Word_Ptr is Code_Word_Access.Object_Pointer;

	procedure Create_Local_Memory_Pool (Pool: in out Memory_Manager.Heap; Code_Size, Data_Size : Storage_Count);

	function Get_Code_Word(Pool : in out Memory_Manager.Heap; Index : in Positive) return Code_Word_Ptr;
	function Allocate_Code_Word(Pool : in out Memory_Manager.Heap; Data_Type : in Word_Type) return Code_Word_Ptr;

private

	Code_Word_Size : constant Positive := (if (Code_Word'Size rem 8) = 0 
											then (Code_Word'Size/8)
											else (Code_Word'Size/8+1));
	function Get_Code_Word_Unsafe(Pool : in out Memory_Manager.Heap; Index : in Natural) return Code_Word_Ptr;

end LibBFCD.Code_Types;

