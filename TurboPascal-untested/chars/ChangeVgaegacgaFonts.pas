(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0006.PAS
  Description: Change VGA/EGA/CGA Fonts
  Author: MICHAEL HOENIE
  Date: 11-26-93  18:05
*)

{
From: MICHAEL HOENIE
Subj: CHARACTER UNIT.
----------------------------------------------------------------------
here is some revised code to allow users to change the standard ASCII
font in EGA or VGA. I don't know if it will work in standard CGA, but
it works well on VGA. }

   unit graphics;

   interface uses dos, crt;

   const
     numnewchars=9; { # of chars available }

     {1 2 4 8 1 3 6 1
      │ │ │ │ 6 2 4 2
      │ │ │ │ │ │ │ 8
      │ │ │ │ │ │ │ │     Character.
      1 2 3 4 5 6 7 8       8x16
     ┌─┬─┬─┬─┬─┬─┬─┬─┐
    1│ │ │ │ │ │ │ │ │=
    2│ │ │ │ │ │ │ │ │=       This is a BYTE mapper.
    3│ │ │ │ │ │ │ │ │=       Fill in the blanks, then add
    4│ │ │ │ │ │ │ │ │=       the numbers together on a calculator.
    5│ │ │ │ │ │ │ │ │=       The # should never be greater than 255.
    6│ │ │ │ │ │ │ │ │=
    7│ │ │ │ │ │ │ │ │=       The #'s are as follows:
    8│ │ │ │ │ │ │ │ │=
    9│ │ │ │ │ │ │ │ │=       1,2,4,8,16,32,64,128
   10│ │ │ │ │ │ │ │ │=
   11│ │ │ │ │ │ │ │ │=       So if you had:
   12│ │ │ │ │ │ │ │ │=
   13│ │ │ │ │ │ │ │ │=       X X X    X  X      X
   14│ │ │ │ │ │ │ │ │=       1 2 4   16 32    128   = 183
   15│ │ │ │ │ │ │ │ │=
   16│ │ │ │ │ │ │ │ │=
     └─┴─┴─┴─┴─┴─┴─┴─┘}

     procedure loadchar; { this is the procedure to change the characters }

   implementation

     procedure loadchar;
     type
       bytearray=array[0..15] of byte;
       chararray=array[1..numnewchars] of record
         charnum:byte;
         chardata:bytearray;
       end;
     const { these are the characters outlined 9 = chr(9), 176 = chr(176) }
       newchars:chararray=(
         (charnum:9; chardata: (24,0,66,0,0,024,165,24,60,102,66,66,66,
                               102,60,0)),
         (charnum:10; chardata: (24,126,255,231,231,255,255,255,255,255,
                                191,255,255,255,255,255)),
         (charnum:24; chardata: (24,24,24,24,24,24,24,24,24,24,126,24,24,
                                24,60,24)),
         (charnum:231; chardata: (8,42,28,127,27,42,8,8,8,8,8,8,8,8,8,0)),
         (charnum:235; chardata: (0,0,102,60,24,24,24,60,60,126,126,126,
                                 60,24,0,0)),
         (charnum:239; chardata: (255,171,213,171,213,171,213,171,213,171,
                                 213,171,213,171,213,171)),
         (charnum:225; chardata: (24,60,102,102,102,60,24,24,24,24,120,120,
                                 24,120,120,0)),
         (charnum:176; chardata: (9,64,4,33,0,136,2,32,1,136,0,66,0,8,64,18)),
         (charnum:177; chardata: (119,119,119,0,238,238,238,0,119,119,119,0,
                                 238,238,238,0)));

     var
       regs:registers;
       i:byte;
     begin
       for i:=1 to numnewchars do
         begin
           with regs do
             begin
               ah:=$11;  { video sub-Function $11 }
               al:=$0;   { Load Chars to table $1 }
               bh:=$10;  { number of Bytes per Char $10 }
               bl:=0;    { Character table to edit }
               cx:=1;    { number of Chars we're definig }
               dx:=newchars[i].charnum;
               es:=seg(newchars[i].chardata);
               bp:=ofs(newchars[i].chardata);
               intr($10,regs);
             end;
         end;
     end;

   begin
   end.

