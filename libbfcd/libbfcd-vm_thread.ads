-- LibBFCD.VM_Thread - Forth VM exec/compile thread
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD; use LibBFCD;
with LiBBFCD.Memory_Manager;
with LibBFCD.Code_Types; use LibBFCD.Code_Types;
with LiBBFCD.Forth_Vocabulary; use LiBBFCD.Forth_Vocabulary;
with LibBFCD.Stacks;

package LibBFCD.VM_Thread is

	Type_Error : exception;

	type Forth_Data_Word_Ptr is access Forth_Data_Word;
	package Data_Stack is new Stacks (Forth_Data_Word_Ptr);
	use Data_Stack;

	type Thread_Data is private;

	task type Forth_Thread (Pool : access Memory_Manager.Heap) is
		entry Test;
	end Forth_Thread;

private

	type Thread_Data is record
		DStack : Data_Stack.Stack;
		RStack : Data_Stack.Stack;
	end record;
	type Thread_Data_Ptr is access all Thread_Data;

	function Create_Thread_Data(Pool : in out Memory_Manager.Heap) return access Thread_Data;

end LibBFCD.VM_Thread;
