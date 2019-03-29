
--  Copyright 2001-2002 Simon Wright <simon@pushface.org>

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

with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with Storage_Timing_Support; use Storage_Timing_Support;

procedure Storage_Timing is

   use Abstract_Collections;

   procedure Time_It (Remark : String;
                      C : in out Abstract_Collection'Class);
   procedure Time_It (Remark : String;
                      C : in out Abstract_Collection'Class) is
      Start : Time;
      Took : Duration;
   begin
      Clear (C);
      Start := Clock;
      for I in 1 .. 1_000 loop
         Append (C, I);
      end loop;
      for I in reverse 1 .. 500 loop
         Remove (C, I * 2);
      end loop;
      for I in 1 .. 500 loop
         Append (C, I * 2, After => I);
      end loop;
      Took := Clock - Start;
      Put_Line (Remark & ":" & Duration'Image (Took * 1_000_000) & " uS");
   end Time_It;

   B : Bounded_Collections.Collection;
   D : Dynamic_Collections.Collection;
   M : Managed_Collections.Collection;
   U : Unmanaged_Collections.Collection;

begin

   Time_It ("Bounded  ", B);
   Time_It ("Dynamic  ", D);
   Time_It ("Managed  ", M);
   Time_It ("Unmanaged", U);

end Storage_Timing;
