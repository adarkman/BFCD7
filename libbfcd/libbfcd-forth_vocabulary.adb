with Ada.Text_IO; use Ada.Text_IO;

package body LibBFCD.Forth_Vocabulary is

	function Create_Vocabulary (Pool : in out Heap; Name : in Forth_String) return access Vocabulary is
		pragma Default_Storage_Pool(Pool);
		voc : access Vocabulary := new Vocabulary;
		vname : access Forth_String := new Forth_String'(Name);
	begin
		Put_Line ("Create_Vocabulary");
		voc.Name := vname;
		voc.next := null;
		return voc;
	end Create_Vocabulary;

end LibBFCD.Forth_Vocabulary;

