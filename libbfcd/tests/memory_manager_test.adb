with LibBFCD.Memory_Manager; use LibBFCD.Memory_Manager;
with LibBFCD.Code_Types; use LibBFCD.Code_Types;
with LibBFCD.Forth_Vocabulary; use LibBFCD.Forth_Vocabulary;
with System.Storage_Elements;
with LibBFCD.VM_Thread; use LibBFCD.VM_Thread;
with LibBFCD.Stacks;
with LibBFCD; use LibBFCD;
with Ada.Text_IO; use Ada.Text_IO;

procedure Memory_Manager_Test is
	use type System.Storage_Elements.Storage_Offset;
	Pool : aliased Heap;
	Pool_1 : aliased Heap;
	pragma Default_Storage_Pool(Pool);
	v1 : access Vocabulary;
	s : access Forth_String;
	type FDW_Ptr is access Forth_Data_Word with Storage_Pool => Pool;
	package Simple_Stack is new Stacks (FDW_Ptr);
	use Simple_Stack;
	Stack : Simple_Stack.Stack;
	fw : FDW_Ptr ;
begin
	--Init_Global_Memory_Pool(1024*1024,1024*1024);
	--Init_Local_Memory_Pool(Pool, 1024*1024, 1024*1024);
	Create_Local_Memory_Pool(Pool, 1024*1024,1024*1024);
	--Create_Local_Memory_Pool(Pool_1, 1024*1024,1024*1024);
	Create (Stack, Pool);
	fw := new Forth_Data_Word;
	Push(Stack, Pool, fw);
	fw := Pop(Stack, Pool);
	declare
		t1 : Forth_Thread (Pool'Access);
	begin
		t1.Test;
	end;
	s := new Forth_String'("FORTH !!!");
	v1 := new Vocabulary;
	--Resize_Pool (Pool, 1024*1024*2);
	v1 := Create_Vocabulary (Pool, "FORTH");
	Put("Memory_Manager test: ");
	if (Global_Allocs /= 9) or (Global_Deallocs /= 1) then
		Put_Line("FAILED");
	else
		Put_Line("OK");
	end if;
end Memory_Manager_Test;

