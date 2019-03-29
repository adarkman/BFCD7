
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

--  This program demonstrates the use of user-defined equality for Map
--  keys.  User_Map_Support defines maps keyed by characters where
--  equality is case-independent.

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with User_Map_Support;

procedure User_Map is

   use Ada.Strings.Unbounded;
   use Ada.Text_IO;
   use User_Map_Support;

   function "+" (S : String) return Unbounded_String
     renames To_Unbounded_String;
   function "-" (S : Unbounded_String) return String
     renames To_String;

   procedure Print_Map (M : in out Maps.Abstract_Map'Class; Named : String);
   procedure Print_Map (M : in out Maps.Abstract_Map'Class; Named : String) is
      procedure Print
        (Key : User_Character; Item : Unbounded_String; OK : out Boolean);
      procedure Print
        (Key : User_Character; Item : Unbounded_String; OK : out Boolean) is
      begin
         Put (" " & Character (Key) & "=>" & (-Item));
         OK := True;
      end Print;
      procedure Visitor is new Maps.Visit (Print);
      It : Maps.Map_Iterator'Class
        := Maps.Map_Iterator'Class (Maps.New_Iterator (M));
   begin
      Put ("Map " & Named & " ");
      Visitor (It);
      New_Line;
   end Print_Map;

   procedure Test (M : in out Maps.Abstract_Map'Class);
   procedure Test (M : in out Maps.Abstract_Map'Class) is
   begin
      Maps.Bind (M, 'a', +"a");
      Maps.Bind (M, 'B', +"B");
      Maps.Bind (M, '1', +"1");
      Maps.Bind (M, '2', +"2");
      if not Maps.Is_Bound (M, 'A') then
         Maps.Bind (M, 'A', +"A");
      end if;
      if not Maps.Is_Bound (M, 'b') then
         Maps.Bind (M, 'b', +"b");
      end if;
      Print_Map (M, "M");
      Maps.Unbind (M, 'A');
      Maps.Unbind (M, 'b');
      Print_Map (M, "M");
   end Test;

   B : MB.Map;
   D : MD.Map;
   U : MU.Map;

begin
   Put_Line ("Hash of 'a' is " & Integer'Image (User_Char_Hash ('a')));
   Put_Line ("Hash of 'A' is " & Integer'Image (User_Char_Hash ('A')));
   Put_Line ("Bounded map:");
   Test (B);
   Put_Line ("Dynamic map:");
   Test (D);
   Put_Line ("Unbounded map:");
   Test (U);
end User_Map;
