--  Copyright 2009-2010 Simon Wright <simon@pushface.org>

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
--
--  Tests for the Booch Components.

with AUnit.Reporter.Text;
with AUnit.Run;
with AUnit.Test_Suites;

with Tests.Items;

with Tests.Auto_Pointers;
with Tests.AVL_Trees;
with Tests.Collections;
with Tests.Indefinite_Collections;
with Tests.Indefinite_Maps;
with Tests.Indefinite_Unmanaged_Maps;
with Tests.Managed_Storage;
with Tests.Multiway_Trees;
with Tests.Rings;

procedure Tests.Main is

   function Suites return AUnit.Test_Suites.Access_Test_Suite;
   procedure Run is new AUnit.Run.Test_Runner (Suites);
   function Suites return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite
        := new AUnit.Test_Suites.Test_Suite;
   begin
      AUnit.Test_Suites.Add_Test (Result, Items.Suite);
      AUnit.Test_Suites.Add_Test (Result, Auto_Pointers.Suite);
      AUnit.Test_Suites.Add_Test (Result, AVL_Trees.Suite);
      AUnit.Test_Suites.Add_Test (Result, Collections.Suite);
      AUnit.Test_Suites.Add_Test (Result, Indefinite_Collections.Suite);
      AUnit.Test_Suites.Add_Test (Result, Indefinite_Maps.Suite);
      AUnit.Test_Suites.Add_Test (Result, Indefinite_Unmanaged_Maps.Suite);
      AUnit.Test_Suites.Add_Test (Result, Managed_Storage.Suite);
      AUnit.Test_Suites.Add_Test (Result, Multiway_Trees.Suite);
      AUnit.Test_Suites.Add_Test (Result, Rings.Suite);
      return Result;
   end Suites;

   Reporter : AUnit.Reporter.Text.Text_Reporter;

begin
   Run (Reporter);
end Tests.Main;
