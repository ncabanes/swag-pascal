(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0103.PAS
  Description: How to read an enhanced keyboard
  Author: SWAG SUPPORT TEAM
  Date: 11-22-95  13:26
*)


{
The code included in this example shows how to read
an enhanced keyboard using Turbo Pascal. That is, it detects
if the F11, F12, etc keys are pressed. It provides a substitute
for the ReadKey and KeyPressed functions.
     This TI includes two source files, the first a unit
called ENHKEY.PAS and the second a test program called TEST.PAS.
ENHKEY.PAS contains three routines:

   KeyEPressed: Works just like the CRT routine called
KeyPressed,
          except it detects keypresses on enhanced keys.


   NewReadKey:  Works very much like ReadKey, except it detects
          enhanced keys.

   ReadEKey:    This is the raw readkey function. It returns a
word.
          The high order word contains the scan code and the
          low word contains the regular key. Some users might
          not want to call this function directle, but instead
          might want to access it through the NewReadKey
function,
          which acts much more like the original ReadKey function

          from the CRT unit.

     The code in the EnhKey unit depends on interrupt 16h,
functions
10 and 11, both of which assume the presence of AT or better
computer.
In this day and age, that's a fairly safe bet, but you should be
aware
that this code will not run on an old XT.
     Notice that if NewReadKey returns zero the first time it is
called, you can grab the scan code in the global variable
ScanCode,
or you can call NewReadKey a second time to return the ScanCode.

}

unit EnhKey;

interface
var
  ScanCode: Byte;

function KeyEPressed: Boolean;
function ReadEKey: Word;
function NewReadKey: Char;

implementation

function KeyEPressed: Boolean; assembler;
asm
  mov ah, $11
  int 16h
  mov ax, 1
  jnz @@True
  xor ax, ax
@@True:
end;

function ReadEKey: Word; assembler;
asm
  mov ah, 10h
  int 16h
end;

function NewReadKey: Char;
var
  Ch: Word;
begin
  if ScanCode <> 0 then begin
    NewReadKey := Char(ScanCode);

    ScanCode := 0;
    exit;
  end;
  Ch := ReadEKey;
  if Lo(Ch) = 0 then begin
    ScanCode := Hi(Ch);
    NewReadKey := #0;
    exit;
  end;
  NewReadKey := Char(Lo(Ch));
end;
begin
  ScanCode := 0;
end.
begin
  ScanCode := 0;
end.

{ ================= The Test Program ================ }

program Test;
uses
  EnhKey;

var
  Ch: Char;
  i: Integer;
begin
  i := 0;
  while (Ch <> #27) do begin
    if KeyEpressed then begin
      Ch := NewReadKey;

      if Ch = #0 then begin
     Ch := NewReadKey;
     WriteLn('Enhanced: ', Ch)
      end else
     WriteLn('Normal: ', Ch);
      inc(i);
    end;
  end;
end.

 


