--  Copyright 1994 Grady Booch
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

with Ada.Exceptions;
with Ada.Text_IO;
with BC;
with Bag_Test_Support;

procedure Bag_Test is

   use Ada.Text_IO;
   use Bag_Test_Support;

   procedure Assertion (B : Boolean; S : String);
   procedure Print_Bag (B : Containers.Container'Class;
                        Named : String);
   pragma Warnings (Off, Print_Bag);
   procedure Test (B1, B2 : in out Bags.Abstract_Bag'Class);
   procedure Test_Active_Iterator (B : in out Bags.Abstract_Bag'Class);
   procedure Test_Passive_Iterator (B : in out Containers.Container'Class);
   procedure Test_Passive_Modifying_Iterator
     (B : in out Containers.Container'Class);

   procedure Assertion (B : Boolean; S : String) is
   begin
      if not B then
         Put_Line (S);
      end if;
   end Assertion;

   procedure Print_Bag (B : Containers.Container'Class;
                        Named : String) is
      procedure Print (Item : Character; OK : out Boolean);
      procedure Print (Item : Character; OK : out Boolean) is
      begin
         Put (" "
              & Item
              & " =>"
              & Positive'Image (Bags.Count (Bags.Abstract_Bag'Class (B),
                                            Item)));
         OK := True;
      end Print;
      procedure Visitor is new Containers.Visit (Print);
      Iter : Containers.Iterator'Class := Containers.New_Iterator (B);
   begin
      Put ("Bag " & Named);
      Visitor (Iter);
      New_Line;
   end Print_Bag;

   procedure Test (B1, B2 : in out Bags.Abstract_Bag'Class) is
   begin
      Assertion (Bags.Is_Empty (B1),
                 "** P01: Bag is not initially empty");
      Assertion (Bags.Extent (B1) = 0,
                 "** P02: Bag Extent is not initially zero");
      Assertion (Bags.Total_Size (B1) = 0,
                 "** P03: Bag Total_Size is not initially zero");
      Bags.Add (B1, '1');
      Bags.Add (B1, '2');
      Bags.Add (B1, '2');
      Bags.Add (B1, '3');
      Assertion (not Bags.Is_Empty (B1), "** P04: Bag is empty");
      Assertion (Bags.Extent (B1) = 3, "** P05: Bag extent is not correct");
      Assertion (Bags.Total_Size (B1) = 4,
                 "** P06: Bag Total_Size is not correct");
      Assertion (Bags.Is_Member (B1, '1'),
                 "** P07: Bag membership is not correct");
      Assertion (Bags.Is_Member (B1, '2'),
                 "** P08: Bag membership is not correct");
      Assertion (Bags.Is_Member (B1, '3'),
                 "** P09: Bag membership is not correct");
      Assertion (Bags.Count (B1, '2') = 2,
                 "** P10: Bag Count is not correct");
      Assertion (Bags.Count (B1, '3') = 1,
                 "** P11: Bag Count is not correct");
      Bags.Clear (B1);
      Assertion (Bags.Is_Empty (B1), "** P12: Bag is not empty");
      Assertion (Bags.Extent (B1) = 0, "** P13: Bag extent is not zero");
      Assertion (Bags.Total_Size (B1) = 0,
                 "** P14: Bag Total_Size is not zero");
      Bags.Add (B1, '4');
      Bags.Add (B1, '5');
      Bags.Add (B1, '6');
      Bags.Add (B1, '5');
      Bags.Add (B1, '6');
      Bags.Add (B1, '6');
      Assertion (not Bags.Is_Empty (B1), "** P15: Bag is empty");
      Assertion (Bags.Extent (B1) = 3, "** P16: Bag extent is not correct");
      Assertion (Bags.Total_Size (B1) = 6,
                 "** P17: Bag Total_Size is not zero");
      Assertion (Bags.Is_Member (B1, '4'),
                 "** P18: Bag membership is not correct");
      Assertion (Bags.Is_Member (B1, '5'),
                 "** P19: Bag membership is not correct");
      Assertion (Bags.Is_Member (B1, '6'),
                 "** P20: Bag membership is not correct");
      Bags.Remove (B1, '4');
      Bags.Remove (B1, '5');
      Assertion (not Bags.Is_Empty (B1), "** P21: Bag is empty");
      Assertion (Bags.Extent (B1) = 2, "** P22: Bag extent is not correct");
      Assertion (Bags.Total_Size (B1) = 4,
                 "** P23: Bag Total_Size is not zero");
      Assertion (not Bags.Is_Member (B1, '4'),
                 "** P24: Bag membership is not correct");
      Assertion (Bags.Is_Member (B1, '5'),
                 "** P25: Bag membership is not correct");
      Assertion (Bags.Is_Member (B1, '6'),
                 "** P26: Bag membership is not correct");
      Bags.Remove (B1, '5');
      Bags.Remove (B1, '6');
      Bags.Remove (B1, '6');
      Bags.Remove (B1, '6');
      Assertion (Bags.Is_Empty (B1), "** P27: Bag is not empty");
      Assertion (Bags.Extent (B1) = 0, "** P28: Bag extent is not zero");
      Assertion (Bags.Total_Size (B1) = 0,
                 "** P29: Bag Total_Size is not zero");
      Bags.Add (B1, '7');
      Bags.Add (B1, '8');
      Bags.Add (B1, '8');
      Bags.Add (B1, '9');
      Bags.Add (B1, '9');
      Bags.Add (B1, '9');
      Assertion (Bags.Extent (B1) = 3, "** P30: Bag extent is not correct");
      Assertion (Bags.Total_Size (B1) = 6,
                 "** P31: Bag Total_Size is not zero");
      B2 := B1;
      Assertion (Bags.Extent (B1) = 3, "** P32: Bag extent is not correct");
      Assertion (Bags.Total_Size (B1) = 6,
                 "** P33: Bag Total_Size is not zero");
      Assertion (Bags.Extent (B2) = 3, "** P34: Bag extent is not correct");
      Assertion (Bags.Total_Size (B2) = 6,
                 "** P35: Bag Total_Size is not zero");
      Assertion (Bags.Are_Equal (B1, B2), "** P36: Bags are not equal");
      Assertion (Bags.Is_Subset (B2, B1), "** P37: Bags are not subsets");
      Assertion (not Bags.Is_Proper_Subset (B2, B1),
                 "** P38: Bags are proper subsets");
      Bags.Add (B1, '1');
      Bags.Add (B1, '2');
      Bags.Add (B1, '2');
      Bags.Add (B1, '9');
      Assertion (Bags.Is_Subset (B2, B1), "** P39: Bags are not subsets");
      Assertion (Bags.Is_Proper_Subset (B2, B1),
                 "** P40: Bags are not proper subsets");
      Bags.Add (B2, '6');
      Bags.Add (B2, '6');
      Bags.Union (B1, B2);
      Assertion (Bags.Extent (B1) = 6, "** P41: Bag Extent is not correct");
      Assertion (Bags.Total_Size (B1) = 18,
                 "** P42: Bag Total_Size is not correct");
      Assertion (Bags.Count (B1, '1') = 1, "** P43: Bag Count is not correct");
      Assertion (Bags.Count (B1, '2') = 2, "** P44: Bag Count is not correct");
      Assertion (Bags.Count (B1, '6') = 2, "** P45: Bag Count is not correct");
      Assertion (Bags.Count (B1, '7') = 2, "** P46: Bag Count is not correct");
      Assertion (Bags.Count (B1, '8') = 4, "** P47: Bag Count is not correct");
      Assertion (Bags.Count (B1, '9') = 7, "** P48: Bag Count is not correct");
      Bags.Remove (B2, '9');
      Bags.Remove (B2, '9');
      Bags.Remove (B2, '9');
      Bags.Add (B2, '5');
      Bags.Add (B2, '7');
      Bags.Add (B2, '7');
      Bags.Intersection (B1, B2);
      Assertion (Bags.Extent (B1) = 3, "** P49: Bag Extent is not correct");
      Assertion (Bags.Total_Size (B1) = 6,
                 "** P50: Bag Total_Size is not correct");
      Assertion (Bags.Count (B1, '6') = 2, "** P51: Bag Count is not correct");
      Assertion (Bags.Count (B1, '7') = 2, "** P52: Bag Count is not correct");
      Assertion (Bags.Count (B1, '8') = 2, "** P53: Bag Count is not correct");
      Bags.Add (B1, '1');
      Bags.Add (B1, '1');
      Bags.Add (B1, '1');
      Bags.Add (B1, '8');
      Bags.Difference (B1, B2);
      Assertion (Bags.Extent (B1) = 2, "** P54: Bag Extent is not correct");
      Assertion (Bags.Total_Size (B1) = 4,
                 "** P55: Bag Total_Size is not correct");
      Assertion (Bags.Count (B1, '1') = 3, "** P56: Bag Count is not correct");
      Assertion (Bags.Count (B1, '8') = 1, "** P57: Bag Count is not correct");
      Bags.Add (B1, '7');
      Bags.Add (B1, '7');
      Bags.Remove (B1, '7');
      Bags.Remove (B1, '7');
      begin
         Bags.Remove (B1, '7');
         Put_Line ("** P62: Bag Remove is not correct");
      exception
         when BC.Not_Found => null;
      end;
      Bags.Remove (B1, '1');
      Bags.Remove (B1, '1');
      Bags.Remove (B1, '1');
      Bags.Add (B1, 'z');
   end Test;

   procedure Test_Active_Iterator (B : in out Bags.Abstract_Bag'Class) is
      use Containers; use Bags;
      Iter : Containers.Iterator'Class := New_Iterator (B);
   begin
      while not Containers.Is_Done (Iter) loop
         Put_Line
           ("      Item: "
            & Containers.Current_Item (Iter)
            & " =>"
            & Positive'Image (Bags.Count (B, Containers.Current_Item (Iter))));
         Containers.Next (Iter);
      end loop;
   end Test_Active_Iterator;

   procedure Test_Passive_Iterator (B : in out Containers.Container'Class) is
      procedure Process (Item : Character; OK : out Boolean);
      procedure Visitor is new Containers.Visit (Process);
      procedure Process (Item : Character; OK : out Boolean) is
      begin
         Put_Line
           ("      Item: "
            & Item
            & " =>"
            & Positive'Image (Bags.Count (Bags.Abstract_Bag'Class (B), Item)));
         OK := True;
      end Process;
      Iter : Containers.Iterator'Class := Containers.New_Iterator (B);
   begin
      Visitor (Iter);
   end Test_Passive_Iterator;

   procedure Test_Passive_Modifying_Iterator
     (B : in out Containers.Container'Class) is
      procedure Process_Modifiable (Item : in out Character;
                                    OK : out Boolean);
      procedure Modifier is new Containers.Modify (Process_Modifiable);
      procedure Process_Modifiable (Item : in out Character;
                                    OK : out Boolean) is
      begin
         Put_Line
           ("      Item (RW): "
            & Item
            & " =>"
            & Positive'Image (Bags.Count (Bags.Abstract_Bag'Class (B), Item)));
         OK := True;
      end Process_Modifiable;
      Iter : Containers.Iterator'Class := Containers.New_Iterator (B);
   begin
      Modifier (Iter);
   end Test_Passive_Modifying_Iterator;

   Bag_B_P1, Bag_B_P2 : BB.Bag;
   Bag_D_P1, Bag_D_P2 : BD.Bag;
   Bag_U_P1, Bag_U_P2 : BU.Bag;
   Bag_UM_P1, Bag_UM_P2 : BUM.Bag;

begin
   Put_Line ("Starting bag tests");
   Put_Line ("...Bounded Bag");
   Test (Bag_B_P1, Bag_B_P2);
   Put_Line ("...Dynamic Bag");
   BD.Preallocate (Bag_D_P1, 50);
   Test (Bag_D_P1, Bag_D_P2);
   Put_Line ("...Unbounded Bag");
   Test (Bag_U_P1, Bag_U_P2);
   Put_Line ("...Unmanaged Bag");
   Test (Bag_UM_P1, Bag_UM_P2);

   Put_Line ("...Bag Active Iterator");
   Put_Line ("   Bounded:");
   Test_Active_Iterator (Bag_B_P1);
   Put_Line ("   Dynamic:");
   Test_Active_Iterator (Bag_D_P1);
   Put_Line ("   Unbounded:");
   Test_Active_Iterator (Bag_U_P1);
   Put_Line ("   Unmanaged:");
   Test_Active_Iterator (Bag_UM_P1);

   Put_Line ("...Bag Passive Iterator");
   Put_Line ("   Bounded:");
   Test_Passive_Iterator (Bag_B_P1);
   Test_Passive_Modifying_Iterator (Bag_B_P1);
   Put_Line ("   Dynamic:");
   Test_Passive_Iterator (Bag_D_P1);
   Test_Passive_Modifying_Iterator (Bag_D_P1);
   Put_Line ("   Unbounded:");
   Test_Passive_Iterator (Bag_U_P1);
   Test_Passive_Modifying_Iterator (Bag_U_P1);
   Put_Line ("   Unmanaged:");
   Test_Passive_Iterator (Bag_UM_P1);
   Test_Passive_Modifying_Iterator (Bag_UM_P1);

   Assertion (Bags.Total_Size (Bag_D_P1) = 2,
              "** M05: Bag Total_Size is not correct");
   Assertion (BD.Count (Bag_D_P2, '8') = 2,
              "** M06: Bag Count is not correct");
   --  the statement above triggers a bug box in GNAT 3.11b2 and 3.11p
   Assertion (Bags.Total_Size (Bag_U_P1) = 2,
              "** M07: Bag Total_Size is not correct");
   Assertion (Bags.Total_Size (Bag_U_P1) = 2,
              "** M07u: Bag Total_Size is not correct");
   Assertion (BU.Count (Bag_U_P2, '8') = 2,
              "** M10: Bag Count is not correct");
   Assertion (BUM.Count (Bag_UM_P2, '8') = 2,
              "** M10u: Bag Count is not correct");

   Put_Line ("Completed bag tests");

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                & Ada.Exceptions.Exception_Name (E)
                & " OCCURRED.");
end Bag_Test;
