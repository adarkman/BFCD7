--  This demonstration is a response to a suggestion by John English
--  <J.English@bton.ac.uk> about assessing different component libraries, in
--  the context of the Ada Standard Component Library WG
--  (http://www.suffix.com/Ada/SCL/). It uses part of Corey Minford
--  <minyard@acm.org>'s solution (why reinvent that wheel?!)

--  John said:

--  As a way of objectively assessing the merits of different approaches,
--  perhaps the way to do this is to code some examples; one of my
--  favourites for this is a program to list the 10 most common words in a
--  file with the number of occurrences of each, where the length of words
--  and the size of the file can be arbitrarily large. In Perl it might look
--  something like this:

--   while (<>) {                     # for each line in the input file(s)
--     chomp;                         # trim the end of the line
--     tr/A-Z/a-z/;                   # fold uppercase to lowercase
--     @words = split /\W+/;          # break the line into words
--     foreach (@words) {
--       if (/^\w+$/) {               # ignore non-words
--         $wordlist{$_}++;           # increment count in associative array
--       }                            # (key = word, val = no. of occurrences)
--     }
--   }
--   $times = 0;
--   foreach (sort {$wordlist{$b} <=> $wordlist{$a}} (keys %wordlist)) {
--     last if (++$times > 10);       # exit loop after 10 iterations
--     print "$_ : $wordlist{$_}\n";  # process array in descending order
--   }                                # of value, printing keys and values

--  What would this look like in Ada using each of the libraries you've
--  listed?  Does anyone else have favourite examples like this?

--  $Id$

with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Word_Parser;
with Word_Count_Support;

procedure Word_Count is
   Word_Found : Boolean;
   File_Done : Boolean;
   Word : Ada.Strings.Unbounded.Unbounded_String;
   Word_Bag : Word_Count_Support.BU.Bag;
   Word_Tree : Word_Count_Support.ST.AVL_Tree;
   Word_Bag_Iter : Word_Count_Support.Containers.Iterator'Class
     := Word_Count_Support.BU.New_Iterator (Word_Bag);
   procedure Word_Processor (Item : Ada.Strings.Unbounded.Unbounded_String;
                             Ok : out Boolean);
   procedure Word_Processor (Item : Ada.Strings.Unbounded.Unbounded_String;
                             Ok : out Boolean) is
      Dummy : Boolean;
   begin
      Word_Count_Support.ST.Insert
        (Word_Tree,
         Word_Count_Support.Word_Stat'
         (Word => Item,
          Count => Word_Count_Support.BU.Count (Word_Bag, Item)),
         Dummy);
      Ok := True;
   end Word_Processor;
   procedure Word_Bag_Visitor
   is new Word_Count_Support.Containers.Visit (Word_Processor);
   Number_Output : Natural := 0;
   procedure Tree_Processor (Item : Word_Count_Support.Word_Stat;
                             OK : out Boolean);
   procedure Tree_Processor (Item : Word_Count_Support.Word_Stat;
                             OK : out Boolean) is
   begin
      Ada.Text_IO.Put_Line
        (Ada.Strings.Unbounded.To_String (Item.Word)
         & " =>"
         & Positive'Image (Item.Count));
      Number_Output := Number_Output + 1;
      OK := Number_Output < 10;          --  this is where we select the top 10
   end Tree_Processor;
   procedure Tree_Visitor is new Word_Count_Support.ST.Visit (Tree_Processor);
begin
   loop
      Word_Parser.Get_Next_Word
        (Ada.Text_IO.Standard_Input, Word, Word_Found, File_Done);
      exit when not Word_Found;
      Word_Count_Support.Bags.Add (Word_Bag, Word);
   end loop;
   Word_Count_Support.Containers.Reset (Word_Bag_Iter);
   Word_Bag_Visitor (Word_Bag_Iter);
   Tree_Visitor (Word_Tree);
end Word_Count;
with Ada.Strings.Unbounded;
with BC.Containers;
with BC.Containers.Bags;
with BC.Containers.Bags.Unbounded;
with BC.Containers.Trees;
with BC.Containers.Trees.AVL;
with Global_Heap;

package Word_Count_Support is

   package Containers is new BC.Containers
     (Item => Ada.Strings.Unbounded.Unbounded_String,
        "=" => Ada.Strings.Unbounded."=");

   package Bags is new Containers.Bags;

   function Hash (S : Ada.Strings.Unbounded.Unbounded_String) return Positive;

   package BU is new Bags.Unbounded (Hash => Hash,
                                     Buckets => 1,
                                     Storage => Global_Heap.Storage);

   type Word_Stat is record
      Word : Ada.Strings.Unbounded.Unbounded_String;
      Count : Positive;
   end record;

   function ">" (L, R : Word_Stat) return Boolean;
   function "=" (L, R : Word_Stat) return Boolean;

   package Stat_Containers is new BC.Containers (Word_Stat);

   package Trees is new Stat_Containers.Trees;

   package ST is new Trees.AVL
     ("<" => ">",     --  we need the most popular first
      Storage => Global_Heap.Storage);

end Word_Count_Support;
package body Word_Count_Support is

   --  This is extraordinarily lazy, of course we should really invent
   --  some better hash function!
   function Hash
     (S : Ada.Strings.Unbounded.Unbounded_String) return Positive is
      pragma Unreferenced (S);
   begin
      return 1;
   end Hash;

   function ">" (L, R : Word_Stat) return Boolean is
      use type Ada.Strings.Unbounded.Unbounded_String;
   begin
      return L.Count > R.Count
        or else (L.Count = R.Count
                 and then L.Word > R.Word);
   end ">";

   function "=" (L, R : Word_Stat) return Boolean is
      use type Ada.Strings.Unbounded.Unbounded_String;
   begin
      return L.Count = R.Count
        and then L.Word = R.Word;
   end "=";

end Word_Count_Support;
--  by Corey Minyard
package body Word_Parser is

   Big_A_Pos   : constant Integer := Character'Pos ('A');
   Small_A_Pos : constant Integer := Character'Pos ('a');

   procedure Xlat_To_Lower_Case (C : in out Character);
   procedure Xlat_To_Lower_Case (C : in out Character) is
   begin
      if (C in 'A' .. 'Z') then
         C := Character'Val (Character'Pos (C) - Big_A_Pos + Small_A_Pos);
      end if;
   end Xlat_To_Lower_Case;

   procedure Get_Next_Word
     (File       : in File_Type;
      Word       : out Ada.Strings.Unbounded.Unbounded_String;
      Word_Found : out Boolean;
      File_Done  : out Boolean) is

      Tmp_Str    : String (1 .. 10);
      Word_Pos   : Positive := Tmp_Str'First;
      Input_Char : Character;
      In_Word    : Boolean := False;
   begin
      --  Start with an empty word.
      Word := Ada.Strings.Unbounded.To_Unbounded_String ("");

      File_Done := False;
      Word_Found := False;

      if (End_Of_File (File)) then
         Word_Found := False;
         File_Done := True;
      else
         loop
            Get (File, Input_Char);
            Xlat_To_Lower_Case (Input_Char);

            if (not In_Word) then
               if (Input_Char in 'a' .. 'z') then
                  In_Word := True;
                  Word_Found := True;
                  Tmp_Str (Word_Pos) := Input_Char;
                  Word_Pos := Word_Pos + 1;
               end if;
            elsif (Input_Char in 'a' .. 'z') then
               Tmp_Str (Word_Pos) := Input_Char;
               if (Word_Pos = Tmp_Str'Last) then
                  Word := Word & Tmp_Str;
                  Word_Pos := Tmp_Str'First;
               else
                  Word_Pos := Word_Pos + 1;
               end if;
            else
               exit;
            end if;

            if (End_Of_File (File)) then
               File_Done := True;
               exit;
            elsif (End_Of_Line (File) and In_Word) then
               exit;
            end if;
         end loop;

         if (Word_Pos /= Tmp_Str'First) then
            --  If we have some stuff left in the temporary string, put it into
            --  the word.
            Word := Word & Tmp_Str (Tmp_Str'First .. Word_Pos - 1);
         end if;
      end if;
   end Get_Next_Word;

end Word_Parser;
--  by Corey Minyard
with Ada.Strings.Unbounded; use type Ada.Strings.Unbounded.Unbounded_String;
with Ada.Text_IO; use Ada.Text_IO;
package Word_Parser is

   procedure Get_Next_Word
     (File       : in File_Type;
      Word       : out Ada.Strings.Unbounded.Unbounded_String;
      Word_Found : out Boolean;
      File_Done  : out Boolean);

end Word_Parser;
