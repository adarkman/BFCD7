
package body LibBFCD.VM_Thread is

	protected body Compiler is
		procedure Init(aPool : Memory_Manager.Heap) is
		begin
			Pool := aPool;
		end Init;
	end Compiler;

end LibBFCD.VM_Thread;

