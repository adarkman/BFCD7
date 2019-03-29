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
with Ring_Test_Support;

procedure Ring_Test is

   use Ada.Text_IO;
   use Ring_Test_Support;
   use Containers;
   use Rings;

   procedure Process (C : Character; OK : out Boolean);
   procedure Process (C : Character; OK : out Boolean) is
   begin
      Put_Line ("Item: " & C);
      OK := True;
   end Process;

   procedure Assertion (Cond : Boolean; Message : String);
   procedure Assertion (Cond : Boolean; Message : String) is
   begin
      if not Cond then
         Put_Line (Message);
      end if;
   end Assertion;

   procedure Test_Active_Iterator (R : Container'Class);
   procedure Test_Active_Iterator (R : Container'Class) is
      Iter : Iterator'Class := New_Iterator (R);
      Success : Boolean;
      Temp : Character;
   begin
      while not Is_Done (Iter) loop
         Temp := Current_Item (Iter);
         Process (Temp, Success);
         Next (Iter);
      end loop;
   end Test_Active_Iterator;

   procedure Test_Passive_Iterator (R : Container'Class);
   procedure Test_Passive_Iterator (R : Container'Class) is
      procedure Iterate is new Visit (Apply => Process);
      Iter : Iterator'Class := New_Iterator (R);
   begin
      Iterate (Using => Iter);
   end Test_Passive_Iterator;

   procedure Test_Primitive (R1, R2 : in out Abstract_Ring'Class);
   procedure Test_Primitive (R1, R2 : in out Abstract_Ring'Class) is
   begin
      Assertion (Is_Empty (R1), "** P01: Ring is not initially empty");
      Assertion (Extent (R1) = 0, "** P02: Ring extent is not initially zero");
      Insert (R1, '1');
      Insert (R1, '2');
      Insert (R1, '3');
      Assertion (not Is_Empty (R1), "** P03: Ring is empty");
      Assertion (Extent (R1) = 3, "** P04: Ring extent is not correct");
      Assertion (Top (R1) = '3', "** P05: Ring top is not correct");
      Clear (R1);
      Assertion (Is_Empty (R1), "** P06: Ring is not empty");
      Assertion (Extent (R1) = 0, "** P07: Ring extent is not zero");
      Insert (R1, '4');
      Insert (R1, '5');
      Insert (R1, '6');
      Assertion (not Is_Empty (R1), "** P08: Ring is empty");
      Assertion (Extent (R1) = 3, "** P09: Ring extent is not correct");
      Assertion (Top (R1) = '6', "** P10: Ring top is not correct");
      Pop (R1);
      Pop (R1);
      Assertion (not Is_Empty (R1), "** P11: Ring is empty");
      Assertion (Extent (R1) = 1, "** P12: Ring extent is not correct");
      Assertion (Top (R1) = '4', "** P13: Ring top is not correct");
      Pop (R1);
      Assertion (Is_Empty (R1), "** P14: Ring is not empty");
      Assertion (Extent (R1) = 0, "** P15: Ring extent is not zero");
      Insert (R1, '7');
      Insert (R1, '8');
      Insert (R1, '9');
      Assertion (not Is_Empty (R1), "** P16: Ring is empty");
      Assertion (Extent (R1) = 3, "** P17: Ring extent is not correct");
      Assertion (Top (R1) = '9', "** P13: Ring top is not correct");
      R2 := R1;
      Assertion (not Is_Empty (R1), "** P19: Ring is empty");
      Assertion (Extent (R1) = 3, "** P20: Ring extent is not correct");
      Assertion (Top (R1) = '9', "** P21: Ring top is not correct");
      Assertion (not Is_Empty (R2), "** P22: Ring is empty");
      Assertion (Extent (R2) = 3, "** P23: Ring extent is not correct");
      Assertion (Top (R2) = '9', "** P24: Ring top is not correct");
      Assertion (Are_Equal (R1, R2), "** P25a: Rings are not equal");
      Assertion (R1 = R2, "** P25b: Rings are not equal");
      Rotate (R2);
      Assertion (Top (R2) = '8', "** P26: Ring top is not correct");
      Rotate (R2);
      Assertion (Top (R2) = '7', "** P27: Ring top is not correct");
      Rotate (R2, Forward);
      Assertion (Top (R2) = '9', "** P28: Ring top is not correct");
      Rotate (R2, Backward);
      Assertion (Top (R2) = '7', "** P29: Ring top is not correct");
      Rotate (R2, Backward);
      Assertion (Top (R2) = '8', "** P30: Ring top is not correct");
      Assertion (not At_Mark (R2), "** P31: Ring at mark");
      Mark (R2);
      Assertion (At_Mark (R2), "** P32: Ring not at mark");
      Rotate (R2, Backward);
      Assertion (Top (R2) = '9', "** P33: Ring top is not correct");
      Assertion (not At_Mark (R2), "** P34: Ring at mark");
      Rotate_To_Mark (R2);
      Assertion (At_Mark (R2), "** P35: Ring not at mark");
      Assertion (Top (R2) = '8', "** P36: Ring top is not correct");
      Assertion (not Are_Equal (R1, R2), "** P37a: Rings are equal");
      Assertion (R1 /= R2, "** P37b: Rings are equal");
      Pop (R2);
      Assertion (Extent (R2) = 2, "** P38: Ring extent is not correct");
      Assertion (Top (R2) = '7', "** P39: Ring top is not correct");
      Assertion (At_Mark (R2), "** P40: Ring at mark");
   end Test_Primitive;

   Ring_B_P1, Ring_B_P2 : RB.Ring;
   Ring_D_P1, Ring_D_P2 : RD.Ring;
   Ring_U_P1, Ring_U_P2 : RU.Ring;
   Ring_UM_P1, Ring_UM_P2 : RUM.Ring;

begin

   Put_Line ("Starting Ring tests");

   Put_Line ("...Bounded Ring");
   Test_Primitive (Ring_B_P1, Ring_B_P2);
   Put_Line ("...Dynamic Ring");
   RD.Preallocate (Ring_D_P1, 50);
   Test_Primitive (Ring_D_P1, Ring_D_P2);
   Put_Line ("...Unbounded Ring");
   Test_Primitive (Ring_U_P1, Ring_U_P2);
   Put_Line ("...Unmanaged Ring");
   Test_Primitive (Ring_UM_P1, Ring_UM_P2);

   Put_Line ("...Ring Active Iterator");
   Put_Line ("   Bounded:");
   Test_Active_Iterator (Ring_B_P1);
   Put_Line ("   Dynamic:");
   Test_Active_Iterator (Ring_D_P1);
   Put_Line ("   Unbounded:");
   Test_Active_Iterator (Ring_U_P1);
   Put_Line ("   Unmanaged:");
   Test_Active_Iterator (Ring_U_P1);

   Put_Line ("...Ring Passive Iterator");
   Put_Line ("   Bounded:");
   Test_Passive_Iterator (Ring_B_P1);
   Put_Line ("   Dynamic:");
   Test_Passive_Iterator (Ring_D_P1);
   Put_Line ("   Unbounded:");
   Test_Passive_Iterator (Ring_U_P1);
   Put_Line ("   Unmanaged:");
   Test_Passive_Iterator (Ring_UM_P1);

   Assertion (RB.Top (Ring_B_P1) = '9', "** M01: Ring top is not correct");
   Assertion (RB.Extent (Ring_B_P2) = 2, "** M02: Ring depth is not correct");
   Assertion (RD.Top (Ring_D_P1) = '9', "** M05: Ring top is not correct");
   Assertion (RD.Extent (Ring_D_P2) = 2, "** M06: Ring depth is not correct");
   Assertion (RU.Top (Ring_U_P1) = '9', "** M09: Ring top is not correct");
   Assertion (RUM.Top (Ring_UM_P1) = '9', "** M09a: Ring top is not correct");
   Assertion (RU.Extent (Ring_U_P2) = 2, "** M10: Ring depth is not correct");
   Assertion (RUM.Extent (Ring_UM_P2) = 2,
              "** M10a: Ring depth is not correct");
   Assertion (RB.Available (Ring_B_P1) = 97,
              "** M13: Available space is not correct");
   Assertion (RB.Available (Ring_B_P2) = 98,
              "** M14: Available space is not correct");

   Put_Line ("Completed Ring tests");

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                & Ada.Exceptions.Exception_Name (E)
                & " OCCURRED.");
end Ring_Test;
