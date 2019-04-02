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

	type Stack_Element is private;
	type Stack is private;

	procedure Create(S : in out Stack; Pool : in out Memory_Manager.Heap);

	procedure Push (S : in out Stack; Pool: in out Memory_Manager.Heap; Item : access Item_Type);
	function Pop (S : in out Stack; Pool : in out Memory_Manager.Heap) return access Item_Type;

private
	
	type Stack_Element is record
		Item : access Item_Type;
		Next : access Stack_Element := null;
		Prev : access Stack_Element := null;
	end record;

	type Stack is record
		Start, Top : access Stack_Element;
		Size : Natural := 0;
	end record;

	procedure Free_Element(Pool: in out Memory_Manager.Heap; Element : access Stack_Element);

end LibBFCD.Stacks;

