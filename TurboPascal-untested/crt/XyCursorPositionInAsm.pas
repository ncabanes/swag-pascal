(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0001.PAS
  Description: XY Cursor Position in ASM
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

{
> If anyone is interested in the BAsm GotoXY/WhereX/WhereY routines
> I'll be happy to post them.   They use standard BIOS routines, and

I simply followed an Interrupt listing I had to create these Functions.

Note the DEC commands in GotoXY, and the INC command in Each WHERE* Function.
These are there to make the Procedures/Functions Compatible With the TP Crt
routines, which are 1-based.  (ie: 1,1 in TP.Crt is upper left hand corner).
The BIOS routines need to be given 0,0 For the same coordinates.   If you don't
want to remain Compatible With Turbo's GotoXY and WHERE* Functions, delete them
out and keep your code Zero-based For X/Y screen coords.
}

Procedure GotoXY(X,Y : Byte); Assembler; Asm
  MOV DH, Y    { DH = Row (Y) }
  MOV DL, X    { DL = Column (X) }
  DEC DH       { Adjust For Zero-based Bios routines }
  DEC DL       { Turbo Crt.GotoXY is 1-based }
  MOV BH,0     { Display page 0 }
  MOV AH,2     { Call For SET CURSOR POSITION }
  INT 10h
end;

Function  WhereX : Byte;  Assembler;
Asm
  MOV     AH,3      {Ask For current cursor position}
  MOV     BH,0      { On page 0 }
  INT     10h       { Return inFormation in DX }
  INC     DL        { Bios Assumes Zero-based. Crt.WhereX Uses 1 based }
  MOV     AL, DL    { Return X position in AL For use in Byte Result }
end;

Function WhereY : Byte; Assembler;
Asm
  MOV     AH,3     {Ask For current cursor position}
  MOV     BH,0     { On page 0 }
  INT     10h      { Return inFormation in DX }
  INC     DH       { Bios Assumes Zero-based. Crt.WhereY Uses 1 based }
  MOV     AL, DH   { Return Y position in AL For use in Byte Result }
end;

{
Note that the WhereX and WhereY Function call the exact same Bios function.
}

