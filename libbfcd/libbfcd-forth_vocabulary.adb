with Ada.Text_IO; use Ada.Text_IO;

package body LibBFCD.Forth_Vocabulary is

	function Create_Vocabulary (Pool : in out Heap; Name : in Forth_String) return Vocabulary_Ptr is
		voc : Vocabulary_Ptr := new Vocabulary;
	begin
		Put_Line ("Create_Vocabulary");
		voc.Name := new Forth_String'(Name);
		return voc;
	end Create_Vocabulary;

end LibBFCD.Forth_Vocabulary;

