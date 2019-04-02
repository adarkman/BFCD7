-- LibBFCD.VM_Thread - Forth VM exec/compile thread
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD; use LibBFCD;
with LiBBFCD.Memory_Manager;
with LibBFCD.Code_Types; use LibBFCD.Code_Types;
with LiBBFCD.Forth_Vocabulary; use LiBBFCD.Forth_Vocabulary;
with LibBFCD.Stacks;

package LibBFCD.VM_Thread is

	type Forth_Data_Word_Ptr is access Forth_Data_Word;
	package Data_Stack is new Stacks (Forth_Data_Word_Ptr);
	use Data_Stack;

	task type Forth_Thread (Pool : access Memory_Manager.Heap) is
		entry Test;
	end Forth_Thread;

end LibBFCD.VM_Thread;
