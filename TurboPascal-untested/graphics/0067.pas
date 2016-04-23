PROGRAM Mode13Demo;             { Oct 10/93, Greg Estabrooks.       }
VAR
   CurCol,
   OldMode:BYTE;
   CurPos,
   X,Y :WORD;
   ScrBuff :ARRAY[1..64000] OF BYTE;

PROCEDURE SetVidMode( Mode :BYTE ); ASSEMBLER;
                {  Routine to set video mode                        }
ASM
  Mov AH,00                     {  Function to set mode             }
  Mov AL,Mode                   {  Mode to change to                }
  Int $10                       {  Call dos                         }
END;{SetVidMode}

PROCEDURE PutPixel( X,Y :WORD; Color :BYTE );
BEGIN
  Mem[$A000:(320*Y)+X]:= Color;
END;

BEGIN
  SetVidMode($13);              { Set Mode to 320x200x256.          }
  FOR Y := 0 To 199 DO          { Loop through all lines.           }
    FOR X := 0 To 319 DO        { Loop through all columns.         }
        PutPixel(X,Y,Random(255));
  CurCol := 0;
  CurPos := 0;
  FOR Y := 0 To 199 DO          { Loop through all lines.           }
   BEGIN
    Inc(CurCol);
    FOR X := 0 To 319 DO        { Loop through all columns.         }
     BEGIN
       Inc(CurPos);
       ScrBuff[CurPos] := CurCol;
     END;
   END;
  Writeln('Press Enter to see the Faster way!');
  Readln;
  Move(ScrBuff,Mem[$A000:0],SizeOf(ScrBuff));
  Readln;
  SetVidMode(3);                { Set Mode 3,80x25.                 }
END.
