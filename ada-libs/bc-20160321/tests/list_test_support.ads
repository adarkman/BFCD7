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

with BC.Containers;
with BC.Containers.Lists;
with BC.Containers.Lists.Single;
with BC.Containers.Lists.Double;
with Global_Heap;

package List_Test_Support is

   package Containers is new BC.Containers (Item => Character);

   package Lists is new Containers.Lists;

   package LS is new Lists.Single (Storage => Global_Heap.Storage);

   package LD is new Lists.Double (Storage => Global_Heap.Storage);

end List_Test_Support;
