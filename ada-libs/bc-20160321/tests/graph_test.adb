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

with Ada.Exceptions;
with Ada.Text_IO;
with Graph_Test_Support;

procedure Graph_Test is

   use Ada.Text_IO;
   use Graph_Test_Support;

   procedure Assertion (B : Boolean; S : String);
   procedure Assertion (B : Boolean; S : String) is
   begin
      if not B then
         Put_Line (S);
      end if;
   end Assertion;

   procedure Test_Directed (G : in out DG.Graph;
                            V1, V2, V3 : in out DG.Vertex;
                            A1, A2, A3 : in out DG.Arc);
   procedure Test_Directed (G : in out DG.Graph;
                            V1, V2, V3 : in out DG.Vertex;
                            A1, A2, A3 : in out DG.Arc) is
      A4 : DG.Arc;
      use AG;
      use DG;
   begin
      Assertion (Is_Empty (G), "** D01: Graph is not initially empty");
      Assertion (Number_Of_Vertices (G) = 0,
                 "** D02: Number of vertices is not correct");
      Assertion (Is_Null (V1),
                 "** D03: Vertex is not initially null");
      Assertion (Is_Null (A1),
                 "** D04: Arc is not initially null");
      Create_Vertex (G, V1, 'a');
      Create_Vertex (G, V2, 'b');
      Create_Vertex (G, V3, 'c');
      Create_Vertex (G, V3, 'd');
      Create_Vertex (G, V3, 'e');
      Create_Vertex (G, V3, 'f');
      Create_Vertex (G, V3, 'g');
      Assertion (not Is_Empty (G),
                 "** D05: Graph is empty");
      Assertion (Number_Of_Vertices (G) = 7,
                 "** D06: Number of vertices is not correct");
      Assertion (not Is_Null (V1),
                 "** D07: Vertex is null");
      Assertion (Is_Shared (V1),
                 "** D08: Vertex is not shared");
      Assertion (Item (V1) = 'a',
                 "** D09: Vertex Item is not correct");
      Assertion (Is_Member (G, V1),
                 "** D10: Vertex is not a member of the graph");
      Assertion (not Is_Null (V3),
                 "** D11: Vertex is null");
      Assertion (Is_Shared (V3),
                 "** D12: Vertex is not shared");
      Assertion (Item (V3) = 'g',
                 "** D13: Vertex Item is not correct");
      Assertion (Is_Member (G, V3),
                 "** D14: Vertex is not a member of the graph");
      --  XXX don't like the type conversion here
      Assertion (Number_Of_Vertices
                 (DG.Graph (Enclosing_Graph (V1).all)) = 7,
                 "** D15: Number of vertices is not correct");
      V3 := V1;
      --  XXX don't like the type conversion here
      Assertion (Number_Of_Vertices
                 (DG.Graph (Enclosing_Graph (V3).all)) = 7,
                 "** D16: Number of vertices is not correct");
      Clear (V3);
      Assertion (Is_Null (V3),
                 "** D17: Vertex is not null");
      Assertion (not Is_Shared (V3),
                 "** D18: Vertex is shared");
      Assertion (not Is_Member (G, V3),
                 "** D19: Vertex is a member of the graph");
      Assertion (Is_Member (G, V1),
                 "** D20: Vertex is not a member of the graph");
      V3 := V1;
      Assertion (V1 = V3,
                 "** D21: Vertices are not equal");
      Set_Item (V1, 'A');
      Assertion (Item (V3) = 'A',
                 "** D22: Vertex Item is not correct");
      Destroy_Vertex (G, V1);
      Assertion (Number_Of_Vertices (G) = 6,
                 "** D23: Number of vertices is not correct");
      Assertion (not Is_Member (G, V1),
                 "** D24: Vertex is a member of the graph");
      Assertion (Is_Null (V1),
                 "** D25: Vertex is not null");
      Assertion (not Is_Shared (V1),
                 "** D26: Vertex is shared");
      Assertion (not Is_Member (G, V3),
                 "** D27: Vertex is a member of the graph");
      Assertion (not Is_Null (V3),
                 "** D28: Vertex is null");
      Assertion (not Is_Shared (V3),
                 "** D29: Vertex is shared");
      Assertion (V1 /= V3,
                 "** D30: Vertices are not equal");
      Assertion (Is_Member (G, V2),
                 "** D31: Vertex is not a member of the graph");
      Clear (G);
      Assertion (Number_Of_Vertices (G) = 0,
                 "** D32: Number of vertices is not correct");
      Assertion (not Is_Member (G, V2),
                 "** D33: Vertex is a member of the graph");
      Assertion (not Is_Null (V2),
                 "** D34: Vertex is null");
      Assertion (not Is_Shared (V2),
                 "** D35: Vertex is shared");
      Assertion (Number_Of_Incoming_Arcs (V2) = 0,
                 "** D36: Arity of incoming arcs is not correct");
      Assertion (Number_Of_Outgoing_Arcs (V2) = 0,
                 "** D37: Arity of outgoing arcs is not correct");
      Create_Vertex (G, V1, 'a');
      Create_Vertex (G, V2, 'b');
      Create_Vertex (G, V3, 'c');
      Create_Arc (G, A1, '0', V1, V2); -- NB, these test the 'reference'
      Create_Arc (G, A2, '1', V2, V3);
      Create_Arc (G, A4, '2', V3, V1);
      Create_Arc (G, A3, '3', V3, V2);
      Assertion (Is_Member (G, A1),
                 "** D38: Arc is not a member of the graph");
      Assertion (Number_Of_Incoming_Arcs (V2) = 2,
                 "** D39: Arity of incoming arcs is not correct");
      Assertion (Number_Of_Outgoing_Arcs (V3) = 2,
                 "** D40: Arity of outgoing arcs is not correct");
      Destroy_Arc (G, A3);
      Assertion (Is_Null (A3),
                 "** D41: Arc is not null");
      Assertion (not Is_Member (G, A3),
                 "** D42: Arc is a member of the graph");
      Assertion (Number_Of_Incoming_Arcs (V2) = 1,
                 "** D43: Arity of incoming arcs is not correct");
      Assertion (Number_Of_Outgoing_Arcs (V3) = 1,
                 "** D44: Arity of outgoing arcs is not correct");
      Create_Arc (G, A3, '3', V3, V2);
      To_Vertex (A3, V1);
      Assertion (V1 = V2,
                 "** D45: Vertices are not equal");
      From_Vertex (A3, V1);
      Assertion (V1 = V3,
                 "** D46: Vertices are not equal");
      From_Vertex (A1, V1);
      Assertion (Item (V1) = 'a',
                 "** D47: Vertex Item is not correct");
      Set_To_Vertex (A3, V1'Access);
      Assertion (Number_Of_Incoming_Arcs (V1) = 2,
                 "** D48: Arity of incoming arcs is not correct");
      Assertion (Number_Of_Incoming_Arcs (V2) = 1,
                 "** D49: Arity of incoming arcs is not correct");
      Assertion (Item (A3) = '3',
                 "** D50: Arc Item is not correct");
      Set_Item (A3, '4');
      Assertion (Item (A3) = '4',
                 "** D51: Arc Item is not correct");
      --  XXX don't like the type conversion here
      Assertion (Number_Of_Vertices
                 (DG.Graph (Enclosing_Graph (A3).all)) = 3,
                 "** D52: Number of vertices is not correct");
      A2 := A3;
      Clear (A2);
      Assertion (not Is_Member (G, A2),
                 "** D53: Arc is a member of the graph");
      Assertion (Is_Member (G, A3),
                 "** D54: Arc is not a member of the graph");
      Set_From_Vertex (A3, V2'Access);
      Assertion (Number_Of_Outgoing_Arcs (V2) = 2,
                 "** D55: Arity of outgoing arcs is not correct");
      Assertion (Number_Of_Outgoing_Arcs (V3) = 1,
                 "** D56: Arity of outgoing arcs is not correct");
      Create_Arc (G, A3, '7', V3, V3);
      Assertion (Number_Of_Outgoing_Arcs (V3) = 2,
                 "** D57: Arity of outgoing arcs is not correct");
      Assertion (Number_Of_Incoming_Arcs (V3) = 2,
                 "** D58: Arity of outgoing arcs is not correct");
      Set_Item (V3, 'C');
      Destroy_Vertex (G, V3);
      Assertion (Is_Null (V3),
                 "** D59: Vertex is not null");
      Assertion (not Is_Null (A3),
                 "** D60: Arc is null");
      Assertion (Number_Of_Incoming_Arcs (V1) = 2,
                 "** D61: Arity of outgoing arcs is not correct");
      Assertion (Number_Of_Outgoing_Arcs (V2) = 2,
                 "** D62: Arity of outgoing arcs is not correct");
      Create_Vertex (G, V1, 'c');
      Create_Arc (G, A3, '5', V1, V1);
      Create_Arc (G, A3, '7', V1, V2);
      Create_Vertex (G, V1, 'd');
      Create_Arc (G, A3, '8', V1, V2);
      Set_From_Vertex (A4, V1'Access);
   end Test_Directed;

   procedure Test_Undirected (G : in out UG.Graph;
                              V1, V2, V3 : in out UG.Vertex;
                              A1, A2, A3 : in out UG.Arc);
   procedure Test_Undirected (G : in out UG.Graph;
                              V1, V2, V3 : in out UG.Vertex;
                              A1, A2, A3 : in out UG.Arc) is
      A4 : UG.Arc;
      use AG;
      use UG;
   begin
      Assertion (Is_Empty (G), "** U01: Graph is not initially empty");
      Assertion (Number_Of_Vertices (G) = 0,
                 "** U02: Number of vertices is not correct");
      Assertion (Is_Null (V1),
                 "** U03: Vertex is not initially null");
      Assertion (Is_Null (A1),
                 "** U04: Arc is not initially null");
      Create_Vertex (G, V1, 'a');
      Create_Vertex (G, V2, 'b');
      Create_Vertex (G, V3, 'c');
      Create_Vertex (G, V3, 'd');
      Create_Vertex (G, V3, 'e');
      Create_Vertex (G, V3, 'f');
      Create_Vertex (G, V3, 'g');
      Assertion (not Is_Empty (G),
                 "** U05: Graph is empty");
      Assertion (Number_Of_Vertices (G) = 7,
                 "** U06: Number of vertices is not correct");
      Assertion (not Is_Null (V1),
                 "** U07: Vertex is null");
      Assertion (Is_Shared (V1),
                 "** U08: Vertex is not shared");
      Assertion (Item (V1) = 'a',
                 "** U09: Vertex Item is not correct");
      Assertion (Is_Member (G, V1),
                 "** U10: Vertex is not a member of the graph");
      Assertion (not Is_Null (V3),
                 "** U11: Vertex is null");
      Assertion (Is_Shared (V3),
                 "** U12: Vertex is not shared");
      Assertion (Item (V3) = 'g',
                 "** U13: Vertex Item is not correct");
      Assertion (Is_Member (G, V3),
                 "** U14: Vertex is not a member of the graph");
      --  XXX don't like the type conversion here
      Assertion (Number_Of_Vertices
                 (UG.Graph (Enclosing_Graph (V1).all)) = 7,
                 "** U15: Number of vertices is not correct");
      V3 := V1;
      --  XXX don't like the type conversion here
      Assertion (Number_Of_Vertices
                 (UG.Graph (Enclosing_Graph (V3).all)) = 7,
                 "** U16: Number of vertices is not correct");
      Clear (V3);
      Assertion (Is_Null (V3),
                 "** U17: Vertex is not null");
      Assertion (not Is_Shared (V3),
                 "** U18: Vertex is shared");
      Assertion (not Is_Member (G, V3),
                 "** U19: Vertex is a member of the graph");
      Assertion (Is_Member (G, V1),
                 "** U20: Vertex is not a member of the graph");
      V3 := V1;
      Assertion (V1 = V3,
                 "** U21: Vertices are not equal");
      Set_Item (V1, 'A');
      Assertion (Item (V3) = 'A',
                 "** U22: Vertex Item is not correct");
      Destroy_Vertex (G, V1);
      Assertion (Number_Of_Vertices (G) = 6,
                 "** U23: Number of vertices is not correct");
      Assertion (not Is_Member (G, V1),
                 "** U24: Vertex is a member of the graph");
      Assertion (Is_Null (V1),
                 "** U25: Vertex is not null");
      Assertion (not Is_Shared (V1),
                 "** U26: Vertex is shared");
      Assertion (not Is_Member (G, V3),
                 "** U27: Vertex is a member of the graph");
      Assertion (not Is_Null (V3),
                 "** U28: Vertex is null");
      Assertion (not Is_Shared (V3),
                 "** U29: Vertex is shared");
      Assertion (V1 /= V3,
                 "** U30: Vertices are not equal");
      Assertion (Is_Member (G, V2),
                 "** U31: Vertex is not a member of the graph");
      Clear (G);
      Assertion (Number_Of_Vertices (G) = 0,
                 "** U32: Number of vertices is not correct");
      Assertion (not Is_Member (G, V2),
                 "** U33: Vertex is a member of the graph");
      Assertion (not Is_Null (V2),
                 "** U34: Vertex is null");
      Assertion (not Is_Shared (V2),
                 "** U35: Vertex is shared");
      Assertion (Arity (V2) = 0,
                 "** U36: Arity of incoming arcs is not correct");
      Create_Vertex (G, V1, 'a');
      Create_Vertex (G, V2, 'b');
      Create_Vertex (G, V3, 'c');
      Create_Arc (G, A1, '0', V1, V2); -- NB, these test the 'reference'
      Create_Arc (G, A2, '1', V2, V3);
      Create_Arc (G, A4, '2', V3, V1);
      Create_Arc (G, A3, '3', V3, V2);
      Assertion (Is_Member (G, A1),
                 "** U37: Arc is not a member of the graph");
      Assertion (Arity (V2) = 3,
                 "** U38: Arity is not correct");
      Assertion (Arity (V3) = 3,
                 "** U39: Arity is not correct");
      Destroy_Arc (G, A3);
      Assertion (Is_Null (A3),
                 "** U40: Arc is not null");
      Assertion (not Is_Member (G, A3),
                 "** U41: Arc is a member of the graph");
      Assertion (Arity (V2) = 2,
                 "** U42: Arity is not correct");
      Assertion (Arity (V3) = 2,
                 "** U43: Arity is not correct");
      Create_Arc (G, A3, '3', V3, V2);
      Second_Vertex (A3, V1);
      Assertion (V1 = V2,
                 "** U44: Vertices are not equal");
      First_Vertex (A3, V1);
      Assertion (V1 = V3,
                 "** U45: Vertices are not equal");
      First_Vertex (A1, V1);
      Assertion (Item (V1) = 'a',
                 "** U46: Vertex Item is not correct");
      Set_Second_Vertex (A3, V1'Access);
      Assertion (Arity (V1) = 3,
                 "** U47: Arity is not correct");
      Assertion (Arity (V2) = 2,
                 "** U48: Arity is not correct");
      Assertion (Item (A3) = '3',
                 "** U49: Arc Item is not correct");
      Set_Item (A3, '4');
      Assertion (Item (A3) = '4',
                 "** U50: Arc Item is not correct");
      --  XXX don't like the type conversion here
      Assertion (Number_Of_Vertices
                 (UG.Graph (Enclosing_Graph (A3).all)) = 3,
                 "** U51: Number of vertices is not correct");
      A2 := A3;
      Clear (A2);
      Assertion (not Is_Member (G, A2),
                 "** U52: Arc is a member of the graph");
      Assertion (Is_Member (G, A3),
                 "** U53: Arc is not a member of the graph");
      Set_First_Vertex (A3, V2'Access);
      Assertion (Arity (V2) = 3,
                 "** U54: Arity is not correct");
      Assertion (Arity (V3) = 2,
                 "** U55: Arity is not correct");
      Create_Arc (G, A3, '7', V3, V3);
      Assertion (Arity (V3) = 3,
                 "** U56: Arity is not correct");
      Set_Item (V3, 'C');
      Destroy_Vertex (G, V3);
      Assertion (Is_Null (V3),
                 "** U57: Vertex is not null");
      Assertion (not Is_Null (A3),
                 "** U58: Arc is null");
      Assertion (Arity (V1) = 3,
                 "** U59: Arity is not correct");
      Assertion (Arity (V2) = 3,
                 "** U60: Arity is not correct");
      Create_Vertex (G, V1, 'c');
      Create_Arc (G, A3, '5', V1, V1);
      Create_Arc (G, A3, '7', V1, V2);
      Create_Vertex (G, V1, 'd');
      Create_Arc (G, A3, '8', V1, V2);
      Set_First_Vertex (A4, V1'Access);
   end Test_Undirected;

   procedure Process_Arc (A : DG.Arc; OK : out Boolean);
   procedure Process_Arc (A : DG.Arc; OK : out Boolean) is
      V1, V2 : DG.Vertex;
   begin
      DG.From_Vertex (A, V1);
      DG.To_Vertex (A, V2);
      Put ("        Arc: " & DG.Item (A));
      if DG.Is_Null (V1) then
         Put (" from: <none>");
      else
         Put (" from: " & DG.Item (V1));
      end if;
      if DG.Is_Null (V2) then
         Put (" to: <none>");
      else
         Put (" to: " & DG.Item (V2));
      end if;
      New_Line;
      OK := True;
   end Process_Arc;

   procedure Process_Directed_Vertex (V : AG.Abstract_Vertex'Class;
                                      OK : out Boolean);
   procedure Process_Directed_Vertex (V : AG.Abstract_Vertex'Class;
                                      OK : out Boolean) is
      DV : constant DG.Vertex := DG.Vertex (V);
      Iter : AG.Vertex_Iterator'Class := DG.New_Vertex_Outgoing_Iterator (DV);
   begin
      Put_Line ("    Vertex: " & DG.Item (DV)
                & " (" & Integer'Image (DG.Number_Of_Incoming_Arcs (DV))
                & "," & Integer'Image (DG.Number_Of_Outgoing_Arcs (DV))
                & " )");
      while not AG.Is_Done (Iter) loop
         declare
            A : constant DG.Arc := DG.Arc (AG.Current_Arc (Iter));
            Dummy : Boolean;
            pragma Unreferenced (Dummy);
         begin
            Process_Arc (A, Dummy);
         end;
         AG.Next (Iter);
      end loop;
      OK := True;
   end Process_Directed_Vertex;

   procedure Test_Directed_Active_Iterator (G : in out DG.Graph);
   procedure Test_Directed_Active_Iterator (G : in out DG.Graph) is
      Iter : AG.Graph_Iterator'Class := DG.New_Graph_Iterator (G);
   begin
      while not AG.Is_Done (Iter) loop
         declare
            V : constant DG.Vertex := DG.Vertex (AG.Current_Vertex (Iter));
            Dummy : Boolean;
            pragma Unreferenced (Dummy);
         begin
            Process_Directed_Vertex (V, Dummy);
         end;
         AG.Next (Iter);
      end loop;
   end Test_Directed_Active_Iterator;

   procedure Test_Directed_Passive_Iterator (G : in out DG.Graph);
   procedure Test_Directed_Passive_Iterator (G : in out DG.Graph) is
      procedure Visit
      is new AG.Visit_Vertices (Apply => Process_Directed_Vertex);
      It : AG.Graph_Iterator'Class := DG.New_Graph_Iterator (G);
   begin
      Visit (It);
   end Test_Directed_Passive_Iterator;

   procedure Process_Arc (A : UG.Arc; OK : out Boolean);
   procedure Process_Arc (A : UG.Arc; OK : out Boolean) is
      V1, V2 : UG.Vertex;
      use UG;
   begin
      First_Vertex (A, V1);
      Second_Vertex (A, V2);
      Put ("        Arc: " & Item (A));
      if Is_Null (V1) then
         Put (" first: <none>");
      else
         Put (" first: " & Item (V1));
      end if;
      if Is_Null (V2) then
         Put (" second: <none>");
      else
         Put (" second: " & Item (V2));
      end if;
      New_Line;
      OK := True;
   end Process_Arc;

   procedure Process_Undirected_Vertex (V : AG.Abstract_Vertex'Class;
                                        OK : out Boolean);
   procedure Process_Undirected_Vertex (V : AG.Abstract_Vertex'Class;
                                        OK : out Boolean) is
      UV : constant UG.Vertex := UG.Vertex (V);
      Iter : AG.Vertex_Iterator'Class := UG.New_Vertex_Iterator (UV);
   begin
      Put_Line ("    Vertex: " & UG.Item (UV)
                & " (" & Integer'Image (UG.Arity (UV)) & " )");
      while not AG.Is_Done (Iter) loop
         declare
            A : constant UG.Arc := UG.Arc (AG.Current_Arc (Iter));
            Dummy : Boolean;
            pragma Unreferenced (Dummy);
         begin
            Process_Arc (A, Dummy);
         end;
         AG.Next (Iter);
      end loop;
      OK := True;
   end Process_Undirected_Vertex;

   procedure Test_Undirected_Active_Iterator (G : in out UG.Graph);
   procedure Test_Undirected_Active_Iterator (G : in out UG.Graph) is
      Iter : AG.Graph_Iterator'Class := UG.New_Graph_Iterator (G);
   begin
      while not AG.Is_Done (Iter) loop
         declare
            V : constant UG.Vertex
              := UG.Vertex (AG.Current_Vertex (Iter));
            Dummy : Boolean;
            pragma Unreferenced (Dummy);
         begin
            Process_Undirected_Vertex (V, Dummy);
         end;
         AG.Next (Iter);
      end loop;
   end Test_Undirected_Active_Iterator;

   procedure Test_Undirected_Passive_Iterator (G : in out UG.Graph);
   procedure Test_Undirected_Passive_Iterator (G : in out UG.Graph) is
      procedure Visit is new AG.Visit_Vertices
        (Apply => Process_Undirected_Vertex);
      It : AG.Graph_Iterator'Class := UG.New_Graph_Iterator (G);
   begin
      Visit (It);
   end Test_Undirected_Passive_Iterator;

   D_G : DG.Graph;
   D_V1, D_V2, D_V3 : DG.Vertex;
   D_A1, D_A2, D_A3 : DG.Arc;

   U_G : UG.Graph;
   U_V1, U_V2, U_V3 : UG.Vertex;
   U_A1, U_A2, U_A3 : UG.Arc;

begin
   Put_Line ("Starting graph tests");

   Put_Line ("...Directed Graph");
   Test_Directed (D_G, D_V1, D_V2, D_V3, D_A1, D_A2, D_A3);

   Put_Line ("...Undirected Graph");
   Test_Undirected (U_G, U_V1, U_V2, U_V3, U_A1, U_A2, U_A3);

   Put_Line ("...Graph Active Iterator");
   Put_Line ("   Directed:");
   Test_Directed_Active_Iterator (D_G);
   Put_Line ("   Undirected:");
   Test_Undirected_Active_Iterator (U_G);

   Put_Line ("...Graph Passive Iterator");
   Put_Line ("   Directed:");
   Test_Directed_Passive_Iterator (D_G);
   Put_Line ("   Undirected:");
   Test_Undirected_Passive_Iterator (U_G);

   Put_Line ("Completed graph tests");

exception
   when E : others =>
      Put_Line ("                                   EXCEPTION "
                & Ada.Exceptions.Exception_Name (E)
                & " OCCURRED.");
end Graph_Test;
