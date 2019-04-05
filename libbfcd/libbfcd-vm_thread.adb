
package body LibBFCD.VM_Thread is

	task body Forth_Thread is
		v1 : access Vocabulary;
		Data : Thread_Data_Ptr := Create_Thread_Data (Pool.all);
	begin
		accept Test do
			v1 := Create_Vocabulary(Pool.all, "AAA");
		end Test;
	end Forth_Thread;

	function Create_Thread_Data(Pool : in out Memory_Manager.Heap) return access Thread_Data is
		pragma Default_Storage_Pool (Pool);
		Data : access Thread_Data := new Thread_Data;
	begin
		Create(Data.DStack, Pool);
		Create(Data.RStack, Pool);
		return Data;
	end Create_Thread_Data;

end LibBFCD.VM_Thread;

