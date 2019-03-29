--  Copyright 1998-2014 Simon Wright <simon@pushface.org>

--  This package is free software; you can redistribute it and/or
--  modify it under terms of the GNU General Public License as
--  published by the Free Software Foundation; either version 2, or
--  (at your option) any later version. This package is distributed in
--  the hope that it will be useful, but WITHOUT ANY WARRANTY; without
--  even the implied warranty of MERCHANTABILITY or FITNESS FOR A
--  PARTICULAR PURPOSE. See the GNU General Public License for more
--  details. You should have received a copy of the GNU General Public
--  License distributed with this package; see file COPYING.  If not,
--  write to the Free Software Foundation, 59 Temple Place - Suite
--  330, Boston, MA 02111-1307, USA.

with BC.Containers;
with BC.Containers.Trees;
with BC.Containers.Trees.AVL;
with BC.Containers.Trees.AVL.Print;
with BC.Containers.Trees.AVL.Validate;
with Global_Heap;

package AVL_Test_Support is

   type Key is range 0 .. 1023;

   type Item is record
      K : Key;
      Count : Integer := 0;
   end record;

   function "=" (L, R : Item) return Boolean;
   function "<" (L, R : Item) return Boolean;
   function Image (Val : Item) return String;

   package Containers is new BC.Containers (Item => Item);

   package Trees is new Containers.Trees;

   package TA is new Trees.AVL (Storage => Global_Heap.Storage);

   procedure Print is new TA.Print (Image => Image);

   procedure Validate is new TA.Validate;

end AVL_Test_Support;
