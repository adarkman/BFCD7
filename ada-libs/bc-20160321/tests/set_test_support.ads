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
with BC.Containers.Sets;
with BC.Containers.Sets.Bounded;
with BC.Containers.Sets.Dynamic;
with BC.Containers.Sets.Unbounded;
with BC.Containers.Sets.Unmanaged;
with BC.Support.Standard_Storage;
with Global_Heap;

package Set_Test_Support is

   package Containers is new BC.Containers (Item => Character);

   package Sets is new Containers.Sets;

   function Char_Hash (C : Character) return Natural;

   package SB is new Sets.Bounded
     (Hash => Char_Hash,
      Buckets => 3,
      Maximum_Size => 100);

   package SD is new Sets.Dynamic
     (Hash => Char_Hash,
      Buckets => 3,
      Storage => Global_Heap.Storage);

   package SU is new Sets.Unbounded
     (Hash => Char_Hash,
      Buckets => 3,
      Storage => BC.Support.Standard_Storage.Pool);

   package SUM is new Sets.Unmanaged
     (Hash => Char_Hash,
      Buckets => 3);

end Set_Test_Support;
