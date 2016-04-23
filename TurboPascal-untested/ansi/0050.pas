{$S+,R-,V-,I-,N-,B-,F-}
{$M 16384,0,655360}

USES Dos, Crt;

VAR
    AscStr : STRING;

    Row,Col,
    x      : BYTE;

    BaseOfScreen : WORD;

procedure  FastWrite(Strng : String; Row, Col, Attr : Byte); assembler;
  { display strings directly on the CRT VERY FAST with color !! }
  asm
      PUSH    DS                     { ;Save DS }
      MOV     CH,Row                 { ;CH = Row }
      MOV     BL,Col                 { ;BL = Column }

      XOR     AX,AX                  { ;AX = 0 }
      MOV     CL,AL                  { ;CL = 0 }
      MOV     BH,AL                  { ;BH = 0 }
      DEC     CH                     { ;Row (in CH) to 0..24 range }
      SHR     CX,1                   { ;CX = Row * 128 }
      MOV     DI,CX                  { ;Store in DI }
      SHR     DI,1                   { ;DI = Row * 64 }
      SHR     DI,1                   { ;DI = Row * 32 }
      ADD     DI,CX                  { ;DI = (Row * 160) }
      DEC     BX                     { ;Col (in BX) to 0..79 range }
      SHL     BX,1                   { ;Account for attribute bytes }
      ADD     DI,BX                  { ;DI = (Row * 160) + (Col * 2) }
      MOV     ES,BaseOfScreen        { ;ES:DI points to BaseOfScreen:Row,Col }

      LDS     SI,DWORD PTR [Strng]   { ;DS:SI points to St[0] }
      CLD                            { ;Set direction to forward }
      LODSB                          { ;AX = Length(St); DS:SI -> St[1] }
      XCHG    AX,CX                  { ;CX = Length; AL = WaitForRetrace }
      JCXZ    @FWExit                { ;If string empty, exit }
      MOV     AH,Attr                { ;AH = Attribute }
    @FWDisplay:
      LODSB                          { ;Load next character into AL }
                                     { ; AH already has Attr }
      STOSW                          { ;Move video word into place }
      LOOP    @FWDisplay             { ;Get next character }
    @FWExit:
      POP     DS                     { ;Restore DS }
  end; {asm block}


PROCEDURE dumphex(a:integer);
CONST
  HEX = '0123456789ABCDEF';

VAR
  inter,u : BYTE;

BEGIN
   AscStr := '';
   FOR u := 1 TO 4 DO
   BEGIN
   inter := a SHR 12;
   a     := a SHL 4;
   AscStr := AscStr + (Copy(hex,inter+1,1));
   END;
END;

Procedure GetAscii;
Var
    A,B,C   : String[15];
    i       : integer;

Begin
   Row := 1;
   For I := 0 to 255 Do
       Begin
       DumpHex(i);
       A := Copy(AscStr,3,2);
       Str(I,B);

       If Length(B)=2 then B:=' '+B;
       If Length(B)=1 then B:='  '+B;

       c:=chr(i);

         IF (i > 0) AND (i mod 23 = 0) THEN
            BEGIN
            Readkey;
            Row := 1;
            END ELSE
                BEGIN
                FastWrite(A+'   '+B+'   '+C, Row, 5 , 15);
                inc(Row);
                END;

       End;
End;

PROCEDURE GetScreenType;
 { set screen address for color or monochrome .. }
BEGIN
ASM
    mov      BaseOfScreen,$B000
    mov      ax,$0F00
    int      $10
    cmp      al,2
    je       @XXX
    cmp      al,7
    je       @XXX
    mov      BaseOfScreen,$B800
@XXX :
end;
END;

BEGIN
     ClrScr;
     GetScreenType;
     GetAscii;
     Readkey;
END.