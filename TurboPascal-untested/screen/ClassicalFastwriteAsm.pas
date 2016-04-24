(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0023.PAS
  Description: Classical FASTWRITE ASM
  Author: GAYLE DAVIS
  Date: 07-16-93  06:08
*)


UNIT FastWrit;

INTERFACE

procedure  FastWrite(Strng : String; Row, Col, Attr : Byte);

IMPLEMENTATION

VAR
    BaseOfScreen : WORD;

procedure  FastWrite(Strng : String; Row, Col, Attr : Byte); assembler;
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
END.
