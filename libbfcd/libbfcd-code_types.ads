-- LibBFCD.Code_Types - BFCD Compiler data types
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Address_To_Access_Conversions;
with Ada.Containers;
with System.Storage_Elements; use System.Storage_Elements;
with LibBFCD; use LibBFCD;
with LibBFCD.Memory_Manager;

package LibBFCD.Code_Types is

	Pool : Memory_Manager.Heap;

	-- Forth Word type
	type Forth_Word_Ptr is access procedure;

	type Forth_String is new Wide_String;
	type Forth_String_Ptr is access all Forth_String 
		with Storage_Pool => Pool;

	type Forth_Data_Type is (Type_Integer, Type_String, Type_Double, Type_Code, Type_Vocabulary);

	type Code_Word;
	
	type Vocabulary_Element is record
		word : access Code_Word;
		next : access all Vocabulary_Element;
	end record;
	type Element_Ptr is access Vocabulary_Element;
	--for Element_Ptr'Storage_Pool use LibBFCD.Global_Data.Pool;

	type Vocabulary_ID is new Positive;
	type Vocabulary is record
		Name : Forth_String_Ptr;
		first : Element_Ptr;
	end record;
	type Vocabulary_Ptr is access all Vocabulary 
		with Storage_Pool => Pool;

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
				voc : Vocabulary_ID;
		end case;
	end record;

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
				operator : Forth_Word_Ptr;
			when Data_Word =>
				data : access Forth_Data_Word;
			when Forth_Word =>
				code : access all Code_Word;
		end case;
	end record;

	package Code_Word_Access is new System.Address_To_Access_Conversions (Object => Code_Word);
	subtype Code_Word_Ptr is Code_Word_Access.Object_Pointer;

	procedure Init_Global_Memory_Pool (Code_Size, Data_Size : Storage_Count);

	function Get_Code_Word(Pool : in out Memory_Manager.Heap; Index : in Positive) return Code_Word_Ptr;
	function Allocate_Code_Word(Pool : in out Memory_Manager.Heap; Data_Type : in Word_Type) return Code_Word_Ptr;

private

	Code_Word_Size : constant Positive := (if (Code_Word'Size rem 8) = 0 
											then (Code_Word'Size/8)
											else (Code_Word'Size/8+1));
	function Get_Code_Word_Unsafe(Pool : in out Memory_Manager.Heap; Index : in Natural) return Code_Word_Ptr;

end LibBFCD.Code_Types;

