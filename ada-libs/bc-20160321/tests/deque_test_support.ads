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
with BC.Containers.Deques;
with BC.Containers.Deques.Bounded;
with BC.Containers.Deques.Dynamic;
with BC.Containers.Deques.Unbounded;
with BC.Containers.Deques.Unmanaged;
with BC.Support.Standard_Storage;
with Global_Heap;

package Deque_Test_Support is

   package Containers is new BC.Containers (Item => Character);

   package Deques is new Containers.Deques;

   package DB is new Deques.Bounded
     (Maximum_Size => 100);

   package DD is new Deques.Dynamic
     (Storage => Global_Heap.Storage);

   package DU is new Deques.Unbounded
     (Storage => BC.Support.Standard_Storage.Pool);

   package DUM is new Deques.Unmanaged;

end Deque_Test_Support;
