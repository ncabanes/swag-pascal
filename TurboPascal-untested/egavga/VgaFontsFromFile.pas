(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0043.PAS
  Description: VGA Fonts from file
  Author: SEAN PALMER
  Date: 05-28-93  13:39
*)

{
  Sean Palmer

> Does anyone know of any way to display a single screen of Graphics on
> EGA 640x350 mode *quickly*.  It can be VGA as well; I'm just trying to
> display the screen *fast* from a disk File.  I know, I could have used
> the GIF or PCX format (or any other format), but I want to make a
> proprietary format to deter hacking of the picture.  So, what I want to
> know is how to read the data from disk directly to screen.  I've
> figured out that BlockRead (if I can get it to work) is the best method
> of reading the data from the disk, but I don't know of any fast, and I
> mean *fast*, methods of writing the data to the screen.  Would it be
> feasible to use an Array the size of the screen and Move the Array to
> the screen (I'd need memory locations For that, if possible)?  Any
> response (ideas, solutions, code fragments) would be appreciated.

You could set up the screen as an Absolute Variable.
Then read in each plane as an Array DIRECTLY from the disk File.
Before reading each plane, set up Write mode 0 (should be already in mode 0)
and make sure that the enable set/reset register is set to 0 so that the cpu
Writes go directly to the planes. Set the sequencer map mask register for
each plane so you only Write to them one at a time. and enable the entire Bit
Mask register ($0F). Then after telling it which plane, read directly from
the File. No I haven't tested the following code and most of it's gonna be
from memory but give it a try:

the File:
  Plane 0
  Plane 1
  Plane 2
  Plane 3

each Plane:
  350 rows of 80 Bytes (each bit belongs to a different pixel)
}

Type
  scrRec = Array[0..640 * 350 div 8 - 1] of Byte;
Var
  screen : scrRec Absolute $A000 : 0000;
  dFile  : File of scrRec;

Const
  gcPort  = $3CE;  {EGA/VGA Graphics controller port}
  seqPort = $3C4;  {EGA/VGA sequencer port}

Procedure readFileToMode10h(s:String);
Var
  dFile : File of scrRec;
  i     : Byte;
begin
  Asm
    mov ax, $10;
    int $10;
  end;  {set up video mode}
  assign (dFile,s);
  reset(s);  {no error checking 8) }
  portw[gcPort] := $0001;    {clear enable set/reset reg}
  portw[gcPort] := $FF08;    {set entire bit mask (this is the default?)}
  For i := 0 to 3 do
  begin
   {set map mask reg to correct plane}
   portw[seqPort] := (1 shl (i + 8)) + $02;
   read(dFile, screen); {load that plane in}
  end;
  portw[seqPort] := $0F02;   {restore stuff to normal}
  portw[gcPort]  := $0F01;
  close(dFile);
end;

