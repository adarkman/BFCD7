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
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with BC.Containers.Trees.Binary.In_Order;
with BC.Containers.Trees.Binary.Pre_Order;
with BC.Containers.Trees.Binary.Post_Order;
with BC.Containers.Trees.Multiway.Pre_Order;
with BC.Containers.Trees.Multiway.Post_Order;
with Tree_Test_Support;

procedure Tree_Test is

   use Ada.Text_IO;
   use Tree_Test_Support;

   procedure Assertion (Cond : Boolean; Message : String);
   procedure Assertion (Cond : Boolean; Message : String) is
   begin
      if not Cond then
         Put_Line (Message);
      end if;
   end Assertion;

   --  I used this while trying to figure out my booboos. An example
   --  (not particularly good) of how to approach tree traversal,
   --  using the functional interfaces Left_Child, Right_Child rather
   --  than the procedural ones.
   procedure Print_Tree (T : TB.Binary_Tree;
                         Message : String := "";
                         Depth : Natural := 0);
   procedure Print_Tree (T : TB.Binary_Tree;
                         Message : String := "";
                         Depth : Natural := 0) is
      use TB;
      procedure Indent (To : Natural := Depth);
      procedure Indent (To : Natural := Depth) is
      begin
         for N in 1 .. Integer (To) loop
            Put ("  ");
         end loop;
      end Indent;
   begin
      if Depth = 0 then
         Put ("Binary tree: " & Message & " ");
      end if;
      if Is_Null (T) then
         Put_Line ("(null)");
      else
         if Is_Root (T) then
            Put ("(root) ");
         end if;
         Put_Line (":= " & Item_At (T));
         if Has_Children (T) then
            Indent;
            Put ("L ");
            Print_Tree (Left_Child (T), Depth => Depth + 1);
            Indent;
            Put ("R ");
            Print_Tree (Right_Child (T), Depth => Depth + 1);
         end if;
      end if;
   end Print_Tree;

   procedure Test_Primitive (T1, T2 : in out TB.Binary_Tree);
   procedure Test_Primitive (T1, T2 : in out TB.Binary_Tree) is
      use TB;
      Tt1, Tt2, Tt3 : Binary_Tree;
   begin
      Clear (T1);
      Assertion (Is_Null (T1), "** B01: Tree is not initially null");
      Assertion (not Is_Shared (T1), "** B02: Tree is initially shared");
      Insert (T1, '1', Left);
      Insert (T1, '2', Right);
      Insert (T1, '3', Left);
      Insert (T1, '4', Right);
      Assertion (not Is_Null (T1), "** B03: Tree is empty");
      Assertion (Item_At (T1) = '4', "** B04: Tree item is not correct");
      Assertion (not Is_Shared (T1), "** B05: Tree is shared");
      Right_Child (T1);
      Assertion (Item_At (T1) = '3', "** B06: Tree item is not correct");
      Left_Child (T1);
      Assertion (Item_At (T1) = '2', "** B07: Tree item is not correct");
      Right_Child (T1);
      Assertion (Item_At (T1) = '1', "** B08: Tree item is not correct");
      Left_Child (T1);
      Assertion (Is_Null (T1), "** B09: Tree is not empty");
      Append (T1, '4', Left, Left);
      Append (T1, '1', Left, Left);
      Append (T1, '2', Left, Left);
      Append (T1, '3', Right, Left);
      Tt1 := T1;
      Tt2 := T1;
      Clear (Tt1);
      --  I know the next test number is out-of-order; this is a copy
      --  of the C++ test
      Assertion (Item_At (T1) = '4', "** B09: Tree item is not correct");
      Child (T1, Left);
      Assertion (Item_At (T1) = '3', "** B10: Tree item is not correct");
      Child (T1, Right);
      Assertion (Item_At (T1) = '2', "** B11: Tree item is not correct");
      Child (T1, Left);
      Assertion (Item_At (T1) = '1', "** B12: Tree item is not correct");
      Child (T1, Right);
      Assertion (Is_Null (T1), "** B13: Tree is not empty");
      Assertion (Is_Null (Tt1), "** B14: Tree is not empty");
      Assertion (not Is_Null (Tt2), "** B15: Tree is empty");
      T2 := Tt2;
      Share (Tt3, T2, Left);
      Share (Tt3, Tt3, Right);
      Share (Tt3, Tt3, Left);
      Assertion (T2 = Tt2, "** B16: Trees are not equal");
      Assertion (T2 /= Tt3, "** B17: Trees are equal");
      Assertion (Item_At (T2) = '4', "** B18: Tree item is not correct");
      Assertion (Item_At (Tt3) = '1', "** B19: Tree item is not correct");
      Assertion (Has_Children (T2), "** B20: Tree has no children");
      Assertion (not Has_Children (Tt3), "** B21: Tree has children");
      Assertion (Is_Root (T2), "** B22: Tree is not root");
      Assertion (not Is_Root (Tt3), "** B23: Tree is root");
      Clear (Tt2);
      T1 := Tt3;
      Clear (Tt3);
      Parent (T1);
      Assertion (Item_At (T1) = '2', "** B24: Tree item is not correct");
      Parent (T1);
      Assertion (Item_At (T1) = '3', "** B25: Tree item is not correct");
      Parent (T1);
      Assertion (Item_At (T1) = '4', "** B26: Tree item is not correct");
      Set_Item (T1, '7');
      Parent (T1);
      Assertion (Is_Null (T1), "** B27: Tree is not null");
      Assertion (Item_At (T2) = '7', "** B27: Tree item is not correct");
      Insert (T1, '5', Left);
      Append (T1, '6', Left, Left);
      Append (T1, '7', Right, Right);
      Tt2 := T1;
      Assertion (Item_At (Tt2) = '5', "** B28: Tree item is not correct");
      Child (Tt2, Left);
      Assertion (Item_At (Tt2) = '6', "** B29: Tree item is not correct");
      Remove (T1, Left);
      Assertion (Item_At (Tt2) = '6', "** B30: Tree item is not correct");
      Tt2 := T1;
      Child (Tt2, Right);
      Assertion (Item_At (Tt2) = '7', "** B31: Tree item is not correct");
      Remove (T1, Right);
      Assertion (Item_At (Tt2) = '7',  "** B32: Tree item is not correct");
      Clear (Tt2);
      Append (T1, '6', Left, Left);
      Append (T1, '7', Right, Right);
      Swap_Child (T1, T2, Left);
      Tt1 := T1;
      Child (Tt1, Left);
      Assertion (Item_At (T2) = '6', "** B33: Tree item is not correct");
      Assertion (not Has_Children (T2), "** B34: Tree has children");
      Assertion (Is_Root (T2), "** B35: Tree is not root");
      Assertion (Item_At (Tt1) = '7', "** B36: Tree item is not correct");
      Assertion (Has_Children (Tt1), "** B37: Tree has no children");
      Assertion (not Is_Root (Tt1), "** B38: Tree is not root");
      Parent (Tt1);
      Assertion (T1 = Tt1, "** B39: Trees are not equal");
      Child (Tt1, Left);
      Assertion (Item_At (Tt1) = '7', "** B40: Tree item is not correct");
   end Test_Primitive;

   B_Tree_P1, B_Tree_P2 : TB.Binary_Tree;

   procedure Test_Primitive (T1, T2 : in out TM.Multiway_Tree);
   procedure Test_Primitive (T1, T2 : in out TM.Multiway_Tree) is
      use TM;
      Tt1, Tt2, Tt3 : Multiway_Tree;
   begin
      Assertion (Is_Null (T1), "** M01: Tree is not initially null");
      Assertion (not Is_Shared (T1), "** M02: Tree is initially shared");
      Insert (T1, '1');
      Insert (T1, '2');
      Insert (T1, '3');
      Insert (T1, '4');
      Assertion (not Is_Null (T1), "** M03: Tree is empty");
      Assertion (Item_At (T1) = '4', "** M04: Tree item is not correct");
      Assertion (not Is_Shared (T1), "** M05: Tree is shared");
      Assertion (Arity (T1) = 1, "** M06: Tree arity is not correct");
      Child (T1, 1);
      Assertion (Item_At (T1) = '3', "** M07: Tree item is not correct");
      Assertion (Arity (T1) = 1, "** M08: Tree arity is not correct");
      Child (T1, 1);
      Assertion (Item_At (T1) = '2', "** M09: Tree item is not correct");
      Assertion (Arity (T1) = 1, "** M10: Tree arity is not correct");
      Child (T1, 1);
      Assertion (Item_At (T1) = '1', "** M11: Tree item is not correct");
      Assertion (Arity (T1) = 0, "** M12: Tree arity is not correct");
      Clear (T1);
      Assertion (Is_Null (T1), "** M13: Tree is not empty");
      Insert (T1, '6');
      Append (T1, '2');
      Append (T1, '3');
      Append (T1, '5');
      Tt1 := T1;
      Tt2 := T1;
      Clear (Tt2);
      Assertion (Item_At (T1) = '6', "** M14: Tree item is not correct");
      Assertion (Arity (T1) = 3, "** M15: Tree arity is not correct");
      Child (T1, 1);
      Assertion (Item_At (T1) = '2', "** M16: Tree item is not correct");
      Parent (T1);
      Assertion (Item_At (T1) = '6', "** M17: Tree item is not correct");
      Child (T1, 2);
      Assertion (Item_At (T1) = '3', "** M18: Tree item is not correct");
      Parent (T1);
      Assertion (Item_At (T1) = '6', "** M19: Tree item is not correct");
      Child (T1, 3);
      Assertion (Item_At (T1) = '5', "** M20: Tree item is not correct");
      T2 := Tt1;
      Append (T2, '4', 1);
      Append (T2, '1', 4);
      Parent (T1);
      Child (T1, 2);
      Assertion (Item_At (T1) = '4', "** M21: Tree item is not correct");
      Parent (T1);
      Child (T1, 5);
      Assertion (Item_At (T1) = '1', "** M22: Tree item is not correct");
      Assertion (not Is_Root (T1), "** M23: Tree is root");
      Assertion (not Has_Children (T1), "** M24: Tree has children");
      Parent (T1);
      Clear (T2);
      Assertion (Tt1 = T1, "** M25: Trees are not equal");
      Set_Item (Tt1, '7');
      Assertion (Item_At (T1) = '7', "** M26: Tree item is not correct");
      Clear (Tt1);
      Assertion (Tt1 /= T1, "** M27: Trees are equal");
      Assertion (Is_Root (T1), "** M28: Tree is root");  -- hmm
      Assertion (Has_Children (T1), "** M29: Tree has children");  -- hmm
      Share (T2, T1, 3);
      Assertion (Item_At (T2) = '3',  "** M30: Tree item is not correct");
      Share (Tt1, T1, 1);
      Assertion (Item_At (Tt1) = '2',  "** M31: Tree item is not correct");
      Share (Tt2, T1, 5);
      Assertion (Item_At (Tt2) = '1',  "** M32: Tree item is not correct");
      Append (T2, '8');
      Append (T2, '9');
      Insert (Tt3, '1');
      Insert (Tt3, '2');
      Insert (Tt3, '3');
      Swap_Child (T1, Tt3, 1);
      Assertion (Tt1 = Tt3, "** M33: Trees are not equal");
      Tt1 := T1;
      Child (Tt1, 1);
      Assertion (Item_At (Tt1) = '3',  "** M34: Tree item is not correct");
      Assertion (Has_Children (Tt1), "** M35: Tree has no children");
      Assertion (not Has_Children (Tt3), "** M36: Tree has children");
      Assertion (Item_At (Tt3) = '2',  "** M37: Tree item is not correct");
      Clear (Tt3);
      Remove (T1, 2);
      Tt3 := T1;
      Child (Tt3, 2);
      Assertion (Tt3 = T2, "** M38: Trees are not equal");
      Clear (Tt3);
      Assertion (not Is_Root (Tt1), "** M39: Tree is root");
      Remove (T1, 1);
      Assertion (Is_Root (Tt1), "** M40: Tree is root");  -- hmm
      Assertion (Arity (T1) = 3, "** M41: Tree arity is not correct");
      Tt3 := T1;
      Child (Tt3, 1);
      Assertion (Tt3 = T2, "** M42: Trees are not equal");
      Clear (Tt3);
      Clear (T1);
      Assertion (Is_Null (T1), "** M43: Tree is not null");
      Assertion (Is_Root (T2), "** M44: Tree is not root");
      Assertion (Item_At (T2) = '3', "** M45: Tree item is not correct");
      Assertion (Is_Root (Tt2), "** M46: Tree is not root");
      Assertion (Item_At (Tt2) = '1', "** M47: Tree item is not correct");
   end Test_Primitive;

   M_Tree_P1, M_Tree_P2 : TM.Multiway_Tree;

   --   procedure Print_Tree is new TA.Print (Character'Image);

   procedure Test_Primitive (T : in out TA.AVL_Tree);
   procedure Test_Primitive (T : in out TA.AVL_Tree) is
      procedure Process (C : Character; Result : out Boolean);
      procedure Process (C : Character; Result : out Boolean) is
      begin
         Put_Line ("      Item: " & C);
         Result := True;
      end Process;
      procedure Visit is new TA.Visit (Process);
      T2 : TA.AVL_Tree;
      use TA;
      Result : Boolean;
   begin
      Assertion (Is_Null (T), "** A01: Tree is not null");
      Insert (T, '4', Result);
      Assertion (Result, "** A02: Tree insertion not correct");
      Insert (T, '5', Result);
      Assertion (Result, "** A03: Tree insertion not correct");
      Insert (T, '7', Result);
      Assertion (Result, "** A04: Tree insertion not correct");
      Insert (T, '2', Result);
      Assertion (Result, "** A05: Tree insertion not correct");
      Insert (T, '1', Result);
      Assertion (Result, "** A06: Tree insertion not correct");
      Insert (T, '3', Result);
      Assertion (Result, "** A07: Tree insertion not correct");
      Insert (T, '6', Result);
      Assertion (Result, "** A08: Tree insertion not correct");
      Assertion (Is_Member (T, '3'), "** A09: Tree membership is not correct");
      Assertion (Is_Member (T, '7'), "** A10: Tree membership is not correct");
      Assertion (not Is_Member (T, 'g'),
                 "** A11: Tree membership is not correct");
      Assertion (not Is_Null (T), "** A12: Tree is null");
      Insert (T, '8', Result);
      Assertion (Result, "** A13: Tree insertion not correct");
      Insert (T, '9', Result);
      Assertion (Result, "** A14: Tree insertion not correct");
      Insert (T, 'A', Result);
      Assertion (Result, "** A15: Tree insertion not correct");
      Insert (T, 'B', Result);
      Assertion (Result, "** A16: Tree insertion not correct");
      Visit (T);
      T2 := T;
      Delete (T, '3', Result);
      Assertion (Result, "** A17: Tree deletion is not correct");
      Delete (T, 'g', Result);
      Assertion (not Result, "** A18: Tree deletion is not correct");
      Delete (T, '5', Result);
      Assertion (Result, "** A19: Tree deletion is not correct");
      Delete (T, 'A', Result);
      Assertion (Result, "** A20: Tree deletion is not correct");
      Delete (T, 'A', Result);
      Assertion (not Result, "** A21: Tree deletion is not correct");
      Delete (T, '8', Result);
      Assertion (Result, "** A22: Tree deletion is not correct");
      Delete (T, '4', Result);
      Assertion (Result, "** A23: Tree deletion is not correct");
      Delete (T, '9', Result);
      Assertion (Result, "** A24: Tree deletion is not correct");
      Delete (T, '2', Result);
      Assertion (Result, "** A25: Tree deletion is not correct");
      Delete (T, '6', Result);
      Assertion (Result, "** A26: Tree deletion is not correct");
      Delete (T, '1', Result);
      Assertion (Result, "** A27: Tree deletion is not correct");
      Delete (T, 'B', Result);
      Assertion (Result, "** A28: Tree deletion is not correct");
      Delete (T, '7', Result);
      Assertion (Result, "** A29: Tree deletion is not correct");
      Assertion (Is_Null (T), "** A30: Tree is not null");
      Insert (T, '4', Result);
      Insert (T, '5', Result);
      Insert (T, '7', Result);
      Insert (T, '2', Result);
      Assertion (Extent (T) = 4, "** A31: Tree extent is not correct");
      Delete (T, '4', Result);
      Assertion (Result, "** A32: Tree deletion is not correct");
      Clear (T);
      Assertion (Extent (T) = 0, "** A33: Tree extent is not correct");
      Assertion (Is_Null (T), "** A34: Tree is not null");
      Assertion (T /= T2, "** A35: Trees are equal");
      for C in Character'('1') .. Character'('9') loop
         Insert (T, C, Result);
      end loop;
      for C in Character'('a') .. Character'('b') loop
         Insert (T, C, Result);
      end loop;
      Assertion (T /= T2, "** A36: Trees are equal");
      for C in Character'('A') .. Character'('B') loop
         Insert (T, C, Result);
      end loop;
      Assertion (T /= T2, "** A37: Trees are equal");
      for C in Character'('a') .. Character'('b') loop
         Delete (T, C, Result);
      end loop;
      Assertion (T = T2, "** A38: Trees are not equal");
      Delete (T2, 'B', Result);
      Assertion (T /= T2, "** A39: Trees are equal");
      Clear (T2);
      Assertion (T /= T2, "** A40: Trees are equal");
      Clear (T);
      Assertion (T = T2, "** A41: Trees are not equal");
   end Test_Primitive;

   A_Tree_P1 : TA.AVL_Tree;

   procedure Test_Binary_Iteration;
   procedure Test_Binary_Iteration is
      T, T1, T2 : TB.Binary_Tree;
      procedure Process_Item (C : Character; Success : out Boolean);
      procedure Process_Item (C : Character; Success : out Boolean) is
      begin
         Put_Line ("      Visit " & C);
         Success := True;
      end Process_Item;
      procedure Binary_Pre_Order is new TB.Pre_Order (Process_Item);
      procedure Binary_In_Order is new TB.In_Order (Process_Item);
      procedure Binary_Post_Order is new TB.Post_Order (Process_Item);
      Success : Boolean;
      use TB;
   begin
      Insert (T1, 'h', Right);
      Insert (T1, 'g', Right);
      Insert (T1, 'e', Right);
      Insert (T2, 'f', Left);
      Swap_Child (T1, T2, Left);
      Insert (T, 'd', Left);
      Insert (T, 'c', Left);
      Insert (T, 'b', Left);
      Swap_Child (T, T1, Right);
      Insert (T, 'a', Left);
      Insert (T1, 'k', Right);
      Insert (T1, 'i', Right);
      Insert (T2, 'j', Left);
      Swap_Child (T1, T2, Left);
      Swap_Child (T, T1, Right);
      Put_Line ("...Binary Pre-Order Scan");
      Binary_Pre_Order (T, Success);
      Put_Line ("...Binary In-Order Scan");
      Binary_In_Order (T, Success);
      Put_Line ("...Binary Post-Order Scan");
      Binary_Post_Order (T, Success);
   end Test_Binary_Iteration;

   procedure Test_Multiway_Iteration;
   procedure Test_Multiway_Iteration is
      T, T1, T2 : TM.Multiway_Tree;
      function To_String (The_Tree : TM.Multiway_Tree) return String;
      function To_String
        (The_Tree : TM.Multiway_Tree) return String is
         use Ada.Strings.Unbounded;
         use TM;
      begin
         if Is_Null (The_Tree) then
            return "()";
         elsif Has_Children (The_Tree) then
            declare
               Result : Unbounded_String
                 := To_Unbounded_String ("(" & Item_At (The_Tree));
               T : Multiway_Tree;
            begin
               for C in 1 .. Arity (The_Tree) loop
                  T := The_Tree;
                  Child (T, C);
                  Result := Result & " " & To_String (T);
               end loop;
               return To_String (Result) & ")";
            end;
         else
            return "" & Item_At (The_Tree);
         end if;
      end To_String;
      procedure Process_Item (C : Character; Success : out Boolean);
      Traversal : String (1 .. 128);
      Last : Natural;
      procedure Process_Item (C : Character; Success : out Boolean) is
      begin
         Last := Last + 1;
         Traversal (Last) := C;
         Success := True;
      end Process_Item;
      procedure Multiway_Pre_Order is new TM.Pre_Order (Process_Item);
      procedure Multiway_Post_Order is new TM.Post_Order (Process_Item);
      Success : Boolean;
      use TM;
   begin
      Insert (T, 'd');
      Insert (T, 'c');
      Insert (T1, 'e');
      Append (T, T1);
      Clear (T1);
      Insert (T1, 'f');
      Append (T, T1);
      Clear (T1);
      Insert (T, 'b');
      Insert (T1, 'g');
      Append (T, T1);
      Clear (T1);
      Insert (T1, 'h');
      Append (T, T1);
      Clear (T1);
      Insert (T1, 'i');
      Append (T, T1);
      Clear (T1);
      Insert (T, 'a');
      Insert (T1, 'l');
      Insert (T1, 'k');
      Insert (T2, 'm');
      Append (T1, T2);
      Clear (T2);
      Insert (T1, 'j');
      Insert (T2, 'n');
      Append (T1, T2);
      Clear (T2);
      Insert (T2, 'p');
      Insert (T2, 'o');
      Append (T1, T2);
      Clear (T2);
      Append (T, T1);
      Clear (T1);
      Put_Line (To_String (T));
      Put_Line ("...Multiway Pre-Order Scan");
      Last := 0;
      Multiway_Pre_Order (T, Success);
      Assertion (Traversal (1 .. Last) = "abcdefghijklmnop",
                 "** MI01, pre-order mismatch");
      Put_Line ("...Multiway Post-Order Scan");
      Last := 0;
      Multiway_Post_Order (T, Success);
      Assertion (Traversal (1 .. Last) = "defcghiblmknpoja",
                 "** MI02, post-order mismatch");
   end Test_Multiway_Iteration;

   procedure Test_AVL_Iteration;
   procedure Test_AVL_Iteration is
      procedure Print (C : Character; OK : out Boolean);
      procedure Print is new Containers.Visit (Print);
      procedure Print (C : Character; OK : out Boolean) is
      begin
         OK := True;
         Put (C);
      end Print;
      T : TA.AVL_Tree;
      It : Containers.Iterator'Class := TA.New_Iterator (T);
      Dummy : Boolean;
      Input : constant String := "qwertyuiopasdfghjklzxcvbnm";
   begin
      Put_Line ("...AVL iteration (empty)");
      Containers.Reset (It);
      Print (It);
      New_Line;
      Containers.Reset (It);
      while not Containers.Is_Done (It) loop
         Put (Containers.Current_Item (It));
         Containers.Next (It);
      end loop;
      New_Line;
      Put_Line ("...AVL iteration (one element)");
      TA.Clear (T);
      TA.Insert (T, '1', Dummy);
      Containers.Reset (It);
      Print (It);
      New_Line;
      Containers.Reset (It);
      while not Containers.Is_Done (It) loop
         Put (Containers.Current_Item (It));
         Containers.Next (It);
      end loop;
      New_Line;
      Put_Line ("...AVL iteration (many elements)");
      TA.Clear (T);
      for C in Input'Range loop
         TA.Insert (T, Input (C), Dummy);
      end loop;
      Containers.Reset (It);
      Print (It);
      New_Line;
      Containers.Reset (It);
      while not Containers.Is_Done (It) loop
         Put (Containers.Current_Item (It));
         Containers.Next (It);
      end loop;
      New_Line;
   end Test_AVL_Iteration;

begin

   Put_Line ("Starting Tree tests");

   Put_Line ("...Binary Tree");
   Test_Primitive (B_Tree_P1, B_Tree_P2);
   Test_Binary_Iteration;
   Print_Tree (B_Tree_P1);

   Put_Line ("...Multiway Tree");
   Test_Primitive (M_Tree_P1, M_Tree_P2);
   Test_Multiway_Iteration;

   Put_Line ("...AVL Tree");
   Test_Primitive (A_Tree_P1);
   Test_AVL_Iteration;

   Put_Line ("Completed Tree tests");

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                & Ada.Exceptions.Exception_Name (E)
                & " OCCURRED.");
end Tree_Test;
