-- LibBFCD.Vocabulary - Forth Vocabulary
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD.Memory_Manager;	use LibBFCD.Memory_Manager;
with LibBFCD.Code_Types;		use LibBFCD.Code_Types;
with LibBFCD.Global_Data;

package LibBFCD.Forth_Vocabulary is

	function Create_Vocabulary (Pool : in out Heap; Name : in Forth_String) return access Vocabulary;

	--
	-- Add low level Forth Word to Vocabulary
	--
	procedure Add(v : access Vocabulary; word : Binary_Word_Ptr);

private	
	
	--
	-- Add allocated Code_Word to Vocabulary
	--
	procedure Add(v : access Vocabulary; word : Code_Word_Ptr);

end LibBFCD.Forth_Vocabulary;

