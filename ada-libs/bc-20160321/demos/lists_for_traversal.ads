--  Copyright 1998-2009 Simon Wright <simon@pushface.org>

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

with Ada.Finalization;
with BC.Lists;
with BC.Lists.Single;
with BC.Lists.Double;
with BC.Support.Managed_Storage;
with BC.Support.Smart_Pointers;
with System.Storage_Pools;
package Lists_For_Traversal is
   type T is new Ada.Finalization.Controlled with record
      V : Integer;
   end record;
   type T_P is access T;
   procedure Finalize (The_T : in out T);
   package Smart is new BC.Support.Smart_Pointers (T, T_P);
   subtype P is Smart.Pointer;
   function "=" (L, R : P) return Boolean;
   package L is new BC.Lists (P);
   Pool : BC.Support.Managed_Storage.Pool (10_000);
   Pool_View : System.Storage_Pools.Root_Storage_Pool'Class
     renames System.Storage_Pools.Root_Storage_Pool'Class (Pool);
   package S is new L.Single (Pool_View);
   package D is new L.Double (Pool_View);
end Lists_For_Traversal;
