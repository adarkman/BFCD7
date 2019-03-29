--  Copyright 1998-2003 Simon Wright <simon@pushface.org>

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
with BC.Containers.Queues;
with BC.Containers.Queues.Bounded;
with BC.Containers.Queues.Dynamic;
with BC.Containers.Queues.Unbounded;
with BC.Containers.Queues.Unmanaged;
with BC.Support.Managed_Storage;
with System.Storage_Pools;

package Queues_For_Timing is
   Size : constant := 10;
   package C is new BC.Containers (Integer);
   package Q is new C.Queues;
   package B is new Q.Bounded (Size);
   Pool : BC.Support.Managed_Storage.Pool (10_000);
   Pool_View : System.Storage_Pools.Root_Storage_Pool'Class
     renames System.Storage_Pools.Root_Storage_Pool'Class (Pool);
   package D is new Q.Dynamic (Pool_View);
   package M is new Q.Unmanaged;
   package U is new Q.Unbounded (Pool_View);
end Queues_For_Timing;
