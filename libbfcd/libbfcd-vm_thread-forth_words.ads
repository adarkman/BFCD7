-- LibBFCD.Forth_Words - low level forth words
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD; use LibBFCD;
with LibBFCD.Memory_Manager;
with LibBFCD.Code_Types;
with System.Address_To_Access_Conversions;

package LibBFCD.VM_Thread.Forth_Words is

	package Thread_Data_Access is new System.Address_To_Access_Conversions (Object => Thread_Data);
	subtype Thread_Data_Ptr is Thread_Data_Access.Object_Pointer;

	procedure Real_Call (Pool : in out Memory_Manager.Heap; Data : Thread_Data_Ptr; operator: Binary_Word_Ptr);

	--
	-- Low Level Forth Words
	--
	procedure Add_Integer(Pool : in out Memory_Manager.Heap; Data_Address : System.Address); -- +

private

	function Convert(ptr : System.Address) return Thread_Data_Ptr;
	pragma Inline(Convert);

end LibBFCD.VM_Thread.Forth_Words;

