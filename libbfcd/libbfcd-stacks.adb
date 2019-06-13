with Ada.Unchecked_Deallocation;
with Ada.Text_IO; use Ada.Text_IO;

package body LibBFCD.Stacks is

	procedure Create(S : in out Stack; lPool : in out Memory_Manager.Heap) is
		e : Stack_Element_Ptr;
	begin
		Memory_Manager.Clone (Child => Pool, Parent => lPool);
		e := new Stack_Element;
		Put_Line("Stack creation ^^^.");
		e.Prev := null;
		e.Next := null;
		--e.Item := null;
		S.Start := e;
		S.Top := e;
		S.Size := 0;
	end Create;

	procedure Push (S : in out Stack; lPool: in out Memory_Manager.Heap; Item : Item_Type) is
		e : Stack_Element_Ptr;
	begin
		Memory_Manager.Clone (Child => Pool, Parent => lPool);
		e := new Stack_Element;
		e.Prev := S.Top;
		e.Item := Item;
		S.Top.Next := e;
		S.Top := e;
		S.Size := S.Size +1;
	end Push;

	function Pop (S : in out Stack; lPool : in out Memory_Manager.Heap) return Item_Type is
		Item : Item_Type;
		cur_top : Stack_Element_Ptr := S.Top;
	begin
		Memory_Manager.Clone (Child => Pool, Parent => lPool);
		if S.Size = 0 then raise Stack_Is_Empty; end if;
		S.Top := cur_top.Prev;
		S.Top.Next := null;
		Item := cur_top.Item;
		Free_Element(Pool, cur_top);
		S.Size := S.Size -1;
		return Item;
	end Pop;

	procedure Free_Element(lPool: in out Memory_Manager.Heap; Element : access Stack_Element) is
		type E_Ptr is access all Stack_Element with Storage_Pool => lPool;
		procedure Free is new Ada.Unchecked_Deallocation (Object => Stack_Element, Name => E_Ptr);
		E : E_Ptr := E_Ptr(Element);
	begin
		Free(E);
	end Free_Element;

	function Top (S : Stack) return Item_Type is (S.Top.Item);

	function Size (S : Stack) return Natural is (S.Size);

	function Nth (S : Stack; Index : Positive) return Item_Type is
		type E_Ptr is access all Stack_Element;
		elem : E_Ptr;
		ci : Positive := 1;
	begin
		if Index > S.Size then raise Stack_Index_Error; end if;
		if Index = 1 then return Top(s); end if;
		elem := E_Ptr(S.Top);
		while ci < Index loop
			elem := E_Ptr(elem.Prev);
			ci := ci +1;
		end loop;
		return elem.Item;
	end Nth;

	function Rot (S : in out Stack) return Item_Type is
		e : Stack_Element_Ptr;
	begin
		e := S.Top.Prev.Prev; -- Nth 3
		-- Изымаем третий элемент
		e.Prev.Next := e.Next; 
		e.Next.Prev := e.Prev;
		-- Добавляем его наверх
		S.Top.Next := e;
		e.Prev := S.Top;
		e.Next := null;
		S.Top := e;
		--
		return S.Top.Item;
	end Rot;

	function mRot (S : in out Stack) return Item_Type is
		e, e3 : Stack_Element_Ptr;
	begin
		e3 := S.Top.Prev.Prev; -- Nth 3
		e := S.Top;
		-- Top => Nth 1
		S.Top := e.Prev;
		S.Top.Next := null;
		-- Вставляем бывший Top перед Nth 3
		e3.Prev.Next := e;
		e.Prev := e3.Prev;
		e.Next := e3;
		e3.Prev := e;
		--
		return S.Top.Item;
	end mRot;

end LibBFCD.Stacks;

