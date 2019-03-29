
--  Copyright 2002 Simon Wright <simon@pushface.org>

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

with Ada.Numerics.Discrete_Random;

package body Configuration_Demo_Support is

   type Special_Integer is mod 2 ** 31;  --  simple to convert to Natural
   Character_Hash : array (Character) of Special_Integer;

   function Hash (S : Ada.Strings.Unbounded.Unbounded_String) return Natural is
      K : Special_Integer := 0;
      N : Special_Integer := 0;
      use Ada.Strings.Unbounded;
   begin

      for M in 1 .. Length (S) loop
         N := Character_Hash (Element (S, M));
         K := K + Special_Integer (M) * N;
      end loop;

      return Natural (K);

   end Hash;

   package Random_Integer is new
     Ada.Numerics.Discrete_Random (Result_Subtype => Special_Integer);

   Generator : Random_Integer.Generator;

begin
   Random_Integer.Reset (Gen => Generator, Initiator => 10009);
   for K in Character_Hash'Range loop
      Character_Hash (K) :=
        Random_Integer.Random (Gen => Generator);
   end loop;
end Configuration_Demo_Support;
