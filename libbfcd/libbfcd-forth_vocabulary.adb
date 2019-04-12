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
		Clone(voc.Pool, Pool);
		return voc;
	end Create_Vocabulary;

	procedure Add(v : access Vocabulary; word : Code_Word_Ptr) is
		pragma Default_Storage_Pool (v.Pool);
		element : access Vocabulary_Element := new Vocabulary_Element;
	begin
		element.word := word;
		element.next := null;
		if v.elements = null then
			v.elements := element;
			v.top := element;
		else
			v.top.next := element;
			v.top := element;
		end if;
	end Add;

	procedure Add(v : access Vocabulary; word : Binary_Word_Ptr) is
		code : Code_Word_Ptr := Allocate_Code_Word (v.Pool, Binary_Word);
	begin
		code.operator := word;
		Add (v, code);
	end Add;

end LibBFCD.Forth_Vocabulary;

