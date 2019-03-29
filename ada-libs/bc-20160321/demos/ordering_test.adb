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
with Ordering_Support;

procedure Ordering_Test is
   procedure Report_Element (Elem : in Ordering_Support.Sortable;
                             Ok : out Boolean);
   procedure Report is new Ordering_Support.Containers.Visit
     (Apply => Report_Element);
   procedure Report_Element (Elem : in Ordering_Support.Sortable;
                             Ok : out Boolean) is
   begin
      Ada.Text_IO.Put_Line ("key =>" & Integer'Image (Elem.Key) &
                            ", ident =>" & Integer'Image (Elem.Ident));
      Ok := True;
   end Report_Element;
   C : Ordering_Support.CU.Collection;
   Q : Ordering_Support.QU.Queue;
begin
   for Ident in 1 .. 5 loop
      Ordering_Support.CU.Append
        (C, Ordering_Support.Sortable'(Key => 1, Ident => Ident));
      Ordering_Support.CU.Append
        (C, Ordering_Support.Sortable'(Key => 2, Ident => Ident));
      Ordering_Support.QU.Append
        (Q, Ordering_Support.Sortable'(Key => 1, Ident => Ident));
      Ordering_Support.QU.Append
        (Q, Ordering_Support.Sortable'(Key => 2, Ident => Ident));
   end loop;
   for Ident in 11 .. 15 loop
      Ordering_Support.CU.Insert
        (C, Ordering_Support.Sortable'(Key => 1, Ident => Ident));
      Ordering_Support.CU.Insert
        (C, Ordering_Support.Sortable'(Key => 2, Ident => Ident));
   end loop;
   declare
      It : Ordering_Support.Containers.Iterator'Class
        := Ordering_Support.CU.New_Iterator (C);
   begin
      Ada.Text_IO.Put_Line ("Reporting on Unbounded_Ordered_Collection");
      Report (Using => It);
   end;
   declare
      It : Ordering_Support.Containers.Iterator'Class
        := Ordering_Support.QU.New_Iterator (Q);
   begin
      Ada.Text_IO.Put_Line ("Reporting on Unbounded_Ordered_Queue");
      Report (Using => It);
   end;
   Ada.Text_IO.Put_Line ("Clearing Unbounded_Ordered_Queue");
   while not Ordering_Support.QU.Is_Empty (Q) loop
      declare
         Dummy : Boolean;
         pragma Unreferenced (Dummy);
      begin
         Report_Element (Ordering_Support.QU.Front (Q), Dummy);
         Ordering_Support.QU.Pop (Q);
      end;
   end loop;
end Ordering_Test;
