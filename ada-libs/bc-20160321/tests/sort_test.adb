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

with Ada.Text_IO;
with BC.Containers.Shellsort;
with BC.Containers.Quicksort;
with Collection_Test_Support;

procedure Sort_Test is

   use Ada.Text_IO;
   use Collection_Test_Support;
   use Containers;

   procedure Add (To : in out CB.Collection; S : String);
   procedure Print (C : Container'Class);

   procedure Print (C : Container'Class) is
      procedure Process (C : Character; OK : out Boolean);
      procedure Process (C : Character; OK : out Boolean) is
      begin
         Put (C);
         OK := True;
      end Process;
      procedure Iterate is new Visit (Apply => Process);
      Iter : Iterator'Class := New_Iterator (C);
   begin
      Put ("|");
      Iterate (Using => Iter);
      Put_Line ("|");
   end Print;

   procedure SSort is new Containers.Shellsort
     (Container => CB.Collection,
      Length => CB.Length);

   procedure Reverse_SSort is new Containers.Shellsort
     (Container => CB.Collection,
        "<" => ">",
      Length => CB.Length);

   procedure QSort is new Containers.Quicksort
     (Container => CB.Collection,
      Length => CB.Length);

   procedure Reverse_QSort is new Containers.Quicksort
     (Container => CB.Collection,
        "<" => ">",
      Length => CB.Length);

   C : CB.Collection;

   procedure Add (To : in out CB.Collection; S : String) is
   begin
      for Ch in S'Range loop
         CB.Append (To, S (Ch));
      end loop;
   end Add;

begin

   Put_Line ("Shellsort:");

   CB.Clear (C);

   Add (C, "holy_moses");
   SSort (C);
   Print (C);
   Reverse_SSort (C);
   Print (C);

   New_Line;

   Add (C, "take_a_look");
   SSort (C);
   Print (C);
   Reverse_SSort (C);
   Print (C);

   New_Line;
   Put_Line ("equal keys, starting from empty");

   CB.Clear (C);
   SSort (C);
   Print (C);

   Add (C, "a");
   SSort (C);
   Print (C);

   Add (C, "a");
   SSort (C);
   Print (C);

   Add (C, "a");
   SSort (C);
   Print (C);

   Add (C, "a");
   SSort (C);
   Print (C);

   New_Line;
   Put_Line ("length 2");
   CB.Clear (C);
   Add (C, "b");
   Add (C, "a");
   SSort (C);
   Print (C);
   Reverse_SSort (C);
   Print (C);

   New_Line;

   Put_Line ("Quicksort:");

   CB.Clear (C);

   Add (C, "holy_moses");
   QSort (C);
   Print (C);
   Reverse_QSort (C);
   Print (C);

   New_Line;

   Add (C, "take_a_look");
   QSort (C);
   Print (C);
   Reverse_QSort (C);
   Print (C);

   New_Line;
   Put_Line ("equal keys, starting from empty");

   CB.Clear (C);
   QSort (C);
   Print (C);

   Add (C, "a");
   QSort (C);
   Print (C);

   Add (C, "a");
   QSort (C);
   Print (C);

   Add (C, "a");
   QSort (C);
   Print (C);

   Add (C, "a");
   QSort (C);
   Print (C);

   New_Line;
   Put_Line ("length 2");
   CB.Clear (C);
   Add (C, "b");
   Add (C, "a");
   QSort (C);
   Print (C);
   Reverse_QSort (C);
   Print (C);

end Sort_Test;
