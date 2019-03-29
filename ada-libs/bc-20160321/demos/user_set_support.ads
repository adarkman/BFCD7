
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

--  This package defines sets of characters where equality is
--  case-independent.

with BC.Containers;
with BC.Containers.Sets;
with BC.Containers.Sets.Bounded;
with BC.Containers.Sets.Dynamic;
with BC.Containers.Sets.Unbounded;
with Global_Heap;

package User_Set_Support is

   type User_Character is new Character;
   function "=" (L, R : User_Character) return Boolean;

   package Containers is new BC.Containers (Item => User_Character);

   package Sets is new Containers.Sets;

   function User_Char_Hash (C : User_Character) return Natural;

   package SB is new Sets.Bounded (Hash => User_Char_Hash,
                                   Buckets => 3,
                                   Maximum_Size => 100);

   package SD is new Sets.Dynamic (Hash => User_Char_Hash,
                                   Buckets => 3,
                                   Storage => Global_Heap.Storage);

   package SU is new Sets.Unbounded (Hash => User_Char_Hash,
                                     Buckets => 3,
                                     Storage => Global_Heap.Storage);

end User_Set_Support;
