(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0003.PAS
  Description: Switch Font Characters
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{
> How can I redefine the ASCII Chars. For example how can
> I make the ASCII code 65 become a "weird form" instead
> of an "A".

You want it, you got it.  Here are the two Procedures you need, plus some
info. First, you need to make a data Type With an Array of [1..16] of Byte,
so the best idea would be this:  Make a Record as follows:
}

Type
  CharRec = Record
    data : Array[1..16] of Byte;
  end;

{ Now, make a Variable to contain the entire Character set. }

Var
  CharSet : Array[0..255] of CharRec;

{ Next, you'll need the two Procedures: }

Procedure GetImageChar(chrVal : Byte; Var CharInfo);
Var
  offset : Word;
begin
  offset := chrVal * 32;
  Inline($FA);
  PortW[$3C4] := $0402;
  PortW[$3C4] := $0704;
  PortW[$3CE] := $0204;
  PortW[$3CE] := $0005;
  PortW[$3CE] := $0006;
  (* refer to following notes For info about the next line *)
  Move(Ptr($A000, offset)^, CharInfo, 16);
  PortW[$3C4] := $0302;
  PortW[$3C4] := $0304;
  PortW[$3CE] := $0004;
  PortW[$3CE] := $1005;
  PortW[$3CE] := $0E06;
  Inline($FB);
end;

{
OK.  That's the Procedure to GET a Character bitmap, and store it in a
Variable.  So, if you use the Type and Var I defined at the top, do this:

GetImageChar(65, CharSet[65]);

This example will copy the bitmap from Character 65 (A) into the Record of 65,
so you'll have copied the bitmap For 'A'.  Now, you can edit the bitmap (I
wrote my own font editor) and Write it to memory With a second Procedure.

Here's the tricky part.  I didn't Write the 2nd Procedure because it is
identical to the first *EXCEPT* For ONE line.  Copy the Procedure and change
it's name to SetImageChar, and change this line:

Move(Ptr($A000, offset)^, CharInfo, 16);

and make it read:

Move(CharInfo, Ptr($A000, offset)^, 16);

That's it!  Have fun!  TTYL.
}

{
OK, 'data' is an Array [1..16] of Byte.  So, you just draw your Character on
Graph paper in binary, convert to decimal Bytes, put them in the Array, and
feed it into this Procedure.  'CharNum' is the ASCII value of the Character you
want to remap.  To make a Procedure that READS the bitmap instead of writing,
just change the line With 'Move(data, Ptr($A000, offset)^, 16)' and make it say
'Move(Ptr($A000, offset)^, data, 16);' and you will now be able to read bitmaps
from the Character set.  I'm running out of time, so I can't explain it very
well, but I hope this helps.  TTYL.
}
{

  I ran that in a loop and after a While it screwed up the whole
  font - might just be my EGA card, but my opinion is that this
  method stinks...there are Registers For getting/setting the
  font; I found code from a Program called Display Font Editor
  (DFE).  DFE edits font Files, and it came With source to
   load these font Files. Following is a bit from setting
  the Registers to load a font (don't have getting a font)

  r.ax := $1110;
  r.bh := 14;                   (* Bytes per Character *)
  r.bl := 0;                    (* load to block 0 *)
  r.cx := 256;                  (* 256 Characters *)
  r.dx := 0;                    (* start With Character 0 *)
  r.es := Seg(P^);              (* segment of table *)
  r.bp := Ofs(P^);              (* offset of the table *)
  intr($10, r);

  With this, you can see, you can even do one Character at a
  time ( cx = 1, dx = ascii, P^ = Array[1..14] of Byte)
}
