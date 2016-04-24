(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0048.PAS
  Description: Export data from OBJ file
  Author: WILBERT VAN LEIJEN
  Date: 11-02-93  05:39
*)

{
WILBERT VAN LEIJEN

> I want to pass its address to an external .obj procedure so I can set
> DS:SI to it... how do I do this?  I know how to do this sort of think if I
> use the tp60 built in asmm thingy, and I know that I can pass values using
> arg like

You cannot export data from an .OBJ file to a Pascal program.  The linker
cannot handle with public identifiers other than in a segment of class CODE,
alas.

Store the data in a File of Byte (DORK.BIN), convert it with BINOBJ to DORK.OBJ
(suggested identifier: Procedure DorkData), link it to your program.
}

Procedure DorkData; External;
{$L DORK.OBJ }

Type
  TDork = Array[0..255] of Byte;
  PDork = ^TDork;

Var
  Dork : PDork;
  i    : Integer;

Begin
  Dork := @DorkData;
  For i := Low(TDork) to High(TDork) Do
    Write(Dork^[i] : 4);
end.

{ If you want to use assembler to access DorkData: }

ASM
  CLD
  PUSH   DS
  PUSH   CS            { Using "LDS SI, DorkData" will not work! }
  POP    DS
  LEA    SI, DorkData            { DS:SI points to DorkData }
  MOV    CX, Type(TDork)         { = 256 }
 @1:     LODSB                { TDork(DorkData[256-CX]) is now in AL }
  { other code }
  LOOP   @1
  POP    DS
end;

