(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0024.PAS
  Description: Time and Int28
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  20:39
*)

PROGRAM TestInt28;

{$M 2048,0,1024}

USES
  DOS, CRT;

CONST
  StatBarColor : WORD = $74;

VAR
  DosIdleVec : PROCEDURE;

function Time(Hour_12 : Boolean) : String;
{ This function will return a string that contains the time in }
{ a format as follows:  HH:MM:SS am/pm or HH:MM:SS }
const
  am   = 'am';
  pm   = 'pm';
  zero = '0';
var
  Hour,
  Minute,
  Second,
  Sec100 : Word;
  Hr,
  Min,
  Sec    : String[2]; { Used in time combining }
begin
  GetTime(Hour, Minute, Second, Sec100); { Get the system time }
  if Hour <= 12 then
  begin
    Str(Hour, HR);     { Convert Hour to string }
    If Hour = 0 then   { Fix for MIDNIGHT }
      if Hour_12 then
        HR := '12'
      else
        HR := ' 0';
  end
  else
  If Hour_12 then
    Str(Hour - 12, HR)     { Convert Hour to string }
  else
    Str(Hour, HR);
  if Length(Hr) = 1 then   { Fix hour for right time }
    Insert(' ', HR, 1);
  Str(Minute, Min);        { Convert Minute to string }
  if Length(Min) = 1 then
     Min := zero + Min;    { Make Min two char }
  Str(Second, Sec);        { Convert Second to string }
  if Length(Sec) = 1 then
     Sec := zero + Sec;    { Make sec two chars }
  If Hour_12 then          { We want 12 hour time }
    If Hour >= 12 then
      Time := Hr + ':' + Min + ':' + Sec + ' ' + pm
    else
      Time := Hr + ':' + Min + ':' + Sec + ' ' + am
  else                                     { We want 24 hour time }
    Time := Hr + ':' + Min + ':' + Sec;
end;

PROCEDURE UpdateTime;
VAR
  TheTime  : STRING;
  Row, Col : BYTE;
  OldAttr  : WORD;
BEGIN
  ASM
    mov  ah, 0Fh   { get the active display page.     }
    int  10h
    mov  ah, 03h   { get the cursor position.         }
    int  10h       { DH = ROW, DL = COL               }
    mov  Row, dh
    mov  Col, dl
  END;
  GotoXY(69, 1);
  TheTime  := Time(True);   { GET the time, write the time..   }
  OldAttr  := TextAttr;     { SAVE text color.                 }
  TextAttr := StatBarColor;
  Write(TheTime);
  TextAttr := OldAttr;      { Restore TEXT color....           }
  GotoXY(Col + 1, Row + 1); { add one because BIOS starts at 0 }
END;

{$F+}
PROCEDURE DOSIDLE; INTERRUPT;
BEGIN
  UpDateTime;
  INLINE($9C);  { push the flags.           }
  DosIdleVec;   { call the old INT routine. }
END;
{$F-}

BEGIN
  CheckBreak := False;           { MAKE SURE USER CANNOT PRESS      }
                                 { CTRL+BREAK TO EXIT.  THE         }
                                 { INTERRUPT WOULD NOT BE RESTORED. }
  GetIntVec($1C, @DOSIdleVec);   { Save old interrupt vector        }
  SetIntVec($1C, Addr(DOSIDLE));

  ClrScr;
  TextAttr := StatBarColor;
  ClrEol;
  Write('TEST PROGRAM FOR hooking timer interrupt, written by Mark Klaamas ▓');
  GotoXY(1, 15);
  TextAttr := $07;
  Write('INPUT HERE PLEASE!!!  ');
  ReadLN;

  SetIntVec($1C, Addr(DOSIdleVec));     { restore old interrupt vector.    }
END.

