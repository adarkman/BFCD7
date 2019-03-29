--  Copyright 2002-2014 Simon Wright <simon@pushface.org>

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

package body Stream_Test_Support is


   function Image (B : Base_Class_P) return String is
   begin
      return Image (B.all);
   end Image;


   function Eq (L, R : Base_Class_P) return Boolean is
   begin
      return L.all = R.all;
   end Eq;


   procedure Write_Base_Class_P
     (Stream : access Ada.Streams.Root_Stream_Type'Class;
      Obj : Base_Class_P) is
   begin
      Base'Class'Output (Stream, Obj.all);
   end Write_Base_Class_P;


   procedure Read_Base_Class_P
     (Stream : access Ada.Streams.Root_Stream_Type'Class;
      Obj : out Base_Class_P) is
      Result : constant Base'Class := Base'Class'Input (Stream);
   begin
      Obj := new Base'Class'(Result);
   end Read_Base_Class_P;


   function Image (B : Brother) return String is
   begin
      return "Brother'(" & Integer'Image (B.I) & ")";
   end Image;


   function Image (S : Sister) return String is
   begin
      return "Sister'(" & Boolean'Image (S.B) & ")";
   end Image;


end Stream_Test_Support;
