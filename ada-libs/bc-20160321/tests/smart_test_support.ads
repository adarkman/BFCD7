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

with Ada.Finalization;
with BC.Support.Smart_Pointers.Test_Finalize;

package Smart_Test_Support is

   --  This type is used to test BC.Support.Smart_Pointers. It's
   --  Controlled simply so that we can see when instances are
   --  deleted.
   type T is new Ada.Finalization.Controlled with record
      C : Character;
   end record;
   type P is access T;

   procedure Finalize (The_T : in out T);

   package Smart is new BC.Support.Smart_Pointers (T => T, P => P);
   procedure Smart_Test_Finalize is new Smart.Test_Finalize;

   function Create (Ch : Character) return Smart.Pointer;
   function Value (P : Smart.Pointer) return Character;

   --  Timing tests. Only need one level of controlledness for this.
   type Character_P is access Character;
   package Smart_Characters
   is new BC.Support.Smart_Pointers (T => Character, P => Character_P);

end Smart_Test_Support;
