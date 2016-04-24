(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0075.PAS
  Description: Random Number Generator
  Author: LEE BARKER
  Date: 11-22-95  15:50
*)


unit TP7Rand;
 interface
{ Changed name from random to randomnbr so can do a compare }
 function RandomNbr(Max: Integer): Integer;

 implementation
 const
  ConstM31 = Longint(-31);  { Scaling constant}
  Factor: Word = $8405;     { Multiplication factor}

function NextRand: Longint; assembler;
 { Compute the next random number
  New := 8088405H * Old + 1
  Out  DX:AX = Next random number
 }
ASM
  MOV  AX,RandSeed.Word[0]
  MOV  BX,RandSeed.Word[2]
  MOV  CX,AX
  MUL  Factor.Word[0]
  SHL  CX,1
  SHL  CX,1
  SHL  CX,1
  ADD  CH,CL
  ADD  DX,CX
  ADD  DX,BX
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

function RandomNbr(Max: Integer): Integer; assembler;
ASM
  CALL  NextRand        { TP6 was }
  MOV   CX,DX           {   xor  ax,ax }
  MUL   Max.Word[0]     {   mov  bx,Max.Word[0] }
  MOV   AX,CX           {   or   bx,bx }
  MOV   CX,DX           {   je   @1    }
  MUL   Max.Word[0]     {   xchg ax,dx }
  ADD   AX,CX           {   div  bx    }
  ADC   DX,0            {   xchg ax,dx }
  MOV   AX,DX           { @1:          }
end;

end.


