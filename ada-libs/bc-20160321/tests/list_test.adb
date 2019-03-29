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
with List_Test_Support;

procedure List_Test is

   use Ada.Text_IO;
   use List_Test_Support;
   use Containers;
   use Lists;
   use LS;
   use LD;

   procedure Assertion (Cond : Boolean; Message : String);
   procedure Assertion (Cond : Boolean; Message : String) is
   begin
      if not Cond then
         Put_Line (Message);
      end if;
   end Assertion;

   procedure Test_Single (L1, L2, T1, T2, T3 : in out LS.List);
   procedure Test_Single (L1, L2, T1, T2, T3 : in out LS.List) is
   begin
      Assertion (Is_Null (L1), "** S01: List is not initially null");
      Assertion ((Length (L1) = 0),
                 "** S02: List Length is not initially zero");
      Assertion (not Is_Shared (L1), "** S03: List is initially shared");
      Append (L1, '3');
      Append (L1, '1', 1);
      Append (L1, '2', 2);
      Assertion (not Is_Null (L1), "** S04: List is empty");
      Assertion ((Length (L1) = 3), "** S05: List Length is not correct");
      Assertion ((Head (L1) = '3'), "** S06: List Head is not correct");
      Assertion (not Is_Shared (L1), "** S07: List is shared");
      Clear (L1);
      Assertion (Is_Null (L1), "** S08: List is not null");
      Assertion ((Length (L1) = 0), "** S09: List Length is not zero");
      Assertion (not Is_Shared (L1), "** S10: List is shared");
      Insert (L1, '4');
      Insert (L1, '5');
      Insert (L1, '6');
      Assertion (not Is_Null (L1), "** S11: List is empty");
      Assertion ((Length (L1) = 3), "** S12: List Length is not correct");
      Assertion ((Foot (L1) = '4'), "** S13: List Head is not correct");
      Assertion (not Is_Shared (L1), "** S14: List is shared");
      T1 := L1;
      Assertion ((L1 = T1), "** S15: Lists are not equal");
      Assertion (Is_Shared (L1), "** S16: List is not shared");
      Assertion (Is_Shared (T1), "** S17: List is not shared");
      Set_Head (T1, '7');
      Assertion ((L1 = T1), "** S18: Lists are not equal");
      Assertion ((Item_At (L1, 1) = '7'), "** S19: List Head is not correct");
      Assertion ((Head (T1) = '7'), "** S20: List Head is not correct");
      Insert (L1, '8');
      Assertion ((L1 /= T1), "** S21: Lists are equal");
      Assertion ((Length (L1) = 4), "** S22: List Length is not correct");
      Assertion ((Item_At (L1, 2) = '7'), "** S23: List Head is not correct");
      Assertion ((Length (T1) = 3), "** S24: List Length is not correct");
      Assertion ((Head (T1) = '7'), "** S25: List Head is not correct");
      T2 := T1;
      Tail (T2);
      Assertion ((T1 /= T2), "** S26: Lists are equal");
      Assertion ((Length (T2) = 2), "** S27: List Length is not correct");
      Assertion ((Head (T2) = '5'), "** S28: List Head is not correct");
      Clear (T1);
      Assertion ((Length (L1) = 4), "** S29: List Length is not correct");
      Assertion ((Head (L1) = '8'), "** S30: List Head is not correct");
      Assertion (not Is_Shared (L1), "** S31: List is not shared");
      Assertion (Is_Null (T1), "** S32: List is not null");
      Assertion ((Length (T1) = 0), "** S33: List Length is not correct");
      Assertion (not Is_Shared (T1), "** S34: List is shared");
      Assertion ((Length (T2) = 2), "** S35: List Length is not correct");
      Assertion ((Head (T2) = '5'), "** S36: List Head is not correct");
      Assertion (Is_Shared (T2), "** S37: List is not shared");
      Clear (L1);
      Assertion (Is_Null (L1), "** S38: List is not null");
      Assertion ((Length (L1) = 0), "** S39: List Length is not correct");
      Assertion (not Is_Shared (L1), "** S40: List is shared");
      Assertion ((Length (T2) = 2), "** S41: List Length is not correct");
      Assertion ((Head (T2) = '5'), "** S42: List Head is not correct");
      Assertion (not Is_Shared (T2), "** S43: List is shared");
      Insert (L2, '1');
      Insert (L2, '3', 1);
      Insert (L2, '2', 2);
      Assertion ((L1 /= L2), "** S44: Lists are equal");
      Assertion (not Is_Null (L2), "** S45: List is empty");
      Assertion ((Length (L2) = 3), "** S46: List Length is not correct");
      Assertion ((Head (L2) = '3'), "** S47: List Head is not correct");
      Assertion (not Is_Shared (L2), "** S48: List is shared");
      L1 := T2;
      T3 := L2;
      L1 := T3;
      Tail (T3);
      Assertion ((L1 = L2), "** S49: Lists are not equal");
      Assertion ((L1 /= T2), "** S50: List are equal");
      Assertion (Is_Shared (L1), "** S51: List is not shared");
      Assertion (not Is_Shared (T2), "** S52: List is not shared");
      Assertion (Is_Shared (T3), "** S53: List is not shared");
      Clear (L1);
      Swap_Tail (L2, T2);
      Assertion (Is_Null (L1), "** S54: List is not null");
      Assertion ((Length (L2) = 3), "** S55: List Length is not correct");
      Assertion (not Is_Shared (L2), "** S56: List is shared");
      Assertion ((T2 = T3), "** S55: Lists are not equal");
      Assertion ((Length (T3) = 2), "** S56: List Length is not correct");
      Assertion ((Head (T3) = '2'), "** S57: List Head is not correct");
      L1 := T2;
      T2 := L2;
      Tail (T2);
      Assertion ((L1 /= L2), "** S58: Lists are equal");
      Assertion ((L1 = T3), "** S59: Lists are not equal");
      Assertion ((Head (T2) = '5'), "** S60: List Head is not correct");
      Assertion ((Length (T2) = 2), "** S61: List Length is not correct");
      Set_Item (L1, '7', 1);
      Assertion ((Head (L1) = '7'), "** S62: List Head is not correct");
      Set_Item (L1, '7', 2);
      Assertion ((Head (L1) = '7'), "** S63: List Head is not correct");
      Set_Item (L1, '2', 1);
      Set_Item (L1, '1', 2);
      T1 := L1;
      T2 := L2;
      Clear (L1);
      Clear (L2);
      Insert (L1, '1');
      Insert (L1, '5');
      Insert (L2, '2');
      Insert (L2, '3');
      Insert (L2, '4');
      Insert (L1, L2, 2);
      Clear (L2);
      Assertion ((Item_At (L1, 1) = '5'), "** S64: List Item is not correct");
      Assertion ((Item_At (L1, 2) = '4'), "** S65: List Item is not correct");
      Assertion ((Item_At (L1, 3) = '3'), "** S66: List Item is not correct");
      Assertion ((Item_At (L1, 4) = '2'), "** S67: List Item is not correct");
      Assertion ((Item_At (L1, 5) = '1'), "** S68: List Item is not correct");
      Clear (T3);
      Append (L2, '7');
      Append (T3, '9');
      Append (T3, '8');
      Insert (L2, T3);
      Clear (T3);
      Append (T3, '2');
      Append (T3, '1');
      Append (L2, T3);
      Clear (T3);
      Append (T3, '6');
      Append (T3, '5');
      Append (T3, '4');
      Append (T3, '3');
      Append (L2, T3, 3);
      Clear (T3);
      Assertion ((Length (L2) = 9), "** S68: List Length is not correct");
      Assertion ((Item_At (L2, 1) = '9'), "** S70: List Item is not correct");
      Assertion ((Item_At (L2, 5) = '5'), "** S71: List Item is not correct");
      Assertion ((Item_At (L2, 7) = '3'), "** S71: List Item is not correct");
      Assertion ((Item_At (L2, 8) = '2'), "** S72: List Item is not correct");
      Assertion ((Item_At (L2, 9) = '1'), "** S74: List Item is not correct");
      Share_Foot (T3, L2);
      Assertion ((Head (T3) = '1'), "** S75: List Item is not correct");
      Share_Head (T3, L2);
      Assertion ((Head (T3) = '9'), "** S76: List Item is not correct");
      Share (T3, L2, 1);
      Clear (L2);
      Assertion ((Head (T3) = '9'), "** S77: List Item is not correct");
      L2 := T3;
      Assertion ((Head (L2) = '9'), "** S78: List Item is not correct");
      Clear (L1);
      Clear (T3);
      L1 := L2;
      Clear (L2);
      Remove (L1, 1);
      Remove (L1, 8);
      Remove (L1, 4);
      Assertion ((Length (L1) = 6), "** S79: List Length is not correct");
      Assertion ((Head (L1) = '8'), "** S80: List Item is not correct");
      Assertion ((Foot (L1) = '2'), "** S81: List Item is not correct");
      Share (T1, L1, 3);
      Share (T2, L1, 5);
      Purge (L1, 4);
      Assertion ((Length (L1) = 3), "** S82: List Length is not correct");
      Assertion ((Length (T1) = 1), "** S83: List Length is not correct");
      Assertion ((Length (T2) = 2), "** S84: List Length is not correct");
      Assertion ((Head (L1) = '8'), "** S85: List Item is not correct");
      Assertion ((Head (T1) = '6'), "** S86: List Item is not correct");
      Assertion ((Head (T2) = '3'), "** S87: List Item is not correct");
      Append (L1, '5');
      Append (L1, '4');
      Append (L1, '3');
      Append (L1, '2');
      Append (L1, '1');
      Share (T1, L1, 3);
      Share (T2, L1, 5);
      Purge (L1, 4, 3);
      Assertion ((Length (L1) = 5), "** S88: List Length is not correct");
      Assertion ((Length (T1) = 3), "** S89: List Length is not correct");
      Assertion ((Length (T2) = 2), "** S90: List Length is not correct");
      Assertion ((Head (L1) = '8'), "** S91: List Item is not correct");
      Assertion ((Item_At (T1, 2) = '2'), "** S92: List Item is not correct");
      Assertion ((Head (T2) = '4'), "** S93: List Item is not correct");
      Preserve (L1, 1);
      Assertion ((Length (L1) = 5), "** S94: List Length is not correct");
      Preserve (L1, 2);
      Assertion ((Length (L1) = 4), "** S95: List Length is not correct");
      Append (L1, '3');
      Append (L1, '4');
      Append (L1, '5');
      Preserve (L1, 3, 4);
      Assertion ((Length (L1) = 4), "** S96: List Length is not correct");
      Assertion ((Length (T1) = 5), "** S97: List Length is not correct");
   end Test_Single;

   procedure Test_Single (L1, L2 : in out LS.List);
   procedure Test_Single (L1, L2 : in out LS.List) is
      T1, T2, T3 : LS.List;
   begin
      Test_Single (L1, L2, T1, T2, T3);
   end Test_Single;

   procedure Test_Double (L1, L2, T1, T2, T3 : in out LD.List);
   procedure Test_Double (L1, L2, T1, T2, T3 : in out LD.List) is
   begin
      Assertion (Is_Null (L1), "** D01: List is not initially null");
      Assertion ((Length (L1) = 0),
                 "** D02: List Length is not initially zero");
      Assertion (not Is_Shared (L1), "** D03: List is initially shared");
      Append (L1, '3');
      Append (L1, '1', 1);
      Append (L1, '2', 2);
      Assertion (not Is_Null (L1), "** D04: List is empty");
      Assertion ((Length (L1) = 3), "** D05: List Length is not correct");
      Assertion ((Head (L1) = '3'), "** D06: List Head is not correct");
      Assertion (not Is_Shared (L1), "** D07: List is shared");
      Clear (L1);
      Assertion (Is_Null (L1), "** D08: List is not null");
      Assertion ((Length (L1) = 0), "** D09: List Length is not zero");
      Assertion (not Is_Shared (L1), "** D10: List is shared");
      Insert (L1, '4');
      Insert (L1, '5');
      Insert (L1, '6');
      Assertion (not Is_Null (L1), "** D11: List is empty");
      Assertion ((Length (L1) = 3), "** D12: List Length is not correct");
      Assertion ((Foot (L1) = '4'), "** D13: List Head is not correct");
      Assertion (not Is_Shared (L1), "** D14: List is shared");
      T1 := L1;
      Assertion ((L1 = T1), "** D15: Lists are not equal");
      Assertion (Is_Shared (L1), "** D16: List is not shared");
      Assertion (Is_Shared (T1), "** D17: List is not shared");
      Set_Head (T1, '7');
      Assertion ((L1 = T1), "** D18: Lists are not equal");
      Assertion ((Item_At (L1, 1) = '7'), "** D19: List Head is not correct");
      Assertion ((Head (T1) = '7'), "** D20: List Head is not correct");
      Insert (L1, '8');
      Assertion ((L1 /= T1), "** D21: Lists are equal");
      Assertion ((Length (L1) = 4), "** D22: List Length is not correct");
      Assertion ((Item_At (L1, 2) = '7'), "** D23: List Head is not correct");
      Assertion ((Length (T1) = 3), "** D24: List Length is not correct");
      Assertion ((Head (T1) = '7'), "** D25: List Head is not correct");
      T2 := T1;
      Tail (T2);
      Assertion ((T1 /= T2), "** D26: Lists are equal");
      Assertion ((Length (T2) = 2), "** D27: List Length is not correct");
      Assertion ((Head (T2) = '5'), "** D28: List Head is not correct");
      Clear (T1);
      Assertion ((Length (L1) = 4), "** D29: List Length is not correct");
      Assertion ((Head (L1) = '8'), "** D30: List Head is not correct");
      Assertion (not Is_Shared (L1), "** D31: List is not shared");
      Assertion (Is_Null (T1), "** D32: List is not null");
      Assertion ((Length (T1) = 0), "** D33: List Length is not correct");
      Assertion (not Is_Shared (T1), "** D34: List is shared");
      Assertion ((Length (T2) = 2), "** D35: List Length is not correct");
      Assertion ((Head (T2) = '5'), "** D36: List Head is not correct");
      Assertion (Is_Shared (T2), "** D37: List is not shared");
      Clear (L1);
      Assertion (Is_Null (L1), "** D38: List is not null");
      Assertion ((Length (L1) = 0), "** D39: List Length is not correct");
      Assertion (not Is_Shared (L1), "** D40: List is shared");
      Assertion ((Length (T2) = 2), "** D41: List Length is not correct");
      Assertion ((Head (T2) = '5'), "** D42: List Head is not correct");
      Assertion (not Is_Shared (T2), "** D43: List is shared");
      Insert (L2, '1');
      Insert (L2, '3', 1);
      Insert (L2, '2', 2);
      Assertion ((L1 /= L2), "** D44: Lists are equal");
      Assertion (not Is_Null (L2), "** D45: List is empty");
      Assertion ((Length (L2) = 3), "** D46: List Length is not correct");
      Assertion ((Head (L2) = '3'), "** D47: List Head is not correct");
      Assertion (not Is_Shared (L2), "** D48: List is shared");
      L1 := T2;
      T3 := L2;
      L1 := T3;
      Tail (T3);
      Assertion ((L1 = L2), "** D49: Lists are not equal");
      Assertion ((L1 /= T2), "** D50: List are equal");
      Assertion (Is_Shared (L1), "** D51: List is not shared");
      Assertion (not Is_Shared (T2), "** D52: List is not shared");
      Assertion (Is_Shared (T3), "** D53: List is not shared");
      Clear (L1);
      Swap_Tail (L2, T2);
      Assertion (Is_Null (L1), "** D54: List is not null");
      Assertion ((Length (L2) = 3), "** D55: List Length is not correct");
      Assertion (not Is_Shared (L2), "** D56: List is shared");
      Assertion ((T2 = T3), "** D55: Lists are not equal");
      Assertion ((Length (T3) = 2), "** D56: List Length is not correct");
      Assertion ((Head (T3) = '2'), "** D57: List Head is not correct");
      L1 := T2;
      T2 := L2;
      Tail (T2);
      Assertion ((L1 /= L2), "** D58: Lists are equal");
      Assertion ((L1 = T3), "** D59: Lists are not equal");
      Assertion ((Head (T2) = '5'), "** D60: List Head is not correct");
      Assertion ((Length (T2) = 2), "** D61: List Length is not correct");
      Set_Item (L1, '7', 1);
      Assertion ((Head (L1) = '7'), "** D62: List Head is not correct");
      Set_Item (L1, '7', 2);
      Assertion ((Head (L1) = '7'), "** D63: List Head is not correct");
      Set_Item (L1, '2', 1);
      Set_Item (L1, '1', 2);
      T1 := L1;
      T2 := L2;
      Clear (L1);
      Clear (L2);
      Insert (L1, '1');
      Insert (L1, '5');
      Insert (L2, '2');
      Insert (L2, '3');
      Insert (L2, '4');
      Insert (L1, L2, 2);
      Clear (L2);
      Assertion ((Item_At (L1, 1) = '5'), "** D64: List Item is not correct");
      Assertion ((Item_At (L1, 2) = '4'), "** D65: List Item is not correct");
      Assertion ((Item_At (L1, 3) = '3'), "** D66: List Item is not correct");
      Assertion ((Item_At (L1, 4) = '2'), "** D67: List Item is not correct");
      Assertion ((Item_At (L1, 5) = '1'), "** D68: List Item is not correct");
      Clear (T3);
      Append (L2, '7');
      Append (T3, '9');
      Append (T3, '8');
      Insert (L2, T3);
      Clear (T3);
      Append (T3, '2');
      Append (T3, '1');
      Append (L2, T3);
      Clear (T3);
      Append (T3, '6');
      Append (T3, '5');
      Append (T3, '4');
      Append (T3, '3');
      Append (L2, T3, 3);
      Clear (T3);
      Assertion ((Length (L2) = 9), "** D68: List Length is not correct");
      Assertion ((Item_At (L2, 1) = '9'), "** D70: List Item is not correct");
      Assertion ((Item_At (L2, 5) = '5'), "** D71: List Item is not correct");
      Assertion ((Item_At (L2, 7) = '3'), "** D71: List Item is not correct");
      Assertion ((Item_At (L2, 8) = '2'), "** D72: List Item is not correct");
      Assertion ((Item_At (L2, 9) = '1'), "** D74: List Item is not correct");
      Share_Foot (T3, L2);
      Assertion ((Head (T3) = '1'), "** D75: List Item is not correct");
      Share_Head (T3, L2);
      Assertion ((Head (T3) = '9'), "** D76: List Item is not correct");
      Share (T3, L2, 1);
      Clear (L2);
      Assertion ((Head (T3) = '9'), "** D77: List Item is not correct");
      L2 := T3;
      Assertion ((Head (L2) = '9'), "** D78: List Item is not correct");
      Clear (L1);
      Clear (T3);
      L1 := L2;
      Clear (L2);
      Remove (L1, 1);
      Remove (L1, 8);
      Remove (L1, 4);
      Assertion ((Length (L1) = 6), "** D79: List Length is not correct");
      Assertion ((Head (L1) = '8'), "** D80: List Item is not correct");
      Assertion ((Foot (L1) = '2'), "** D81: List Item is not correct");
      Share (T1, L1, 3);
      Share (T2, L1, 5);
      Purge (L1, 4);
      Assertion ((Length (L1) = 3), "** D82: List Length is not correct");
      Assertion ((Length (T1) = 1), "** D83: List Length is not correct");
      Assertion ((Length (T2) = 2), "** D84: List Length is not correct");
      Assertion ((Head (L1) = '8'), "** D85: List Item is not correct");
      Assertion ((Head (T1) = '6'), "** D86: List Item is not correct");
      Assertion ((Head (T2) = '3'), "** D87: List Item is not correct");
      Append (L1, '5');
      Append (L1, '4');
      Append (L1, '3');
      Append (L1, '2');
      Append (L1, '1');
      Share (T1, L1, 3);
      Share (T2, L1, 5);
      Purge (L1, 4, 3);
      Assertion ((Length (L1) = 5), "** D88: List Length is not correct");
      Assertion ((Length (T1) = 3), "** D89: List Length is not correct");
      Assertion ((Length (T2) = 2), "** D90: List Length is not correct");
      Assertion ((Head (L1) = '8'), "** D91: List Item is not correct");
      Assertion ((Item_At (T1, 2) = '2'), "** D92: List Item is not correct");
      Assertion ((Head (T2) = '4'), "** D93: List Item is not correct");
      Preserve (L1, 1);
      Assertion ((Length (L1) = 5), "** D94: List Length is not correct");
      Preserve (L1, 2);
      Assertion ((Length (L1) = 4), "** D95: List Length is not correct");
      Append (L1, '3');
      Append (L1, '4');
      Append (L1, '5');
      Preserve (L1, 3, 4);
      Assertion ((Length (L1) = 4), "** D96: List Length is not correct");
      Assertion ((Length (T1) = 5), "** D97: List Length is not correct");
      Share (T1, L1, 2);
      Assertion (Is_Head (L1), "** D98: List is Head is not correct");
      Assertion (not Is_Head (T1), "** D99: List is Head is not correct");
      Predecessor (T1);
      Assertion (Is_Head (T1), "** D100: List is Head is not correct");
      Predecessor (T1);
      Assertion (Is_Null (T1), "** D101: List is not null");
   end Test_Double;

   procedure Test_Double (L1, L2 : in out LD.List);
   procedure Test_Double (L1, L2 : in out LD.List) is
      T1, T2, T3 : LD.List;
   begin
      Test_Double (L1, L2, T1, T2, T3);
   end Test_Double;

   procedure Process (C : in Character; OK : out Boolean);
   procedure Process (C : in Character; OK : out Boolean) is
   begin
      Put_Line ("Item: " & C);
      OK := True;
   end Process;

   procedure Test_Active_Iterator (L : Container'Class);
   procedure Test_Active_Iterator (L : Container'Class) is
      Iter : Iterator'Class := New_Iterator (L);
      Success : Boolean;
      Temp : Character;
   begin
      while not Is_Done (Iter) loop
         Temp := Current_Item (Iter);
         Process (Temp, Success);
         Next (Iter);
      end loop;
   end Test_Active_Iterator;

   procedure Test_Passive_Iterator (L : Container'Class);
   procedure Test_Passive_Iterator (L : Container'Class) is
      procedure Iterate is new Visit (Apply => Process);
      Iter : Iterator'Class := New_Iterator (L);
   begin
      Iterate (Using => Iter);
   end Test_Passive_Iterator;

   procedure Test_Iterator_Deletion (L : in out LS.List);
   procedure Test_Iterator_Deletion (L : in out LS.List) is
      Iter : Iterator'Class := New_Iterator (L);
      Delete : Boolean;
   begin
      Clear (L);
      Append (L, '1');
      Append (L, '2');
      Append (L, '3');
      Append (L, '4');
      Append (L, '5');
      Append (L, '6');
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
         Assertion (False, "** IS01: Deletion succeeded");
      exception
         when BC.Not_Found => null;
         when others =>
            Assertion (False, "** IS02: Unexpected exception");
      end;
      Assertion (Length (L) = 3, "** IS03: List length is not correct");
      Assertion (Head (L) = '1', "** IS04: List item is not correct");
      Remove (L, 1);
      Assertion (Head (L) = '3', "** IS05: List item is not correct");
      Remove (L, 1);
      Assertion (Head (L) = '5', "** IS06: List item is not correct");
      Remove (L, 1);
      Assertion (Length (L) = 0, "** IS07: List length is not zero");
   end Test_Iterator_Deletion;

   procedure Test_Iterator_Deletion (L : in out LD.List);
   procedure Test_Iterator_Deletion (L : in out LD.List) is
      Iter : Iterator'Class := New_Iterator (L);
      Delete : Boolean;
   begin
      Clear (L);
      Append (L, '1');
      Append (L, '2');
      Append (L, '3');
      Append (L, '4');
      Append (L, '5');
      Append (L, '6');
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
         Assertion (False, "** ID01: Deletion succeeded");
      exception
         when BC.Not_Found => null;
         when others =>
            Assertion (False, "** ID02: Unexpected exception");
      end;
      Assertion (Length (L) = 3, "** ID03: List length is not correct");
      Assertion (Head (L) = '1', "** ID04: List item is not correct");
      Remove (L, 1);
      Assertion (Head (L) = '3', "** ID05: List item is not correct");
      Remove (L, 1);
      Assertion (Head (L) = '5', "** ID06: List item is not correct");
      Remove (L, 1);
      Assertion (Length (L) = 0, "** ID07: List length is not zero");
   end Test_Iterator_Deletion;

   Slist_P1, Slist_P2 : LS.List;

   Dlist_P1, Dlist_P2 : LD.List;

begin
   Put_Line ("Starting list tests");

   Put_Line ("...Single List");
   Test_Single (Slist_P1, Slist_P2);

   Put_Line ("...Double List");
   Test_Double (Dlist_P1, Dlist_P2);

   Put_Line ("...List Active Iterator");
   Put_Line ("   Single");
   Test_Active_Iterator (Slist_P1);
   Put_Line ("   Double");
   Test_Active_Iterator (Dlist_P1);

   Put_Line ("...List Passive Iterator");
   Put_Line ("   Single");
   Test_Passive_Iterator (Slist_P1);
   Put_Line ("   Double");
   Test_Passive_Iterator (Dlist_P1);

   Put_Line ("...List Iterator Deletion");
   Put_Line ("   Single:");
   Test_Iterator_Deletion (Slist_P1);
   Put_Line ("   Double:");
   Test_Iterator_Deletion (Dlist_P1);

   Put_Line ("Completed list tests");

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                & Ada.Exceptions.Exception_Name (E)
                & " OCCURRED.");
end List_Test;
