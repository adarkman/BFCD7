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
--  Tests for Auto_Pointers.

with AUnit.Assertions; use AUnit.Assertions;
with AUnit.Test_Cases; use AUnit.Test_Cases;
with Ada.Text_IO; use Ada.Text_IO;

with Ada.Finalization;
with BC.Support.Auto_Pointers;

pragma Warnings (Off, Ada.Text_IO);
--  May not be referenced for released versions

package body Tests.Auto_Pointers is


   type Value is new Ada.Finalization.Controlled with record
      Id : Natural := 0;
      Adjusts : Natural := 0;
   end record;
   procedure Adjust (V : in out Value);
   procedure Finalize (V : in out Value);
   type Value_P is access Value;

   --  Incremented at each call to Value.Finalize.
   --
   --  Remember to zero this after the Value_Pointer has been set.
   Finalizations : Natural;

   package Value_Pointers is new BC.Support.Auto_Pointers (T => Value,
                                                           P => Value_P);


   -----------------------
   --  Test procedures  --
   -----------------------

   procedure Destroy_Owning_Pointer (C : in out Test_Case'Class);
   procedure Destroy_Owning_Pointer (C : in out Test_Case'Class) is
      pragma Unreferenced (C);
   begin
      declare
         Ptr : Value_Pointers.Pointer := Value_Pointers.Create (new Value);
         pragma Unreferenced (Ptr);
      begin
         Finalizations := 0;
      end;
      Assert (Finalizations = 1, "incorrect number of finalizations");
   end Destroy_Owning_Pointer;


   procedure Copy_Pointer (C : in out Test_Case'Class);
   procedure Copy_Pointer (C : in out Test_Case'Class) is
      pragma Unreferenced (C);
      P1, P2 : Value_Pointers.Pointer;
   begin
      P1 := Value_Pointers.Create (new Value);
      Finalizations := 0;
      Value_Pointers.Value (P1).Adjusts := 0;
      Value_Pointers.Value (P1).Id := 42;
      P2 := P1;
      Assert (Value_Pointers.Value (P1) = null, "copied pointer not null");
      Assert (Value_Pointers.Value (P2).Adjusts = 0,
              "wrong number of adjusts");
      Assert (Value_Pointers.Value (P2).Id = 42, "wrong id");
      Assert (Finalizations = 0, "incorrect number of finalizations");
   end Copy_Pointer;


   procedure Return_From_Function (C : in out Test_Case'Class);
   procedure Return_From_Function (C : in out Test_Case'Class) is
      pragma Unreferenced (C);
      function Inner return Value_Pointers.Pointer;
      function Inner return Value_Pointers.Pointer is
         Ptr : constant Value_Pointers.Pointer
           := Value_Pointers.Create (new Value);
      begin
         Value_Pointers.Value (Ptr).Adjusts := 0;
         Value_Pointers.Value (Ptr).Id := 42;
         return Ptr;
      end Inner;
      P : Value_Pointers.Pointer;
   begin
      Finalizations := 0;
      P := Inner;
      Assert (Value_Pointers.Value (P).Adjusts = 0,
              "wrong number of adjusts");
      Assert (Value_Pointers.Value (P).Id = 42, "wrong id");
      Assert (Finalizations = 0, "incorrect number of finalizations");
   end Return_From_Function;


   -----------------------------------------
   --  Support/framework implementations  --
   -----------------------------------------

   procedure Adjust (V : in out Value) is
   begin
      V.Adjusts := V.Adjusts + 1;
   end Adjust;


   procedure Finalize (V : in out Value) is
      pragma Unreferenced (V);
   begin
      Finalizations := Finalizations + 1;
   end Finalize;


   type Case_1 is new Test_Case with null record;
   function Name (C : Case_1) return AUnit.Message_String;
   procedure Register_Tests (C : in out Case_1);


   function Name (C : Case_1) return AUnit.Message_String is
      pragma Warnings (Off, C);
   begin
      return new String'("Auto_Pointers");
   end Name;


   procedure Register_Tests (C : in out Case_1) is
   begin
      Registration.Register_Routine
        (C,
         Destroy_Owning_Pointer'Access,
         "destroying an owning pointer deletes the value");
      Registration.Register_Routine
        (C,
         Copy_Pointer'Access,
         "copying an owning pointer transfers the value");
      Registration.Register_Routine
        (C,
         Return_From_Function'Access,
         "returning from a function transfers the value");
   end Register_Tests;


   ----------------------------
   --  Suite implementation  --
   ----------------------------

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite
        := new AUnit.Test_Suites.Test_Suite;
   begin
      AUnit.Test_Suites.Add_Test (Result, new Case_1);
      return Result;
   end Suite;


end Tests.Auto_Pointers;
