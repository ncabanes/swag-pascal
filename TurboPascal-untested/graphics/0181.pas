{
Ok, it's finished now, and it's pretty fast (1600-1700 poly's per second on
one of the DX2-66's in school). You can find it below. But I doubt if you'll
learn a lot from it, except asm tricks. Better is to understand the method,
and then write you own routines. But you're allowed to use it :-) (Credit
me, allright? I like that :-).

> I haven't done much figure graphics(stuff like polygons, 3d,
> rotating, etc...), simply because I'm still learning, and am
> going slow.  But, what else can you expect, I'm only 14.  <g>

Well, in that case you've got enough time to learn :-). I'm 19 now, and I'm
still learning every day (In fact I've been born 10 years early, I started
programming on a ZX Spectrum (yech, 8 colors) :-). Just pay attention in
math-class. For efficient code, you need to know your math's really well!

Ok, here's the polygon-routine:
}

Procedure TriAngle(X1,Y1,X2,Y2,X3,Y3:Integer; Color:Byte); Assembler;
Var RV1,RV2,IF1,IF2,DeX1,DeX2,DeY1,DeY2 : Integer;
Asm

  CLI

  {Sort by Y-value}
  Mov  CX,2
@@SortLoop:
  Mov  AX,[Y2]; Cmp  AX,[Y3]; JBE  @@Skip1
  Xor  AX,[Y3]; Xor  [Y3],AX; Xor  AX,[Y3]; Mov  [Y2],AX
  Mov  AX,[X2]; Xor  AX,[X3]; Xor  [X3],AX; Xor  AX,[X3]; Mov  [X2],AX
@@Skip1:
  Mov  AX,[Y1]; Cmp  AX,[Y2]; JBE  @@Skip2
  Xor  AX,[Y2]; Xor  [Y2],AX; Xor  AX,[Y2]; Mov  [Y1],AX
  Mov  AX,[X1]; Xor  AX,[X2]; Xor  [X2],AX; Xor  AX,[X2]; Mov  [X1],AX
@@Skip2:
  Mov  AX,[Y1]; Cmp  AX,[Y3]; JBE  @@Skip3
  Xor  AX,[Y3]; Xor  [Y3],AX; Xor  AX,[Y3]; Mov  [Y1],AX
  Mov  AX,[X1]; Xor  AX,[X3]; Xor  [X3],AX; Xor  AX,[X3]; Mov  [X1],AX
@@Skip3:
  Loop @@SortLoop

  {Calculate start-offsets}
  Mov  DX,[Y1]; Shl  DX,6; Mov  BX,DX; Shl  DX,2; Add  DX,BX
  Add  DX,[X1]; Mov  SI,DX

  {Claculate DY, and fill DeY en RefVar with it}
  {Just sorted by Y-value, so no checking for <0 is needed}
  Mov  AX,[Y3]; Sub  AX,[Y1]; Inc  AX; Mov  [DeY1],AX
  Mov  [RV1],AX; Mov  AX,[Y2]; Sub  AX,[Y1]; Inc  AX
  Mov  [DeY2],AX; Mov  [RV2],AX

  {Same for DX. Possible to get a <0 value, so check for that}
  Mov  [IF1],1; Mov  AX,[X3]; Sub  AX,[X1]; JNC  @@SkipDXNeg1
  Neg  AX; Neg  [IF1]
@@SkipDXNeg1:
  Inc  AX; Mov  [DeX1],AX; Mov  [IF2],1; Mov  AX,[X2]
  Sub  AX,[X1]; JNC  @@SkipDXNeg2; Neg  AX; Neg  [IF2]
@@SkipDXNeg2:
  Inc  AX; Mov  [DeX2],AX

  {Video segment in ES}
  Mov  AX,$A000; Mov  ES,AX

  Mov  AL,[Color]; Mov  AH,AL; Mov  CX,[DeY2]
@@DrawLoop1:
  Push CX
  {Draw a horizontal line}
  Mov  DI,DX
  Mov  CX,SI
  Cmp  CX,DI
  JA   @@DontSwap1
  Xchg CX,DI
@@DontSwap1:
  Sub  CX,DI
  Inc  CX
  Test CX,1
  JZ   @@Even1
  StosB
@@Even1:
  Shr  CX,1
  Rep  StosW

  {Adapt: RV1, Ofs1}
  Mov  BX,[RV1]
  Sub  BX,[DeX1]
  Cmp  BX,0
  JG   @@DoNothing1
@@DoSomething1:
  Add  BX,[DeY1]
  Add  DX,[IF1]
  Cmp  BX,0
  JLE  @@DoSomething1
@@DoNothing1:
  Add  DX,320
  Mov  [RV1],BX

  {Adapt: RV2, Ofs2}
  Mov  BX,[RV2]
  Sub  BX,[DeX2]
  Cmp  BX,0
  JG   @@DoNothing2
@@DoSomething2:
  Add  BX,[DeY2]
  Add  SI,[IF2]
  Cmp  BX,0
  JLE  @@DoSomething2
@@DoNothing2:
  Add  SI,320
  Mov  [RV2],BX

  Pop  CX
  Loop @@DrawLoop1

  {Adapt: DeY2, DeX2, RV2, IF2}
  Push DX
  Mov  DX,[Y3]
  Sub  DX,[Y2]
  Inc  DX
  Mov  [DeY2],DX
  Mov  [RV2],DX
  Mov  [IF2],1
  Mov  DX,[X3]
  Sub  DX,[X2]
  JNC  @@DX2Pos
  Neg  DX
  Neg  [IF2]
@@DX2Pos:
  Inc  DX
  Mov  [DeX2],DX
  Pop  DX

  {Draw second half of poly}
  Mov  CX,[DeY2]
@@DrawLoop2:
  Push CX
  {Draw a horizontal line}
  Mov  DI,DX
  Mov  CX,SI
  Cmp  CX,DI
  JA   @@DontSwap2
  Xchg CX,DI
@@DontSwap2:
  Sub  CX,DI
  Inc  CX
  Test CX,1
  JZ   @@Even2
  StosB
@@Even2:
  Shr  CX,1
  Rep  StosW

  {Adapt: RV1, Ofs1}
  Mov  BX,[RV1]
  Sub  BX,[DeX1]
  Cmp  BX,0
  JG   @@DoNothing3
@@DoSomething3:
  Add  BX,[DeY1]
  Add  DX,[IF1]
  Cmp  BX,0
  JLE  @@DoSomething3
@@DoNothing3:
  Add  DX,320
  Mov  [RV1],BX

  {Adapt: RV2, Ofs2}
  Mov  BX,[RV2]
  Sub  BX,[DeX2]
  Cmp  BX,0
  JG   @@DoNothing4
@@DoSomething4:
  Add  BX,[DeY2]
  Add  SI,[IF2]
  Cmp  BX,0
  JLE  @@DoSomething4
@@DoNothing4:
  Add  SI,320
  Mov  [RV2],BX

  Pop  CX
  Loop @@DrawLoop2
@@Exit:
  STI
End;{NewTri3}

{
To make the source readeable again, get rid of all ; (Done to decrease size).
If you want I can explain to you how it works.
}
