with Ada.Text_IO; use Ada;
with Ada.Wide_Text_IO; 

package body LibBFCD.Forth_Vocabulary is

	function Create_Vocabulary (Pool : in out Heap; Name : in Forth_String) return access Vocabulary is
		pragma Default_Storage_Pool(Pool);
		voc : access Vocabulary := new Vocabulary;
		vname : access Forth_String := new Forth_String'(Name);
	begin
		Text_IO.Put("Create_Vocabulary ");
		Wide_Text_IO.Put_Line(Wide_String(Name));
		voc.Create (Pool, Name);
		return voc;
	end Create_Vocabulary;

	procedure Add(v : access Vocabulary; word : Code_Word_Ptr) is
		element : Vocabulary_Element_Ptr;
	begin
		v.Allocate_Element (element);
		element.word := word;
		v.Add (element);
	end Add;

	procedure Add(v : access Vocabulary; word : Binary_Word_Ptr) is
		pool : Memory_Manager.Heap;
		code : Code_Word_Ptr;
	begin
		v.Link_Pool_To (pool);
		code := Allocate_Code_Word (pool, Binary_Word);
		code.operator := word;
		Add (v, code);
	end Add;

end LibBFCD.Forth_Vocabulary;

