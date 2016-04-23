==============================================================================
 BBS: The Sand Box BBS - SourceNet Central HUB
  To: JUD MCCRANIE                 Date: 12-17─92 (16:42)
From: TREVOR CARLSEN             Number: 531    [87] FD-Pascal
Subj: BP 7 DIFFERENCE            Status: Public
------------------------------------------------------------------------------
 JM> The behavior of RANDOM (with RandSeed set) is different in
 JM> BP7 (and presumably TP7) from that in TP 5.5.  (I don't know
 JM> how TP 6 compares since I burned it off my disk).

 JM> RandSeed := 123;
 JM> for i := 1 to 8 do writeln( random( 1000));

 JM> TP 5.5: 343 282 986 996 781 855 343  32
 JM> BP 7.0: 859  80 869 854 317 257  20  46

 JM> ...both are consistant, but they are different sequences.
 JM> This can have some dire consequences.  ...

It certainly could if you did not know about it and unfortunately I can
find no reference to the changes in the documentation. (Richard Nelson?)

Here is a fix (supplied to me via Netmail courtesy Joe Lamoine - thanks Joe).

>Quote........

I posted a message on Compuserve last nite and got the following
unit in a response.  It seems to work fine!


{ *  Turbo Pascal Runtime Library Version 6.0     * ;
  *  Random Number Generator                      * ;
  *                                               * ;
  *  Copyright (C) 1988,92 Borland International  * }

 unit TP6Rand;

 interface

 function Random(Max: Integer): Integer;

 implementation

 const
  { Scaling constant}
  ConstM31 = Longint(-31);
  { Multiplication factor}
  Factor: Word = $8405;


 function NextRand: Longint; assembler;
 { Compute next random number
  New := 8088405H * Old + 1
  Out  DX:AX = Next random number
 }
 asm
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

function Random(Max: Integer): Integer; assembler;
 asm
  CALL  NextRand
  XOR   AX,AX
  MOV   BX,Max.Word[0]
  OR    BX,BX
  JE    @@1
  XCHG  AX,DX
  DIV   BX
  XCHG  AX,DX
 @@1:
 end;

end.

>End of quote.


TeeCee


--- TC-ED   v2.01
 * Origin: The Pilbara's Pascal Centre (+61 91 732930) (3:690/644)
