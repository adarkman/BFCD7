--  Copyright 1994 Grady Booch
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
with BC.Containers.Stacks;
with BC.Containers.Stacks.Bounded;
with BC.Containers.Stacks.Dynamic;
with BC.Containers.Stacks.Unbounded;
with BC.Containers.Stacks.Unmanaged;
with BC.Support.Standard_Storage;
with Global_Heap;

package Stack_Test_Support is

   package Containers is new BC.Containers (Item => Character);

   package Stacks is new Containers.Stacks;

   package SB is new Stacks.Bounded
     (Maximum_Size => 100);

   package SD is new Stacks.Dynamic
     (Storage => Global_Heap.Storage);

   package SU is new Stacks.Unbounded
     (Storage => BC.Support.Standard_Storage.Pool);

   package SUM is new Stacks.Unmanaged;

end Stack_Test_Support;
