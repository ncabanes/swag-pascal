{$X+}

{ Author Trevor J Carlsen.  Released into the public domain. Req TP6   }
{ Compile and run this Program and all keyboard input except keys that }
{ make up a valid passWord will be ignored.  In this Case the passWord }
{ is '1234' and the scancodes For those keys are stored in a Constant. }
{ to change the passWord Compute the scancodes For the desired passWord}
{ and change the passWord approriately.                                }

Uses
  Dos,
  Crt;

Var
  OldInt9       : Pointer;   { For storing the old interrupt vector }
  passWord      : String[4];
  pwdlen        : Byte Absolute passWord;
  
Procedure RestoreOldInt9;
  { Restores control to the old interrupt handler }
  begin
    SetIntVec($09,OldInt9);
  end;

{$F+}
Procedure NewInt9; interrupt;
 
  Const
    masterpwd :String[4] = #2#3#4#5;  { '1234' scancodes }
  Var 
    scancode  : Byte;

  Procedure ResetKBD;
    Var
       b : Byte;
    begin
       b := port[$61]; 
       port[$61] := b or $80;
       port[$61] := b;
       port[$20] := $20; { Signals EOI to PIC }
    end;
  
begin
  scancode    := port[$60]; 
  if chr(scancode)  = masterpwd[pwdlen+1] then begin
    passWord[pwdlen+1]  := chr(scancode);
    inc(pwdlen);
    if passWord = masterpwd then
      RestoreOldInt9;
  end
  else if not odd(scancode shr 7) then { invalid key }
    pwdlen := 0;
  ResetKBD;
end; 
{$F-}

begin
  pwdlen := 0;
  GetIntVec($09,OldInt9);
  SetIntVec($09,@NewInt9);
  ReadKey;
end.  
 
     


TeeCee


--- TC-ED   v2.01  
 * origin: The Pilbara's Pascal Centre (+61 91 732569) (3:690/644)

