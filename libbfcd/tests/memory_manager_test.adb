with LibBFCD.Memory_Manager; use LibBFCD.Memory_Manager;
with LibBFCD.Code_Types; use LibBFCD.Code_Types;
with LibBFCD.Forth_Vocabulary; use LibBFCD.Forth_Vocabulary;
with System.Storage_Elements;

procedure Memory_Manager_Test is
	use type System.Storage_Elements.Storage_Offset;
	pragma Default_Storage_Pool(LibBFCD.Code_Types.Pool);
	v1 : access Vocabulary;
	s : Forth_String_Ptr;
begin
	Init_Global_Memory_Pool(1024*1024,1024*1024);
	s := new Forth_String'("FORTH");
	v1 := new Vocabulary;
	v1 := Create_Vocabulary (LibBFCD.Code_Types.Pool, "FORTH");
end Memory_Manager_Test;

