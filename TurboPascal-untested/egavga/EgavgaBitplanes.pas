(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0079.PAS
  Description: EGA/VGA Bitplanes
  Author: JAN DOGGEN
  Date: 01-27-94  11:59
*)

{
> Attention: All those who are familiar with graphics ports
> (ie. Sean Palmer, Jan Doggen, and others I don't yet know).

Don't consider myself that familiar with 'em, but here are some
snippets and remarks. BTW I consider phasing out all BGI stuff in my
code in the first half of '93 or so, which will be a major effort.
After that, I'll rank myself among the register-twiddlers. Maybe we
should team up on this project if you plan on going in that direction
too.

> Would you mind explaining the EGA map mask (?) and
> sequencer (?) register ports (I don't know what they are
> *really* called, but they are the ones that control which
> bitplane gets written to in EGA mode
> 640x350x16, 4 bitplanes) to me (please)?

There are several write modes and read modes for EGA/VGA, and the
exact workings of the registers depend on the mode. What you are
talking about (I assume) is read/write mode 0 which you would use
to pump bytes directly into a bit plane. I use the following
procedure for this:


(*************************** EGA/VGA bit planes ****************************)
}

CONST
  GDCIndexReg = $3CE;  { Index register of EGA/VGA Graphics Device Controller }
  GDCDataReg  = $3CF;  { Data  register of EGA/VGA Graphics Device Controller }
  SeqIndexReg = $3C4;  { Index register of EGA/VGA Sequencer }
  SeqDataReg  = $3C5;  { Data  register of EGA/VGA Sequencer }

PROCEDURE PrepareBitPlaneRead(Plane: Byte);
  BEGIN
    Port[GDCIndexReg] := 5;           { Number of Mode register }
    Port[GDCDataReg ] := 0;           { Value of register: 0: read mode 0 }
    Port[GDCIndexReg] := 4;           { Number of Read Map Select register }
    Port[GDCDataReg ] := Plane;       { Value of register: bit for plane to
read }
  END; { PrepareBitPlaneRead }


PROCEDURE ConcludeBitPlaneRead(Plane: Byte);
  BEGIN
    Port[GDCIndexReg] := 5;           { Number of Mode register }
    Port[GDCDataReg ] := $10;         { Value of register: 10: default for
modes 10h and 12h }
    Port[GDCIndexReg] := 4;           { Number of Read Map Select register }
    Port[GDCDataReg ] := 0;           { Value of register: plane to read }
  END; { ConcludeBitPlaneRead }


PROCEDURE PrepareBitPlaneWrite(Plane,PutMode: Byte);
  BEGIN
    Port[GDCIndexReg] := 5;           { Number of Mode register }
    Port[GDCDataReg ] := 0;           { Value of register: 0: write mode 0 }
    Port[GDCIndexReg] := 1;           { Number of Enable Set/Reset register }
    Port[GDCDataReg ] := 0;           { Value of register: 0 }
    Port[GDCIndexReg] := 3;           { Number of Data Rotate/Function Select
register }
   (* Bits 3 and 4 from the Rotate/Function Select register mean:
    *          Bit 4  Bit 3   Replacement function:
    *            0      0           Replace
    *            0      1           AND
    *            1      0           OR
    *            1      1           XOR    *)
    CASE PutMode OF
      AndPut : Port[GDCDataReg] :=  8;   { No rotation; AND with buffer }
      OrPut  : Port[GDCDataReg] := 16;   { No rotation; OR  with buffer }
      XORPut : Port[GDCDataReg] := 24    { No rotation; XOR with buffer }
    ELSE
      Port[GDCDataReg] :=  0;    { No rotation; replace; use this as default }
    END; { CASE }
    Port[GDCIndexReg] := 8;           { Number of BitMask register }
    Port[GDCDataReg ] := $FF;         { Value of register: $FF: use all bits }
    Port[SeqIndexReg] := 2;           { Number of Map Mask register }
    Port[SeqDataReg ] := 1 SHL Plane; { Value of register: plane number }
  END; { PrepareBitPlaneWrite }


PROCEDURE ConcludeBitPlaneWrite(Plane: Byte);
  BEGIN
    Port[GDCIndexReg] := 1;           { Number of Enable Set/Reset register }
    Port[GDCDataReg ] := 0;           { Value of register: 0 }
    Port[SeqIndexReg] := 2;           { Number of Map Mask register }
    Port[SeqDataReg ] := $0F;         { Value of register: Enable all planes }
    Port[GDCIndexReg] := 3;           { Number of Data Rotate/Function Select
register }
    Port[GDCDataReg ] := 0;           { Value of register: No rotation; replace
}
  END; { ConcludeBitPlaneWrite }

{
A good explanation can be found in:
  Wilton,R - Programmers' guide to PC and PS/2 video systems
  Microsoft Press

You should invest in some books on EGA/VGA programming if you have
more of these questions, otherwise you're being 'penny wise, pound
foolish'.

The book by Wilton is considered more or less a 'must have' together
with
  Ferraro, R.F. - Programmer's guide to the EGA and VGA cards
  Addison-Wesley

Ferraro gives you detailed register info. It also deals with Super
VGAs. Because I'll have to expand a program to use VESA super VGA
modes, I bought this together with:
  Rimmer, S - Super VGA graphics programming secrets
  WindCrest/McGraw Hill
}
