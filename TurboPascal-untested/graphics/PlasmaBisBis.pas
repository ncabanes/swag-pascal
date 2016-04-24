(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0100.PAS
  Description: PLASMA
  Author: KAARE BOEEGH
  Date: 05-26-94  06:20
*)

{
15 minutes ago I suddenly got a idea to a fullscreen plasma (320*200). But
I have promised my group mates to do no more plasmas so here it is and it
is all yours. It is not 320*200, because I did not do it in assembler since I
am not going to use the routine myself, but it should be pretty easy to
convert.

 -+--+--+--- CUT -+--+--+--- }

 PROGRAM _320_100_PLASMA;

 VAR
  FT :ARRAY [0..511] OF BYTE;
  SINT :ARRAY [0..255] OF BYTE;
  I1,A,B,D,C,OD,COLOR :BYTE;
  X,Y,K,I :WORD;

 BEGIN
 {SET 320*200*256}
  ASM
    MOV AX,0013H; INT 10H;
   {THIS THINGGY DOUBLES THE HEIGT OF THE PIXELS}
    mov dx,3d4h
    mov al,9
    out dx,al
    inc dx
    in al,dx
    and al,0e0h
    add al,3
    out dx,al
  END;

  {DO PALETTE}
  PORT [$3C8]:=0;
  FOR I:=0 TO 255 DO
    BEGIN
      PORT [$3C9]:=I DIV 4;
      PORT [$3C9]:=I DIV 5;
      PORT [$3C9]:=I DIV 6
    END;

  {DO TABLES}
  FOR I:=0 TO 511 DO FT [I]:=ROUND (64+63*SIN (I/40.74));
  FOR I:=0 TO 255 DO SINT [I]:=ROUND (128+127*SIN (I/40.74));

  {MAIN LOOP}
  REPEAT
  INC (I1);                    {GRID COUNTER}
  DEC (C,2);
  INC (OD,1);
  D:=OD;
  FOR Y:=0 TO 100 DO
    BEGIN
       K:=Y*320+Y AND 1;     {CALCULATE OFFSET AND ADD ONE EVERY SECOND LINE}
K:=K-(I1 AND 1)*320;  {MOVE GRID ONE PIXEL DOWN EVERY SECOND FRAME}
       INC (D,2);
       A:=SINT [(C+Y) AND 255];
       B:=SINT [(D) AND 255];
         FOR X:=0 TO 159 DO
           BEGIN
             COLOR:=FT [A+B]+FT [Y+B];
             MEM [$A000:K]:=COLOR;
             INC (A,1+COLOR SHR 7);
             INC (B,2); INC (K,2);
             {OFFSET OF PLASMA PIXEL, INCREASED BY TWO TO CREATE THE GRID}
           END;
    END;
 UNTIL PORT [$60]<128; {EXIT IF KEY PRESSED} END.


