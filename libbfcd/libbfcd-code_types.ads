-- LibBFCD.Code_Types - BFCD Compiler data types
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Address_To_Access_Conversions;
with Ada.Containers;

package LibBFCD.Code_Types is

	-- Forth Word type
	type Forth_Word_Ptr is access procedure;

	type Forth_Data_Type is (Type_Integer, Type_String, Type_Double, Type_Code, Type_Vocabulary);

	type Code_Word;
	type Vocabulary;
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

end LibBFCD.Code_Types;

