package body LibBFCD.VM_Thread.Forth_Words is

	procedure Real_Call (Pool : in out Memory_Manager.Heap; Data : Thread_Data_Ptr; operator: Binary_Word_Ptr) is
		addr : System.Address := Thread_Data_Access.To_Address(Data);
	begin
		operator.all(Pool, addr);
	end Real_Call;

	function Convert(ptr : System.Address) return Thread_Data_Ptr is
	begin
		return Thread_Data_Ptr(Thread_Data_Access.To_Pointer(ptr));
	end Convert;

end LibBFCD.VM_Thread.Forth_Words;

