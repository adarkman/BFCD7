with Ada.Text_IO; use Ada.Text_IO;

package body LibBFCD.Forth_Vocabulary is

	function Create_Vocabulary (Pool : in out Heap; Name : in Wide_String) return Vocabulary_Ptr is
		--pragma Default_Storage_Pool(Pool);
		voc : Vocabulary_Ptr := new (Pool) Vocabulary;
	begin
		Put_Line ("Create_Vocabulary");
		voc.Name := new (Pool) Wide_String'(Name);
		return voc;
	end Create_Vocabulary;

end LibBFCD.Forth_Vocabulary;

