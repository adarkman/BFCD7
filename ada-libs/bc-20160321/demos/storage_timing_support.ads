--  Copyright 2001-2002 Simon Wright <simon@pushface.org>

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

--  $Revision$
--  $Date$
--  $Author$

with BC.Containers.Collections.Bounded;
with BC.Containers.Collections.Dynamic;
with BC.Containers.Collections.Unbounded;
with BC.Support.Managed_Storage;
with BC.Support.Standard_Storage;
with System.Storage_Pools;

package Storage_Timing_Support is

   package Abstract_Containers is new BC.Containers (Integer);
   package Abstract_Collections is new Abstract_Containers.Collections;

   package Bounded_Collections is new Abstract_Collections.Bounded
     (Maximum_Size => 1_000);

   package Dynamic_Collections is new Abstract_Collections.Dynamic
     (Storage => BC.Support.Standard_Storage.Pool,
      Initial_Size => 100);

   Pool : BC.Support.Managed_Storage.Pool (4_000);

   package Managed_Collections is new Abstract_Collections.Unbounded
     (Storage => System.Storage_Pools.Root_Storage_Pool'Class (Pool));

   package Unmanaged_Collections is new Abstract_Collections.Unbounded
     (Storage => BC.Support.Standard_Storage.Pool);

end Storage_Timing_Support;
