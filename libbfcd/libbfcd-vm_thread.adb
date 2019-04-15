
package body LibBFCD.VM_Thread is

	task body Forth_Thread is
		v1 : access Vocabulary;
		Data : Thread_Data_Ptr := Create_Thread_Data (Pool.all);
	begin
		Init_Global_Vocabulary(Pool.all);
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

	procedure Init_Global_Vocabulary (Pool : in out Memory_Manager.Heap) is
	begin
		if Main_Vocabulary = null then
			Main_Vocabulary := Create_Vocabulary (Pool, Main_Vocabulary_Name);
		end if;
	end Init_Global_Vocabulary;

end LibBFCD.VM_Thread;

