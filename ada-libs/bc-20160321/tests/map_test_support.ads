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
with BC.Containers.Maps;
with BC.Containers.Maps.Bounded;
with BC.Containers.Maps.Dynamic;
with BC.Containers.Maps.Unbounded;
with BC.Containers.Maps.Unmanaged;
with BC.Support.Standard_Storage;
with Chunks;
with Global_Heap;

package Map_Test_Support is

   package Containers is new BC.Containers
     (Item => Chunks.Chunk_Ptr, "=" => Chunks."=");

   package Maps is new Containers.Maps (Key => Character);

   function Char_Hash (C : Character) return Natural;

   package MB is new Maps.Bounded
     (Hash => Char_Hash,
      Buckets => 3,
      Maximum_Size => 100);

   package MD is new Maps.Dynamic
     (Hash => Char_Hash,
      Buckets => 3,
      Storage => Global_Heap.Storage);

   package MU is new Maps.Unbounded
     (Hash => Char_Hash,
      Buckets => 3,
      Storage => BC.Support.Standard_Storage.Pool);

   package MUM is new Maps.Unmanaged
     (Hash => Char_Hash,
      Buckets => 3);
   Gitems : array (1 .. 7) of aliased Chunks.Chunk;

end Map_Test_Support;
