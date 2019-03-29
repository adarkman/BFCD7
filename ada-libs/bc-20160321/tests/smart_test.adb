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

with Ada.Calendar;
with Ada.Exceptions;
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
with Smart_Test_Support;

procedure Smart_Test is

   use Ada.Text_IO;
   use Smart_Test_Support;

begin

   --  Logic tests.
   declare
      A : Smart.Pointer;
      B : Smart.Pointer := A;
      C : Smart.Pointer;
   begin

      Put_Line ("creating m, assigning to a");
      A := Create ('m');
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("assigning a to a");
      A := A;
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("assigning b to b");
      B := B;
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("assigning a to c");
      C := A;
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("assigning a to b");
      B := A;
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("assigning a to a");
      A := A;
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("creating n, assigning to a");
      A := Create ('n');
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("creating o, assigning to a");
      A := Create ('o');
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("assigning a to b");
      B := A;
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("creating p, assigning to c");
      C := Create ('p');
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("creating q, assigning to b");
      B := Create ('q');
      Put_Line ("a " & Value (A) & ", b " & Value (B) & ", c " & Value (C));

      Put_Line ("logic tests done.");

      Put_Line ("idempotency of finalization...");
      A := B;
      Smart_Test_Finalize (A);
      Put_Line ("finalized a, b " & Value (B));
      Smart_Test_Finalize (A);
      Put_Line ("finalized a again, b " & Value (B));
      Put_Line ("idempotency of finalization done.");

   end;

   --  Timing tests.
   declare
      procedure Free is new Ada.Unchecked_Deallocation
        (Character, Character_P);
      Start, Finish : Ada.Calendar.Time;
      use type Ada.Calendar.Time;
   begin

      Start := Ada.Calendar.Clock;
      for I in 1 .. 1_000 loop
         declare
            C_P : Character_P;
         begin
            C_P := new Character'('0');
            Free (C_P);
         end;
      end loop;
      Finish := Ada.Calendar.Clock;
      Put_Line ("a plain allocation took"
                  & Duration'Image ((Finish - Start) / 1_000.0)
                  & " s.");

      Start := Ada.Calendar.Clock;
      for I in 1 .. 1_000 loop
         declare
            C_P : Smart_Characters.Pointer;
         begin
            C_P := Smart_Characters.Create (new Character'('0'));
            C_P := Smart_Characters.Null_Pointer;
         end;
      end loop;
      Finish := Ada.Calendar.Clock;
      Put_Line ("a smart allocation took"
                  & Duration'Image ((Finish - Start) / 1_000.0)
                  & " s.");

   end;

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                  & Ada.Exceptions.Exception_Name (E)
                  & " OCCURRED.");
end Smart_Test;
