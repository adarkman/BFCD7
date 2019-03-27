-- LibBFCD.Vocabulary - Forth Vocabulary
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD.Memory_Manager;	use LibBFCD.Memory_Manager;
with LibBFCD.Code_Types;		use LibBFCD.Code_Types;
with LibBFCD.Global_Data;

package LibBFCD.Forth_Vocabulary is

	--pragma Default_Storage_Pool (LibBFCD.Global_Data.Pool);

	function Create_Vocabulary (Pool : in out Heap; Name : in Wide_String) return Vocabulary_Ptr;

private	

end LibBFCD.Forth_Vocabulary;

