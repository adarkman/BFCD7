with LibBFCD.Memory_Manager; use LibBFCD.Memory_Manager;
with LibBFCD.Code_Types; use LibBFCD.Code_Types;
with LibBFCD.Forth_Vocabulary; use LibBFCD.Forth_Vocabulary;
With LibBFCD.Global_Data;
with System.Storage_Elements;

procedure Memory_Manager_Test is
	package Globals renames LibBFCD.Global_Data;
	use type System.Storage_Elements.Storage_Offset;
	pragma Default_Storage_Pool(Globals.Pool);
	v1 : access Vocabulary;
	s : access Wide_String;
begin
	Init(Globals.Pool,1024*1024,1024*1024);
	s := new Wide_String'("");
	v1 := new Vocabulary;
	v1 := Create_Vocabulary (Globals.Pool, "");
end Memory_Manager_Test;

