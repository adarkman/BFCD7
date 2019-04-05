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

--  Contains test support code.

with Ada.Finalization;

package Chunks is

   pragma Elaborate_Body;

   type Chunk is private;
   type Chunk_Ptr is access all Chunk;

   function "=" (L, R : Chunk) return Boolean;

   function Priority (C : Chunk) return Natural;

   function Image (C : Chunk) return String;

private

   type Chunk is new Ada.Finalization.Controlled with record
      Number : Natural;
      Count : Natural;
   end record;

   procedure Initialize (C : in out Chunk);

   procedure Adjust (C : in out Chunk);

end Chunks;