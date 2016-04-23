{
John Wong

>Does anyone out there have any fade-in routines??? Also can anyone
>recomend some good books on VGA Programming and Animation???

This might be a fade out routine, but you could modify it to fade in.
}
{$G+}
Program fades;

Uses
  Crt, Dos;
                  { TPC /$G+ To Compile }
Var
  All_RGB : Array[1..256 * 3] Of Byte;
  x,color : Integer;


Procedure FadeOut2; { This is Hard Cores Fade Out }
begin
  {for using Textmode use color 7, or For Graphics}
  x := 1;
  Color := 7;
  Repeat;
    port[$3c8] := color;
    port[$3c9] := 60 - x;
    port[$3c9] := 60 - x;
    port[$3c9] := 60 - x;
    inc(x);
    Delay(75);
  Until x = 60;

         { Get The Screen Back ( Change This ) }
  Color := 7;
  port[$3c8] := color;
  port[$3c9] := 60 + x;
  port[$3c9] := 60 + x;
  port[$3c9] := 60 + x;
  inc(x);
  Delay(25);
end;

Procedure FadeOut;
Label
  OneCycle,
  ReadLoop,
  DecLoop,
  Continue,
  Retr,
  Wait,
  Retr2,
  Wait2;
begin { FadeOut }
  Asm
    MOV   CX,64
  OneCycle:

    MOV     DX,3DAh
  Wait:   in      AL,DX
    TEST    AL,08h
    JZ      Wait
  Retr:   in      AL,DX
    TEST    AL,08h
    JNZ     Retr

    MOV   DX,03C7h
    xor   AL,AL
    OUT   DX,AL
    INC   DX
    INC   DX
    xor   BX,BX
  ReadLoop:
    in    AL,DX
    MOV   Byte Ptr All_RGB[BX],AL
    INC   BX
    CMP   BX,256*3
    JL    ReadLoop

    xor   BX,BX
  DecLoop:
    CMP   Byte Ptr All_RGB[BX],0
    JE    Continue
    DEC   Byte Ptr All_RGB[BX]

  Continue:
    INC   BX
    CMP   BX,256*3
    JL    DecLoop

    MOV     DX,3DAh
  Wait2:   in      AL,DX
    TEST    AL,08h
    JZ      Wait2
  Retr2:   in      AL,DX
    TEST    AL,08h
    JNZ     Retr2

    MOV   DX,03C8h
    MOV   AL,0
    OUT   DX,AL
    INC   DX
    MOV   SI,OFFSET All_RGB
    CLD
    PUSH  CX
    MOV   CX,256*3
    REP   OUTSB
    POP   CX

    LOOP  OneCycle

  end;
end; { FadeOut }


begin
  fadeout;
  NormVideo;
  Fadeout2;
end.
