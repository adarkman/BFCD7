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
with Chunks;
with Map_Test_Support;

procedure Map_Test is

   use Ada.Text_IO;
   use Assertions;
   use Map_Test_Support;
   use Containers;
   use Maps;
   use Chunks;

   procedure Process (Key : Character; Item : Chunk_Ptr; OK : out Boolean);
   procedure Process_Modifiable (Key : Character;
                                 Item : in out Chunk_Ptr;
                                 OK : out Boolean);
   procedure Test (M1, M2 : in out Abstract_Map'Class);
   procedure Test_Active_Iterator (M : in out Abstract_Map'Class);
   procedure Test_Passive_Iterator (M : in out Abstract_Map'Class);
   procedure Test_Passive_Modifying_Iterator (M : in out Abstract_Map'Class);
   procedure Test_Simple_Active_Iterator (M : in out Abstract_Map'Class);
   procedure Test_Iterator_Deletion (M : in out Abstract_Map'Class);

   package Iteration_Check is
      type Result is record
         Key : Character;
         Item : Chunks.Chunk_Ptr;
      end record;
      type Results is array (Positive range <>) of Result;
      procedure Reset;
      procedure Register (Key : Character; Item : Chunks.Chunk_Ptr);
      procedure Check (Expected : Results;
                       Message : String;
                       Items_Only : Boolean := False);
   end Iteration_Check;

   package body Iteration_Check is

      Last_Result : Integer := 0;

      The_Results : Results (1 .. 32);

      procedure Reset is
      begin
         Last_Result := 0;
      end Reset;

      procedure Register (Key : Character; Item : Chunks.Chunk_Ptr) is
      begin
         Last_Result := Last_Result + 1;
         The_Results (Last_Result) := (Key => Key, Item => Item);
      end Register;

      procedure Check (Expected : Results;
                       Message : String;
                       Items_Only : Boolean := False) is
      begin
         Assertion (Expected'Length = Last_Result,
                    Message & ", length error");
         if Items_Only then
            for I in Expected'Range loop
               The_Results (I).Key := Expected (I).Key;
            end loop;
         end if;
         if Expected'Length = Last_Result then
            Assertion (Expected = The_Results (1 .. Last_Result),
                       Message & ", mismatch");
         end if;
      end Check;

   end Iteration_Check;

   procedure Test (M1, M2 : in out Abstract_Map'Class) is
   begin
      Assertion (Maps.Is_Empty (M1),
                 "** P01: Map is not initially empty");
      Assertion (Maps.Extent (M1) = 0,
                 "** P02: Map Extent is not initially zero");
      Maps.Bind (M1, '1', Gitems (1)'Access);
      Maps.Bind (M1, '2', Gitems (2)'Access);
      Maps.Bind (M1, '3', Gitems (3)'Access);
      Maps.Bind (M1, '4', Gitems (4)'Access);
      Maps.Bind (M1, '5', Gitems (5)'Access);
      Maps.Bind (M1, '6', Gitems (6)'Access);
      Maps.Bind (M1, '7', Gitems (7)'Access);
      Assertion (not Maps.Is_Empty (M1), "** P03: Map is empty");
      Assertion (Maps.Extent (M1) = 7, "** P04: Map Extent is not correct");
      Assertion (Maps.Is_Bound (M1, '3'),
                 "** P05: Map binding is not correct");
      Maps.Clear (M1);
      Assertion (Maps.Is_Empty (M1), "** P06: Map is not empty");
      Assertion (Maps.Extent (M1) = 0, "** P07: Map Extent is not zero");
      Maps.Bind (M1, '1', Gitems (1)'Access);
      Maps.Bind (M1, '2', Gitems (2)'Access);
      Maps.Bind (M1, '3', Gitems (3)'Access);
      Maps.Bind (M1, '4', Gitems (4)'Access);
      Assertion (not Maps.Is_Empty (M1), "** P08: Map is empty");
      Assertion (Maps.Extent (M1) = 4, "** P09: Map Extent is not correct");
      Assertion (Maps.Is_Bound (M1, '4'),
                 "** P10: Map binding is not correct");
      Maps.Unbind (M1, '1');
      Maps.Unbind (M1, '3');
      Assertion (not Maps.Is_Empty (M1), "** P11: Map is empty");
      Assertion (Maps.Extent (M1) = 2, "** P12: Map Extent is not correct");
      Assertion (Maps.Is_Bound (M1, '2'),
                 "** P13: Map binding is not correct");
      Maps.Unbind (M1, '4');
      Maps.Unbind (M1, '2');
      Assertion (Maps.Is_Empty (M1), "** P14: Map is not empty");
      Assertion (Maps.Extent (M1) = 0, "** P15: Map Extent is not zero");
      Maps.Bind (M1, '5', Gitems (5)'Access);
      Maps.Bind (M1, '6', Gitems (6)'Access);
      Maps.Bind (M1, '7', Gitems (7)'Access);
      Maps.Rebind (M1, '5', Gitems (7)'Access);
      Maps.Rebind (M1, '6', Gitems (6)'Access);
      Maps.Rebind (M1, '7', Gitems (5)'Access);
      Assertion (not Maps.Is_Empty (M1), "** P16: Map is empty");
      Assertion (Maps.Extent (M1) = 3, "** P17: Map Extent is not correct");
      Assertion (Maps.Is_Bound (M1, '7'),
                 "** P18: Map binding is not correct");
      Assertion (Maps.Item_Of (M1, '5') = Gitems (7)'Access,
                 "** P19: Map binding is not correct");
      Assertion (Maps.Item_Of (M1, '6') = Gitems (6)'Access,
                 "** P20: Map binding is not correct");
      Assertion (Maps.Item_Of (M1, '7') = Gitems (5)'Access,
                 "** P21: Map binding is not correct");
      M2 := M1;
      Assertion (not Maps.Is_Empty (M2), "** P22: Map is empty");
      Assertion (Maps.Extent (M2) = 3, "** P23: Map Extent is not correct");
      Assertion (Maps.Is_Bound (M2, '7'),
                 "** P24: Map binding is not correct");
      Assertion (Maps.Item_Of (M2, '5') = Gitems (7)'Access,
                 "** P25: Map binding is not correct");
      Assertion (Maps.Item_Of (M2, '6') = Gitems (6)'Access,
                 "** P26: Map binding is not correct");
      Assertion (Maps.Item_Of (M2, '7') = Gitems (5)'Access,
                 "** P27: Map binding is not correct");
      Assertion (Maps.Are_Equal (M1, M2), "** P28: Maps are not equal");
      Maps.Clear (M2);
      Maps.Bind (M1, '1', Gitems (4)'Access);
      Maps.Bind (M2, '1', Gitems (4)'Access);
      Maps.Bind (M2, '7', Gitems (5)'Access);
      Maps.Bind (M2, '6', Gitems (6)'Access);
      Maps.Bind (M2, '5', Gitems (7)'Access);
      Assertion (Maps.Are_Equal (M1, M2), "** P28a: Maps are not equal");
      Assertion (M1 = M2, "** P28b: Maps are not equal");
      Maps.Rebind (M2, '1', Gitems (1)'Access);
      Assertion (not Maps.Are_Equal (M1, M2), "** P28c: Maps are equal");
      Assertion (M1 /= M2, "** P28d: Maps are equal");
      Maps.Unbind (M2, '1');
      Maps.Bind (M2, '4', Gitems (4)'Access);
      Assertion (not Maps.Are_Equal (M1, M2), "** P28e: Maps are equal");
      Assertion (M1 /= M2, "** P28f: Maps are equal");
      Maps.Clear (M2);
      Maps.Unbind (M1, '1');
      Assertion (not Maps.Is_Empty (M1), "** P29: Map is empty");
      Assertion (Maps.Extent (M1) = 3, "** P30: Map Extent is not correct");
      Assertion (Maps.Is_Bound (M1, '6'),
                 "** P31: Map binding is not correct");
      Assertion (Maps.Is_Empty (M2), "** P32: Map is not empty");
      Assertion (Maps.Extent (M2) = 0, "** P33: Map Extent is not correct");
      Assertion (Maps."/=" (M1, M2), "** P34: Maps equal");
      Assertion (Maps.Is_Bound (M1, '6'),
                 "** P35: Map binding is not correct");
      Maps.Unbind (M1, '6');
      Assertion (not Maps.Is_Bound (M1, '6'),
                 "** P37: Map binding is not correct");
      Maps.Bind (M1, '6', Gitems (6)'Access);
      Assertion (Maps.Is_Bound (M1, '6'),
                 "** P38: Map binding is not correct");
      begin
         Maps.Bind (M1, '6', Gitems (6)'Access);
         Put_Line ("** P40: Map was not already bound");
      exception
         when BC.Duplicate => null;
      end;
      Maps.Unbind (M1, '6');
      begin
         Maps.Rebind (M1, '6', Gitems (6)'Access);
         Put_Line ("** P41: Map was not already unbound");
      exception
         when BC.Not_Found => null;
      end;
      begin
         Maps.Unbind (M1, '6');
         Put_Line ("** P42: Map was not already unbound");
      exception
         when BC.Not_Found => null;
      end;
      Maps.Bind (M1, '6', Gitems (6)'Access);
   end Test;

   procedure Test_Simple_Active_Iterator (M : in out Abstract_Map'Class) is
      Iter : Iterator'Class := New_Iterator (M);
   begin
      Iteration_Check.Reset;
      while not Is_Done (Iter) loop
         Iteration_Check.Register ('x', Current_Item (Iter));
         Next (Iter);
      end loop;
      Iteration_Check.Check ((('6', Gitems (6)'Access),
                              ('7', Gitems (5)'Access),
                              ('5', Gitems (7)'Access)),
                             "I01: standard iterator",
                             Items_Only => True);
   end Test_Simple_Active_Iterator;

   procedure Test_Active_Iterator (M : in out Abstract_Map'Class) is
      Map_Iter : Map_Iterator'Class := Map_Iterator'Class (New_Iterator (M));
      Dummy : Boolean;
   begin
      Iteration_Check.Reset;
      while not Is_Done (Map_Iter) loop
         Process (Current_Key (Map_Iter), Current_Item (Map_Iter), Dummy);
         Next (Map_Iter);
      end loop;
      Iteration_Check.Check ((('6', Gitems (6)'Access),
                              ('7', Gitems (5)'Access),
                              ('5', Gitems (7)'Access)),
                             "I02: active map iterator");
   end Test_Active_Iterator;

   procedure Process (Key : Character; Item : Chunk_Ptr; OK : out Boolean) is
   begin
      Iteration_Check.Register (Key, Item);
      OK := True;
   end Process;

   procedure Process_Modifiable (Key : Character;
                                 Item : in out Chunk_Ptr;
                                 OK : out Boolean) is
   begin
      Iteration_Check.Register (Key, Item);
      OK := True;
   end Process_Modifiable;

   procedure Test_Passive_Iterator (M : in out Abstract_Map'Class) is
      procedure Visitor is new Maps.Visit (Process);
      Map_Iter : Map_Iterator'Class := Map_Iterator'Class (New_Iterator (M));
   begin
      Iteration_Check.Reset;
      Visitor (Using => Map_Iter);
      Iteration_Check.Check ((('6', Gitems (6)'Access),
                              ('7', Gitems (5)'Access),
                              ('5', Gitems (7)'Access)),
                             "I03: passive map iterator");
   end Test_Passive_Iterator;

   procedure Test_Passive_Modifying_Iterator (M : in out Abstract_Map'Class) is
      procedure Modifier is new Maps.Modify (Process_Modifiable);
      Map_Iter : Map_Iterator'Class := Map_Iterator'Class (New_Iterator (M));
   begin
      Iteration_Check.Reset;
      Modifier (Using => Map_Iter);
      Iteration_Check.Check ((('6', Gitems (6)'Access),
                              ('7', Gitems (5)'Access),
                              ('5', Gitems (7)'Access)),
                             "I04: passive modifying map iterator");
   end Test_Passive_Modifying_Iterator;

   procedure Test_Iterator_Deletion (M : in out Abstract_Map'Class) is
      Iter : Map_Iterator'Class := Map_Iterator'Class (New_Iterator (M));
   begin
      Iteration_Check.Reset;
      Clear (M);
      Maps.Bind (M, '1', Gitems (1)'Access);
      Maps.Bind (M, '2', Gitems (2)'Access);
      Maps.Bind (M, '3', Gitems (3)'Access);
      Maps.Bind (M, '4', Gitems (4)'Access);
      Maps.Bind (M, '5', Gitems (5)'Access);
      Maps.Bind (M, '6', Gitems (6)'Access);
      Maps.Bind (M, '7', Gitems (7)'Access);
      Reset (Iter);
      while not Is_Done (Iter) loop
         case Maps.Current_Key (Iter) is
            when '1' | '3' | '5' | '7' =>
               Next (Iter);
            when others =>
               Delete_Item_At (Iter);
         end case;
      end loop;
      begin
         Delete_Item_At (Iter);
         Assertion (False, "** IS01: Deletion succeeded");
      exception
         when BC.Not_Found => null;
         when others =>
            Assertion (False, "** IS02: Unexpected exception");
      end;
      Assertion (Maps.Extent (M) = 4,
                 "IS03: incorrect length" & Integer'Image (Maps.Extent (M)));
      Assertion (Maps.Is_Bound (M, '1'), "IS04a : incorrect membership");
      Assertion (Maps.Is_Bound (M, '3'), "IS04b : incorrect membership");
      Assertion (Maps.Is_Bound (M, '5'), "IS04c : incorrect membership");
      Assertion (Maps.Is_Bound (M, '7'), "IS04d : incorrect membership");
   end Test_Iterator_Deletion;

   type B is record
      Map_B_Pu1 : MB.Map;
      Map_B_Pu2 : MB.Map;
   end record;
   The_B : B := (MB.Null_Container, MB.Null_Container);

   type D is record
      Map_D_Pu1 : MD.Map;
      Map_D_Pu2 : MD.Map;
   end record;
   The_D : D := (MD.Null_Container, MD.Null_Container);

   type U is record
      Map_U_Pu1 : MU.Map;
      Map_U_Pu2 : MU.Map;
   end record;
   The_U : U := (MU.Null_Container, MU.Null_Container);

   type UM is record
      Map_UM_Pu1 : MUM.Map;
      Map_UM_Pu2 : MUM.Map;
   end record;
   The_UM : UM := (MUM.Null_Container, MUM.Null_Container);

begin

   Put_Line ("Starting map tests");
   Put_Line ("...Bounded Map");
   Test (The_B.Map_B_Pu1, The_B.Map_B_Pu2);
   Put_Line ("...Dynamic Map");
   MD.Preallocate (The_D.Map_D_Pu1, 50);
   Test (The_D.Map_D_Pu1, The_D.Map_D_Pu2);
   Put_Line ("...Unbounded Map");
   Test (The_U.Map_U_Pu1, The_U.Map_U_Pu2);
   Put_Line ("...Unmanaged Map");
   Test (The_UM.Map_UM_Pu1, The_UM.Map_UM_Pu2);

   Put_Line ("...Map Simple Active Iterator");
   Put_Line ("   Bounded:");
   Test_Simple_Active_Iterator (The_B.Map_B_Pu1);
   Put_Line ("   Dynamic:");
   Test_Simple_Active_Iterator (The_D.Map_D_Pu1);
   Put_Line ("   Unbounded:");
   Test_Simple_Active_Iterator (The_U.Map_U_Pu1);
   Put_Line ("   Unmanaged:");
   Test_Simple_Active_Iterator (The_UM.Map_UM_Pu1);

   Put_Line ("...Map Active Iterator");
   Put_Line ("   Bounded:");
   Test_Active_Iterator (The_B.Map_B_Pu1);
   Put_Line ("   Dynamic:");
   Test_Active_Iterator (The_D.Map_D_Pu1);
   Put_Line ("   Unbounded:");
   Test_Active_Iterator (The_U.Map_U_Pu1);
   Put_Line ("   Unmanaged:");
   Test_Active_Iterator (The_UM.Map_UM_Pu1);

   Put_Line ("...Map Passive Iterator");
   Put_Line ("   Bounded:");
   Test_Passive_Iterator (The_B.Map_B_Pu1);
   Test_Passive_Modifying_Iterator (The_B.Map_B_Pu1);
   Put_Line ("   Dynamic:");
   Test_Passive_Iterator (The_D.Map_D_Pu1);
   Test_Passive_Modifying_Iterator (The_D.Map_D_Pu1);
   Put_Line ("   Unbounded:");
   Test_Passive_Iterator (The_U.Map_U_Pu1);
   Test_Passive_Modifying_Iterator (The_U.Map_U_Pu1);
   Put_Line ("   Unmanaged:");
   Test_Passive_Iterator (The_UM.Map_UM_Pu1);
   Test_Passive_Modifying_Iterator (The_UM.Map_UM_Pu1);

   Put_Line ("...Map Iterator Deletion");
   Put_Line ("   Bounded:");
   declare
      M : MB.Map;
   begin
      Test_Iterator_Deletion (M);
   end;
   Put_Line ("   Dynamic:");
   declare
      M : MD.Map;
   begin
      Test_Iterator_Deletion (M);
   end;
   Put_Line ("   Unbounded:");
   declare
      M : MU.Map;
   begin
      Test_Iterator_Deletion (M);
   end;
   Put_Line ("   Unmanaged:");
   declare
      M : MUM.Map;
   begin
      Test_Iterator_Deletion (M);
   end;

   Assertion (MB.Is_Bound (The_B.Map_B_Pu1, '6'),
              "** M01: Map binding is not correct");
   Assertion (MB.Extent (The_B.Map_B_Pu2) = 0,
              "** M02: Map Extent is not correct");
   Assertion (MD.Is_Bound (The_D.Map_D_Pu1, '6'),
              "** M03: Map binding is not correct");
   Assertion (MD.Extent (The_D.Map_D_Pu2) = 0,
              "** M04: Map Extent is not correct");
   Assertion (MU.Is_Bound (The_U.Map_U_Pu1, '6'),
              "** M05: Map binding is not correct");
   Assertion (MU.Extent (The_U.Map_U_Pu2) = 0,
              "** M06: Map Extent is not correct");
   --  I don't understand this one ..
   declare
      Map_D_Pu3 : constant MD.Map := The_D.Map_D_Pu1;
   begin
      Assertion (MD."=" (The_D.Map_D_Pu1, Map_D_Pu3),
                 "** M08: Maps are not equal");
   end;
   declare
      Map_U_Pu3 : constant MU.Map := The_U.Map_U_Pu1;
   begin
      Assertion (MU."=" (The_U.Map_U_Pu1, Map_U_Pu3),
                 "** M09: Maps are not equal");
   end;
   Assertion (MB.Available (The_B.Map_B_Pu1) = 97,
              "** M10: Available space is not correct");
   Assertion (MB.Available (The_B.Map_B_Pu2) = 100,
              "** M11: Available space is not correct");
   Put_Line ("Completed map tests");

   Assertions.Report;

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                & Ada.Exceptions.Exception_Name (E)
                & " OCCURRED.");
end Map_Test;
