--  Copyright Simon Wright <simon@pushface.org>

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

--  $Revision$
--  $Date$
--  $Author$
--
--  Tests for AVL Trees.

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with Ada.Text_IO; use Ada.Text_IO;

with BC.Containers.Trees;
with BC.Containers.Trees.AVL;
with Global_Heap;

with Tests.Support;

pragma Warnings (Off, Ada.Text_IO);
--  May not be referenced for released versions

package body Tests.AVL_Trees is

   package Containers is new BC.Containers
     (Item => Tests.Support.Item,
      "=" => Tests.Support."=");

   package Trees is new Containers.Trees;

   package TA is new Trees.AVL
     (Storage => Global_Heap.Storage,
      "<" => Tests.Support ."<");
   use TA;

   function To_String (The_Tree : AVL_Tree) return String;

   subtype Item is Tests.Support.Item;
   use type Tests.Support.Item;


   type Case_1 is new Test_Case with null record;
   function Name (C : Case_1) return AUnit.Message_String;
   procedure Register_Tests (C : in out Case_1);


   -----------------------
   --  Test procedures  --
   -----------------------

   procedure Initially_Empty (C : in out Test_Case'Class);
   procedure Initially_Empty (C : in out Test_Case'Class) is
      pragma Unreferenced (C);
      T : AVL_Tree;
   begin
      Assert (To_String (T) = "",
              "expecting """", got """ & To_String (T) & """");
      Assert (Extent (T) = 0, "extent not 0");
      Assert (Is_Null (T), "tree not null");
      Assert (not Is_Member (T, Item'('a', 0)), "('a', 0) is a member");
      declare
         Found : Boolean := True;
      begin
         Delete (T, Item'('a', 0), Found);
         Assert (not Found, "('a', 0) found on deletion");
      end;
   end Initially_Empty;


   procedure One_Element (C : in out Test_Case'Class);
   procedure One_Element (C : in out Test_Case'Class) is
      pragma Unreferenced (C);
      T : AVL_Tree;
      Not_Found : Boolean;
   begin
      Not_Found := False;
      Insert (T, Item'('a', 0), Not_Found);
      Assert (Not_Found, "('a', 0) was found");
      Assert (To_String (T) = "a",
              "expecting ""a"", got """ & To_String (T) & """");
      Assert (Extent (T) = 1, "extent not 1");
      Assert (not Is_Null (T), "tree is null");
      Assert (Is_Member (T, Item'('a', 0)), "('a', 0) is not a member");
      Assert (Is_Member (T, Item'('a', 1)), "('a', 1) is not a member");
      Assert (Is_Member (T, Item'('A', 0)), "('A', 0) is not a member");
      Assert (not Is_Member (T, Item'('b', 0)), "('b', 0) is a member");
      Assert (not Is_Member (T, Item'('B', 0)), "('B', 0) is a member");
      declare
         T2 : AVL_Tree := T;
         Found : Boolean := False;
      begin
         Delete (T2, Item'('a', 0), Found);
         Assert (Found, "('a', 0) found on deletion");
         Assert (Extent (T2) = 0, "extent not 0 after deleting ('a', 0)");
      end;
      declare
         T2 : AVL_Tree := T;
         Found : Boolean := False;
      begin
         Delete (T2, Item'('A', 0), Found);
         Assert (Found, "('A', 0) found on deletion");
         Assert (Extent (T2) = 0, "extent not 0 after deleting ('A', 0)");
      end;
      declare
         Found : Boolean := True;
      begin
         Delete (T, Item'('b', 0), Found);
         Assert (not Found, "('b', 0) found on deletion");
      end;
      Not_Found := True;
      Insert (T, Item'('a', 1), Not_Found);
      Assert (not Not_Found, "('a', 1) was not found");
      Assert (Extent (T) = 1, "extent not 1 after inserting ('a', 1)");
      Not_Found := True;
      Insert (T, Item'('A', 2), Not_Found);
      Assert (not Not_Found, "('A', 2) was not found");
      Assert (Extent (T) = 1, "extent not 1 after inserting ('A', 2)");
   end One_Element;


   ----------------------------------------
   --  Support/framework implementations --
   ----------------------------------------

   function To_String
     (The_Tree : AVL_Tree) return String is
      procedure Add_Char (Elem : Support.Item; OK : out Boolean);
      procedure Get_Result is new Visit (Apply => Add_Char);
      Result : String (1 .. Extent (The_Tree));
      Last : Natural := 0;
      procedure Add_Char (Elem : Support.Item; OK : out Boolean) is
      begin
         OK := True;
         Last := Last + 1;
         Result (Last) := Elem.C;
      end Add_Char;
   begin
      Get_Result (The_Tree);
      pragma Assert (Last = Result'Last, "too short");
      return Result;
   end To_String;


   function Name (C : Case_1) return AUnit.Message_String is
      pragma Warnings (Off, C);
   begin
      return new String'("AVL Trees");
   end Name;


   procedure Register_Tests (C : in out Case_1) is
   begin
      Registration.Register_Routine
        (C,
         Initially_Empty'Access,
         "tests with no elements");
      Registration.Register_Routine
        (C,
         One_Element'Access,
         "tests with one element");
   end Register_Tests;


   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite
        := new AUnit.Test_Suites.Test_Suite;
   begin
      AUnit.Test_Suites.Add_Test (Result, new Case_1);
      return Result;
   end Suite;


end Tests.AVL_Trees;
