--  Copyright 1998 Pat Rogers

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

with BC.Support.Managed_Storage;
with System.Storage_Pools;

package Global_Heap is

   subtype Pool is BC.Support.Managed_Storage.Pool;
   Storage_Pool : Pool (Chunk_Size => 1024);

   Storage : System.Storage_Pools.Root_Storage_Pool'Class
     renames System.Storage_Pools.Root_Storage_Pool'Class (Storage_Pool);

end Global_Heap;
