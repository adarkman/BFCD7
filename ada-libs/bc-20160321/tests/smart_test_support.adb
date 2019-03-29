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

with Ada.Text_IO;

package body Smart_Test_Support is

   procedure Finalize (The_T : in out T) is
   begin
      Ada.Text_IO.Put_Line ("finalizing " & The_T.C);
   end Finalize;

   function Create (Ch : Character) return Smart.Pointer is
   begin
      return Smart.Create
        (new T'(Ada.Finalization.Controlled with C => Ch));
   end Create;

   function Value (P : Smart.Pointer) return Character is
   begin
      return Smart.Value (P).C;
   exception
      when Constraint_Error =>
         return 'x';
   end Value;

end Smart_Test_Support;
