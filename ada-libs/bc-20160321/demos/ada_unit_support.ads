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

with Ada.Strings.Unbounded;
with BC.Graphs;
with BC.Graphs.Directed;
with Global_Heap;

package Ada_Unit_Support is

   type Unit is abstract tagged private;
   type Unit_P is access Unit'Class;
   function Name (Of_The_Unit : Unit) return String;
   function Description (Of_The_Unit : Unit) return String is abstract;

   type Normal_Unit is new Unit with private;
   function Description (Of_The_Unit : Normal_Unit) return String;
   function Create_Normal_Unit (Unit_Named : String) return Unit_P;

   type Generic_Unit is new Unit with private;
   function Description (Of_The_Unit : Generic_Unit) return String;
   function Create_Generic_Unit (Unit_Named : String) return Unit_P;

   procedure Add_Dependency (Unit_Is_Withed : Unit_P; By : Unit_P);

   procedure Report_Dependencies;

   procedure Report_Dependencies (For_Unit : Unit_P);

private

   type Dependency is null record;

   package Dependencies_Base is new BC.Graphs
     (Vertex_Item => Unit_P,
      Arc_Item => Dependency,
      Storage => Global_Heap.Storage);
   package Dependencies is new Dependencies_Base.Directed;

   type Unit is abstract tagged record
      Named : Ada.Strings.Unbounded.Unbounded_String;
      Vertex : Dependencies.Vertex;
   end record;

   type Normal_Unit is new Unit with null record;
   type Generic_Unit is new Unit with null record;

end Ada_Unit_Support;
