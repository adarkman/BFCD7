--  Copyright 2001-2014 Simon Wright <simon@pushface.org>

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

with Ada.Text_IO; use Ada.Text_IO;

package body Assertions is

   Failures : Natural := 0;

   procedure Reset is
   begin
      Failures := 0;
   end Reset;

   procedure Assertion (B : Boolean; S : String) is
   begin
      if not B then
         Failures := Failures + 1;
         Put_Line (S);
      end if;
   end Assertion;

   procedure Report is
   begin
      case Failures is
         when 0 =>
            Put_Line ("No failures.");
         when 1 =>
            Put_Line ("One failure.");
         when others =>
            Put_Line (Integer'Image (Failures) & " failures.");
      end case;
   end Report;

end Assertions;
