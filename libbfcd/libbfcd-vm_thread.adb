
package body LibBFCD.VM_Thread is

	task body Forth_Thread is
		v1 : access Vocabulary;
	begin
		accept Test do
			v1 := Create_Vocabulary(Pool.all, "AAA");
		end Test;
	end Forth_Thread;

end LibBFCD.VM_Thread;

