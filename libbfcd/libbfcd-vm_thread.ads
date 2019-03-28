-- LibBFCD.VM_Thread - Forth VM exec/compile thread
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD; use LibBFCD;
with LiBBFCD.Memory_Manager;
with LibBFCD.Code_Types;
with LiBBFCD.Forth_Vocabulary;

package LibBFCD.VM_Thread is

	protected type Compiler is
		procedure Init(aPool : Memory_Manager.Heap); 
	private
		Pool : Memory_Manager.Heap;
	end Compiler;

end LibBFCD.VM_Thread;
