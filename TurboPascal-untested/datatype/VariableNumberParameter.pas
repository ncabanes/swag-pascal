(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0018.PAS
  Description: Variable Number Parameter
  Author: JANOS SZAMOSFALVI
  Date: 01-27-94  12:24
*)

{
|│-> You can allocate some memory and put all your parameters there, then
|│-> pass a pointer which points to this memory block.  You have to
|│-> setup some convention if you want to pass different types, or
|│-> parameters with different length.
|│
|│Well how do I do that in Pascal- I really think that I might be better
|│off making the function in C and then compiling it out to an object file
|│and then linking it into pascal

Mixed language programming is tricky and difficult unless the
compilers explicitely support it.

|│but I am not sure that that will even
|│work I might just abandon Pascal and learn C

Good luck!  <evil grin>

|│(even though the SYNTAX rules for C are based on Pascal anyhow)
                                          ^^^^^^^^^^^^^^^
Hmmmm.....

Anyway, here's a quick and dirty example (untested) about passing
pointers and variable # of parameters.
}
PROGRAM Pass_Pointer;     {Compiled with TP _3.01A_}

TYPE
   Short_String = STRING[15];

CONST
   max_count  = 13;
   terminator : Short_String = #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;

TYPE
   String_Array = ARRAY [0..max_count] OF Short_String;
   Pointer = ^String_Array;

VAR
   star : Pointer;
   sstr : Short_String;
   count, i : INTEGER;

PROCEDURE Receiver (P : pointer);
BEGIN
   i := 0;
   WHILE (P^[i] <> terminator) AND (i < max_count) DO BEGIN
      writeln(P^[i]);
      i := i + 1;
   END;
END;

BEGIN
   count := 0;
   New (star);
   REPEAT
      write('Enter a short string: ');
      readln(sstr);
      star^[count] := sstr;
      count := count + 1;
   UNTIL (sstr = '') OR (count >= max_count);

   IF count < max_count THEN
      star^[count - 1] := terminator;

   Receiver(star);
END.

