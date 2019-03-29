--  Copyright 1998-2002 Simon Wright <simon@pushface.org>

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

--  This program demonstrates the use of user-defined equality for
--  Sets.  User_Set_Support defines sets of characters where equality
--  is case-independent.

with Ada.Text_IO;
with User_Set_Support;

procedure User_Set is

   use Ada.Text_IO;
   use User_Set_Support;

   procedure Print_Set (S : in out Sets.Abstract_Set'Class; Named : String);
   procedure Print_Set (S : in out Sets.Abstract_Set'Class; Named : String) is
      procedure Print (Item : User_Character; OK : out Boolean);
      procedure Print (Item : User_Character; OK : out Boolean) is
      begin
         Put (" " & Character (Item));
         OK := True;
      end Print;
      procedure Visitor is new Containers.Visit (Print);
      It : Containers.Iterator'Class
        := Containers.New_Iterator (Containers.Container'Class (S));
   begin
      Put ("Set " & Named & " ");
      Visitor (It);
      New_Line;
   end Print_Set;

   procedure Test (S : in out Sets.Abstract_Set'Class);
   procedure Test (S : in out Sets.Abstract_Set'Class) is
   begin
      Sets.Add (S, 'a');
      Sets.Add (S, 'B');
      Sets.Add (S, '1');
      Sets.Add (S, '2');
      if not Sets.Is_Member (S, 'A') then
         Sets.Add (S, 'A');
      end if;
      if not Sets.Is_Member (S, 'b') then
         Sets.Add (S, 'b');
      end if;
      Print_Set (S, "S");
      Sets.Remove (S, 'A');
      Sets.Remove (S, 'b');
      Print_Set (S, "S");
   end Test;

   B : SB.Set;
   D : SD.Set;
   U : SU.Set;

begin
   Put_Line ("Hash of 'a' is " & Integer'Image (User_Char_Hash ('a')));
   Put_Line ("Hash of 'A' is " & Integer'Image (User_Char_Hash ('A')));
   Put_Line ("Bounded set:");
   Test (B);
   Put_Line ("Dynamic set:");
   Test (D);
   Put_Line ("Unbounded set:");
   Test (U);
end User_Set;
