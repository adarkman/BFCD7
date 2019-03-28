-- LibBFCD.VM_Thread - Forth VM exec/compile thread
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD; use LibBFCD;
with LiBBFCD.Memory_Manager;
with LibBFCD.Code_Types; use LibBFCD.Code_Types;
with LiBBFCD.Forth_Vocabulary; use LiBBFCD.Forth_Vocabulary;

package LibBFCD.VM_Thread is

	task type Forth_Thread (Pool : access Memory_Manager.Heap) is
		entry Test;
	end Forth_Thread;

end LibBFCD.VM_Thread;
