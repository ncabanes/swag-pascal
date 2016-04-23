UNIT CCursor;

INTERFACE

CONST
   HideCursor: Word = $2607;
   NormCursor: Word = $0506;
   HalfCursor: Word = $0306;
   BlockCursor: Word = $0006;

PROCEDURE ChangeCursor(Curs: Word);

IMPLEMENTATION

PROCEDURE ChangeCursor(Curs: Word); Assembler;

ASM
   MOV Ax,$0100
   MOV Cx,Curs
   INT $10
END;


BEGIN
END.
