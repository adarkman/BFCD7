with Ada.Unchecked_Deallocation;

package body LibBFCD.Stacks is

	procedure Create(S : in out Stack; Pool : in out Memory_Manager.Heap) is
		pragma Default_Storage_Pool (Pool);
		e : access Stack_Element := new Stack_Element;
	begin
		e.Prev := null;
		e.Next := null;
		e.Item := null;
		S.Start := e;
		S.Top := e;
		S.Size := 0;
	end Create;

	procedure Push (S : in out Stack; Pool: in out Memory_Manager.Heap; Item : access Item_Type) is
		pragma Default_Storage_Pool (Pool);
		e : access Stack_Element := new Stack_Element;
	begin
		e.Prev := S.Top;
		e.Item := Item;
		S.Top.Next := e;
		S.Top := e;
	end Push;

	function Pop (S : in out Stack; Pool : in out Memory_Manager.Heap) return access Item_Type is
		pragma Default_Storage_Pool (Pool);
		Item : access Item_Type;
		cur_top : access Stack_Element := S.Top;
	begin
		if S.Size = 0 then raise Stack_Is_Empty; end if;
		S.Top := cur_top.Prev;
		S.Top.Next := null;
		Item := cur_top.Item;
		Free_Element(Pool, cur_top);
		S.Size := S.Size -1;
		return Item;
	end Pop;

	procedure Free_Element(Pool: in out Memory_Manager.Heap; Element : access Stack_Element) is
		type E_Ptr is access all Stack_Element with Storage_Pool => Pool;
		procedure Free is new Ada.Unchecked_Deallocation (Object => Stack_Element, Name => E_Ptr);
		E : E_Ptr := E_Ptr(Element);
	begin
		Free(E);
	end Free_Element;

end LibBFCD.Stacks;

