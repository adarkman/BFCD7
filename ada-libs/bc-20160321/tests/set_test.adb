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
with Assertions;
with BC;
with Set_Test_Support;
procedure Set_Test is

   use Ada.Text_IO;
   use Assertions;
   use Set_Test_Support;

   procedure Print_Set (S : in out Sets.Abstract_Set'Class; Named : String);
   pragma Warnings (Off, Print_Set);
   procedure Process (Item : Character; OK : out Boolean);
   procedure Process_Modifiable (Item : in out Character; OK : out Boolean);
   procedure Test (S1, S2 : in out Sets.Abstract_Set'Class);
   procedure Test_Active_Iterator (S : in out Sets.Abstract_Set'Class);
   procedure Test_Passive_Iterator (S : in out Containers.Container'Class);
   procedure Test_Passive_Modifying_Iterator
     (S : in out Containers.Container'Class);

   package Iteration_Check is
      procedure Reset;
      procedure Register (C : Character);
      procedure Check (Expected : String; Message : String);
   end Iteration_Check;

   package body Iteration_Check is

      Last_Char : Integer := 0;

      Results : String (1 .. 32);

      procedure Reset is
      begin
         Last_Char := 0;
      end Reset;

      procedure Register (C : Character) is
      begin
         Last_Char := Last_Char + 1;
         Results (Last_Char) := C;
      end Register;

      procedure Check (Expected : String; Message : String) is
      begin
         Assertion (Expected'Length = Last_Char,
                    Message & ", length error");
         if Expected'Length = Last_Char then
            Assertion (Expected = Results (1 .. Last_Char),
                       Message & ", mismatch");
         end if;
      end Check;

   end Iteration_Check;

   procedure Print_Set (S : in out Sets.Abstract_Set'Class; Named : String) is
      procedure Print (Item : Character; OK : out Boolean);
      procedure Print (Item : Character; OK : out Boolean) is
      begin
         Put (" " & Item);
         OK := True;
      end Print;
      procedure Visitor is new Containers.Visit (Print);
      It : Containers.Iterator'Class
        := Containers.New_Iterator (Containers.Container'Class (S));
   begin
      Put ("Set " & Named);
      Visitor (It);
      New_Line;
   end Print_Set;

   procedure Test (S1, S2 : in out Sets.Abstract_Set'Class) is
      Status : Boolean;
   begin
      Assertion (Sets.Is_Empty (S1),
                 "** P01: Set is not initially empty");
      Assertion (Sets.Extent (S1) = 0,
                 "** P02: Set Extent is not initially zero");
      Sets.Add (S1, '1');
      Sets.Add (S1, '2');
      Sets.Add (S1, '3');
      Assertion (not Sets.Is_Empty (S1), "** P03: Set is empty");
      Assertion (Sets.Extent (S1) = 3, "** P04: Set extent is not correct");
      Assertion (Sets.Is_Member (S1, '1'),
                 "** P05: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '2'),
                 "** P06: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '3'),
                 "** P07: Set membership is not correct");
      Sets.Clear (S1);
      Assertion (Sets.Is_Empty (S1), "** P08: Set is not empty");
      Assertion (Sets.Extent (S1) = 0, "** P09: Set extent is not zero");
      Sets.Add (S1, '4');
      Sets.Add (S1, '5');
      Sets.Add (S1, '6');
      Assertion (not Sets.Is_Empty (S1), "** P10: Set is empty");
      Assertion (Sets.Extent (S1) = 3, "** P11: Set extent is not correct");
      Assertion (Sets.Is_Member (S1, '4'),
                 "** P12: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '5'),
                 "** P13: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '6'),
                 "** P14: Set membership is not correct");
      Sets.Remove (S1, '4');
      Sets.Remove (S1, '6');
      Assertion (not Sets.Is_Empty (S1), "** P15: Set is empty");
      Assertion (Sets.Extent (S1) = 1, "** P16: Set extent is not correct");
      Assertion (not Sets.Is_Member (S1, '4'),
                 "** P17: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '5'),
                 "** P18: Set membership is not correct");
      Assertion (not Sets.Is_Member (S1, '6'),
                 "** P19: Set membership is not correct");
      Sets.Remove (S1, '5');
      Assertion (Sets.Is_Empty (S1), "** P20: Set is not empty");
      Assertion (Sets.Extent (S1) = 0, "** P21: Set extent is not zero");
      Sets.Add (S1, '7');
      Sets.Add (S1, '8');
      Sets.Add (S1, '9');
      Sets.Remove (S1, '8');
      Sets.Remove (S1, '9');
      Assertion (not Sets.Is_Empty (S1), "** P22: Set is empty");
      Assertion (Sets.Extent (S1) = 1, "** P23: Set extent is not correct");
      Assertion (Sets.Is_Member (S1, '7'),
                 "** P24: Set membership is not correct");
      S2 := S1;
      Assertion (not Sets.Is_Empty (S1), "** P25: Set is empty");
      Assertion (Sets.Extent (S1) = 1, "** P26: Set extent is not correct");
      Assertion (Sets.Is_Member (S1, '7'),
                 "** P27: Set membership is not correct");
      Assertion (not Sets.Is_Empty (S2), "** P28: Set is empty");
      Assertion (Sets.Extent (S2) = 1, "** P29: Set extent is not correct");
      Assertion (Sets.Is_Member (S2, '7'),
                 "** P30: Set membership is not correct");
      Assertion (Sets.Are_Equal (S1, S2), "** P31: Sets are not equal");
      Assertion (Sets.Is_Subset (S2, S1), "** P32: Sets are not subsets");
      Assertion (not Sets.Is_Proper_Subset (S2, S1),
                 "** P33: Sets are proper subsets");
      Sets.Add (S1, '1');
      Sets.Add (S1, '2');
      Sets.Add (S1, '3');
      Assertion (Sets.Is_Subset (S2, S1), "** P34: Sets are not subsets");
      Assertion (Sets.Is_Proper_Subset (S2, S1),
                 "** P35: Sets are not proper subsets");
      Sets.Add (S2, '8');
      Sets.Add (S2, '9');
      Sets.Union (S1, S2);
      Assertion (Sets.Extent (S1) = 6, "** P36: Set extent is not correct");
      Assertion (Sets.Is_Member (S1, '8'),
                 "** P37: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '9'),
                 "** P38: Set membership is not correct");
      Sets.Remove (S1, '9');
      Assertion (not Sets.Is_Subset (S2, S1),
                 "** P39: Sets are subsets");
      Assertion (not Sets.Is_Proper_Subset (S2, S1),
                 "** P40: Sets are proper subsets");
      Sets.Intersection (S1, S2);
      Assertion (Sets.Extent (S1) = 2, "** P41: Set extent is not correct");
      Assertion (Sets.Is_Member (S1, '7'),
                 "** P42: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '8'),
                 "** P43: Set membership is not correct");
      Sets.Add (S1, '1');
      Sets.Add (S1, '2');
      Sets.Add (S1, '3');
      Sets.Difference (S1, S2);
      Assertion (Sets.Extent (S1) = 3, "** P44: Set extent is not correct");
      Assertion (Sets.Is_Member (S1, '1'),
                 "** P45: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '2'),
                 "** P46: Set membership is not correct");
      Assertion (Sets.Is_Member (S1, '3'),
                 "** P47: Set membership is not correct");
      Sets.Remove (S1, '2');
      Sets.Remove (S1, '3');
      Sets.Add (S1, '3', Added => Status);
      if not Status then
         Put_Line ("** P48: Set add is not correct");
      end if;
      Sets.Add (S1, '3', Added => Status);
      if Status then
         Put_Line ("** P49: Set add is not correct");
      end if;
      begin
         Sets.Remove (S1, '3');
      exception
         when others =>
            Put_Line ("** P50: Set remove is not correct");
      end;
      begin
         Sets.Remove (S1, '3');
         Put_Line ("** P51: Set remove is not correct");
      exception
         when BC.Not_Found => null;
         when others => Put_Line ("** P51: Set remove is not correct");
      end;
      Sets.Add (S1, 'z', Added => Status);
   end Test;

   procedure Test_Active_Iterator (S : in out Sets.Abstract_Set'Class) is
      use Containers; use Sets; use SB;
      Iter : Containers.Iterator'Class := New_Iterator (S);
      Dummy : Boolean;
   begin
      Iteration_Check.Reset;
      while not Containers.Is_Done (Iter) loop
         Process (Current_Item (Iter), Dummy);
         Containers.Next (Iter);
      end loop;
      Iteration_Check.Check ("1z", "I01: active iterator");
   end Test_Active_Iterator;

   procedure Process (Item : Character; OK : out Boolean) is
   begin
      Iteration_Check.Register (Item);
      OK := True;
   end Process;

   procedure Process_Modifiable (Item : in out Character; OK : out Boolean) is
   begin
      Iteration_Check.Register (Item);
      OK := True;
   end Process_Modifiable;

   procedure Test_Passive_Iterator (S : in out Containers.Container'Class) is
      procedure Visitor is new Containers.Visit (Process);
      Iter : Containers.Iterator'Class := Containers.New_Iterator (S);
   begin
      Iteration_Check.Reset;
      Visitor (Using => Iter);
      Iteration_Check.Check ("1z", "I02: passive iterator");
   end Test_Passive_Iterator;

   procedure Test_Passive_Modifying_Iterator
     (S : in out Containers.Container'Class) is
      procedure Modifier is new Containers.Modify (Process_Modifiable);
      Iter : Containers.Iterator'Class := Containers.New_Iterator (S);
   begin
      Iteration_Check.Reset;
      Modifier (Using => Iter);
      Iteration_Check.Check ("1z", "I03: passive modifying iterator");
   end Test_Passive_Modifying_Iterator;

   Set_B_Pu1, Set_B_Pu2 : SB.Set;
   Set_D_Pu1, Set_D_Pu2 : SD.Set;
   Set_U_Pu1, Set_U_Pu2 : SU.Set;
   Set_UM_Pu1, Set_UM_Pu2 : SUM.Set;

begin

   Put_Line ("Starting set tests");
   Put_Line ("...Bounded Set");
   Test (Set_B_Pu1, Set_B_Pu2);
   Put_Line ("...Dynamic Set");
   SD.Preallocate (Set_D_Pu1, 50);
   Test (Set_D_Pu1, Set_D_Pu2);
   Put_Line ("...Unbounded Set");
   Test (Set_U_Pu1, Set_U_Pu2);
   Put_Line ("...Unmanaged Set");
   Test (Set_UM_Pu1, Set_UM_Pu2);

   Put_Line ("...Set Active Iterator");
   Put_Line ("   Bounded:");
   Test_Active_Iterator (Set_B_Pu1);
   Put_Line ("   Dynamic:");
   Test_Active_Iterator (Set_D_Pu1);
   Put_Line ("   Unbounded:");
   Test_Active_Iterator (Set_U_Pu1);
   Put_Line ("   Unmanaged:");
   Test_Active_Iterator (Set_UM_Pu1);
   Put_Line ("...Set Passive Iterator");
   Put_Line ("   Bounded:");
   Test_Passive_Iterator (Set_B_Pu1);
   Test_Passive_Modifying_Iterator (Set_B_Pu1);
   Put_Line ("   Dynamic:");
   Test_Passive_Iterator (Set_D_Pu1);
   Test_Passive_Modifying_Iterator (Set_D_Pu1);
   Put_Line ("   Unbounded:");
   Test_Passive_Iterator (Set_U_Pu1);
   Test_Passive_Modifying_Iterator (Set_U_Pu1);
   Put_Line ("   Unmanaged:");
   Test_Passive_Iterator (Set_UM_Pu1);
   Test_Passive_Modifying_Iterator (Set_UM_Pu1);

   Assertion (SB.Is_Member (Set_B_Pu1, '1'),
              "** M01: Set membership is not correct");
   Assertion (SB.Extent (Set_B_Pu2) = 3, "** M02: Set extent is not correct");
   Assertion (SD.Is_Member (Set_D_Pu1, '1'),
              "** M05: Set membership is not correct");
   Assertion (SD.Extent (Set_D_Pu2) = 3, "** M06: Set extent is not correct");
   Assertion (SU.Is_Member (Set_U_Pu1, '1'),
              "** M09: Set membership is not correct");
   Assertion (SU.Is_Member (Set_U_Pu1, 'z'),
              "** M10: Set membership is not correct");
   Assertion (SU.Extent (Set_U_Pu2) = 3, "** M10: Set extent is not correct");
   Assertion (SB.Available (Set_B_Pu1) = 98,
              "** M13: Available space is not correct");
   Assertion (SB.Available (Set_B_Pu2) = 97,
              "** M14: Available space is not correct");
   Put_Line ("Completed set tests");

   Assertions.Report;

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                & Ada.Exceptions.Exception_Name (E)
                & " OCCURRED.");
end Set_Test;
