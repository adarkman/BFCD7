
--  Copyright 2002 Simon Wright <simon@pushface.org>

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

with Ada.Strings.Unbounded;
with BC.Containers.Maps.Unbounded;
with BC.Support.Standard_Storage;

package Configuration_Demo_Support is

   package Abstract_String_Containers is new BC.Containers
     (Item => Ada.Strings.Unbounded.Unbounded_String,
      "=" => Ada.Strings.Unbounded."=");

   package Abstract_String_Maps
   is new Abstract_String_Containers.Maps
     (Key => Ada.Strings.Unbounded.Unbounded_String,
      "=" => Ada.Strings.Unbounded."=");

   function Hash (S : Ada.Strings.Unbounded.Unbounded_String) return Natural;

   package String_Maps
   is new Abstract_String_Maps.Unbounded
     (Hash => Hash,
      Buckets => 43,
      Storage => BC.Support.Standard_Storage.Pool);

end Configuration_Demo_Support;
