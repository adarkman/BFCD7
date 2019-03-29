--  Copyright 1998 Pat Rogers
--  Copyright 1998-2002 Simon Wright <simon@pushface.org>

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

--  $Id$

with Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Unchecked_Deallocation;
with BC.Support.Managed_Storage;
with BC.Support.Unmanaged_Storage;

with System.Storage_Elements;


procedure Storage is

   use type System.Storage_Elements.Storage_Count;

   package Managed_Storage renames BC.Support.Managed_Storage;
   package Unmanaged_Storage renames BC.Support.Unmanaged_Storage;

   type T is array (Integer range <>) of Character;

   T_Overhead : constant := 2 * (System.Word_Size / System.Storage_Unit);
   --  to include dope for lower/upper bounds, since T is unconstrained

   Managed_Pool : Managed_Storage.Pool (4096 + T_Overhead);
   Unmanaged_Pool : Unmanaged_Storage.Pool;

   type M_P is access T;
   for M_P'Storage_Pool use Managed_Pool;
   type U_P is access T;
   for U_P'Storage_Pool use Unmanaged_Pool;

   procedure Delete is new Ada.Unchecked_Deallocation (T, M_P);
   procedure Delete is new Ada.Unchecked_Deallocation (T, U_P);

   M_Ptr : M_P;
   U_Ptr : U_P;

   Trying : Integer;

begin

   begin
      Ada.Text_IO.Put_Line ("Trying Managed Store.");
      Ada.Text_IO.Put_Line ("We expect this to fail at size 4097.");
      Ada.Text_IO.Put_Line ("Note, this allocation pattern is" &
                            " pathologically bad for Managed Store!");
      for I in 0 .. 4097 loop
         Trying := I;
         M_Ptr := new T (1 .. Trying);
         Delete (M_Ptr);
      end loop;
      Ada.Text_IO.Put_Line (".. done all 4097 allocations.");

   exception
      when BC.Storage_Error =>
         Ada.Text_IO.Put ("exception BC.Storage_Error raised at size");
         Ada.Integer_Text_IO.Put (Trying);
         Ada.Text_IO.New_Line;

   end;

   begin
      Ada.Text_IO.Put_Line ("Trying Unmanaged Store:");
      for I in 0 .. 4097 loop
         Trying := I;
         U_Ptr := new T (1 .. Trying);
         Delete (U_Ptr);
      end loop;
      Ada.Text_IO.Put_Line (".. done all 4097 allocations.");

   exception
      when BC.Storage_Error =>
         Ada.Text_IO.Put ("exception BC.Storage_Error raised at size");
         Ada.Integer_Text_IO.Put (Trying);
         Ada.Text_IO.New_Line;

   end;

end Storage;
