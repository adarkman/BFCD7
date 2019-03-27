-- LibBFCD.Vocabulary - Forth Vocabulary
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD.Memory_Manager;	use LibBFCD.Memory_Manager;
with LibBFCD.Code_Types;		use LibBFCD.Code_Types;
--with LibBFCD.Global_Data;

package LibBFCD.Vocabulary is

	type Vocabulary is limited private;
	type Vocabulary_Ptr is access Vocabulary;
	--for Vocabulary_Ptr'Storage_Pool use LibBFCD.Global_Data.Pool;

	function Create (Name : in Wide_String) return Vocabulary_Ptr;

private	

	type Element is record
		word : access Code_Word;
		next : access Element;
	end record;
	type Element_Ptr is access Element;
	--for Element_Ptr'Storage_Pool use LibBFCD.Global_Data.Pool;

	type Vocabulary is record
		Name : access Wide_String;
		first : Element_Ptr;
	end record;

end LibBFCD.Vocabulary;

