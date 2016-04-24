(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0023.PAS
  Description: Text to COM File
  Author: FRED JOHNSON
  Date: 11-02-93  06:00
*)

{
FRED JOHNSON

> Can anyone shed some light on creating a front-end loader for a Pascal .EXE
> file?

{
 *** Here is a piece of code that expresses the basic concept for which
 *** you are looking.  It takes a text file (.msg) you supply and performs
 *** an extremely simple encription on it and attaches a display method
 *** and a password you supply.  It then makes a .COM file that displays
 *** the file contents once you enter the correct password.
 *** The code is very inefficient, but written that way to show the method
 *** used to write the ASM code to the file. A better way to do this would
 *** be to place your standard ASM code in an array and increment a
 *** pointer to each command as you write it to the disk.  Let me know if
 *** you want to see a rewrite.
}
Uses
  DOS,
  CRT;

VAR
  FName,
  RName    : File Of Byte;
  B, Q     : Byte;
  Password : String[10];
  I_name   : String[12];
  J        : Integer;

PROCEDURE Z;
Begin
  Write(FName, Q);
End;

Begin
  ClrScr;
  Write('Input file name (extension must be .msg) : ');
  Readln(I_name);
  Assign(FName, I_name + '.com');
  Assign(RName, I_name + '.msg');
  ReWrite(FName);
  Reset(RName);
  Write('What is the Password you wish to use? 1 - 9 characters :');
  Readln(Password);
  B := Length(Password);
  J := 1;
{***********************************************************************}
  Q := $b4; Z; Q := $0a; Z;              { MOV    AH,0A   }
  Q := $ba; Z; Q := $4b; Z; Q := $01; Z; { MOV    DX,014B }
  Q := $cd; Z; Q := $21; Z;              { INT    21      }
  Q := $BE; Z; Q := $4D; Z; Q := $01; Z; { MOV    SI,014D }
  Q := $8A; Z; Q := $04; Z;              { MOV    AL,[SI] }
  Q := $3C; Z; Q := $24; Z;              { CMP    AL,24   }
  Q := $74; Z; Q := $07; Z;              { JZ     0117    }
  Q := $04; Z; Q := $08; Z;              { ADD    AL,08   }
  Q := $88; Z; Q := $04; Z;              { MOV    [SI],AL }
  Q := $46; Z;                           { INC    SI      }
  Q := $EB; Z; Q := $F3; Z;              { JMP    010A    }
  Q := $B8; Z; Q := $03; Z; Q := $00; Z; { MOV    AX,0003 }
  Q := $CD; Z; Q := $10; Z;              { INT    10      }
  Q := $B9; Z; Q := B;   Z; Q := $00; Z; { MOV    CX,length of Password }
  Q := $BE; Z; Q := $4d; Z; Q := $01; Z; { MOV    SI,014c }
  Q := $BF; Z; Q := $57; Z; Q := $01; Z; { MOV    DI,0148 }
  Q := $F3; Z;                           { REPZ           }
  Q := $A6; Z;                           { CMPSB          }
  Q := $75; Z; Q := $1b; Z;              { JNZ    014a    }
  Q := $BE; Z; Q := $61; Z; Q := $01; Z; { MOV    SI,0161 }{message start}
  Q := $8A; Z; Q := $04; Z;              { MOV    AL,[SI] }
  Q := $3C; Z; Q := $24; Z;              { CMP    AL,24   }
  Q := $74; Z; Q := $07; Z;              { JZ     013a    }
  Q := $34; Z; Q := $02; Z;              { XOR    AL,02   }
  Q := $88; Z; Q := $04; Z;              { MOV    [SI],AL }
  Q := $46; Z;                           { INC    SI      }
  Q := $EB; Z; Q := $F3; Z;              { JMP    012d    }
  Q := $B4; Z; Q := $09; Z;              { MOV    AH,09   }
  Q := $BA; Z; Q := $61; Z; Q := $01; Z; { MOV    DX,0161 }{message start}
  Q := $CD; Z; Q := $21; Z;              { INT    21      }
  Q := $31; Z; Q := $C0; Z;              { XOR    AX,AX   }
  Q := $CD; Z; Q := $16; Z;              { INT    16      }
  Q := $B8; Z; Q := $03; Z; Q := $00; Z; { MOV    AX,0003 }
  Q := $CD; Z; Q := $10; Z;              { INT    10      }
  Q := $CD; Z; Q := $20; Z;              { INT    20      }
{************************************************************************}
  Q := B + 1;
  Z;
  Q := $24;
  For B := 1 to 11 do
    Z;
  For B := 1 to Length(Password) Do
  Begin
    Q := Ord(Password[B]) + 8;
    Z;
  End;
  While Length(Password) < 10 Do
  Begin
    Password := Password + '$';
    Z;
  End;
  While Not EOF(RName) Do
  Begin
    Read(RName, B);
    If B <> 26 Then
    Begin
      Q := B XOr 2;
      Z;
      Inc(J);
    End;
  End;
  Q := $24;
  Z;
  Close(RName);
  Close(FName);
End.

