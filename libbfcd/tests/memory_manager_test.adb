with LibBFCD.Memory_Manager; use LibBFCD.Memory_Manager;
with LibBFCD.Code_Types; use LibBFCD.Code_Types;
with LibBFCD.Forth_Vocabulary; use LibBFCD.Forth_Vocabulary;
with System.Storage_Elements;
with LibBFCD.VM_Thread; use LibBFCD.VM_Thread;

procedure Memory_Manager_Test is
	use type System.Storage_Elements.Storage_Offset;
	Pool : aliased Heap;
	Pool_1 : aliased Heap;
	pragma Default_Storage_Pool(Pool);
	v1 : access Vocabulary;
	s : access Forth_String;
begin
	--Init_Global_Memory_Pool(1024*1024,1024*1024);
	--Init_Local_Memory_Pool(Pool, 1024*1024, 1024*1024);
	Create_Local_Memory_Pool(Pool, 1024*1024,1024*1024);
	--Create_Local_Memory_Pool(Pool_1, 1024*1024,1024*1024);
	declare
		t1 : Forth_Thread (Pool'Access);
	begin
		t1.Test;
	end;
	v1 := new Vocabulary;
	Resize_Pool (Pool, 1024*1024*2);
	s := new Forth_String'("FORTH !!!");
	v1 := Create_Vocabulary (Pool, "FORTH");
end Memory_Manager_Test;

