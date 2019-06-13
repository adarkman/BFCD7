-- LibBFCD.Stacks - Stacks in Memory_Manager pools
-- (C) Hell Design 2019
-- Author: Alexandr Darkman

with LibBFCD; use LibBFCD;
with LibBFCD.Memory_Manager;
with Ada.Containers.Ordered_Maps;

generic 
	type Item_Type is private;
package LibBFCD.Stacks is

	-- Реализация стека не типична.
	-- Стек сделан на двухсвязном списке для возможности быстрой передачи слайсов
	-- между стеками.

	Stack_Is_Empty : exception;
	Stack_Index_Error : exception;

	Pool : Memory_Manager.Heap;

	type Stack_Element is private;
	type Stack is private;

	procedure Create(S : in out Stack; lPool : in out Memory_Manager.Heap);

	procedure Push (S : in out Stack; lPool: in out Memory_Manager.Heap; Item : Item_Type);
	function Pop (S : in out Stack; lPool : in out Memory_Manager.Heap) return Item_Type;
	function Top (S : Stack) return Item_Type;
	function Nth (S : Stack; Index : Positive) return Item_Type; -- Index считается сверху стека
	function Rot (S : in out Stack) return Item_Type; -- Forth ROT
	function mRot (S : in out Stack) return Item_Type; -- Forth -ROT

	function Size (S : Stack) return Natural;

private
	
	type Stack_Element is record
		Item : Item_Type;
		Next : access Stack_Element := null;
		Prev : access Stack_Element := null;
	end record;
	--
	-- Не использовать без необходимости, и только там где без него "край".
	-- (в основном используется для гашения 'warning: accessibility check failure') 
	-- Пока есть возможность - декларировать локальный _Ptr тип.
	--
	type Stack_Element_Internal_Ptr is access all Stack_Element;
	type Stack_Element_Ptr is access all Stack_Element with Storage_Pool => Pool;
	--

	type Stack is record
		Start, Top : Stack_Element_Ptr;
		Size : Natural := 0;
	end record;

	procedure Free_Element(lPool: in out Memory_Manager.Heap; Element : access Stack_Element);

end LibBFCD.Stacks;

