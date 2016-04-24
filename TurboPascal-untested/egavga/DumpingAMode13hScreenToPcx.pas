(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0196.PAS
  Description: Dumping a Mode 13h Screen to PCX
  Author: KEVIN LUCK
  Date: 05-26-95  23:02
*)

{
  Here's some code for SWAG to dump the current mode $13 screen to a PCX file.
Feel free to use/modify, just give credit.  Also, if you do a good mod of it
(ie, A mode X version, faster compression, whatever), I'd love to see it.

Reference: Bit-Mapped Graphics (2nd Edition)
    Steve Rimmer
    ISBN 0-8306-4209-9
    (C code but still pretty useful)

PCX is of course (tm) Z-Soft Corp.

Copyright 1995 Kevin M. Luck
}

Unit SavePCX;


Interface


Uses Dos,CRT;


Procedure Save_PCX (FN : String);


Implementation


Procedure Save_PCX (FN : String);

Var
  F : File;
  Ln : Byte;

Procedure Write_Header;

Const
  OldPal : Array [1..48] of Byte = (0,0,0,216,152,56,120,116,4,112,108,4,236,
        172,76,248,196,128,64,36,36,36,40,20,248,
        188,104,212,144,156,60,36,36,116,112,8,
        120,116,8,124,120,8,52,48,4,240,196,136);

Var
  B,L : Byte;
  I : Integer;

Begin
  B := 10;                              (*  Manufacturer                *)
  BlockWrite (F,B,1);
  B := 5;                               (*  Version                     *)
  BlockWrite (F,B,1);
  B := 1;                               (*  Encoding                    *)
  BlockWrite (F,B,1);
  B := 8;                               (*  Bytes Per Pixel             *)
  BlockWrite (F,B,1);
  I := 0;                               (*  Min X                       *)
  BlockWrite (F,I,2);
  I := 0;                               (*  Min Y                       *)
  BlockWrite (F,I,2);
  I := 319;                             (*  Max X                       *)
  BlockWrite (F,I,2);
  I := 199;                             (*  Max Y                       *)
  BlockWrite (F,I,2);
  I := 320;                             (*  Horizontal Resolution       *)
  BlockWrite (F,I,2);
  I := 200;                             (*  Vertical Resolution         *)
  BlockWrite (F,I,2);                   (*  Default Palette             *)
  BlockWrite (F,Mem [Seg (OldPal):Ofs (OldPal)],48);
  B := 0;                               (*  Reserved                    *)
  BlockWrite (F,B,1);
  B := 1;                               (*  Color Planes                *)
  BlockWrite (F,B,1);
  I := 320;                             (*  Bytes Per Line              *)
  BlockWrite (F,I,2);
  I := 0;                               (*  Palette Type                *)
  BlockWrite (F,I,2);
  B := 0;
  For L := 1 to 58 Do BlockWrite (F,B,1);
End;

Procedure Encode_Line (Ln : Byte);

Var
  B : Array [1..64] of Byte;
  I,J,T : Word;
  A : Byte;
  P : Array [0..319] of Byte;

Begin
  I := 0;
  J := 0;
  T := 0;
  Move (Mem [$a000:Ln * 320],P,320);
  While T < 320 Do
  Begin
    I := 0;
    While ((P [T + I] = P [T + I + 1]) And ((T + I) < 320) And (I < 63)) Do
      Inc (I);
    If I > 0 Then
    Begin
      A := I Or 192;
      BlockWrite (F,A,1);
      BlockWrite (F,P [T],1);
      Inc (T,I);
      Inc (J,2);
    End
    Else Begin
      If (((P [T]) And 192) = 192) Then
      Begin
 A := 193;
 BlockWrite (F,A,1);
 Inc (J);
      End;
      BlockWrite (F,P [T],1);
      Inc (T);
      Inc (J);
    End;
  End;
End;

Procedure Write_Palette;

Var
  L,R,G,B : Byte;

Procedure GetPal (ColorNo : Byte; Var R,G,B : Byte);

Begin
  Port [$3c7] := ColorNo;
  R := Port [$3c9];
  G := Port [$3c9];
  B := Port [$3c9];
End;

Begin
  L := 12;
  BlockWrite (F,L,1);
  For L := 0 to 255 Do
  Begin
    GetPal (L,R,G,B);
    R := R * 4;
    G := G * 4;
    B := B * 4;
    BlockWrite (F,R,1);
    BlockWrite (F,G,1);
    BlockWrite (F,B,1);
  End;
End;

Begin
  Assign (F,FN);
{$I-}
  Rewrite (F,1);
{$I+}
  Write_Header;
  For Ln := 0 to 199 Do Encode_Line (Ln);
  Write_Palette;
  Close (F);
End;


End.

