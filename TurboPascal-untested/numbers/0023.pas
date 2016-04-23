{
Borland changed the Random() algorithm between TP6 and TP/BP7.  The Unit
below provides the TP6 Random Function in its Integer flavour.  (The
Randomize Procedure wasn't changed.)

{ *  Turbo Pascal Runtime Library Version 6.0     * ;
  *  Random Number Generator                      * ;
  *                                               * ;
  *  Copyright (C) 1988,92 Borland International  * }

Unit TP6Rand;

Interface

Function Random(Max: Integer): Integer;

Implementation

Const
  { Scaling Constant}
  ConstM31 = LongInt(-31);
  { Multiplication factor}
  Factor: Word = $8405;


Function NextRand: LongInt; Assembler;
{
  Compute next random number
  New := 8088405H * Old + 1
  Out  DX:AX = Next random number
}
Asm
  MOV  AX,RandSeed.Word[0]
  MOV  BX,RandSeed.Word[2]
  MOV  CX,AX
  MUL  Factor.Word[0]     { New = Old.w0 * 8405H }
  SHL  CX,1               { New.w2 += Old.w0 * 808H }
  SHL  CX,1
  SHL  CX,1
  ADD  CH,CL
  ADD  DX,CX
  ADD  DX,BX              { New.w2 += Old.w2 * 8405H }
  SHL  BX,1
  SHL  BX,1
  ADD  DX,BX
  ADD  DH,BL
  MOV  CL,5
  SHL  BX,CL
  ADD  DH,BL
  ADD  AX,1      { New += 1 }
  ADC  DX,0
  MOV  RandSeed.Word[0],AX
  MOV  RandSeed.Word[2],DX
end;

Function Random(Max: Integer): Integer; Assembler;
Asm
 CALL  NextRand
 xor   AX,AX
 MOV   BX,Max.Word[0]
 or    BX,BX
 JE    @@1
 XCHG  AX,DX
 div   BX
 XCHG  AX,DX
@@1:
end;

end.
