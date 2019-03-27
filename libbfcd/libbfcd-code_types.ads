-- LibBFCD.Code_Types - BFCD Compiler data types
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with System.Address_To_Access_Conversions;
--with Ada.Wide_Strings;	use Ada.Wide_Strings;

package LibBFCD.Code_Types is

	-- Forth Word type
	type Forth_Word_Ptr is access procedure;

	type Word_Type is (Binary_Word, Data_Word, Forth_Word);

	-- Code_Word must have default discriminant value for 
	-- array of Code_Word can be declared
	type Code_Word (Data_Type : Word_Type := Data_Word) is record
		Index : Natural := 0;
		Name : access Wide_String;
		case Data_Type is
			when Binary_Word =>
				operator : Forth_Word_Ptr;
			when Data_Word =>
				data : access all Code_Word;
			when Forth_Word =>
				code : Positive;
		end case;
	end record;

	package Code_Word_Access is new System.Address_To_Access_Conversions (Object => Code_Word);
	subtype Code_Word_Ptr is Code_Word_Access.Object_Pointer;

end LibBFCD.Code_Types;

