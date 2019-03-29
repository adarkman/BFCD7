--  Copyright 2009 Simon Wright <simon@pushface.org>

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
--
--  Non-simple item kinds for tests.

package Tests.Support is

   type Item is record
      C : Character;
      I : Integer;
   end record;

   function "=" (L, R : Item) return Boolean;
   --  Compares only the Character components (case-insensitively).

   function "<" (L, R : Item) return Boolean;
   --  Compares only the Character components (case-insensitively).

end Tests.Support;
