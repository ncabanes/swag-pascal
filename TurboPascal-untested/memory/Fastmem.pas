(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0005.PAS
  Description: FASTMEM.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:50
*)

Unit MEM16;
{
 Author:        Paul VanderSpek
 Date:          03-20-1993

    This source code is being released as Free-Ware.  You may use
  this code in your Programs and modify it to fit your needs. The
  only  restrictions are that you  may not distribute the  source
  code in modified Form or Charge For the source code itself.


}

Interface

Procedure Move16(Var Source,Dest;Count:Word);
Procedure FillChar16(Var X; Count: Word; Value:Byte);

Implementation

Procedure Move16(Var Source,Dest;Count:Word); Assembler;
Asm
  PUSH DS
  LDS SI,SOURCE
  LES DI,DEST
  MOV AX,COUNT
  MOV CX,AX
  SHR CX,1
  REP MOVSW
  TEST AX,1
  JZ @end
  MOVSB
@end:POP DS
end;

Procedure FillChar16(Var X; Count: Word; Value:Byte); Assembler;
Asm
  LES DI,X
  MOV CX,COUNT
  SHR CX,1
  MOV AL,ValUE
  MOV AH,AL
  REP StoSW
  TEST COUNT,1
  JZ @end
  StoSB
@end:
end;

end.

{
These routines are twice as fast as the normal Move and FillChar routines
sInce they use MOVSW and StoSW instead of MOVSB and StoSB. They work in
exactly the same way, so you can just replace Move and FillChar With them.
}

{
>     This source code is being released as Free-Ware.  You may use
>   this code in your Programs and modify it to fit your needs. The
>   only  restrictions are that you  may not distribute the  source
>   code in modified form or Charge For the source code itself.

I'm sorry to say that I'm not impressed, since hundreds of people already have
invented this wheel.  Besides, your move routine has at least one serious flaw:
it assumes that source and destinaton do not overlap.  Which is not always the
case; if you have a Variable of the Type String as the source, and you want to
copy a few Characters furtheron in this Variable, you'll mess up the result.

>      SHR CX,1
>      REP MOVSW
>      TEST AX,1
>      JZ @end
>      MOVSB
> @end:POP DS

The TEST AX, 1 instruction is superfluous.  If the number of Bytes in the CX
register is odd, the SHR CX, 1 instruction will set the carry bit.  It's more
convenient to test this bit.  Here's how:

         SHR   CX, 1
         JNC   @1
         MOVSB
         REP   MOVSW
    @1:

> Have Fun,

No fun if source and destination overlap, as said earlier.  Here follows a
memory move routine With 16-bit moves and overlap check:
}
Procedure MoveMem(Var source, target; size : Word); Assembler;

Asm
        PUSH    DS
        LDS     SI, source
        LES     DI, target
        MOV     CX, size
        CLD

    { If an overlap of source and target could occur,
      copy data backwards }

        CMP     SI, DI
        JAE     @2

        ADD     SI, CX
        ADD     DI, CX
        DEC     SI
        DEC     DI
        STD

        SHR     CX, 1
        JAE     @1
        MOVSB
@1:     DEC     SI
        DEC     DI
        JMP     @3

@2:     SHR     CX, 1
        JNC     @3
        MOVSB

@3:     REP     MOVSW
        POP     DS
end;  { MoveMem }


{
> For I := 0 to 200 do
>  Move(Buffer,Mem[$A000:0000],320);

Looks weird to me. Why moving all that stuff 200 times to the first line
of the screen ?

> For I := 100 to 200 do
>  Move(Buffer[320*I],Mem[$A000:(I*320)],320);

This could be done via

Move(Buffer[320*StartLine], Mem[$a000:320*StartLine], 320*NumberOfLines) ;

which should somehow be faster.

Also note that TP's Move Procedure Uses a LODSB instruction, which is
twice as slow as a LODSW instruction on 286+ computers, With big buffers.
So here is a replacement Move proc, which works fine EXCEPT if the two
buffers overlap and destination is at a greater address than source, which
anyway is not the Case here.
}
Procedure FastMove(Var Src, Dst ; Cnt : Word) ;
Assembler ;
Asm
     Mov       DX, DS         { Sauvegarde DS }
     Mov       CX, Cnt
     LDS       SI, Src
     LES       DI, Dst
     ClD                      { A priori, on va du dbut vers la fin }
     ShR       CX, 1          { On va travailler sur des mots }
     Rep       MovSW          { Copie des mots }
     JNC       @Done          { Pas d'octet restant (Cnt pair) ? }
     MovSB                    { Copie dernier octet }
@Done:
     Mov       DS, DX         { Restauration DS }
end ;
{
Well, just a note : this proc works twice faster than TP's Move _only_ if
Src and Dst are Word aligned, which is the Case if :
- they are Variables allocated on the heap,
- they are declared in the stack,
- $a+ is specified,
- you use it as described in your examples of code :-)
}
