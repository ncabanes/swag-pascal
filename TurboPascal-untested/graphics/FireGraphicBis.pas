(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0109.PAS
  Description: Fire Graphic
  Author: ALEX CHALFIN
  Date: 08-24-94  13:38
*)

{
Here is a little something for all you pyromaniacs, and demo coders out there.

I got my hands on Jare's fire code and thought it was pretty cool, so I made
my own fire program. Although it didn't turn out like I thought it would (like
Jare's) what I have is (at least I think so) something that looks more
realistic.

This program was completely written by myself and was inspired by Jare's fire
code (available on Internet FTP at ftp.eng.ufl.edu  pub/msdos/demos/programming
/source). A 386 computer is required (Double Word copies are used), but a 486
is highly recommended, as 28800 pixels are calculated each frame (I use
standard mode 13h). The entire source is Pascal/Inline asm and was written
using Turbo Pascal v6.0.    I hope you like it.


{ **** Program starts here ******** }

Program Phire;
{$G+}    { Enable 286 instructions }
{ coded by Phred  7/23/94     aka Alex Chalfin    }
{               Internet: achalfin@uceng.uc.edu   }
{ A fast computer is HIGHLY recommended.          }
{ Inspired by Jare's fire code                    }

Var
  Screen : Array[0..63999] of Byte ABSOLUTE $A000:$0000; { the VGA screen }
  VScreen : Array[0..63999] of Byte;                { an offscreen buffer }
  Lookup : Array[0..199] of Word;    { an Offset lookup table }

Procedure SetPalette; Near;
{ Sets the Palette }

Var
  p : Array[0..767] of Byte;
  x : integer;

Begin
  for x := 0 to 255 do            { Generate fade from orange to black }
    Begin
      p[x*3] := (x * 63) Shr 8;
      P[x*3+1] := (x * 22) Shr 8;
      P[x*3+2] := 0;
    End;
  Port[$3C8] := 0;
  For x := 0 to 255 do        { Set the palette }
    Begin
      Port[$3C9] := P[x*3];
      Port[$3C9] := P[x*3+1];
      Port[$3C9] := P[x*3+2];
    End;
End;

Procedure Burnin_Down_The_House;

Var
  c : Integer;

Begin
  Randomize;
  Repeat
    For c := 0 to 319 do    { Setup bottom line "hot spots" }
      If Random(4) = 1
        Then VScreen[LookUp[199] + c] := Random(3) * 255;
    Asm
      MOV  CX,28800         { Number of pixels to calculate }
      PUSH CX               { Store count on stack }
      MOV  AX,Offset VScreen
      PUSH AX               { Store value on stack }
      MOV  SI,AX
      MOV  BX,199
      SHL  BX,1
      MOV  AX,Word Ptr [LookUp + BX]
      ADD  SI,AX
      DEC  SI            { DS:SI := VScreen[LookUp[198]+319] }
     @Looper:
      XOR  AX,AX
      XOR  BX,BX
      MOV  AL,DS:[SI+319]
      ADD  BX,AX
      MOV  AL,DS:[SI+320]
      ADD  BX,AX
      MOV  AL,DS:[SI+321]
      ADD  BX,AX
      MOV  AL,DS:[SI]
      ADD  BX,AX    { Average the three pixels below and the one that its on}
      SHR  BX,2     { Divide by 4 }
      JZ  @Skip
      DEC  BX       { Subtract 1 if value > 0 }
     @Skip:
      MOV  DS:[SI],BL  { Store pixel to screen }
      DEC  SI          { Move to next pixel }
      DEC  CX
      JNZ @Looper
    { Copy the screen Buffer using Double Word copies }
      MOV  BX,110
      SHL  BX,1
      MOV  AX,Word Ptr [LookUp + BX]
      MOV  DX,AX
      POP  SI        { Restore starting offset of VScreen  }
      MOV  AX,$A000
      MOV  ES,AX     { DS:SI = starting location in buffer }
      XOR  DI,DI     { ES:DI = Starting location in screen }
      ADD  SI,DX
      ADD  DI,DX
      POP  CX        { Retrive Count off the stack }
      SHR  CX,2      { divide by 4 to get # of double words.              }
     db 66h          { Since TP won't allow 386 instructions, fake it.    }
      REP  MOVSW     { This translates into REP MOVSD (move double words) }
    End;
  Until Port[$60] = 1;   { Until ESC is pressed }
End;

Begin
  Asm              { Initialize mode 13h VGA mode }
    MOV  AX,13h
    INT  10h
  End;
  For LookUp[0] := 1 to 199 do            { Calculate lookup table }
    LookUp[LookUp[0]] := LookUp[0] * 320;
  LookUp[0] := 0;
  SetPalette;
  FillChar(VScreen, 64000, 0);
  Burnin_Down_The_House;
  Asm
    MOV  AX,3
    INT  10h
  End;
End.


