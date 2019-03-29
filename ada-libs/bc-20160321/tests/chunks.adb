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

package body Chunks is

   Magic_Number : Natural := 0;

   function "=" (L, R : Chunk) return Boolean is
   begin
      return L.Number = R.Number and then L.Count = R.Count;
   end "=";

   function Priority (C : Chunk) return Natural is
   begin
      return C.Number;
   end Priority;

   function Image (C : Chunk) return String is
   begin
      return "[ID:"
        & Integer'Image (C.Number)
        & ","
        & Integer'Image (C.Count)
        & "]";
   end Image;

   procedure Initialize (C : in out Chunk) is
   begin
      Magic_Number := Magic_Number + 1;
      C.Number := Magic_Number;
      C.Count := 0;
   end Initialize;

   procedure Adjust (C : in out Chunk) is
   begin
      C.Count := C.Count + 1;
   end Adjust;

end Chunks;
