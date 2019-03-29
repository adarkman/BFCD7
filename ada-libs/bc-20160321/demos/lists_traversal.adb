--  Copyright 1998-2003 Simon Wright <simon@pushface.org>

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

--  The purpose of this test procedure is to check out a problem that
--  was reported where the Predecessor() operation didn't behave as
--  expected.  Although there was an error, it turns out that
--  Predecessor() can't be used to reverse a Tail() operation when the
--  previous head of the list wasn't shared by another alias. You may
--  not like this limitation, but that's the way the Components are
--  defined!

with Ada.Finalization;
with Ada.Text_IO;
with BC.Support.Exceptions;
with Lists_For_Traversal;

procedure Lists_Traversal is
   D : Lists_For_Traversal.D.List;
begin
   for I in 1 .. 10 loop
      Lists_For_Traversal.D.Append
        (D,
         Lists_For_Traversal.Smart.Create
         (new Lists_For_Traversal.T'(Ada.Finalization.Controlled with
                                     V => I)));
   end loop;
   Ada.Text_IO.Put_Line ("Full list's length is"
                         & Natural'Image (Lists_For_Traversal.D.Length (D)));
   --  K := D;
   for I in 1 .. 9 loop
      Lists_For_Traversal.D.Tail (D);
   end loop;
   Ada.Text_IO.Put_Line ("Remnant list's length is"
                         & Natural'Image (Lists_For_Traversal.D.Length (D)));
   declare
      N : Integer := 0;
   begin
      loop
         Lists_For_Traversal.D.Predecessor (D);
         N := N + 1;
         Ada.Text_IO.Put_Line
           (".. list's length is"
            & Natural'Image (Lists_For_Traversal.D.Length (D)));
      end loop;
   exception
      when E : others =>
         BC.Support.Exceptions.Report (E);
         Ada.Text_IO.Put_Line (".. N =" & Integer'Image (N));
   end;
   Ada.Text_IO.Put_Line ("Final list's length is"
                         & Natural'Image (Lists_For_Traversal.D.Length (D)));
exception
   when others =>
      Ada.Text_IO.Put_Line ("oops");
end Lists_Traversal;
