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

--  $Id$

with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Configuration_Demo_Support;

procedure Configuration_Demo is

   use Configuration_Demo_Support.String_Maps;

   function "+" (S : String) return Unbounded_String
     renames To_Unbounded_String;
   function "+" (US : Unbounded_String) return String
     renames To_String;

   Configuration : Map;

   F : Ada.Streams.Stream_IO.File_Type;

begin


   Bind (Configuration, K => +"/big/top/length", I => +"100");
   Bind (Configuration, K => +"/big/top/width", I => +"200");
   Bind (Configuration, K => +"/big/top/height", I => +"300");
   Bind (Configuration, K => +"/big/top/depth", I => +"400");

   Create (F, Name => "configuration_demo.dat");
   Map'Output (Stream (F), Configuration);
   Reset (F, Mode => In_File);

   declare
      procedure Check (K : String);
      C : Map;
      procedure Check (K : String) is
      begin
         if Is_Bound (C, +K) then
            Put_Line ("value for key """ &
                        K &
                        """ is """ &
                        (+Item_Of (C, +K)) &
                        """");
         else
            Put_Line
              ("key """ & K & """ not found.");
         end if;
      end Check;
   begin
      C := Map'Input (Stream (F));
      Check ("/little/top/height");
      Check ("/big/top/length");
      Check ("/big/top/width");
      Check ("/big/top/height");
      Check ("/big/top/depth");
      Clear (C);
   end;

   Close (F);

end Configuration_Demo;
