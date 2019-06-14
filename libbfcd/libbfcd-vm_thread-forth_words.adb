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

	--
	-- Low Level Forth Words
	--
	procedure Add_Integer(Pool : in out Memory_Manager.Heap; Data_Address : System.Address) is
		pragma Default_Storage_Pool (Pool);
		Data : Therad_Data_Ptr := Convert(Data_Address);
		a,b : Integer;
		res : Forth_Data_Word_Ptr := new Forth_Data_Word(Type_Integer);
	begin
		a := Pop(Data.DStack, Pool);
		b := Pop(Data.DStack, Pool);
		if a.Data_Type /= Type_Integer or b.Data_Type /= Type_Integer  then raise Type_Error; end if;
		res.int := a.int + b.int;
		Push(Data.DStack, Pool, res);
	end Add_Integer;

	procedure Minus_Integer(Pool : in out Memory_Manager.Heap; Data_Address : System.Address) is
		pragma Default_Storage_Pool (Pool);
		Data : Therad_Data_Ptr := Convert(Data_Address);
		a,b : Integer;
		res : Forth_Data_Word_Ptr := new Forth_Data_Word(Type_Integer);
	begin
		a := Pop(Data.DStack, Pool);
		b := Pop(Data.DStack, Pool);
		if a.Data_Type /= Type_Integer or b.Data_Type /= Type_Integer  then raise Type_Error; end if;
		res.int := b.int - a.int;
		Push(Data.DStack, Pool, res);
	end Minus_Integer;

end LibBFCD.VM_Thread.Forth_Words;

