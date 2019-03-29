--  Checks the number of loops required for the clock to change, for
--  both Ada.Calendar and BC.Support.High_Resolution_Time.
--
--  It used to be that Ada.Calendar had a 10 ms tick if you were
--  lucky; modern operating systems support 1 us. If you have one of
--  those, your need for BC.Support.High_Resolution_Time is much
--  reduced.
--
--  Note that the clock resolution is not necessarily the delay
--  resolution.

with Ada.Calendar;
with Ada.Text_IO; use Ada.Text_IO;
with BC.Support.High_Resolution_Time;

procedure Time_Change is

   type Ada_Info is record
      Time : Ada.Calendar.Time;
      Loops : Natural := 0;
   end record;
   Ada_Times : array (1 .. 10) of Ada_Info;

   type BC_Info is record
      Time : BC.Support.High_Resolution_Time.Time;
      Loops : Natural := 0;
   end record;
   BC_Times : array (1 .. 10) of BC_Info;

   use type Ada.Calendar.Time;
   use type BC.Support.High_Resolution_Time.Time;

begin

   Put_Line ("Using Ada.Calendar.Clock");
   Ada_Times (Ada_Times'First).Time := Ada.Calendar.Clock;
   for I in Ada_Times'First + 1 .. Ada_Times'Last loop
      loop
         Ada_Times (I).Time := Ada.Calendar.Clock;
         Ada_Times (I).Loops := Ada_Times (I).Loops + 1;
         exit when Ada_Times (I).Time /= Ada_Times (I - 1).Time;
      end loop;
   end loop;
   for I in Ada_Times'First + 1 .. Ada_Times'Last loop
      Put_Line ("difference is "
                  & Duration'Image (Ada_Times (I).Time
                                      - Ada_Times (I - 1).Time)
                  & " after"
                  & Natural'Image (Ada_Times (I).Loops)
                  & " call(s)");
   end loop;
   New_Line;

   Put_Line ("Using BC.Support.High_Resolution_Time.Clock");
   BC_Times (BC_Times'First).Time := BC.Support.High_Resolution_Time.Clock;
   for I in BC_Times'First + 1 .. BC_Times'Last loop
      loop
         BC_Times (I).Time := BC.Support.High_Resolution_Time.Clock;
         BC_Times (I).Loops := BC_Times (I).Loops + 1;
         exit when BC_Times (I).Time /= BC_Times (I - 1).Time;
      end loop;
   end loop;
   for I in BC_Times'First + 1 .. BC_Times'Last loop
      Put_Line ("difference is "
                  & Duration'Image (BC_Times (I).Time - BC_Times (I - 1).Time)
                  & " after"
                  & Natural'Image (BC_Times (I).Loops)
                  & " call(s)");
   end loop;

end Time_Change;
