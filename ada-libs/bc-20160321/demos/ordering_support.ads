
--  Copyright 1998-2002 Simon Wright <simon@pushface.org>

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

--  $Id$

with BC.Containers;
with BC.Containers.Collections;
with BC.Containers.Collections.Ordered;
with BC.Containers.Collections.Ordered.Unbounded;
with BC.Containers.Queues;
with BC.Containers.Queues.Ordered;
with BC.Containers.Queues.Ordered.Unbounded;
with Global_Heap;

package Ordering_Support is

   type Sortable is record
      Key : Integer;
      Ident : Integer;
   end record;

   function "<" (L, R : Sortable) return Boolean;

   package Containers is new BC.Containers (Item => Sortable);

   package Base_Collections is new Containers.Collections;

   package Collections is new Base_Collections.Ordered;

   package CU is new Collections.Unbounded
     (Storage => Global_Heap.Storage);

   package Base_Queues is new Containers.Queues;

   package Queues is new Base_Queues.Ordered;

   package QU is new Queues.Unbounded (Storage => Global_Heap.Storage);

end Ordering_Support;
