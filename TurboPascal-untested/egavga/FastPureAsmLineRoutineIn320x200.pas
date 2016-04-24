(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0200.PAS
  Description: Fast Pure ASM Line Routine in 320x200
  Author: JEROEN BOUWENS
  Date: 05-26-95  23:05
*)

{
> Could someone send me a fast line drawing source?
}

Procedure Line(X1,Y1,X2,Y2:Word; Color:Byte); Assembler;

Var DeX,DeY  : Integer;
    IncF     : Integer;
    Offset   : Word;

Asm
    Mov  AX,[X2]
    Sub  AX,[X1]
    JNC  @@Dont1
    Neg  AX
  @@Dont1:
    Mov  [DeX],AX
    Mov  AX,[Y2]
    Sub  AX,[Y1]
    JNC  @@Dont2
    Neg  AX
  @@Dont2:
    Mov  [DeY],AX

    Cmp  AX,[DeX]
    JBE  @@OtherLine

    Mov  AX,[Y1]
    Cmp  AX,[Y2]
    JBE  @@DontSwap1
    Mov  BX,[Y2]
    Mov  [Y1],BX
    Mov  [Y2],AX
    Mov  AX,[X1]
    Mov  BX,[X2]
    Mov  [X1],BX
    Mov  [X2],AX
  @@DontSwap1:
    Mov  [IncF],1
    Mov  AX,[X1]
    Cmp  AX,[X2]
    JBE  @@SkipNegate1
    Neg  [IncF]
  @@SkipNegate1:
    Mov  AX,[Y1]
    Mov  BX,320
    Mul  BX
    Mov  DI,AX
    Add  DI,[X1]        {Offset in DI}
    Mov  BX,[DeY]       {RefVar in BX}
    Mov  CX,BX
    Mov  AX,$A000
    Mov  ES,AX          {Video segment}
    Mov  DL,[Color]
    Mov  SI,[DeX]
  @@DrawLoop1:
    Mov  ES:[DI],DL
    Add  DI,320
    Sub  BX,SI
    JNC  @@GoOn1
    Add  BX,[DeY]
    Add  DI,[IncF]
  @@GoOn1:
    Loop @@DrawLoop1
    Jmp  @@ExitLine

  @@OtherLine:
    Mov  AX,[X1]
    Cmp  AX,[X2]
    JBE  @@DontSwap2
    Mov  BX,[X2]
    Mov  [X1],BX
    Mov  [X2],AX
    Mov  AX,[Y1]
    Mov  BX,[Y2]
    Mov  [Y1],BX
    Mov  [Y2],AX
  @@DontSwap2:
    Mov  [IncF],320
    Mov  AX,[Y1]
    Cmp  AX,[Y2]
    JBE  @@SkipNegate2
    Neg  [IncF]
  @@SkipNegate2:
    Mov  AX,[Y1]
    Mov  BX,320
    Mul  BX
    Mov  DI,AX
    Add  DI,[X1]        {Offset in DI}
    Mov  BX,[DeX]       {RefVar in BX}
    Mov  CX,BX
    Mov  AX,$A000
    Mov  ES,AX          {Video segment}
    Mov  DL,[Color]
    Mov  SI,[DeY]
  @@DrawLoop2:
    Mov  ES:[DI],DL
    Inc  DI
    Sub  BX,SI
    JNC  @@GoOn2
    Add  BX,[DeX]
    Add  DI,[IncF]
  @@GoOn2:
    Loop @@DrawLoop2

  @@ExitLine:
End;

{
It assumes video-mode 13h. It's hardly commented, but hey! It works, so....
Some test-results:

On my 286-12Mhz the routine draws: 1300 random lines per second.
                                   650  lines from (0,0)-(319,199) per second.
}

