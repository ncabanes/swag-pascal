{
 RK> Is there anyone out there who has anything, on how to do PHONG shading in
 RK> Pascal. (If it's possible in Pas..I've seen it done in C, but never in
 RK> Pas)         ^^^.. I didn't have the time to grab the guys source
 RK> code...:(

However I quote this message because I have some plasma stuff!

Here's a little configurable plasma unit! }

UNIT PLASMA;

Interface


Procedure InitPlasma(NbLines : BYTE);
Procedure DoPlasma(xx, yy, xs, ys : WORD);
Procedure ClosePlasma;



VAR
  FT :ARRAY [0..511] OF BYTE;
  SINT :ARRAY [0..255] OF BYTE;
  I1,A,B,D,C,OD,COLOR :BYTE;
  X,Y,K,I :WORD;
  clong   : longint;


Implementation

uses crt;



Procedure ClosePlasma; assembler;
  ASM
    mov dx,3d4h
    mov al,9
    out dx,al
    inc dx
    in al,dx
    and al,0e0h
    add al,2
    out dx,al
  END;




Procedure InitPlasma(nblines : byte);
Begin
  ASM
    mov dx,3d4h
    mov al,9
    out dx,al
    inc dx
    in al,dx
    and al,0e0h
    add al,nblines
    out dx,al
  END;
  {DO TABLES}
  FOR I:=0 TO 511 DO FT [I]:=ROUND (64+63*SIN (I/40.74));
  FOR I:=0 TO 255 DO SINT [I]:=ROUND (256+255*SIN (I/40.74));
End;


Procedure DoPlasma;
BEGIN
  INC (I1);                    {GRID COUNTER}
  DEC (C,2);
  INC (OD,1);
  D:=OD;
  FOR Y:=yy TO yy+ys DO
    BEGIN
       K:=Y*320{+Y AND 1};     {CALCULATE OFFSET AND ADD ONE EVERY SECOND LINE}
       {K:=K-(I1 AND 1)*320;}  {MOVE GRID ONE PIXEL DOWN EVERY SECOND FRAME}
       INC (D,2);
       A:=SINT [(C+Y) AND 255];
       B:=SINT [(D) AND 255];
         FOR X:=xx TO xx+xs DO
           BEGIN
             COLOR:=FT[A+B] + FT[Y+B];
             clong:= color shl 24 + color shl 16 + color shl 8 + color;
             asm
               mov ax, 0a000h
               mov es, ax
               mov di, k
               mov ah, color
               mov al, ah
               stosw
               stosw
              { mov es:[di], ax   }
             end;
             INC (A,1+COLOR SHR 7);
             INC (B,2);
             INC (K,4);
           END;
    END;
END;


Begin
End.
