-- LibBFCD.Code_Types - BFCD Compiler data types
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

package LibBFCD.Code_Types is

	type Word_Type is (Binary_Word, Data_Word, Forth_Word);

	-- Code_Word must have default discriminant value for 
	-- array of Code_Word can be declared
	type Code_Word (Data_Type : Word_Type := Data_Word) is record
		case Data_Type is
			when Binary_Word =>
				operator : Integer;
			when Data_Word =>
				data : access all Code_Word;
			when Forth_Word =>
				code : Integer;
		end case;
	end record;
	type Code_Word_Ptr is access all Code_Word;

end LibBFCD.Code_Types;
