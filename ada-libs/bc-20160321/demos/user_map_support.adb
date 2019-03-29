--  Copyright 1999-2002 Simon Wright <simon@pushface.org>

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

with Ada.Characters.Handling;

package body User_Map_Support is

   package ACH renames Ada.Characters.Handling;

   function "=" (L, R : User_Character) return Boolean is
   begin
      return ACH.To_Upper (Character (L)) = ACH.To_Upper (Character (R));
   end "=";

   function User_Char_Hash (C : User_Character) return Natural is
   begin
      return Character'Pos (ACH.To_Upper (Character (C)));
   end User_Char_Hash;

end User_Map_Support;
