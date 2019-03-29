--  Copyright 1994 Grady Booch
--  Copyright 1994-1997 David Weller
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
with Deque_Test_Support;

procedure Deque_Test is
   use Ada.Text_IO;
   use Deque_Test_Support;
   use Containers;
   use Deques;

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

   procedure Test_Active_Iterator (D : Container'Class);
   procedure Test_Active_Iterator (D : Container'Class) is
      Iter : Iterator'Class := New_Iterator (D);
      Success : Boolean;
      Temp : Character;
   begin
      while not Is_Done (Iter) loop
         Temp := Current_Item (Iter);
         Process (Temp, Success);
         Next (Iter);
      end loop;
   end Test_Active_Iterator;

   procedure Test_Primitive (D1, D2 : in out Abstract_Deque'Class);
   procedure Test_Primitive (D1, D2 : in out Abstract_Deque'Class) is
   begin
      Assertion (Is_Empty (D1), "** P01: Deque is not initially empty");
      Assertion (Length (D1) = 0,
                 "** P02: Deque length is not initially zero");
      Append (D1, '2');
      Append (D1, '3');
      Append (D1, '1', Front);
      Assertion (not (Is_Empty (D1)), "** P03: Deque is empty");
      Assertion ((Length (D1) = 3), "** P04: Deque length is not correct");
      Assertion ((Front (D1) = '1'), "** P05: Deque front is not correct");
      Clear (D1);
      Assertion (Is_Empty (D1), "** P06: Deque is not empty");
      Assertion ((Length (D1) = 0), "** P07: Deque length is not zero");
      Append (D1, '5');
      Append (D1, '6');
      Append (D1, '4', Front);
      Assertion (not (Is_Empty (D1)), "** P08: Deque is empty");
      Assertion ((Length (D1) = 3), "** P09: Deque length is not correct");
      Assertion ((Front (D1) = '4'), "** P10: Deque front is not correct");
      Assertion ((Back (D1) = '6'), "** P10a: Deque back is not correct");
      Pop (D1);
      Pop (D1, Back);
      Assertion (not (Is_Empty (D1)), "** P11: Deque is empty");
      Assertion ((Length (D1) = 1), "** P12: Deque length is not correct");
      Assertion ((Front (D1) = '5'), "** P13: Deque front is not correct");
      Pop (D1);
      Assertion (Is_Empty (D1), "** P14: Deque is not empty");
      Assertion ((Length (D1) = 0), "** P15: Deque length is not zero");
      Append (D1, '7');
      Append (D1, '8');
      Append (D1, '9');
      Pop (D1);
      Pop (D1);
      Assertion (not (Is_Empty (D1)), "** P16: Deque is empty");
      Assertion ((Length (D1) = 1), "** P17: Deque length is not correct");
      Assertion ((Front (D1) = '9'), "** P18: Deque front is not correct");
      D2 := D1;
      Assertion (not (Is_Empty (D1)), "** P19: Deque is empty");
      Assertion ((Length (D1) = 1), "** P20: Deque length is not correct");
      Assertion ((Front (D1) = '9'), "** P21: Deque front is not correct");
      Assertion (not (Is_Empty (D2)), "** P22: Deque is empty");
      Assertion ((Length (D2) = 1), "** P23: Deque length is not correct");
      Assertion ((Front (D2) = '9'), "** P24: Deque front is not correct");
      Assertion ((D1 = D2), "** P25: Deques are not equal");
      Clear (D2);
      Assertion ((not (Is_Empty (D1))), "** P26: Deque is empty");
      Assertion ((Length (D1) = 1), "** P27: Deque length is not correct");
      Assertion ((Front (D1) = '9'), "** P28: Deque front is not correct");
      Assertion (Is_Empty (D2), "** P29: Deque is not empty");
      Assertion ((Length (D2) = 0), "** P30: Deque length is not correct");
      Assertion ((D1 /= D2), "** P31: Deques not equal");
      Append (D2, '1');
      Append (D2, '2');
      Append (D2, '3');
      Append (D2, '4');
      Assertion (Location (D2, '1') = 1,
                 "** P32: Deque location is not correct");
      Assertion (Location (D2, '2') = 2,
                 "** P33: Deque location is not correct");
      Assertion (Location (D2, '4') = 4,
                 "** P34: Deque location is not correct");
      Remove (D2, 1);
      Remove (D2, 2);
      Remove (D2, 2);
      Assertion ((Length (D2) = 1), "** P35: Deque length is not correct");
      Assertion ((Front (D2) = '2'), "** P36: Deque front is not correct");
      Remove (D2, 1);
      Assertion ((Length (D2) = 0), "** P37: Deque length is not correct");
      Append (D2, 'a');
      Append (D2, 'z');
      declare
         procedure P (Ch : in out Character);
         procedure P (Ch : in out Character) is
         begin
            Ch := Character'Succ (Ch);
         end P;
         procedure Acc is new Deques.Process_Front (P);
      begin
         Acc (D2);
      end;
      Assertion (Length (D2) = 2, "** P38: Deque length is not correct");
      Assertion (Front (D2) = 'b', "** P39: Deque front is not correct");
      Assertion (Back (D2) = 'z', "** P40: Deque front is not correct");
      Clear (D2);
      Append (D2, 'A');
      Append (D2, 'Y');
      declare
         procedure P (Ch : in out Character);
         procedure P (Ch : in out Character) is
         begin
            Ch := Character'Succ (Ch);
         end P;
         procedure Acc is new Deques.Process_Back (P);
      begin
         Acc (D2);
      end;
      Assertion (Length (D2) = 2, "** P41: Deque length is not correct");
      Assertion (Front (D2) = 'A', "** P42: Deque front is not correct");
      Assertion (Back (D2) = 'Z', "** P43: Deque front is not correct");
      Clear (D2);
      Append (D1, 'z');
   end Test_Primitive;

   procedure Test_Passive_Iterator (D : Container'Class);
   procedure Test_Passive_Iterator (D : Container'Class) is
      procedure Iterate is new Visit (Apply => Process);
      Iter : Iterator'Class := New_Iterator (D);
   begin
      Iterate (Using => Iter);
   end Test_Passive_Iterator;

   procedure Test_Iterator_Deletion (D : in out Abstract_Deque'Class);
   procedure Test_Iterator_Deletion (D : in out Abstract_Deque'Class) is
      Iter : Iterator'Class := New_Iterator (D);
      Delete : Boolean;
   begin
      Clear (D);
      Append (D, '1');
      Append (D, '2');
      Append (D, '3');
      Append (D, '4');
      Append (D, '5');
      Append (D, '6');
      Delete := False;
      Reset (Iter);
      while not Is_Done (Iter) loop
         if Delete then
            Delete_Item_At (Iter);
            Delete := False;
         else
            Next (Iter);
            Delete := True;
         end if;
      end loop;
      begin
         Delete_Item_At (Iter);
         Assertion (False, "** I01: Deletion succeeded");
      exception
         when BC.Not_Found => null;
         when others =>
            Assertion (False, "** I02: Unexpected exception");
      end;
      Assertion (Length (D) = 3, "** I03: Deque length is not correct");
      Assertion (Front (D) = '1', "** I04: Deque item is not correct");
      Pop (D);
      Assertion (Front (D) = '3', "** I05: Deque item is not correct");
      Pop (D);
      Assertion (Front (D) = '5', "** I06: Deque item is not correct");
      Pop (D);
      Assertion (Length (D) = 0, "** I07: Deque length is not zero");
   end Test_Iterator_Deletion;

   Deque_B_P1, Deque_B_P2 : DB.Deque;
   Deque_D_P1, Deque_D_P2 : DD.Deque;
   Deque_U_P1, Deque_U_P2 : DU.Deque;
   Deque_UM_P1, Deque_UM_P2 : DUM.Deque;

begin
   Put_Line ("Starting deque tests");

   Put_Line ("...Bounded Deque");
   Test_Primitive (Deque_B_P1, Deque_B_P2);

   Put_Line ("...Dynamic Deque");
   DD.Preallocate (Deque_D_P1, 50);
   Test_Primitive (Deque_D_P1, Deque_D_P2);

   Put_Line ("...Unbounded Deque");
   Test_Primitive (Deque_U_P1, Deque_U_P2);

   Put_Line ("...Unmanaged Deque");
   Test_Primitive (Deque_UM_P1, Deque_UM_P2);

   Put_Line ("...Deque Active Iterator");
   Put_Line ("   Bounded:");
   Test_Active_Iterator (Deque_B_P1);
   Put_Line ("   Dynamic:");
   Test_Active_Iterator (Deque_D_P1);
   Put_Line ("   Unbounded:");
   Test_Active_Iterator (Deque_U_P1);
   Put_Line ("   Unmanaged:");
   Test_Active_Iterator (Deque_UM_P1);

   Put_Line ("...Deque Passive Iterator");
   Put_Line ("   Bounded:");
   Test_Passive_Iterator (Deque_B_P1);
   Put_Line ("   Dynamic:");
   Test_Passive_Iterator (Deque_D_P1);
   Put_Line ("   Unbounded:");
   Test_Passive_Iterator (Deque_U_P1);
   Put_Line ("   Unmanaged:");
   Test_Passive_Iterator (Deque_UM_P1);

   Assertion (DB.Front (Deque_B_P1) = '9',
              "** M01: Deque front is not correct");
   Assertion (DB.Length (Deque_B_P2) = 0,
              "** M02: Deque length is not correct");
   Assertion (DD.Front (Deque_D_P1) = '9',
              "** M05: Deque front is not correct");
   Assertion (DD.Length (Deque_D_P2) = 0,
              "** M06: Deque length is not correct");
   Assertion (DU.Front (Deque_U_P1) = '9',
              "** M09: Deque front is not correct");
   Assertion (DUM.Front (Deque_UM_P1) = '9',
              "** M09a: Deque front is not correct");
   Assertion (DU.Length (Deque_U_P2) = 0,
              "** M10: Deque length is not correct");
   Assertion (DUM.Length (Deque_UM_P2) = 0,
              "** M10a: Deque length is not correct");

   Assertion (DB.Available (Deque_B_P1) = 98,
              "** M13: Available space not correct");
   Assertion
     (DB.Available (Deque_B_P2) = 100, "** M14: Available space not correct");

   Put_Line ("...Deque Iterator Deletion");
   Put_Line ("   Bounded:");
   Test_Iterator_Deletion (Deque_B_P1);
   Put_Line ("   Dynamic:");
   Test_Iterator_Deletion (Deque_D_P1);
   Put_Line ("   Unbounded:");
   Test_Iterator_Deletion (Deque_U_P1);
   Put_Line ("   Unmanaged:");
   Test_Iterator_Deletion (Deque_UM_P1);

   Put_Line ("Completed deque tests");

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                & Ada.Exceptions.Exception_Name (E)
                & " OCCURRED.");
end Deque_Test;
