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
with Ada_Unit_Support;

procedure Ada_Units is
   use Ada_Unit_Support;
   U_Text_IO : constant Unit_P
     := Create_Normal_Unit ("ada.text_io");
   U_Ada_Units : constant Unit_P
     := Create_Normal_Unit ("ada_units");
   U_Ada_Unit_Support : constant Unit_P
     := Create_Normal_Unit ("ada_unit_support");
   U_Directed : constant Unit_P
     := Create_Generic_Unit ("bc.graphs.directed");
   U_Undirected : constant Unit_P
     := Create_Generic_Unit ("bc.graphs.undirected");
   U_Graphs : constant Unit_P
     := Create_Generic_Unit ("bc.graphs");
begin
   Add_Dependency (U_Graphs, U_Ada_Unit_Support);
   Add_Dependency (U_Directed, U_Ada_Unit_Support);
   Add_Dependency (U_Undirected, U_Ada_Unit_Support);
   Add_Dependency (U_Text_IO, U_Ada_Units);
   Add_Dependency (U_Ada_Unit_Support, U_Ada_Units);
   Add_Dependency (U_Text_IO, U_Ada_Unit_Support);
   Report_Dependencies;
   Ada.Text_IO.New_Line;
   Report_Dependencies (U_Ada_Units);
   Ada.Text_IO.New_Line;
   Report_Dependencies (U_Ada_Unit_Support);
end Ada_Units;
