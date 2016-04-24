(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0103.PAS
  Description: ROM Font in $13
  Author: GREG ESTABROOKS
  Date: 05-25-94  08:22
*)

{
 The following does not use assembly but it should do what you want,
 and should give you an idea about how its done incase you want to
 translate it to BASM later. It uses the ROM text font information
 for its screen writes.

{***********************************************************************}
PROGRAM RomFontDemo;            { May 08/94, Greg Estabrooks.           }
VAR
   Colors :BYTE;

PROCEDURE SetVidMode( Mode :BYTE ); ASSEMBLER;
                {  Routine to set video mode                            }
ASM
  Mov AH,00                     {  Function to set mode                 }
  Mov AL,Mode                   {  Mode to change to                    }
  Int $10                       {  Call dos                             }
END;{SetVidMode}

PROCEDURE PutPixel( X,Y :WORD; Color :BYTE );
BEGIN
  Mem[$A000:(320*Y)+X]:= Color;
END;

PROCEDURE WriteXY( X,Y :WORD; Color :BYTE; Str :STRING );
VAR
   OldX :WORD;                  { Holds Original Column.                }
   OldY :WORD;
   StrPos :BYTE;                { Character pos in string to write.     }
   FontChr:BYTE;                { ROM font info.                        }
   FontPos:BYTE;
   BitPos :BYTE;
BEGIN
  OldY := Y;                    { Save Starting Row.                    }
  FOR StrPos := 1 TO Length(Str) DO
  BEGIN                         { Loop through every character.         }
   OldX := X;                   { Save Current Column.                  }
   Y := OldY;                   { Restore starting row.                 }
   FOR FontPos := 0 TO 7 DO
   BEGIN                        { Scroll through all 8 BYTES of font.   }
    FontChr := MEM[$FFA6:$E+(ORD(Str[StrPos]) SHL 3) + FontPos];
    FOR BitPos := 7 DOWNTO 0 DO
    BEGIN                       { Scroll through all 8 BITS of each BYTE.}
     IF (FontChr AND (1 SHL BitPos)) <> 0 THEN
      PutPixel(X,Y,Color);      { IF bit is set then draw pixel.        }
     INC(X);                    { point to next column.                 }
    END;
    INC(Y);                     { point to next row.                    }
    X := OldX;                  { Restore old column for next line.     }
   END;
   X := X + 8;                  { Move 9 columns ahead.                 }
  END;
END;{WriteXY}

BEGIN
  SetVidMode($13);
  FOR Colors := 1 TO 19 DO
   WriteXY(Colors*10,Colors*10,Colors,'Greg Estabrooks');
  Readln;
  SetVidMode($03);
END.
{***********************************************************************}

